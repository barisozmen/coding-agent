# frozen_string_literal: true

require "ruby_llm/tool"
require_relative "../concerns/toolable"

module CodingAgent
  module Tools
    # Search for text patterns in files - like grep but beautiful
    # Progressive enhancement: simple search with room to grow
    class SearchFiles < RubyLLM::Tool
      include Concerns::Toolable

      description "Search for patterns across files to find definitions, usages, or specific code. " \
                  "Like grep but returns rich context with file paths and line numbers. " \
                  "Perfect for finding where functions are defined, tracking down TODO comments, " \
                  "or understanding how a feature is implemented across multiple files. " \
                  "Supports regex patterns and file filtering."

      param :pattern,
            desc: "The text pattern to search for (supports basic regex)",
            required: true,
            type: :string

      param :path,
            desc: "Path to search in (defaults to entire workspace)",
            required: false,
            type: :string

      param :file_pattern,
            desc: "File pattern to match (e.g., '*.rb', '*.js')",
            required: false,
            type: :string

      def execute(pattern:, path: ".", file_pattern: "*")
        search_path = safe_path(path)

        unless File.exist?(search_path)
          return { error: "Search path not found: #{path}" }
        end

        matches = find_matches(search_path, pattern, file_pattern)

        ui.success("Found #{matches.size} matches for '#{pattern}'")

        {
          pattern: pattern,
          matches: matches,
          count: matches.size
        }
      rescue StandardError => e
        ui.error("Search failed: #{e.message}")
        { error: e.message }
      end

      private

      def find_matches(search_path, pattern, file_pattern)
        matches = []
        regex = Regexp.new(pattern, Regexp::IGNORECASE)

        glob_pattern = File.directory?(search_path) ? "#{search_path}/**/#{file_pattern}" : search_path

        Dir.glob(glob_pattern).each do |file|
          next unless File.file?(file)
          next if binary_file?(file)

          File.readlines(file).each_with_index do |line, index|
            if line.match?(regex)
              matches << {
                file: file.delete_prefix("#{workspace_path}/"),
                line_number: index + 1,
                line: line.strip,
                context: extract_context(file, index)
              }
            end
          end
        rescue StandardError => e
          # Skip files we can't read
          ui.warning("Skipped #{file}: #{e.message}") if Configuration.config.verbose
        end

        matches.first(100) # Limit results to avoid overwhelming the LLM
      end

      def binary_file?(path)
        # Simple heuristic: check first 1000 bytes for null bytes
        File.open(path, "rb") do |f|
          sample = f.read(1000)
          sample&.include?("\x00")
        end
      rescue StandardError
        true # If we can't read it, treat as binary
      end

      def extract_context(file, line_index, context_lines: 2)
        lines = File.readlines(file)
        start_idx = [0, line_index - context_lines].max
        end_idx = [lines.length - 1, line_index + context_lines].min

        lines[start_idx..end_idx].map(&:strip)
      rescue StandardError
        []
      end
    end
  end
end
