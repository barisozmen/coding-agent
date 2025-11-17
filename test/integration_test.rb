# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

# End-to-end behavioral tests for the Coding Agent
# These tests focus on real-world workflows, not unit testing
class IntegrationTest < Minitest::Test
  def setup
    super
    @test_dir = Dir.mktmpdir("coding_agent_test")
    @original_dir = Dir.pwd
    Dir.chdir(@test_dir)

    # Configure for testing
    CodingAgent::Configuration.apply(
      workspace_path: @test_dir,
      save_conversation_history: false,
      auto_execute_safe_commands: true
    )
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  # Scenario: User wants to understand their project structure
  def test_exploring_project_structure
    # Given: A project with some files
    create_test_file("README.md", "# Test Project")
    create_test_file("src/main.rb", "puts 'Hello'")
    create_test_file("test/main_test.rb", "# Test file")

    # When: Listing files
    tool = CodingAgent::Tools::ListFiles.new(ui: @ui)
    result = tool.execute

    # Then: Should see all files
    assert result[:entries].include?("README.md")
    assert result[:entries].include?("src/")
    assert result[:entries].include?("test/")
    assert_equal 3, result[:count]
  end

  # Scenario: User wants to read a specific file
  def test_reading_file_content
    # Given: A file with content
    content = "def hello\n  puts 'Hello, World!'\nend"
    create_test_file("hello.rb", content)

    # When: Reading the file
    tool = CodingAgent::Tools::ReadFile.new(ui: @ui)
    result = tool.execute(path: "hello.rb")

    # Then: Should get the content back
    assert_equal content, result[:content]
    assert_equal 3, result[:lines]
    assert result[:size] > 0
  end

  # Scenario: User wants to create a new file
  def test_creating_new_file
    # Given: No file exists
    refute File.exist?("new_feature.rb")

    # When: Creating a file using edit_file with empty old_str
    tool = CodingAgent::Tools::EditFile.new(ui: @ui)
    new_content = "class Feature\n  def run\n    'working'\n  end\nend"
    result = tool.execute(
      path: "new_feature.rb",
      old_str: "",
      new_str: new_content
    )

    # Then: File should be created
    assert File.exist?("new_feature.rb")
    assert_equal "created", result[:action]
    assert_equal new_content, File.read("new_feature.rb")
    assert_equal 5, result[:lines]
  end

  # Scenario: User wants to modify existing file
  def test_modifying_existing_file
    # Given: An existing file
    original = "def old_method\n  'old'\nend"
    create_test_file("code.rb", original)

    # When: Editing the file
    tool = CodingAgent::Tools::EditFile.new(ui: @ui)
    result = tool.execute(
      path: "code.rb",
      old_str: "'old'",
      new_str: "'new'"
    )

    # Then: File should be modified
    assert_equal "edited", result[:action]
    assert_includes File.read("code.rb"), "'new'"
    refute_includes File.read("code.rb"), "'old'"
  end

  # Scenario: User searches for code patterns
  def test_searching_for_patterns
    # Given: Multiple files with code
    create_test_file("app.rb", "def process\n  # TODO: implement\nend")
    create_test_file("lib.rb", "# TODO: refactor\nclass Lib\nend")
    create_test_file("other.rb", "puts 'hello'")

    # When: Searching for TODO comments
    tool = CodingAgent::Tools::SearchFiles.new(ui: @ui)
    result = tool.execute(pattern: "TODO")

    # Then: Should find matches
    assert result[:count] > 0
    assert result[:matches].any? { |m| m[:file].include?("app.rb") }
    assert result[:matches].any? { |m| m[:file].include?("lib.rb") }
  end

  # Scenario: User wants to check git status
  def test_git_operations
    # Given: A git repository
    `git init`
    create_test_file("new.rb", "puts 'test'")

    # When: Checking git status
    tool = CodingAgent::Tools::GitOperations.new(ui: @ui)
    result = tool.execute(operation: "status")

    # Then: Should get status
    assert result[:success]
    assert_includes result[:output], "new.rb"
  end

  # Scenario: User runs a safe command
  def test_running_safe_commands
    # Given: A file exists
    create_test_file("test.txt", "content")

    # When: Running ls command
    tool = CodingAgent::Tools::RunShellCommand.new(ui: @ui)

    # Mock the confirmation to auto-accept
    CodingAgent::Configuration.apply(auto_execute_safe_commands: true)

    result = tool.execute(command: "ls")

    # Then: Should execute successfully
    assert result[:success]
    assert_includes result[:stdout], "test.txt"
  end

  # Scenario: Complete workflow - Create, Edit, Verify
  def test_complete_development_workflow
    # Given: Starting a new feature

    # Step 1: Create new file
    edit_tool = CodingAgent::Tools::EditFile.new(ui: @ui)
    edit_tool.execute(
      path: "calculator.rb",
      old_str: "",
      new_str: "class Calculator\n  def add(a, b)\n    a + b\n  end\nend"
    )

    # Step 2: Read it back to verify
    read_tool = CodingAgent::Tools::ReadFile.new(ui: @ui)
    content = read_tool.execute(path: "calculator.rb")
    assert_includes content[:content], "Calculator"
    assert_includes content[:content], "def add"

    # Step 3: Edit to add more functionality
    edit_tool.execute(
      path: "calculator.rb",
      old_str: "  def add(a, b)\n    a + b\n  end",
      new_str: "  def add(a, b)\n    a + b\n  end\n\n  def subtract(a, b)\n    a - b\n  end"
    )

    # Step 4: Verify the change
    updated = read_tool.execute(path: "calculator.rb")
    assert_includes updated[:content], "def subtract"

    # Step 5: Search for all methods
    search_tool = CodingAgent::Tools::SearchFiles.new(ui: @ui)
    methods = search_tool.execute(pattern: "def ", file_pattern: "*.rb")
    assert methods[:count] >= 2
  end

  # Scenario: Error handling - file not found
  def test_reading_nonexistent_file
    # When: Trying to read a file that doesn't exist
    tool = CodingAgent::Tools::ReadFile.new(ui: @ui)
    result = tool.execute(path: "missing.rb")

    # Then: Should get helpful error with hint
    assert result[:error]
    assert_includes result[:error], "not found"
    assert result[:hint]
    assert_includes result[:hint], "list_files"
  end

  # Scenario: Error handling - string not unique in file
  def test_editing_with_non_unique_string
    # Given: File with duplicate strings
    create_test_file("dup.rb", "puts 'hello'\nputs 'world'\nputs 'hello'")

    # When: Trying to replace non-unique string
    tool = CodingAgent::Tools::EditFile.new(ui: @ui)
    result = tool.execute(
      path: "dup.rb",
      old_str: "puts 'hello'",
      new_str: "puts 'hi'"
    )

    # Then: Should get helpful error
    assert result[:error]
    assert_includes result[:error], "must be unique"
    assert result[:hint]
    assert_includes result[:hint], "more surrounding context"
  end

  # Scenario: Creating file with directory structure
  def test_creating_file_with_nested_directories
    # When: Creating a file in nested dirs that don't exist
    tool = CodingAgent::Tools::EditFile.new(ui: @ui)
    result = tool.execute(
      path: "lib/models/user.rb",
      old_str: "",
      new_str: "class User\nend"
    )

    # Then: Directories and file should be created
    assert File.exist?("lib/models/user.rb")
    assert_equal "created", result[:action]
  end

  private

  def create_test_file(path, content)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless dir == "."
    File.write(path, content)
  end
end
