# Example Interactive Session

Here's what a beautiful interaction with the Coding Agent looks like:

## Starting the Agent

```bash
$ bin/coding_agent chat

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              🤖  Coding Agent  🤖                         ║
║                                                           ║
║          Your AI Pair Programmer                          ║
║          Optimized for Programmer Happiness               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  I'm your AI pair programmer, ready to help with your code.    │
│  Type 'help' for commands, 'exit' to quit.                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

────────────────────────────────────────────────────────────────────
```

## Example 1: Code Review

```
➜ Review the Agent class and suggest improvements

AI:
  Read lib/coding_agent/agent.rb (150 lines)

I've reviewed the Agent class. Here are my observations:

**Strengths:**
- Beautiful use of concerns (Conversational) for separation of concerns
- Elegant dependency injection for UI and tools
- Clear separation between interactive and one-shot modes
- Good error handling with user-friendly messages

**Suggestions for improvement:**
1. Consider extracting command handling to a Commands concern
2. The display methods could be moved to a Presenter class
3. Add a configuration option for customizing the prompt symbol

Would you like me to implement any of these improvements?
────────────────────────────────────────────────────────────────────
```

## Example 2: Adding a Feature

```
➜ Add a new tool that can check Ruby syntax without executing code

AI:
  Created lib/coding_agent/tools/syntax_checker.rb

I've created a new SyntaxChecker tool! Here's what it does:

- Takes a file path or Ruby code string
- Uses Ruby's built-in parser to check syntax
- Returns detailed error messages if syntax is invalid
- Works safely without executing any code

The tool follows the project's conventions:
✅ Includes Toolable concern
✅ Beautiful error handling
✅ User feedback via UI
✅ Comprehensive documentation

Would you like me to add tests for this new tool?
────────────────────────────────────────────────────────────────────
```

## Example 3: Debugging

```
➜ Why is my code failing? Find all references to 'api_key'

AI:
  Found 8 matches for 'api_key'

Here are all references to 'api_key' in your codebase:

1. lib/coding_agent/configuration.rb:10
   setting :OPENAI_API_KEY, default: ENV.fetch("OPENAI_API_KEY", nil)

2. lib/coding_agent/configuration.rb:24
   errors << "OPENAI_API_KEY is not set" if config.OPENAI_API_KEY.blank?

3. lib/coding_agent.rb:17
   config.OPENAI_API_KEY = Configuration.config.OPENAI_API_KEY

4. .env.example:2
   OPENAI_API_KEY=your_api_key_here

The issue is likely that your .env file doesn't have the API key set.
Run `bin/coding_agent setup` to configure it interactively.
────────────────────────────────────────────────────────────────────
```

## Example 4: Git Operations

```
➜ What changed since yesterday?

AI:
  Git log completed

Here's what changed in the last 24 hours:

**Commits:**
- e0779c3 Add SearchFiles tool for pattern matching (2 hours ago)
- a1b2c3d Refactor UI for better spinner support (5 hours ago)
- d4e5f6g Update documentation (1 day ago)

**File Changes:**
M lib/coding_agent/tools/search_files.rb (added)
M lib/coding_agent/ui.rb (modified)
M README.md (modified)

Would you like to see the detailed diff?
────────────────────────────────────────────────────────────────────
```

## Example 5: Refactoring

```
➜ Extract the validation logic from Configuration into a validator class

AI:
  Created lib/coding_agent/configuration_validator.rb
  Edited lib/coding_agent/configuration.rb

I've refactored the validation logic! Here's what I did:

**New ConfigurationValidator class:**
- Extracted all validation logic
- Added descriptive error messages
- Made it easy to add new validations
- Follows Single Responsibility Principle

**Updated Configuration:**
- Now delegates to ConfigurationValidator
- Cleaner, more focused on settings
- Maintains backward compatibility

The code is now more maintainable and testable. Want me to add
tests for the new validator?
────────────────────────────────────────────────────────────────────
```

## Special Commands

```
➜ help

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                      Available Commands                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

┌─────────────────┬─────────────────────────────────────────────┐
│ Command         │ Description                                 │
├─────────────────┼─────────────────────────────────────────────┤
│ help            │ Show this help message                      │
│ clear           │ Clear the screen                            │
│ history         │ Show conversation history                   │
│ stats           │ Show agent statistics                       │
│ exit/quit/q     │ Exit the agent                              │
└─────────────────┴─────────────────────────────────────────────┘

➜ stats

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                      Agent Statistics                         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

┌──────────────────────────┬────────────────────────────────────┐
│ Metric                   │ Value                              │
├──────────────────────────┼────────────────────────────────────┤
│ Total messages           │ 24                                 │
│ User messages            │ 12                                 │
│ Agent messages           │ 12                                 │
│ Tools available          │ 6                                  │
│ Workspace                │ /Users/dev/my_project              │
└──────────────────────────┴────────────────────────────────────┘
```

## One-Shot Mode

For quick queries without entering interactive mode:

```bash
$ bin/coding_agent ask "How many lines of Ruby code are in this project?"

AI:
  Listed 16 items in lib
  Read lib/coding_agent.rb (25 lines)
  [... reads all files ...]

Your project has approximately 847 lines of Ruby code across 16 files:

**Breakdown by directory:**
- lib/coding_agent/: 623 lines
- test/: 142 lines
- bin/: 12 lines
- lib/: 70 lines

**Largest files:**
1. lib/coding_agent/agent.rb (150 lines)
2. lib/coding_agent/ui.rb (142 lines)
3. lib/coding_agent/cli.rb (135 lines)
```

---

## The Beauty of the Experience

Notice how every interaction:

- ✨ Provides **clear, colorful** feedback
- 🎯 Offers **specific, actionable** information
- 💡 Suggests **next steps** naturally
- 🛡️ Handles **errors gracefully**
- 😊 Makes you **smile** while coding

That's programmer happiness in action!
