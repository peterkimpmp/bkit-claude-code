#!/bin/bash
# scripts/phase6-ui-post.sh
# Purpose: Verify layer separation after UI implementation
# Hook: PostToolUse (Write) for phase-6-ui-integration skill

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Check if file is in UI layer
if [[ "$FILE_PATH" == *"/pages/"* ]] || [[ "$FILE_PATH" == *"/components/"* ]] || [[ "$FILE_PATH" == *"/features/"* ]]; then
    cat << 'EOF'
{"hookSpecificOutput": {"additionalContext": "🔍 UI Layer Check:\n- Components should use hooks, not direct fetch\n- Follow: Components → hooks → services → apiClient\n- No business logic in UI components"}}
EOF
elif [[ "$FILE_PATH" == *"/services/"* ]]; then
    cat << 'EOF'
{"hookSpecificOutput": {"additionalContext": "🔍 Service Layer Check:\n- Services should only call apiClient\n- No direct DOM manipulation\n- Keep domain logic isolated"}}
EOF
else
    echo '{}'
fi
