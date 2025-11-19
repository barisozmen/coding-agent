# frozen_string_literal: true

module CodingAgent
  # Auto-discovers and manages tool classes
  # Convention over configuration: any class in Tools module that includes Toolable is a tool
  class ToolRegistry
    class << self
      # Returns all tool classes that are properly configured
      # Tools must:
      # 1. Be in the CodingAgent::Tools namespace
      # 2. Inherit from RubyLLM::Tool
      # 3. Include Concerns::Toolable
      def all_tools
        Tools.constants
          .map { |name| Tools.const_get(name) }
          .select { |klass| tool_class?(klass) }
      end

      private

      def tool_class?(klass)
        klass.is_a?(Class) &&
          klass < RubyLLM::Tool &&
          klass.included_modules.include?(Concerns::Toolable)
      end
    end
  end
end
