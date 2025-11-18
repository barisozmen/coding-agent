# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../concerns/toolable"
require "active_support/core_ext/object/blank"

module CodingAgent
  module Tools
    # List files and directories with beautiful formatting
    # Convention: directories end with /, files don't
    class ListFiles < RubyLLM::Tool
      include Concerns::Toolable

      description "Explore directory structure to find files and subdirectories. " \
                  "Essential for understanding project layout before making changes. " \
                  "Directories end with '/', files don't. " \
                  "Use this to discover what files exist, then read_file to examine them. " \
                  "Defaults to current directory if no path provided."

      param :path,
            desc: "Relative path to list (defaults to current directory)",
            required: false,
            type: :string

      def execute(path: "")
        full_path = safe_path(path.presence || ".")

        unless File.exist?(full_path)
          return {
            error: "Path not found: #{path}",
            hint: "List parent directory first to see what's available",
          }
        end

        unless File.directory?(full_path)
          return {
            error: "#{path} is not a directory",
            hint: "This is a file. Use read_file to view its contents",
          }
        end

        entries = Dir.glob("#{full_path}/*", File::FNM_DOTMATCH)
                     .reject { |e| File.basename(e).in?(%w[. ..]) }
                     .map { |entry| format_entry(entry, full_path) }
                     .sort

        ui.success("Listed #{entries.size} items in #{path.presence || '.'}")

        {
          path: path.presence || ".",
          entries: entries,
          count: entries.size,
        }
      rescue StandardError => e
        ui.error("Failed to list #{path}: #{e.message}")
        {
          error: e.message,
          hint: "Check if you have permission to access this directory",
        }
      end

      private

      def format_entry(entry, base_path)
        relative = entry.delete_prefix("#{base_path}/")
        File.directory?(entry) ? "#{relative}/" : relative
      end
    end
  end
end
