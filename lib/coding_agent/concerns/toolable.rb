# frozen_string_literal: true

require "active_support/concern"
require_relative "../tool_output_collector"

module CodingAgent
  module Concerns
    # Toolable concern provides shared behavior for tools
    # This is a beautiful example of extracting cross-cutting concerns
    # while maintaining the power of direct access to tool state
    module Toolable
      extend ActiveSupport::Concern

      included do
        attr_reader :ui, :workspace_path, :output
      end

      class_methods do
        # DSL for declaring tool metadata elegantly
        def description(text = nil)
          if text
            @description = text
          else
            @description
          end
        end

        # Declare parameters with beautiful syntax
        def param(name, desc:, required: true, type: :string)
          @params ||= {}
          @params[name] = { desc: desc, required: required, type: type }
        end

        def params
          @params || {}
        end
      end

      # Initialize with dependencies
      def initialize(ui: UI.new, workspace_path: Configuration.config.workspace_path)
        @ui = ui
        @workspace_path = workspace_path
        @output = ToolOutputCollector.new
      end

      # Safe file operations within workspace
      def safe_path(path)
        full_path = File.expand_path(path, workspace_path)

        raise SecurityError, "Path #{path} is outside workspace" unless full_path.start_with?(workspace_path)

        full_path
      end

      # Override RubyLLM::Tool#call to orchestrate beautiful bordered output
      def call(args)
        @output = ToolOutputCollector.new
        params = args.transform_keys(&:to_sym)
        status = :success

        result = execute(**params)
        result
      rescue StandardError => e
        status = :error
        output.error("#{e.class}: #{e.message}")
        { error: e.message, backtrace: e.backtrace.first(3) }
      ensure
        ui.tool_execution_box(
          tool_name: self.class.name,
          outputs: output.messages,
          status: status
        )
      end

      # Log tool usage for debugging
      def log_execution(params, result)
        return unless Configuration.config.verbose

        ui.info("Tool: #{self.class.name}")
        ui.info("Params: #{params.inspect}")
        ui.info("Result: #{result.inspect}")
      end
    end
  end
end
