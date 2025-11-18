# frozen_string_literal: true

require "thor"
require_relative "agent"
require_relative "ui"
require_relative "configuration"

module CodingAgent
  # Beautiful command-line interface using Thor
  # Convention over Configuration for CLI design
  class Cli < Thor
    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: "Enable verbose output"

    class_option :workspace,
                 type: :string,
                 aliases: "-w",
                 desc: "Set workspace directory"

    def initialize(*args)
      super
      @ui = UI.new
      apply_global_options
    end

    desc "chat", "Start an interactive chat session with the coding agent"
    long_desc <<~DESC
      Start an interactive coding agent session. The agent will help you with:
      - Reading and analyzing code
      - Editing files
      - Running commands
      - Git operations
      - Searching codebases

      Type 'help' during the session for available commands.
    DESC
    def chat
      display_banner
      Agent.new(ui: @ui).run
    end

    desc "ask QUESTION", "Ask the agent a single question and exit"
    long_desc <<~DESC
      Ask a single question without entering interactive mode.
      Useful for scripting and quick queries.

      Examples:
        coding_agent ask "What does the User model do?"
        coding_agent ask "Find all TODO comments in Ruby files"
    DESC
    def ask(question)
      result = Agent.new(ui: @ui).ask(question)
      exit(result ? 0 : 1)
    end

    desc "version", "Show version information"
    def version
      @ui.info("Coding Agent v#{VERSION}")
      @ui.info("Ruby #{RUBY_VERSION}")
      @ui.info("Powered by RubyLLM and OpenAI")
    end

    desc "config", "Show current configuration"
    def config
      @ui.header("Current Configuration")

      config_data = [
        ["Model", Configuration.config.default_model],
        ["Workspace", Configuration.config.workspace_path],
        ["Max tokens", Configuration.config.max_tokens],
        ["Temperature", Configuration.config.temperature],
        ["Auto-execute safe commands", Configuration.config.auto_execute_safe_commands],
        ["Save history", Configuration.config.save_conversation_history],
        ["History file", Configuration.config.history_file_path],
      ]

      @ui.render_table(
        header: ["Setting", "Value"],
        rows: config_data
      )

      unless Configuration.valid?
        @ui.error("\nConfiguration issues:")
        Configuration.validation_errors.each do |error|
          @ui.error("  - #{error}")
        end
      end
    end

    desc "setup", "Interactive setup wizard"
    long_desc <<~DESC
      Run an interactive setup wizard to configure the coding agent.
      This will help you:
      - Set up your OpenAI API key
      - Configure preferences
      - Test the connection
    DESC
    def setup
      @ui.header("Coding Agent Setup")

      # API Key
      if Configuration.config.OPENAI_API_KEY.blank?
        api_key = @ui.mask("Enter your OpenAI API key:")
        if api_key.present?
          create_env_file(api_key)
          @ui.success("API key saved to .env file")
        end
      else
        @ui.success("API key is already configured")
      end

      # Preferences
      configure_preferences if @ui.confirm?("Would you like to configure preferences?", default: false)

      @ui.success("\nSetup complete! Run 'coding_agent chat' to start.")
    end

    default_task :chat

    private

    def apply_global_options
      Configuration.config.verbose = true if options[:verbose]

      Configuration.config.workspace_path = File.expand_path(options[:workspace]) if options[:workspace]
    end

    def display_banner
      banner = <<~BANNER

        ╔═══════════════════════════════════════════════════════════╗
        ║                                                           ║
        ║              🤖  Coding Agent  🤖                         ║
        ║                                                           ║
        ║          Your AI Pair Programmer                          ║
        ║          Optimized for Programmer Happiness               ║
        ║                                                           ║
        ╚═══════════════════════════════════════════════════════════╝

      BANNER

      puts @ui.pastel.decorate(banner, :bright_magenta, :bold)
    end

    def create_env_file(api_key)
      content = <<~ENV
        # OpenAI API Configuration
        OPENAI_API_KEY=#{api_key}

        # Optional: Override default model
        # DEFAULT_MODEL=claude-3-7-sonnet

        # Optional: Set workspace path
        # WORKSPACE_PATH=#{Dir.pwd}
      ENV

      File.write(".env", content)
    end

    def configure_preferences
      choices = @ui.multi_select(
        "Select features to enable:",
        [
          { name: "Auto-execute safe commands (ls, git status, etc.)", value: :auto_execute },
          { name: "Save conversation history", value: :save_history },
          { name: "Verbose output", value: :verbose },
        ]
      )

      Configuration.config.auto_execute_safe_commands = choices.include?(:auto_execute)
      Configuration.config.save_conversation_history = choices.include?(:save_history)
      Configuration.config.verbose = choices.include?(:verbose)

      @ui.success("Preferences saved!")
    end
  end
end
