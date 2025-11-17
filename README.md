# 🤖 Coding Agent

> Your AI pair programmer, beautifully crafted in Ruby with love for the craft.

A sophisticated coding agent built with **Ruby**, following the **Rails Doctrine** and optimized for **programmer happiness**. This is not just another AI tool – it's a thoughtfully designed system that exalts beautiful code and progressive enhancement.

## ✨ Philosophy

This coding agent is built on the principles of the [Rails Doctrine](https://rubyonrails.org/doctrine):

- **Optimize for programmer happiness** - Every interaction is designed to make you smile
- **Convention over Configuration** - Sensible defaults, less decision fatigue
- **Beautiful code** - Leveraging Ruby's elegance and expressiveness
- **Provide sharp knives** - Trust developers with powerful tools
- **Value integrated systems** - Everything works together harmoniously

## 🎨 Features

### Rich Terminal Interface
Built with the beautiful TTY ecosystem:
- 🎨 **Colorful output** with Pastel
- 📊 **Pretty tables** with TTY::Table
- 📦 **Beautiful boxes** with TTY::Box
- ⏳ **Delightful spinners** with TTY::Spinner
- 💬 **Interactive prompts** with TTY::Prompt

### Powerful AI Capabilities
- 📖 **Read and analyze** code across your entire project
- ✏️ **Edit files** with precision
- 🔍 **Search codebases** intelligently
- 🏃 **Run commands** with safety confirmations
- 📝 **Git operations** for version control
- 💬 **Conversation history** that learns from context

### Developer Experience
- 🚀 **Interactive chat** mode for pair programming
- ❓ **Single-shot** questions for quick queries
- 🛠️ **Setup wizard** for easy configuration
- 📚 **Help commands** always at hand
- 🎯 **Smart context** management

## 📦 Installation

### Prerequisites
- Ruby 3.2 or higher
- An [OpenAI API key](https://console.OpenAI.com/)

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/coding_agent.git
cd coding_agent

# Install dependencies
bundle install

# Run the setup wizard
rake setup

# Or manually copy the example env file
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

## 🚀 Usage

### Interactive Chat Mode

```bash
# Start a chat session
bin/coding_agent chat

# Or simply
bin/coding_agent
```

During the session, you can:
- Ask questions about your code
- Request file edits and refactoring
- Search for patterns across files
- Run tests and commands
- Perform git operations

**Special commands:**
- `help` - Show available commands
- `clear` - Clear the screen
- `history` - View conversation history
- `stats` - Show agent statistics
- `exit` or `quit` - Exit the agent

### One-Shot Questions

```bash
# Ask a single question
bin/coding_agent ask "What does the User model do?"

# Search for patterns
bin/coding_agent ask "Find all TODO comments in Ruby files"

# Get code explanations
bin/coding_agent ask "Explain the authentication flow"
```

### Configuration

```bash
# View current configuration
bin/coding_agent config

# Run setup wizard
bin/coding_agent setup

# Use custom workspace
bin/coding_agent --workspace /path/to/project chat

# Enable verbose output
bin/coding_agent --verbose chat
```

## 🏗️ Architecture

The coding agent is beautifully architected following Rails patterns:

```
lib/coding_agent/
├── agent.rb              # Core agent with conversation management
├── cli.rb                # Thor-based command-line interface
├── configuration.rb      # Dry::Configurable settings
├── ui.rb                 # Rich terminal UI with TTY
├── concerns/
│   ├── conversational.rb # Conversation history mixin
│   └── toolable.rb       # Tool behavior mixin
└── tools/
    ├── read_file.rb      # File reading
    ├── list_files.rb     # Directory listing
    ├── edit_file.rb      # File editing
    ├── run_shell_command.rb  # Command execution
    ├── search_files.rb   # Pattern searching
    └── git_operations.rb # Git integration
```

### Design Patterns Used

- **ActiveSupport::Concern** - For elegant mixins (Toolable, Conversational)
- **Dependency Injection** - Tools receive UI and workspace dependencies
- **Template Method** - Tools inherit shared behavior, implement specifics
- **Strategy Pattern** - Different tools for different operations
- **Convention over Configuration** - Sensible defaults everywhere
- **Zeitwerk** - Automatic code loading following conventions

## 🔧 Tools Available

The agent has access to these beautiful, sharp tools:

| Tool | Purpose | Safety |
|------|---------|--------|
| **ReadFile** | Read file contents | ✅ Safe |
| **ListFiles** | List directory contents | ✅ Safe |
| **EditFile** | Modify or create files | ⚠️ Confirms |
| **RunShellCommand** | Execute shell commands | ⚠️ Requires confirmation |
| **SearchFiles** | Search for text patterns | ✅ Safe |
| **GitOperations** | Git status, diff, log, etc. | ✅ Safe (read-only ops) |

## ⚙️ Configuration Options

All configuration can be set via environment variables in `.env`:

```bash
# Required
OPENAI_API_KEY=your_key_here

# Optional LLM settings
DEFAULT_MODEL=claude-3-7-sonnet
MAX_TOKENS=4096
TEMPERATURE=0.7

# Optional behavior
WORKSPACE_PATH=/custom/path
AUTO_EXECUTE_SAFE_COMMANDS=false
REQUIRE_CONFIRMATION_FOR_DESTRUCTIVE=true

# Optional UI
COLOR_ENABLED=true
VERBOSE=false
SHOW_TOKEN_USAGE=false

# Optional history
MAX_CONVERSATION_HISTORY=50
SAVE_CONVERSATION_HISTORY=true
HISTORY_FILE_PATH=~/.coding_agent_history.yml
```

## 🎯 Examples

### Code Review
```
You: Review the User model for potential issues

Agent: Let me read the User model...
[Reads file, analyzes, provides detailed feedback]
```

### Refactoring
```
You: Extract the authentication logic into a concern

Agent: I'll create a new concern and refactor the code...
[Creates concern, updates model, shows changes]
```

### Debugging
```
You: Find where CustomerMailer is called

Agent: Searching for CustomerMailer...
[Shows all usages with context]
```

### Git Workflow
```
You: What changed since last commit?

Agent: Let me check git diff...
[Shows beautiful diff summary]
```

## 🧪 Development

```bash
# Run tests
rake test

# Run RuboCop
rake rubocop

# Run both
rake

# Interactive console
rake console
```

## 🎨 The Ruby Way

This coding agent embodies Ruby's philosophy:

- **Programmer happiness** comes first
- **Beautiful code** is a feature, not a luxury
- **Sharp knives** in the hands of capable developers
- **Progressive enhancement** over rigid architecture
- **Integrated systems** beat distributed complexity

Every file, every method, every class is crafted with care. Because code is not just instructions for computers – it's communication between humans.

## 📝 License

MIT License - Use it, learn from it, make it your own.

## 🙏 Acknowledgments

- **Matz** for creating Ruby and prioritizing happiness
- **DHH** for the Rails Doctrine that guides this implementation
- **OpenAI** for Claude, the AI that powers the agent
- **Piotr Murach** for the beautiful TTY ecosystem
- The Ruby community for keeping the joy in programming

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Write beautiful, tested code
4. Submit a pull request

Remember: We optimize for happiness and exalt beautiful code!

---

**Made with ❤️ and Ruby**

*"I hope to see Ruby help every programmer in the world to be productive, and to enjoy programming, and to be happy. That is the primary purpose of Ruby language."* — Yukihiro Matsumoto
