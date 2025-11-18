# frozen_string_literal: true

require "ruby_llm"
require "active_support/core_ext/object/blank"
require "yaml"
require_relative "ui"
require_relative "configuration"
require_relative "concerns/conversational"
require_relative "tools/read_file"
require_relative "tools/list_files"
require_relative "tools/edit_file"
require_relative "tools/run_shell_command"
require_relative "tools/search_files"
require_relative "tools/git_operations"

module CodingAgent
  # The heart of the coding agent
  # Optimized for programmer happiness with beautiful abstractions
  class Agent
    include Concerns::Conversational

    attr_reader :chat, :ui, :tools, :token_usage

    def initialize(ui: UI.new)
      @ui = ui
      @tools = build_tools
      @chat = configure_chat
      @token_usage = { input: 0, output: 0, total: 0 }
      initialize_conversation
      setup_system_prompt
    end

    # Main interaction loop - where the magic happens
    def run
      display_welcome
      validate_configuration!

      loop do
        user_input = get_user_input
        break if should_exit?(user_input)

        handle_special_commands(user_input) || process_request(user_input)
      end

      display_farewell
    end

    # Single-shot mode for non-interactive use
    def ask(question)
      process_request(question, interactive: false)
    end

    private

    def build_tools
      [
        Tools::ReadFile,
        Tools::ListFiles,
        Tools::EditFile,
        Tools::RunShellCommand,
        Tools::SearchFiles,
        Tools::GitOperations,
      ].map { |tool_class| tool_class.new(ui: ui) }
    end

    def configure_chat
      chat = RubyLLM.chat
      chat.with_tools(*tools)
      chat
    end

    def display_welcome
      ui.clear
      ui.header("Coding Agent")
      ui.info_box(
        "I'm your AI pair programmer, ready to help with your code.\n" \
        "Type 'help' for commands, 'exit' to quit."
      )
      ui.divider
    end

    def validate_configuration!
      return if Configuration.valid?

      ui.error("Configuration errors:")
      Configuration.validation_errors.each do |error|
        ui.error("  - #{error}")
      end
      exit 1
    end

    def get_user_input
      user_prompt = ui.pastel.decorate("You", :bright_cyan, :bold) +
                    ui.pastel.decorate(" > ", :bright_white)
      ui.prompt.ask(user_prompt) do |q|
        q.modify :trim
      end
    end

    def should_exit?(input)
      %w[exit quit q].include?(input&.downcase)
    end

    def handle_special_commands(input)
      case input&.downcase
      when "help"
        display_help
        true
      when "clear"
        ui.clear
        display_welcome
        true
      when "history"
        display_history
        true
      when "stats"
        display_stats
        true
      else
        false
      end
    end

    def process_request(input, interactive: true)
      return if input.blank?

      record_message(role: "user", content: input)

      response = String.new(encoding: Encoding::UTF_8)
      response_metadata = nil
      first_chunk = true
      spinner = start_thinking_spinner if interactive

      chat.ask(input) do |chunk|
        content = chunk.content
        next if content.nil?

        # Stop spinner and show AI prompt on first content chunk
        if first_chunk
          stop_spinner_and_show_prompt(spinner) if interactive
          first_chunk = false
        end

        content = content.force_encoding(Encoding::UTF_8)
        print content
        response << content

        # Capture metadata from the final chunk
        response_metadata = chunk if chunk.respond_to?(:usage)
      end

      finish_response(response, response_metadata, interactive)
    rescue StandardError => e
      ui.error("Error: #{e.message}")
      ui.error(e.backtrace.first(3).join("\n")) if Configuration.config.verbose
      nil
    end

    def start_thinking_spinner
      puts # Add spacing
      spinner = TTY::Spinner.new(
        "[:spinner] #{ui.pastel.decorate('Thinking...', :bright_green)}",
        format: :dots,
        output: $stdout
      )
      spinner.auto_spin
      spinner
    end

    def stop_spinner_and_show_prompt(spinner)
      spinner&.stop
      print "\r" # Clear the spinner line
      print " " * 80 # Clear any remaining spinner text
      print "\r" # Return to start of line
      ai_prompt = ui.pastel.decorate("AI", :bright_green, :bold) +
                  ui.pastel.decorate(" > ", :bright_white)
      print ai_prompt
    end

    def finish_response(response, response_metadata, interactive)
      puts "\n"
      record_message(role: "assistant", content: response)

      # Track token usage if available
      update_token_usage(response_metadata) if response_metadata
      display_token_usage if interactive && Configuration.config.show_token_usage

      ui.divider if interactive
      response
    end

    def display_help
      ui.header("Available Commands")

      commands = [
        ["help", "Show this help message"],
        ["clear", "Clear the screen"],
        ["history", "Show conversation history"],
        ["stats", "Show agent statistics"],
        ["exit/quit/q", "Exit the agent"],
      ]

      ui.render_table(
        header: ["Command", "Description"],
        rows: commands
      )
    end

    def display_history
      ui.header("Conversation History")

      if conversation_history.empty?
        ui.info("No conversation history yet.")
        return
      end

      conversation_history.last(5).each do |msg|
        role_color = msg[:role] == "user" ? :bright_cyan : :bright_green
        ui.info(ui.pastel.decorate("#{msg[:role].capitalize}:", role_color, :bold))
        ui.info("  #{msg[:content].truncate(200)}")
        ui.info("  #{ui.pastel.dim(msg[:timestamp].strftime('%Y-%m-%d %H:%M:%S'))}")
        ui.divider(width: 60, color: :dim)
      end
    end

    def display_stats
      ui.header("Agent Statistics")

      stats = [
        ["Total messages", conversation_history.size],
        ["User messages", conversation_history.count { |m| m[:role] == "user" }],
        ["Agent messages", conversation_history.count { |m| m[:role] == "assistant" }],
        ["Tools available", tools.size],
        ["Workspace", Configuration.config.workspace_path],
        ["Total tokens", token_usage[:total]],
        ["Input tokens", token_usage[:input]],
        ["Output tokens", token_usage[:output]],
      ]

      ui.render_table(
        header: ["Metric", "Value"],
        rows: stats
      )
    end

    def display_farewell
      ui.divider
      ui.success("Thank you for using Coding Agent. Happy coding!")

      return unless token_usage[:total].positive?

      token_summary = "Session tokens: #{token_usage[:total]} " \
                      "(in: #{token_usage[:input]}, out: #{token_usage[:output]})"
      ui.info(ui.pastel.dim(token_summary))
    end

    def update_token_usage(metadata)
      return unless metadata.respond_to?(:usage)

      usage = metadata.usage
      @token_usage[:input] += usage.input_tokens if usage.respond_to?(:input_tokens)
      @token_usage[:output] += usage.output_tokens if usage.respond_to?(:output_tokens)
      @token_usage[:total] = @token_usage[:input] + @token_usage[:output]
    end

    def display_token_usage
      ui.info(ui.pastel.dim("Tokens: #{token_usage[:total]} total (↑#{token_usage[:input]} ↓#{token_usage[:output]})"))
    end

    def setup_system_prompt
      system_message = <<~SYSTEM
        You are a helpful AI coding assistant with access to powerful file and command execution tools.

        CORE PRINCIPLES:
        1. **Explore before acting**: Use list_files and read_file to understand the codebase structure
        2. **Search to understand**: Use search_files to find how features are implemented
        3. **Verify changes**: Read files after editing to confirm changes were applied correctly
        4. **Test your work**: Run tests or builds to verify functionality
        5. **Be transparent**: Explain what you're doing and why

        TOOL USAGE PATTERNS:
        - To understand a project: list_files → read_file (key files) → search_files (specific patterns)
        - To make changes: read_file → edit_file → read_file (verify) → run_shell_command (test)
        - To create files: Use edit_file with old_str='' (empty string) and new_str as full content
        - To track changes: git_operations with 'status' and 'diff'

        BEST PRACTICES:
        - Always read a file before editing it to understand its current state
        - Make small, focused changes rather than large rewrites
        - Include context in old_str to ensure uniqueness when editing
        - Run tests after making changes to catch regressions
        - Use git status to understand what files you've modified

        Remember: You have the tools to explore, understand, modify, and verify code autonomously.
        Use them proactively to provide the best help possible.
      SYSTEM

      record_message(role: "system", content: system_message)
    end
  end
end
