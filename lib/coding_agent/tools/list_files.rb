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
          output.error("Path not found: #{path}")
          return { error: "Path not found: #{path}" }
        end

        unless File.directory?(full_path)
          output.error("#{path} is not a directory")
          return { error: "#{path} is not a directory" }
        end

        entries = Dir.glob("#{full_path}/*", File::FNM_DOTMATCH)
                     .reject { |e| File.basename(e).in?(%w[. ..]) }
                     .map { |entry| format_entry(entry, full_path) }
                     .sort

        output.info("#{entries.size} items in #{path.presence || 'current workspace'}:")
        entries.each { |entry| output.info(entry) }

        {
          path: path.presence || ".",
          entries: entries,
          count: entries.size,
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
