# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../concerns/toolable"
require "active_support/core_ext/string/filters"
require "fileutils"

module CodingAgent
  module Tools
    # Edit files with precision and beautiful feedback
    # Sharp knife: allows creating new files and modifying existing ones
    class EditFile < RubyLLM::Tool
      include Concerns::Toolable

      description "Edit files by replacing exact string matches. " \
                  "To CREATE a new file: pass empty string as old_str. " \
                  "To EDIT existing file: old_str must match exactly (including whitespace) and be unique. " \
                  "Returns detailed feedback about the operation. " \
                  "Examples: Create with old_str='', Edit by finding unique substring."

      param :path,
            desc: "Relative path to the file (will be created if it doesn't exist)",
            required: true,
            type: :string

      param :old_str,
            desc: "String to find and replace. Use empty string '' to create new file with new_str as content",
            required: true,
            type: :string

      param :new_str,
            desc: "Replacement string (or full content if creating new file)",
            required: true,
            type: :string

      def execute(path:, old_str:, new_str:)
        # Validate inputs
        if old_str == new_str && old_str != ""
          return {
            error: "old_str and new_str are identical. No changes needed.",
            hint: "If creating a file, use old_str='' (empty string)",
          }
        end

        full_path = safe_path(path)
        file_existed = File.exist?(full_path)

        # Handle file creation (Go implementation pattern)
        if old_str.empty?
          if file_existed
            return {
              error: "Cannot create file - #{path} already exists",
              hint: "To edit existing file, provide the exact old_str to replace",
            }
          end

          # Create directory structure if needed
          FileUtils.mkdir_p(File.dirname(full_path)) unless File.dirname(full_path) == "."

          File.write(full_path, new_str)
          ui.success("Created #{path} (#{new_str.lines.count} lines)")

          return {
            path: path,
            action: "created",
            content_length: new_str.length,
            lines: new_str.lines.count,
          }
        end

        # Handle file editing
        unless file_existed
          return {
            error: "File #{path} does not exist",
            hint: "To create it, use old_str='' (empty string) with new_str as the full content",
          }
        end

        content = File.read(full_path)

        unless content.include?(old_str)
          return {
            error: "String not found in #{path}",
            hint: "Ensure old_str matches exactly, including whitespace and newlines",
            searched_for: old_str.truncate(100),
          }
        end

        # Check for uniqueness (critical for correctness)
        occurrences = content.scan(old_str).length
        if occurrences > 1
          return {
            error: "old_str appears #{occurrences} times in #{path} - must be unique",
            hint: "Include more surrounding context to make old_str unique in the file",
            occurrences: occurrences,
          }
        end

        # Perform the replacement
        new_content = content.sub(old_str, new_str)
        File.write(full_path, new_content)

        lines_delta = new_content.lines.count - content.lines.count
        ui.success("Edited #{path} (#{'+' if lines_delta >= 0}#{lines_delta} lines)")

        {
          path: path,
          action: "edited",
          old_length: content.length,
          new_length: new_content.length,
          lines_changed: lines_delta,
        }
      rescue StandardError => e
        ui.error("Failed to edit #{path}: #{e.message}")
        { error: e.message, backtrace: e.backtrace.first(2) }
      end
    end
  end
end
