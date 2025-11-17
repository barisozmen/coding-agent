# Contributing to Coding Agent

Thank you for your interest in making Coding Agent even more beautiful!

## Philosophy

This project follows the [Rails Doctrine](https://rubyonrails.org/doctrine). Before contributing, please familiarize yourself with these principles:

1. **Optimize for programmer happiness** - Code should be joyful to write and read
2. **Convention over Configuration** - Prefer sensible defaults
3. **Exalt beautiful code** - Aesthetics matter
4. **Provide sharp knives** - Trust developers with powerful tools
5. **Value integrated systems** - Keep things cohesive

## Getting Started

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/coding_agent.git
cd coding_agent

# Run the setup
rake setup

# Run tests
rake test

# Run RuboCop
rake rubocop
```

## Code Style

We use RuboCop to maintain beautiful, consistent code:

- **Line length**: 120 characters max (readability over brevity)
- **String literals**: Double quotes preferred
- **Documentation**: Code should be self-documenting; comments for why, not what
- **Methods**: Keep them focused and expressive (max 25 lines)
- **Classes**: Rich and expressive (max 200 lines)

Run `rake rubocop` to check your code.

## Writing Beautiful Code

### Good Examples

```ruby
# Beautiful - expressive and clear
def process_request(input, interactive: true)
  return if input.blank?

  record_message(role: "user", content: input)

  if interactive
    display_thinking_indicator
  end

  handle_response(input)
end

# Beautiful - Ruby's elegance shines
def safe_commands
  %w[ls pwd git\ status].freeze
end

# Beautiful - concerns for cross-cutting behavior
module Toolable
  extend ActiveSupport::Concern

  included do
    attr_reader :ui, :workspace_path
  end
end
```

### Less Beautiful Examples

```ruby
# Less beautiful - too terse
def pr(i, int)
  return if i.nil?
  rec_msg("u", i)
  h_resp(i) if int
end

# Less beautiful - no Ruby elegance
SAFE_COMMANDS = ["ls", "pwd", "git status"]

# Less beautiful - inheritance where concern fits better
class BaseTool
  def initialize(ui, wp)
    @ui = ui
    @workspace_path = wp
  end
end
```

## Adding New Tools

Tools should:

1. Inherit from `RubyLLM::Tool`
2. Include the `Toolable` concern
3. Provide a clear description
4. Define parameters with descriptions
5. Implement `execute` with keyword arguments
6. Handle errors gracefully
7. Provide user feedback via `@ui`

Example:

```ruby
module CodingAgent
  module Tools
    class MyNewTool < RubyLLM::Tool
      include Concerns::Toolable

      description "Clear description of what this tool does"

      param :my_param,
            desc: "What this parameter means",
            required: true,
            type: :string

      def execute(my_param:)
        # Your implementation
        ui.success("Did something beautiful!")

        { result: "data" }
      rescue StandardError => e
        ui.error("Failed gracefully: #{e.message}")
        { error: e.message }
      end
    end
  end
end
```

## Testing

Write tests that:

- Cover the happy path
- Cover edge cases
- Are readable and expressive
- Use descriptive test names

```ruby
class MyNewToolTest < Minitest::Test
  def test_executes_successfully_with_valid_input
    tool = CodingAgent::Tools::MyNewTool.new(ui: @ui)
    result = tool.execute(my_param: "valid")

    assert result[:result]
    assert_includes stdout_output, "Did something beautiful!"
  end

  def test_handles_errors_gracefully
    tool = CodingAgent::Tools::MyNewTool.new(ui: @ui)
    result = tool.execute(my_param: nil)

    assert result[:error]
  end
end
```

## Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Write** beautiful code
4. **Add** tests for your changes
5. **Ensure** all tests pass (`rake test`)
6. **Ensure** RuboCop is happy (`rake rubocop`)
7. **Commit** with a descriptive message
8. **Push** to your fork
9. **Open** a Pull Request

### Good Commit Messages

```
Add SearchFiles tool for pattern matching

Implements a new tool that searches for text patterns across
files in the workspace. Uses regex support and provides context
around matches. Includes safety checks for binary files.

- Add SearchFiles tool with pattern matching
- Include context extraction around matches
- Skip binary files automatically
- Add comprehensive tests
```

## Questions?

Feel free to open an issue for:
- Questions about contributing
- Suggestions for improvements
- Discussion about design decisions

Remember: We optimize for happiness and exalt beautiful code!

---

*"Code is not just for computers to execute. It's for humans to read, understand, and delight in."*
