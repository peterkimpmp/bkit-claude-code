#!/bin/bash
# scripts/phase5-design-post.sh
# Purpose: Verify design token consistency after component write
# Hook: PostToolUse (Write) for phase-5-design-system skill

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // ""')

# Check if file is a component
if [[ "$FILE_PATH" == *"/components/"* ]] || [[ "$FILE_PATH" == *"/ui/"* ]]; then
    # Check for hardcoded colors (common anti-pattern)
    if echo "$CONTENT" | grep -qE '#[0-9a-fA-F]{3,6}|rgb\(|rgba\('; then
        cat << 'EOF'
{"hookSpecificOutput": {"additionalContext": "⚠️ Design Token Check:\nHardcoded colors detected!\n\nUse CSS variables instead:\n- var(--primary)\n- var(--background)\n- var(--foreground)\n\nSee globals.css for available tokens"}}
EOF
    else
        cat << 'EOF'
{"hookSpecificOutput": {"additionalContext": "✅ Design Token Check: Component uses design tokens correctly"}}
EOF
    fi
else
    echo '{}'
fi
