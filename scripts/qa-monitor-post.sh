#!/bin/bash
# scripts/qa-monitor-post.sh
# Purpose: Trigger pdca-iterator on critical issues
# Hook: PostToolUse (Write) for qa-monitor agent

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // ""')

# Check if this is a QA report
if [[ "$FILE_PATH" == *"docs/03-analysis/"* ]] && [[ "$FILE_PATH" == *qa* ]]; then
    # Check for critical issues in the content
    if echo "$CONTENT" | grep -qE '🔴 Critical|Critical.*[1-9]'; then
        cat << 'EOF'
{"hookSpecificOutput": {"additionalContext": "🚨 Critical issues detected in QA report!\n\nRecommended actions:\n1. Fix critical issues immediately\n2. Run /pdca-iterate for auto-fix\n3. Re-run Zero Script QA after fixes"}}
EOF
    else
        cat << 'EOF'
{"hookSpecificOutput": {"additionalContext": "✅ QA Report saved. No critical issues detected.\n\nNext steps:\n1. Review warning items if any\n2. Proceed to next phase when ready"}}
EOF
    fi
else
    echo '{}'
fi
