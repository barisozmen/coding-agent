# Coding Agent Improvements

Based on the Go implementation at https://ampcode.com/how-to-build-an-agent

## Summary

This document outlines the improvements made to the Ruby coding agent based on learnings from a production Go implementation. The changes focus on making the agent more autonomous, token-efficient, and LLM-friendly.

## Key Improvements

### 1. Enhanced File Creation (EditFile Tool)

**What Changed:**
- The `edit_file` tool now supports creating new files using an empty string for `old_str`
- This matches the Go implementation's elegant pattern: `edit_file(path: "new.rb", old_str: "", new_str: "file content")`
- Automatically creates parent directories as needed

**Why It Matters:**
- Simplifies the tool interface - one tool for both creating and editing
- Makes it more intuitive for the LLM to discover file creation capability
- Reduces the number of tools the LLM needs to manage

**Code Location:** `lib/coding_agent/tools/edit_file.rb:47-68`

### 2. Token Usage Tracking

**What Changed:**
- Added comprehensive token tracking for input, output, and total tokens
- Displays token usage in stats command and at session end
- Optional real-time token display during conversations

**Why It Matters:**
- Critical for managing costs in production
- Helps identify when conversations are getting too long
- Aligns with the Go implementation's "stateless server" model where token management is essential

**Code Locations:**
- Agent initialization: `lib/coding_agent/agent.rb:28`
- Token tracking: `lib/coding_agent/agent.rb:221-231`
- Display methods: `lib/coding_agent/agent.rb:212-220, 233-235`

### 3. Transparent Tool Invocation

**What Changed:**
- Rewrote all tool descriptions to be self-discoverable
- Added usage hints and examples directly in descriptions
- Emphasized when tools should be used automatically

**Examples:**
- ReadFile: "Automatically called when analyzing code structure or debugging"
- ListFiles: "Essential for understanding project layout before making changes"
- SearchFiles: "Perfect for finding where functions are defined"

**Why It Matters:**
- The Go implementation showed that LLMs can infer when to use tools without explicit instructions
- Better descriptions = fewer wasted tokens on explanations
- More autonomous behavior = better user experience

**Code Locations:**
- `lib/coding_agent/tools/read_file.rb:13-16`
- `lib/coding_agent/tools/list_files.rb:14-18`
- `lib/coding_agent/tools/edit_file.rb:14-18`
- `lib/coding_agent/tools/search_files.rb:13-17`
- `lib/coding_agent/tools/run_shell_command.rb:14-18`
- `lib/coding_agent/tools/git_operations.rb:13-17`

### 4. Smart Conversation Trimming

**What Changed:**
- Implemented intelligent history trimming that preserves critical context
- Keeps first 2 messages (system prompts) and most recent exchanges
- Added token estimation method for future optimization

**Why It Matters:**
- Prevents context window overflow in long sessions
- Maintains conversation coherence by preserving initial instructions
- Supports the "stateless conversation" model from the Go implementation

**Code Location:** `lib/coding_agent/concerns/conversational.rb:51-63`

### 5. System Prompt for Tool Guidance

**What Changed:**
- Added a comprehensive system prompt that teaches the LLM best practices
- Includes tool usage patterns (e.g., "list_files → read_file → edit_file")
- Emphasizes verification and testing

**System Prompt Highlights:**
```
CORE PRINCIPLES:
1. Explore before acting
2. Search to understand
3. Verify changes
4. Test your work
5. Be transparent

TOOL USAGE PATTERNS:
- To understand: list_files → read_file → search_files
- To modify: read_file → edit_file → read_file (verify) → run_shell_command (test)
- To create: edit_file with old_str='' 
```

**Why It Matters:**
- Guides the LLM toward productive workflows
- Reduces trial-and-error in tool usage
- Establishes quality standards (always verify changes, run tests)

**Code Location:** `lib/coding_agent/agent.rb:237-266`

### 6. LLM-Friendly Error Messages

**What Changed:**
- All error responses now include a "hint" field
- Hints guide the LLM toward the correct action
- Error messages reference related tools

**Examples:**
- File not found → "Use list_files to see available files"
- Directory instead of file → "Use list_files(path: '#{path}') to see what's inside"
- Edit string not unique → "Include more surrounding context to make old_str unique"

**Why It Matters:**
- The LLM can self-correct without user intervention
- Reduces back-and-forth in conversations
- Makes the agent more autonomous

**Code Locations:**
- `lib/coding_agent/tools/read_file.rb:27-30, 34-37, 53-56`
- `lib/coding_agent/tools/list_files.rb:29-32, 36-39, 56-59`
- `lib/coding_agent/tools/edit_file.rb:39-41, 50-53, 73-75, 82-85, 92-95`

## Implementation Philosophy

These changes embody key principles from the Go implementation:

### 1. "An LLM, a Loop, and Enough Tokens"
- Simple architecture focused on core functionality
- Token management as a first-class concern
- Stateless conversations that grow with context

### 2. String Replacement Over Line Numbers
- The `edit_file` tool uses string matching, not line numbers
- More intuitive for LLMs (Claude is excellent at string manipulation)
- Less brittle than line-based editing

### 3. Transparent Tool Discovery
- Tools are discovered through description, not instruction
- The LLM infers when to use tools based on their descriptions
- Reduces prompt engineering burden

### 4. Sharp Knives Philosophy
- Provide powerful tools with safety checks
- Trust the AI but verify paths and inputs
- Clear error messages guide toward correct usage

## Migration Guide

### For Users

No breaking changes! The improvements are backward compatible.

**New Capabilities:**
1. Create files using: `edit_file(path: "new.rb", old_str: "", new_str: "content")`
2. Track token usage with the `stats` command
3. Enable real-time token display: Set `show_token_usage: true` in config

### For Developers

**Testing File Creation:**
```ruby
# Old way: N/A (couldn't create files)
# New way:
agent.ask("Create a new file hello.rb with a hello world program")
# Will use: edit_file(path: "hello.rb", old_str: "", new_str: "puts 'Hello'")
```

**Monitoring Token Usage:**
```ruby
agent.token_usage  # => { input: 1234, output: 567, total: 1801 }
```

## Performance Characteristics

### Token Efficiency
- **Before:** No token tracking, could hit context limits unexpectedly
- **After:** Active tracking with estimated ~4 chars/token ratio

### Tool Discovery
- **Before:** Generic descriptions requiring user to explain tool usage
- **After:** Self-documenting tools that guide autonomous usage

### Error Recovery
- **Before:** Errors required user intervention
- **After:** LLM can self-correct using hints in error messages

## Future Improvements

Based on the Go implementation, potential next steps:

1. **Line-by-line streaming**: Stream tool execution output for long-running commands
2. **Parallel tool execution**: Execute independent tools concurrently
3. **Smart context compression**: Summarize old messages instead of dropping them
4. **Tool usage analytics**: Track which tools are most effective
5. **Adaptive token budgets**: Dynamically adjust history retention based on available tokens

## Testing

All improvements have been tested for:
- ✅ Backward compatibility
- ✅ RuboCop compliance (with acceptable metric overrides for display methods)
- ✅ Integration with RubyLLM gem
- ✅ Error handling and edge cases

## References

- Go Implementation: https://ampcode.com/how-to-build-an-agent
- Design Philosophy: "Convention over Configuration"
- Ruby Best Practices: "Beautiful abstractions for programmer happiness"

---

*Generated as part of the coding agent improvement initiative*
*Based on production lessons from ampcode.com*
