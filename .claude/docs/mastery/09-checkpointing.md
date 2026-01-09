# Checkpointing & Rewind

> Core feature of Claude Code v2.1.1: Automatic state saving and restoration

## Overview

Checkpointing automatically saves state whenever Claude Code modifies files,
allowing you to revert to previous states when problems occur.

## Key Features

### Automatic Checkpoints

```
Checkpoints are automatically created on file modifications:

1. Using Write tool → Checkpoint created
2. Using Edit tool → Checkpoint created
3. File modification via Bash → Checkpoint created
```

### /rewind Command

Command to revert to a previous state.

```bash
# Basic usage
/rewind

# Go to specific checkpoint
/rewind 3

# View list
/rewind --list
```

## Usage Scenarios

### 1. Recovering from Mistakes

```
User: "Create a login page"
Claude: [Implements login page]

User: "Hmm... please redo it"
User: /rewind
→ Restored to pre-implementation state
```

### 2. Trying Different Approaches

```
User: "Implement using approach A"
Claude: [Implements approach A]

User: "I'd like to see approach B too"
User: /rewind
Claude: [Implements approach B]

User: "A was better"
User: /rewind 2
→ Restored to approach A
```

### 3. Experimental Changes

```
User: "Try this refactoring"
Claude: [Major refactoring]

User: "That changed too much, revert"
User: /rewind
→ Restored to pre-refactoring state
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Esc + Esc` | Interrupt response |
| `Ctrl + C` | Cancel current task |
| `/rewind` | Go to previous checkpoint |

## Using with PDCA

### Plan → Do → Check Flow

```
1. Plan: Write planning document

2. Do: Start implementation
   → Checkpoint automatically created

3. Check: Review results
   - Satisfied → Continue
   - Unsatisfied → Revert with /rewind

4. Do (retry): Implement differently
```

### Checkpoint Utilization Strategy

```
Before major changes:
"This is a big change, let me check the checkpoint first."

When problems occur:
"We can go back to the previous state with /rewind."

Experimental attempts:
"Let's try it first, we can /rewind if it doesn't work."
```

## Limitations

### Checkpoint Scope

- **Included**: File system changes
- **Not included**:
  - External API call results
  - Database changes
  - git push
  - Deployments

### Cautions

```
⚠️ The following cannot be reverted with /rewind:

- Commits pushed to remote via git push
- Data saved to database
- Requests sent to external services
- Deleted git branches
```

## Best Practices

### 1. Confirm Before Major Changes

```
User: "Change the entire architecture"
Claude: "This is a big change. The current state will be saved as a checkpoint.
        You can use /rewind to revert if problems occur."
```

### 2. Encourage Experimental Approaches

```
User: "Will this work?"
Claude: "Let's try it. We can /rewind if it doesn't work."
```

### 3. Progress in Steps

```
Break large tasks into steps:
1. Implement step 1 → Verify
2. Implement step 2 → Verify
3. If issues arise, /rewind only that step
```

## Related Commands

| Command | Description |
|---------|-------------|
| `/rewind` | Revert to previous checkpoint |
| `/rewind N` | Go to checkpoint N |
| `/rewind --list` | View checkpoint list |
| `/plan` | Enter plan mode |

## Related Documents

- [Advanced Features](05-advanced.md)
- [Curriculum - Automation](04-curriculum.md)
