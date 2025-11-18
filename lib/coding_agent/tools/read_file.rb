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
          output.error("File not found: #{path}")
          return {
            error: "File not found: #{path}",
            hint: "Use list_files to see available files",
          }
        end

        if File.directory?(full_path)
          output.error("#{path} is a directory, not a file")
          return {
            error: "#{path} is a directory",
            hint: "Use list_files(path: '#{path}') to see contents",
          }
        end

        content = File.read(full_path)
        lines = content.lines.count

        output.info("Read #{path} (#{lines} lines, #{content.bytesize} bytes)")

        {
          path: path,
          content: content,
          lines: lines,
          size: content.bytesize,
        }
      end
    end
  end
end
