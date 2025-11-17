# frozen_string_literal: true

require "dry-configurable"
require "active_support/core_ext/hash"

module CodingAgent
  # Beautiful configuration with validation and sensible defaults
  # Convention over Configuration in action!
  class Configuration
    extend Dry::Configurable

    # LLM Configuration
    setting :OPENAI_API_KEY, default: ENV.fetch("OPENAI_API_KEY", nil)
    setting :default_model, default: ENV.fetch("DEFAULT_MODEL", "gpt-4")
    setting :max_tokens, default: 4096
    setting :temperature, default: 0.7

    # Agent behavior
    setting :workspace_path, default: Dir.pwd
    setting :auto_execute_safe_commands, default: false
    setting :require_confirmation_for_destructive, default: true

    # UI preferences
    setting :color_enabled, default: true
    setting :verbose, default: false
    setting :show_token_usage, default: false

    # History and context
    setting :max_conversation_history, default: 50
    setting :save_conversation_history, default: true
    setting :history_file_path, default: File.expand_path("~/.coding_agent_history.yml")

    class << self
      # Validate configuration is ready for use
      def valid?
        config.OPENAI_API_KEY.present?
      end

      # Human-friendly validation errors
      def validation_errors
        errors = []
        errors << "OPENAI_API_KEY is not set" if config.OPENAI_API_KEY.blank?
        errors << "Workspace path does not exist" unless Dir.exist?(config.workspace_path)
        errors
      end

      # Apply configuration from hash (useful for testing)
      def apply(options = {})
        options.each do |key, value|
          config.public_send(:"#{key}=", value) if config.respond_to?(:"#{key}=")
        end
      end

      # Reset to defaults
      def reset!
        # Recreate configuration
        instance_variable_set(:@config, nil)
      end
    end
  end
end
