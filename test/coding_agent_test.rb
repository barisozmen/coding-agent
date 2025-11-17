# frozen_string_literal: true

require "test_helper"

class CodingAgentTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil CodingAgent::VERSION
  end

  def test_module_exists
    assert_kind_of Module, CodingAgent
  end

  def test_configuration_exists
    assert CodingAgent::Configuration
  end

  def test_ui_exists
    assert CodingAgent::UI
  end

  def test_agent_exists
    assert CodingAgent::Agent
  end
end
