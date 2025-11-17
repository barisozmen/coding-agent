# Quick Reference: Improved Coding Agent

## New Features at a Glance

### 1. File Creation Made Easy

```ruby
# Create a new file (old way: not supported)
# Create a new file (new way):
edit_file(
  path: "new_feature.rb",
  old_str: "",  # Empty string = create new file
  new_str: "# Your code here"
)
```

**The agent will automatically:**
- Create parent directories if needed
- Prevent overwriting existing files
- Give clear errors with hints if something goes wrong

### 2. Token Usage Tracking

```bash
# During chat session:
> stats

# Shows:
# Total tokens: 2,450
# Input tokens: 1,500
# Output tokens: 950
```

**Enable real-time display:**
```ruby
# In your configuration
Configuration.config.show_token_usage = true
```

### 3. Better Tool Descriptions

All tools now tell the LLM when to use them:

| Tool | Auto-discovers | Best For |
|------|----------------|----------|
| `read_file` | Code analysis | Understanding file contents before editing |
| `list_files` | Project exploration | Finding what files exist |
| `edit_file` | Code changes | Creating or modifying files |
| `search_files` | Code search | Finding where features are implemented |
| `run_shell_command` | Testing | Running tests, builds, git commands |
| `git_operations` | Version control | Tracking changes, viewing history |

### 4. Smart Error Messages

**Before:**
```
Error: File not found: config.rb
```

**After:**
```
Error: File not found: config.rb
Hint: Use list_files to see available files, or check if the path is correct
```

The LLM can now self-correct without user help!

### 5. Guided Workflows

The agent now knows these patterns:

**Understanding a project:**
```
list_files → read_file (key files) → search_files (patterns)
```

**Making changes:**
```
read_file → edit_file → read_file (verify) → run_shell_command (test)
```

**Creating new files:**
```
edit_file (with old_str='') → read_file (verify) → run_shell_command (test)
```

## Configuration Options

```ruby
# ~/.coding_agent.yml or environment variables

# Show tokens after each response
show_token_usage: true

# Maximum conversation history (default: 50)
max_conversation_history: 50

# Auto-run safe commands (default: false)
auto_execute_safe_commands: true

# Save conversation history (default: true)
save_conversation_history: true
```

## CLI Commands

```bash
# Start interactive session
coding_agent chat

# Ask single question
coding_agent ask "What does the User model do?"

# Show configuration
coding_agent config

# Show version
coding_agent version

# Interactive setup
coding_agent setup
```

## During Chat Session

```bash
# Available commands
help      # Show help message
clear     # Clear screen
history   # Show conversation history
stats     # Show agent statistics (includes tokens!)
exit      # Exit the agent
```

## Best Practices for Users

1. **Let the agent explore**: Ask "understand this codebase" instead of explaining everything
2. **Trust the tools**: The agent knows when to use list_files, read_file, etc.
3. **Ask for verification**: "Make the change and verify it works" triggers read→edit→verify→test
4. **Monitor tokens**: Use `stats` command to check token usage in long sessions

## Example Interactions

### Creating a New Feature

**You:** "Create a new User authentication module"

**Agent will:**
1. `list_files` to understand project structure
2. `search_files` for existing auth patterns
3. `edit_file` with `old_str=''` to create new files
4. `read_file` to verify creation
5. `run_shell_command` to run tests
6. `git_operations` to show what changed

### Debugging an Issue

**You:** "Why is the login failing?"

**Agent will:**
1. `search_files` for "login" to find relevant code
2. `read_file` on login-related files
3. `git_operations` with 'diff' to see recent changes
4. Analyze and explain the issue
5. Suggest fixes with `edit_file`

### Refactoring Code

**You:** "Refactor the payment processing to use a service object"

**Agent will:**
1. `read_file` on current payment code
2. `search_files` for similar service patterns
3. `edit_file` to extract service object
4. `edit_file` to update callers
5. `run_shell_command` to run tests
6. `read_file` to verify changes

## Troubleshooting

### "Too many tokens"
- Check `stats` to see token usage
- History auto-trims after 50 messages
- Use `clear` to start fresh if needed

### "File creation failed"
- Ensure you're using `old_str=""` (empty string)
- Check that file doesn't already exist
- Verify parent directory path is correct

### "String not found in file"
- Agent will retry with more context automatically
- Errors now include hints for self-correction
- If stuck, ask to "read the file first"

## What's Different from the Go Implementation?

| Feature | Go Version | Ruby Version |
|---------|------------|--------------|
| File editing | String replacement | ✅ Same |
| File creation | `old_str=""` | ✅ Same |
| Token tracking | Built-in | ✅ Added |
| Tool discovery | Transparent | ✅ Enhanced |
| Error hints | Basic | ✅ Comprehensive |
| System prompt | Minimal | ✅ Detailed |
| Context trimming | None (stateless) | ✅ Smart preservation |

## Performance Tips

1. **Token efficiency**: Clear descriptions = fewer wasted tokens
2. **Autonomous operation**: Better error hints = less user intervention
3. **Smart history**: Keeps system prompts while trimming old messages
4. **Batch operations**: Agent can chain multiple tools autonomously

---

**Need more details?** See [IMPROVEMENTS.md](IMPROVEMENTS.md) for technical documentation.
