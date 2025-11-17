# frozen_string_literal: true

require "test_helper"

class UITest < Minitest::Test
  def test_info_outputs_with_style
    @ui.info("Hello world")
    assert_includes stdout_output, "Hello world"
  end

  def test_success_outputs_with_style
    @ui.success("Task completed")
    assert_includes stdout_output, "Task completed"
  end

  def test_error_outputs_with_style
    @ui.error("Something went wrong")
    assert_includes stdout_output, "Something went wrong"
  end

  def test_warning_outputs_with_style
    @ui.warning("Be careful")
    assert_includes stdout_output, "Be careful"
  end

  def test_with_spinner
    result = @ui.with_spinner("Testing") { "done" }
    assert_equal "done", result
  end

  def test_render_table
    @ui.render_table(
      header: %w[Name Age],
      rows: [["Alice", 30], ["Bob", 25]]
    )
    assert_includes stdout_output, "Alice"
    assert_includes stdout_output, "Bob"
  end
end
