# frozen_string_literal: true

module CodingAgent
  # Tracks token usage across the agent session
  # Provides beautiful summaries for programmer awareness of costs
  class TokenTracker
    attr_reader :usage

    def initialize
      @usage = { input: 0, output: 0, total: 0 }
    end

    # Update usage from LLM response metadata
    def update(metadata)
      return unless metadata.respond_to?(:usage)

      usage_data = metadata.usage
      @usage[:input] += usage_data.input_tokens if usage_data.respond_to?(:input_tokens)
      @usage[:output] += usage_data.output_tokens if usage_data.respond_to?(:output_tokens)
      @usage[:total] = @usage[:input] + @usage[:output]
    end

    # Inline token summary for display during interaction
    # Format: "Tokens: 1234 total (↑500 ↓734)"
    def inline_summary
      "Tokens: #{usage[:total]} total (↑#{usage[:input]} ↓#{usage[:output]})"
    end

    # Session summary for farewell display
    # Format: "Session tokens: 1234 (in: 500, out: 734)"
    def session_summary
      "Session tokens: #{usage[:total]} (in: #{usage[:input]}, out: #{usage[:output]})"
    end

    # Check if any tokens have been used
    def any?
      usage[:total].positive?
    end
  end
end
