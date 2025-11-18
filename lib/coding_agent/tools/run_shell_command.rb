# frozen_string_literal: true

require "English"
require "ruby_llm/tool"
require_relative "../concerns/toolable"
require "active_support/core_ext/array/access"

module CodingAgent
  module Tools
    # Execute shell commands with user confirmation for safety
    # This is a very sharp knife - handle with care!
    class RunShellCommand < RubyLLM::Tool
      include Concerns::Toolable

      description "Execute shell commands to run tests, build projects, check git status, or perform system " \
                  "operations. Automatically runs safe commands (ls, git status, tests). " \
                  "Asks user confirmation for potentially destructive operations. " \
                  "Use this when you need to verify changes work, run test suites, or check system state. " \
                  "Returns stdout, stderr, and exit code."

      param :command,
            desc: "The shell command to execute",
            required: true,
            type: :string

      # Commands that are safe to run without confirmation
      SAFE_COMMANDS = %w[
        ls pwd cat echo git\ status git\ log git\ diff
        npm\ test bundle\ exec\ rspec pytest
      ].freeze

      def execute(command:)
        unless should_execute?(command)
          ui.warning("Command execution cancelled by user")
          return { error: "User declined to execute command" }
        end

        ui.info("Executing: #{command}")

        result = ui.with_spinner("Running command") do
          execute_command(command)
        end

        if result[:success]
          ui.success("Command completed successfully")
        else
          ui.error("Command failed with exit code #{result[:exit_code]}")
        end

        result
      rescue StandardError => e
        ui.error("Failed to execute command: #{e.message}")
        { error: e.message }
      end

      private

      def should_execute?(command)
        return true if Configuration.config.auto_execute_safe_commands && safe_command?(command)

        ui.warning("\nAI wants to execute:")
        ui.code_block(command, language: :bash)

        ui.confirm?("Execute this command?", default: false)
      end

      def safe_command?(command)
        SAFE_COMMANDS.any? { |safe| command.strip.start_with?(safe) }
      end

      def execute_command(command)
        stdout_str = ""
        stderr_str = ""
        exit_code = nil

        # Change to workspace directory for execution
        Dir.chdir(workspace_path) do
          # Use backticks for simple execution, capture output
          stdout_str = `#{command} 2>&1`
          exit_code = $CHILD_STATUS.exitstatus
        end

        {
          success: exit_code.zero?,
          exit_code: exit_code,
          stdout: stdout_str,
          stderr: stderr_str,
          command: command,
        }
      end
    end
  end
end
