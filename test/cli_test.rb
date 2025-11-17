# frozen_string_literal: true

require "test_helper"
require "open3"

# End-to-end CLI behavioral tests
# These test the actual command-line interface
class CliTest < Minitest::Test
  def setup
    # Use absolute path to bin/coding_agent
    project_root = File.expand_path("..", __dir__)
    @bin_path = File.join(project_root, "bin", "coding_agent")

    skip "bin/coding_agent not found" unless File.exist?(@bin_path)
  end

  # Scenario: User checks version
  def test_version_command
    # When: Running version command
    stdout, _stderr, status = Open3.capture3(@bin_path, "version")

    # Then: Should show version information
    assert status.success?
    assert_includes stdout, "Coding Agent"
    assert_includes stdout, "Ruby"
    assert_includes stdout, "OpenAI"
  end

  # Scenario: User views configuration
  def test_config_command
    # When: Running config command
    stdout, _stderr, status = Open3.capture3(@bin_path, "config")

    # Then: Should display configuration
    assert status.success?
    assert_includes stdout, "Configuration"
    assert_includes stdout, "Model"
    assert_includes stdout, "Workspace"
  end

  # Scenario: User runs help
  def test_help_command
    # When: Running help
    stdout, _stderr, status = Open3.capture3(@bin_path, "help")

    # Then: Should show available commands
    assert status.success?
    assert_includes stdout, "Commands:"
    assert_includes stdout, "chat"
    assert_includes stdout, "ask"
    assert_includes stdout, "version"
    assert_includes stdout, "config"
  end

  # Scenario: Invalid command
  def test_invalid_command
    # When: Running invalid command
    stdout, stderr, _status = Open3.capture3(@bin_path, "invalid_command")

    # Then: Should show error message in stderr
    combined_output = stdout + stderr
    assert_includes combined_output, "Could not find"
  end
end
