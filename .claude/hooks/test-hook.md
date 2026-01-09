# Hook Testing Guide

> Test to verify that your Hooks are working properly.

## Verify Test Environment

Check current Hook settings:
```bash
cat .claude/settings.local.json
```

## Exercise 1: PreToolUse Hook Test

### Test Method
1. Request Claude to create a file
2. Verify that the Hook triggers and shows a design verification message

### Test Command
```
Ask Claude: "Create a test-file.txt file"
```

### Expected Result
- Design document verification reminder displayed before Write tool use
- Checkpoint operation verified before file creation

---

## Exercise 2: PostToolUse Hook Test

### Test Method
1. Request Claude to git commit
2. Verify PDCA status update message after commit

### Test Command
```
Ask Claude: "Commit the current changes"
```

### Expected Result
- PDCA status check reminder displayed after commit completion

---

## Exercise 3: Writing Custom Hooks

### Goal
Add a type check reminder when writing `.ts` files.

### TODO: Complete the Hook configuration below

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write(*.ts)",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "/* Write your reminder message here */"
          }
        ]
      }
    ]
  }
}
```

### Hints
- Check if type definitions are clear
- Guide to avoid using `any` type
- Recommend reusing existing types

---

## Debugging

### When Hooks Don't Work

1. **Check settings file location**
   ```
   .claude/settings.local.json (local settings)
   ~/.claude/settings.json (global settings)
   ```

2. **Validate JSON syntax**
   ```bash
   cat .claude/settings.local.json | jq .
   ```

3. **Check matcher patterns**
   - `Write` - All file writes
   - `Write(*.ts)` - Only .ts files
   - `Bash(git commit:*)` - git commit commands

### Check Logs
Use `--verbose` option when running Claude Code to verify Hook triggers

---

## References

- [HOOKS-GUIDE.md](./HOOKS-GUIDE.md) - Hook Basic Guide
- [Claude Code Hooks Documentation](https://docs.anthropic.com/claude-code/hooks)
