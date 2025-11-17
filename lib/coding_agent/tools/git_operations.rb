# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../concerns/toolable"

module CodingAgent
  module Tools
    # Git operations with beautiful feedback
    # Following the doctrine: provide sharp knives!
    class GitOperations < RubyLLM::Tool
      include Concerns::Toolable

      description "Perform git operations to track changes, view history, and manage commits. " \
                  "Use 'status' to see what files changed, 'diff' to examine specific changes, " \
                  "'log' to view commit history, 'add' to stage files, 'commit' to save changes. " \
                  "Essential for understanding project state and creating checkpoints. " \
                  "Returns formatted git output for easy parsing."

      param :operation,
            desc: "Git operation to perform: status, diff, log, commit, add",
            required: true,
            type: :string

      param :args,
            desc: "Additional arguments for the git command",
            required: false,
            type: :string

      ALLOWED_OPERATIONS = %w[status diff log add commit branch].freeze

      def execute(operation:, args: "")
        unless ALLOWED_OPERATIONS.include?(operation)
          return {
            error: "Operation '#{operation}' not allowed. " \
                   "Allowed: #{ALLOWED_OPERATIONS.join(', ')}"
          }
        end

        command = build_git_command(operation, args)

        result = execute_git(command)

        if result[:success]
          ui.success("Git #{operation} completed")
        else
          ui.warning("Git #{operation} had issues")
        end

        result
      rescue StandardError => e
        ui.error("Git operation failed: #{e.message}")
        { error: e.message }
      end

      private

      def build_git_command(operation, args)
        case operation
        when "status"
          "git status --short --branch"
        when "diff"
          args.present? ? "git diff #{args}" : "git diff"
        when "log"
          args.present? ? "git log #{args}" : "git log --oneline -10"
        when "add"
          "git add #{args}"
        when "commit"
          # Require confirmation for commits
          "git commit #{args}"
        when "branch"
          args.present? ? "git branch #{args}" : "git branch"
        else
          "git #{operation} #{args}"
        end
      end

      def execute_git(command)
        Dir.chdir(workspace_path) do
          output = `#{command} 2>&1`
          exit_code = $?.exitstatus

          {
            success: exit_code.zero?,
            exit_code: exit_code,
            output: output,
            command: command
          }
        end
      end
    end
  end
end
