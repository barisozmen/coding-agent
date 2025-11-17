# frozen_string_literal: true

require "active_support/concern"

module CodingAgent
  module Concerns
    # Conversational provides message history and context management
    # Beautiful abstraction for maintaining conversation state
    module Conversational
      extend ActiveSupport::Concern

      included do
        attr_reader :conversation_history
      end

      def initialize_conversation
        @conversation_history = []
        load_history if Configuration.config.save_conversation_history
      end

      # Add message to history with timestamp
      def record_message(role:, content:)
        @conversation_history << {
          role: role,
          content: content,
          timestamp: Time.now
        }

        trim_history
        save_history if Configuration.config.save_conversation_history
      end

      # Get recent context for the LLM with smart token management
      # Following Go implementation: maintain stateless conversation by resending context
      def recent_context(limit = 10)
        conversation_history.last(limit).map do |msg|
          { role: msg[:role], content: msg[:content] }
        end
      end

      # Estimate conversation token count (rough approximation)
      def estimated_token_count
        conversation_history.sum do |msg|
          # Rough estimate: ~4 characters per token
          msg[:content].length / 4
        end
      end

      private

      # Keep history manageable with smart trimming
      # Preserve important messages (first/system prompts, recent exchanges)
      def trim_history
        max = Configuration.config.max_conversation_history
        return unless @conversation_history.size > max

        # Keep first 2 messages (likely system/initial context)
        # and most recent messages up to max
        preserved = @conversation_history.first(2)
        recent = @conversation_history.last(max - 2)

        @conversation_history = preserved + recent
      end

      # Persist conversation for learning and debugging
      def save_history
        return if conversation_history.empty?

        File.write(
          Configuration.config.history_file_path,
          conversation_history.to_yaml
        )
      rescue StandardError => e
        # Silently fail - history is nice to have, not critical
        warn "Failed to save history: #{e.message}" if Configuration.config.verbose
      end

      def load_history
        path = Configuration.config.history_file_path
        return unless File.exist?(path)

        @conversation_history = YAML.load_file(path) || []
      rescue StandardError => e
        warn "Failed to load history: #{e.message}" if Configuration.config.verbose
        @conversation_history = []
      end
    end
  end
end
