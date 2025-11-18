# frozen_string_literal: true

require "zeitwerk"
require "active_support"
require "active_support/core_ext"
require "ruby_llm"

# Beautiful module structure following Rails conventions
module CodingAgent
  VERSION = "1.0.0"

  class << self
    attr_writer :loader

    def loader
      @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
        loader.inflector.inflect("ui" => "UI")
        loader.setup
      end
    end

    # Configure RubyLLM with our settings
    def configure_llm!
      RubyLLM.configure do |config|
        config.openai_api_key = Configuration.config.OPENAI_API_KEY
        config.default_model = Configuration.config.default_model
      end
    end

    # Root path of the gem
    def root
      @root ||= Pathname.new(File.expand_path("..", __dir__))
    end
  end
end

# Manual requires for core files that Zeitwerk needs to know about
require_relative "coding_agent/configuration"
require_relative "coding_agent/ui"

# Setup Zeitwerk to load everything else automatically
CodingAgent.loader.setup
CodingAgent.loader.eager_load if ENV["EAGER_LOAD"] == "true"

# Configure LLM on load
CodingAgent.configure_llm!
