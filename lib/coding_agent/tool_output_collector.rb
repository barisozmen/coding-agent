# frozen_string_literal: true

module CodingAgent
  # Collects output from tool execution
  # Simple, beautiful, focused
  class ToolOutputCollector
    attr_reader :messages

    def initialize
      @messages = []
    end

    def info(text)
      @messages << { level: :info, text: text }
    end

    def success(text)
      @messages << { level: :success, text: text }
    end

    def warning(text)
      @messages << { level: :warning, text: text }
    end

    def error(text)
      @messages << { level: :error, text: text }
    end

    def empty?
      @messages.empty?
    end
  end
end
