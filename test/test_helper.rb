# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "coding_agent"
require "minitest/autorun"
require "minitest/reporters"

# Beautiful test output
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new(color: true),
]

module Minitest
  class Test
    # Helper to create a test UI with captured output
    def setup
      @stdout = StringIO.new
      @stderr = StringIO.new
      @ui = CodingAgent::UI.new(out: @stdout, err: @stderr)
    end

    def stdout_output
      @stdout.string
    end

    def stderr_output
      @stderr.string
    end
  end
end
