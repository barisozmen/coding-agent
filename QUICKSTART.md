# 🚀 Quickstart Guide

Get your beautiful coding agent running in 5 minutes!

## Prerequisites

- Ruby 3.2 or higher
- Bundler gem
- An OpenAI API key ([get one here](https://console.OpenAI.com/))

## Installation

### Step 1: Install Dependencies

```bash
bundle install
```

This installs all the beautiful gems:
- 🎨 TTY ecosystem (7 gems for gorgeous terminal UI)
- 🤖 RubyLLM (AI integration)
- 💎 ActiveSupport (Rails' sharp knives)
- ⚙️ Configuration gems (Dry, Dotenv, Zeitwerk)

### Step 2: Configure

Choose your path:

#### Option A: Setup Wizard (Recommended)

```bash
rake setup
```

This will:
1. Create `.env` file
2. Prompt for your API key
3. Configure preferences interactively
4. Test the connection

#### Option B: Manual Setup

```bash
# Copy the example file
cp .env.example .env

# Edit with your favorite editor
vim .env  # or nano, code, etc.

# Add your API key
OPENAI_API_KEY=your_key_here
```

### Step 3: Run!

```bash
# Interactive mode
bin/coding_agent chat

# Or simply
bin/coding_agent

# One-shot questions
bin/coding_agent ask "What files are in this project?"
```

## First Commands to Try

Once you're in the chat:

```
# Get help
➜ help

# See your workspace
➜ list the files in this directory

# Analyze code
➜ read the Gemfile and explain the gems

# Search
➜ find all TODO comments in Ruby files

# Check git status
➜ what's the current git status?

# Get stats
➜ stats

# View history
➜ history
```

## Configuration Options

Edit `.env` to customize:

```bash
# Required
OPENAI_API_KEY=sk-ant-...

# Optional: Change model
DEFAULT_MODEL=claude-3-7-sonnet

# Optional: Auto-run safe commands
AUTO_EXECUTE_SAFE_COMMANDS=true

# Optional: Enable detailed output
VERBOSE=true
```

## Verify Installation

Run the test suite:

```bash
rake test
```

Check code style:

```bash
rake rubocop
```

View configuration:

```bash
bin/coding_agent config
```

## Common Issues

### "API key not set"
- Make sure `.env` exists
- Verify `OPENAI_API_KEY` is set
- No quotes needed around the key

### "Command not found"
```bash
# Make executable
chmod +x bin/coding_agent

# Or run via Ruby
ruby -Ilib bin/coding_agent
```

### Gems won't install
```bash
# Update Bundler
gem install bundler

# Clean and reinstall
bundle clean --force
bundle install
```

### Ruby version too old
```bash
# Check version
ruby -v

# Update Ruby via rbenv, rvm, or asdf
rbenv install 3.2.0
rbenv global 3.2.0
```

## What's Next?

- 📖 Read [README.md](README.md) for comprehensive guide
- 🏛️ Check [ARCHITECTURE.md](ARCHITECTURE.md) to understand the design
- 📚 Browse [examples/interactive_session.md](examples/interactive_session.md) for inspiration
- 🤝 Read [CONTRIBUTING.md](CONTRIBUTING.md) to contribute

## Quick Reference

### CLI Commands
```bash
bin/coding_agent chat              # Interactive mode
bin/coding_agent ask "question"    # One-shot question
bin/coding_agent config            # Show configuration
bin/coding_agent setup             # Setup wizard
bin/coding_agent version           # Version info
bin/coding_agent --help            # All options
```

### Interactive Commands
```
help      # Show available commands
clear     # Clear screen
history   # Show conversation
stats     # Show statistics
exit      # Exit (or quit, q)
```

### Rake Tasks
```bash
rake test       # Run tests
rake rubocop    # Check style
rake console    # Interactive console
rake setup      # Setup environment
```

## Tips

1. **Start with simple questions** to understand the agent's capabilities
2. **Be specific** in your requests for better results
3. **Use special commands** (help, stats) to explore features
4. **Check history** to review past conversations
5. **Read the docs** - they're actually useful and well-written!

## Support

Having issues? Check:
- [README.md](README.md) - Full documentation
- [GitHub Issues](https://github.com/yourusername/coding_agent/issues) - Known issues
- The source code - it's beautiful and readable!

---

**Enjoy your beautiful coding agent!** 🎨✨

*Remember: This tool optimizes for programmer happiness. If you're not smiling yet, give it another try!*
