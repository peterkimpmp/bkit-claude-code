#!/bin/bash
# scripts/phase2-convention-pre.sh
# Purpose: Check coding style conventions before write
# Hook: PreToolUse (Write|Edit) for phase-2-convention skill

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Check if this is a code file
if [[ "$FILE_PATH" == *.ts ]] || [[ "$FILE_PATH" == *.tsx ]] || [[ "$FILE_PATH" == *.js ]] || [[ "$FILE_PATH" == *.jsx ]]; then
    cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📏 Convention Check:\n- Components: PascalCase\n- Functions: camelCase\n- Constants: UPPER_SNAKE_CASE\n- Files: kebab-case or PascalCase\n\nSee CONVENTIONS.md for full rules"}}
EOF
elif [[ "$FILE_PATH" == *.env* ]]; then
    cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "🔒 Environment Variable Convention:\n- NEXT_PUBLIC_* for client\n- DB_* for database\n- API_* for external APIs\n- AUTH_* for authentication"}}
EOF
else
    echo '{}'
fi
