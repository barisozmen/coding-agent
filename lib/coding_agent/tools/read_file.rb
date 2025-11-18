# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../concerns/toolable"

module CodingAgent
  module Tools
    # Read files with beautiful error handling and safety checks
    # This is a sharp knife - we trust the AI, but verify the path
    class ReadFile < RubyLLM::Tool
      include Concerns::Toolable

      description "Read file contents to examine code, configuration, documentation, or data. " \
                  "Use whenever you need to understand what's in a file before editing it. " \
                  "Automatically called when analyzing code structure or debugging. " \
                  "Returns full file content with metadata (lines, size)."

      param :path,
            desc: "Relative path to the file you want to read",
            required: true,
            type: :string

      def execute(path:)
        full_path = safe_path(path)

        unless File.exist?(full_path)
          return {
            error: "File not found: #{path}",
            hint: "Use list_files to see available files, or check if the path is correct",
          }
        end

        if File.directory?(full_path)
          return {
            error: "#{path} is a directory, not a file",
            hint: "Use list_files(path: '#{path}') to see what's inside this directory",
          }
        end

        content = File.read(full_path)
        lines = content.lines.count

        ui.success("Read #{path} (#{lines} lines)")

        {
          path: path,
          content: content,
          lines: lines,
          size: content.bytesize,
        }
      rescue StandardError => e
        ui.error("Failed to read #{path}: #{e.message}")
        {
          error: e.message,
          hint: "Check file permissions or if the file contains binary data",
        }
      end
    end
  end
end
