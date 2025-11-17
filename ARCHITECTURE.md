# Architecture

> A beautiful Ruby coding agent following the Rails Doctrine

## Overview

This coding agent is designed as an **integrated system** following Rails principles. Every component works harmoniously together, optimized for **programmer happiness** and **beautiful code**.

## Core Principles Applied

### 1. Optimize for Programmer Happiness

Every design decision prioritizes the developer experience:

- **Beautiful terminal UI** - Using the TTY ecosystem for delightful interactions
- **Intuitive API** - Natural method names that read like English
- **Helpful feedback** - Clear, actionable messages at every step
- **Smart defaults** - Convention over Configuration throughout

Example:
```ruby
# This makes us smile!
ui.with_spinner("Processing") { expensive_operation }
tool.safe_path(path) # Security made simple
```

### 2. Convention over Configuration

We minimize decisions through sensible conventions:

- **Zeitwerk** for automatic code loading
- **Tool naming** - All tools in `tools/`, inherit from `RubyLLM::Tool`
- **Concerns** for cross-cutting behavior
- **Default workspace** - Current directory
- **Standard configuration** - `.env` file

### 3. The Menu is Omakase

We provide a complete, integrated stack:

- **Thor** for CLI (not OptionParser, not custom)
- **TTY::*** for all terminal UI (consistent ecosystem)
- **ActiveSupport** for Ruby enhancements (Rails' sharp knives)
- **Dry::Configurable** for settings
- **RubyLLM** for AI integration

No need to choose - we've assembled the best tools.

### 4. No One Paradigm

We embrace multiple paradigms where they shine:

- **Object-Oriented** - Core Agent, Tools, UI classes
- **Functional** - Tool execution, data transformations
- **Procedural** - Simple helper methods where appropriate
- **Declarative** - Configuration DSL, tool parameter declarations

Example:
```ruby
# Declarative tool definition
class ReadFile < RubyLLM::Tool
  description "Read file contents"
  param :path, desc: "File path"

  # Procedural execution
  def execute(path:)
    File.read(safe_path(path))
  end
end
```

### 5. Exalt Beautiful Code

Beauty is not an afterthought:

```ruby
# Beautiful concern usage
module Conversational
  extend ActiveSupport::Concern

  included do
    attr_reader :conversation_history
  end

  def record_message(role:, content:)
    @conversation_history << {
      role: role,
      content: content,
      timestamp: Time.now
    }
  end
end

# Beautiful UI methods
def with_spinner(message)
  spinner = TTY::Spinner.new("[:spinner] #{message}")
  spinner.auto_spin
  result = yield
  spinner.success("(done)")
  result
end
```

### 6. Provide Sharp Knives

We trust developers with powerful tools:

- **EditFile** - Can create and modify any file
- **RunShellCommand** - Execute arbitrary commands (with confirmation)
- **Concerns** - Ruby modules for mixins (potential for misuse, but powerful)
- **Safe Path** - Security, but doesn't prevent all file operations

Example:
```ruby
# Sharp knife - trusting the developer
def execute(command:)
  if should_execute?(command)
    Dir.chdir(workspace_path) { `#{command}` }
  end
end
```

### 7. Value Integrated Systems

Everything works together as one system:

```
┌─────────────────────────────────────────────┐
│                                             │
│  CLI (Thor)                                 │
│    ↓                                        │
│  Agent                                      │
│    ├── UI (TTY::*)                          │
│    ├── Configuration (Dry::Configurable)    │
│    ├── Conversational (Concern)             │
│    └── Tools                                │
│         ├── Toolable (Concern)              │
│         ├── ReadFile                        │
│         ├── EditFile                        │
│         ├── ListFiles                       │
│         ├── SearchFiles                     │
│         ├── RunShellCommand                 │
│         └── GitOperations                   │
│                                             │
└─────────────────────────────────────────────┘
```

No microservices, no distributed complexity - just a beautiful, integrated whole.

### 8. Progress over Stability

We use modern Ruby and gems:

- **Ruby 3.2+** - Latest stable features
- **Active gems** - Regularly updated dependencies
- **New patterns** - Zeitwerk, Dry::Configurable
- **Room to grow** - Easy to add new tools and features

## Component Details

### Agent (`lib/coding_agent/agent.rb`)

The heart of the system. Coordinates:
- User input/output via UI
- Conversation history via Conversational concern
- Tool registration and execution
- LLM communication via RubyLLM

**Key patterns:**
- Dependency injection (UI, tools)
- Template method (run loop)
- Concern composition (Conversational)

### UI (`lib/coding_agent/ui.rb`)

Terminal interface wrapper. Provides:
- Colorful output (Pastel)
- Spinners (TTY::Spinner)
- Tables (TTY::Table)
- Boxes (TTY::Box)
- Prompts (TTY::Prompt)

**Key patterns:**
- Facade (wraps TTY ecosystem)
- Builder (for complex UI elements)

### Configuration (`lib/coding_agent/configuration.rb`)

Settings management using Dry::Configurable. Features:
- Type-safe settings
- Default values
- Validation
- Environment variable integration

**Key patterns:**
- Singleton (class-level config)
- Strategy (validation)

### Tools

Each tool is a separate class inheriting from `RubyLLM::Tool`:

**Common behavior via Toolable concern:**
- UI access
- Workspace path sandboxing
- Error handling
- Parameter validation

**Individual tools:**
- `ReadFile` - File content reading
- `ListFiles` - Directory listing
- `EditFile` - File modification (sharp knife!)
- `RunShellCommand` - Command execution (very sharp!)
- `SearchFiles` - Pattern searching
- `GitOperations` - Version control

### Concerns

**Toolable** - Shared behavior for all tools:
```ruby
module Toolable
  extend ActiveSupport::Concern

  included do
    attr_reader :ui, :workspace_path
  end

  def safe_path(path)
    # Security logic
  end
end
```

**Conversational** - Conversation history management:
```ruby
module Conversational
  extend ActiveSupport::Concern

  def record_message(role:, content:)
    # History logic
  end
end
```

### CLI (`lib/coding_agent/cli.rb`)

Thor-based command-line interface. Commands:
- `chat` - Interactive mode
- `ask` - One-shot questions
- `config` - Show configuration
- `setup` - Setup wizard
- `version` - Version info

**Key patterns:**
- Command pattern (Thor commands)
- Template method (command structure)

## Data Flow

### Interactive Mode

```
User Input
   ↓
CLI#chat
   ↓
Agent#run
   ↓
Agent#process_request
   ↓
RubyLLM::Chat#ask ←→ Tools
   ↓
Stream Response → UI
   ↓
Record History
```

### One-Shot Mode

```
Command Line Args
   ↓
CLI#ask
   ↓
Agent#ask
   ↓
RubyLLM::Chat#ask ←→ Tools
   ↓
Return Result
   ↓
Exit
```

## Testing Strategy

- **Unit tests** - Individual components
- **Integration tests** - Tool execution
- **UI tests** - Output verification
- **Minitest** with beautiful reporters

## Dependencies

### Production
- `ruby_llm` - LLM integration
- `thor` - CLI framework
- `tty-*` - Terminal UI ecosystem (7 gems)
- `pastel` - Colors
- `activesupport` - Ruby enhancements
- `dry-configurable` - Configuration
- `zeitwerk` - Code loading
- `dotenv` - Environment variables

### Development
- `minitest` + `minitest-reporters` - Testing
- `rubocop` + extensions - Linting
- `debug` - Debugging

## File Organization

```
coding_agent/
├── bin/
│   └── coding_agent          # Executable
├── lib/
│   ├── coding_agent.rb        # Main module
│   └── coding_agent/
│       ├── agent.rb           # Core agent
│       ├── cli.rb             # Thor CLI
│       ├── configuration.rb   # Settings
│       ├── ui.rb              # Terminal UI
│       ├── concerns/
│       │   ├── conversational.rb
│       │   └── toolable.rb
│       └── tools/
│           ├── read_file.rb
│           ├── list_files.rb
│           ├── edit_file.rb
│           ├── run_shell_command.rb
│           ├── search_files.rb
│           └── git_operations.rb
├── test/
│   ├── test_helper.rb
│   ├── coding_agent_test.rb
│   └── ui_test.rb
├── config/                    # Future: More complex config
├── examples/
│   └── interactive_session.md
├── Gemfile
├── Rakefile
├── .env.example
├── .rubocop.yml
├── .gitignore
├── README.md
├── ARCHITECTURE.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Extension Points

Want to add functionality? Here's where:

### New Tool
1. Create `lib/coding_agent/tools/my_tool.rb`
2. Inherit from `RubyLLM::Tool`
3. Include `Concerns::Toolable`
4. Implement `execute`
5. Register in `Agent#build_tools`

### New CLI Command
1. Add method to `CLI` class
2. Use Thor DSL for description
3. Call `Agent` methods

### New Configuration
1. Add `setting` to `Configuration`
2. Update `.env.example`
3. Use via `Configuration.config.my_setting`

### New Concern
1. Create `lib/coding_agent/concerns/my_concern.rb`
2. Use `ActiveSupport::Concern`
3. Include in classes that need it

## Why This Architecture?

This architecture follows the Rails Doctrine because:

1. **It makes us happy** - Beautiful code, great tools
2. **It's conventional** - Easy to navigate and extend
3. **It's integrated** - Everything works together
4. **It's flexible** - Multiple paradigms where they fit
5. **It's progressive** - Modern Ruby, modern patterns
6. **It trusts you** - Sharp knives available

Most importantly: **It works as a complete system** that feels cohesive and joyful to use.

---

*"The architecture is the manifestation of our values."*
