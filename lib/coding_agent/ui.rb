# frozen_string_literal: true

require "tty-prompt"
require "tty-spinner"
require "tty-table"
require "tty-box"
require "tty-command"
require "pastel"

module CodingAgent
  # Pretty UI layer using TTY ecosystem
  # Optimized for programmer happiness with beautiful terminal output
  class UI
    attr_reader :prompt, :pastel, :command

    def initialize(out: $stdout, err: $stderr)
      @prompt  = TTY::Prompt.new(output: out)
      @pastel  = Pastel.new
      @command = TTY::Command.new(printer: :null, output: out)
      @out     = out
      @err     = err
    end

    # Beautiful headers for major sections
    def header(text)
      box = TTY::Box.frame(
        width: [text.size + 8, 60].max,
        height: 3,
        align: :center,
        border: :thick,
        style: {
          border: { fg: :bright_magenta },
        }
      ) { pastel.decorate(text, :bold, :bright_white) }
      @out.puts box
    end

    # Informational messages with style
    def info(text)
      @out.puts pastel.decorate("  #{text}", :cyan)
    end

    # Important information in a beautiful box
    def info_box(text)
      box = TTY::Box.frame(
        width: [text.size + 8, 70].max,
        padding: 1,
        border: :thick,
        style: {
          border: { fg: :bright_blue },
        }
      ) { pastel.decorate(text, :bright_blue, :bold) }
      @out.puts box
    end

    # Success messages that make you smile
    def success(text)
      @out.puts pastel.decorate("  #{text}", :green, :bold)
    end

    # Errors that are clear but not harsh
    def error(text)
      @out.puts pastel.decorate("  #{text}", :red, :bold)
    end

    # Warnings that catch attention
    def warning(text)
      @out.puts pastel.decorate("  #{text}", :yellow)
    end

    # Spinner for operations that delight
    def with_spinner(message, delay: 0.08, format: :pulse_2)
      spinner = TTY::Spinner.new(
        "[:spinner] #{message}",
        format: format,
        interval: delay,
        output: @out
      )
      spinner.auto_spin
      result = nil

      begin
        result = yield spinner
        spinner.success(pastel.decorate("(done)", :green))
      rescue StandardError
        spinner.error(pastel.decorate("(failed)", :red))
        raise
      end

      result
    end

    # Multiple spinners for concurrent operations
    def with_multi_spinner(message)
      multi = TTY::Spinner::Multi.new(
        "[:spinner] #{message}",
        format: :pulse_2,
        output: @out
      )
      yield multi
      multi.auto_spin
      multi
    end

    # Pretty table rendering
    def render_table(header:, rows:, **options)
      table = TTY::Table.new(header, rows)

      # Get terminal width, default to 120 if not available
      terminal_width = TTY::Screen.width rescue 120

      styled_table = table.render(
        :unicode,
        multiline: true,
        padding: [0, 2, 0, 2],
        width: terminal_width,
        resize: true,
        **options
      ) do |renderer|
        renderer.border.style = :bright_blue
      end
      @out.puts styled_table
    end

    # Elegant confirmation prompts
    def confirm?(message, default: false)
      prompt.yes?(message) { |q| q.default(default) }
    end

    # Beautiful selections
    def select(message, choices, **)
      prompt.select(message, choices, **)
    end

    # Multi-select with elegance
    def multi_select(message, choices, **)
      prompt.multi_select(message, choices, **)
    end

    # Get input with style
    def ask(message, **)
      prompt.ask(message, **)
    end

    # Masked input for secrets
    def mask(message, **)
      prompt.mask(message, **)
    end

    # Display a beautiful progress bar
    def progress_bar(total, **)
      TTY::ProgressBar.new(
        "[:bar] :percent :eta",
        total: total,
        output: @out,
        **
      )
    end

    # Show the AI thinking with style
    def ai_thinking(&)
      with_spinner(
        pastel.decorate("AI is thinking...", :cyan, :italic),
        format: :dots, &
      )
    end

    # Display streamed content beautifully
    def stream_content(&block)
      @out.print pastel.decorate("  ", :bright_green)
      block.call
      @out.puts
    end

    # Divider for visual separation
    def divider(char: "─", width: 80, color: :dim)
      @out.puts pastel.decorate(char * width, color)
    end

    # Clear the screen elegantly
    def clear
      @out.print "\e[H\e[2J"
    end

    # Display code with syntax awareness (basic)
    def code_block(code, language: :ruby)
      box = TTY::Box.frame(
        padding: 1,
        border: :thick,
        style: {
          border: { fg: :bright_black },
        }
      ) { pastel.decorate(code, :bright_white) }
      @out.puts box
    end

    # Display tool execution with beautiful borders
    # Shows tool name, parameters, and status in an elegant box
    def tool_execution(tool_name:, params: {}, status: :running)
      display_tool_box(tool_name, params, status)
    end

    private

    def display_tool_box(tool_name, params, status)
      status_icon = get_status_icon(status)
      header = "#{status_icon} #{pastel.decorate(tool_name)}"

      content = [header] + format_params(params)
      border_color = get_border_color(status)

      box = TTY::Box.frame(
        padding: [0, 1],
        # border: :thick,
        style: { border: { fg: border_color } }
      ) { content.join("\n") }

      @out.puts ""
      @out.puts box
    end

    # def format_tool_name(tool_name)
    #   tool_name.to_s.split("::").last
    #            .gsub(/([A-Z])/, ' \1').strip
    #            .upcase
    # end

    def get_status_icon(status)
      case status
      when :running then pastel.decorate("▶", :bright_yellow)
      when :success then pastel.decorate("✓", :bright_green)
      when :error then pastel.decorate("✗", :bright_red)
      else pastel.decorate("•", :bright_blue)
      end
    end

    def format_params(params)
      return [] unless params.any?

      params.map do |key, value|
        formatted_value = value.to_s.length > 60 ? "#{value.to_s[0...60]}..." : value.to_s
        "  #{pastel.dim(key.to_s)}: #{pastel.bright_white(formatted_value)}"
      end
    end

    def get_border_color(status)
      case status
      when :running then :bright_yellow
      when :success then :bright_green
      when :error then :bright_red
      else :bright_blue
      end
    end
  end
end
