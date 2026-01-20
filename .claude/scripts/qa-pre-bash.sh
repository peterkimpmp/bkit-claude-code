#!/bin/bash
# scripts/qa-pre-bash.sh
# Purpose: Validate bash commands are safe for QA testing
# Hook: PreToolUse (Bash) for zero-script-qa skill

set -e

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# List of destructive patterns to block
DESTRUCTIVE_PATTERNS=(
    "rm -rf"
    "rm -r"
    "DROP TABLE"
    "DROP DATABASE"
    "DELETE FROM"
    "TRUNCATE"
    "> /dev/"
    "mkfs"
    "dd if="
    ":(){ :|:& };:"
)

# Check for destructive patterns
for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
    if [[ "$COMMAND" == *"$pattern"* ]]; then
        cat << EOF
{"decision": "block", "reason": "Destructive command detected: '$pattern'. QA testing should not include destructive operations."}
EOF
        exit 0
    fi
done

# Allow safe commands with context
cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "QA Testing: Command validated as safe for testing environment."}}
EOF
