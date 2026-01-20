#!/bin/bash
# scripts/design-validator-pre.sh
# Purpose: Auto-detect new design files and trigger validation
# Hook: PreToolUse (Write) for design-validator agent

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Check if file is a design document
if [[ "$FILE_PATH" == *"docs/02-design/"* ]] && [[ "$FILE_PATH" == *.md ]]; then
    cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📋 Design Document Detected!\n\nValidation checklist:\n- [ ] Overview section\n- [ ] Requirements section\n- [ ] Architecture diagram\n- [ ] Data model\n- [ ] API specification\n- [ ] Error handling\n\nAfter writing, run validation to check completeness."}}
EOF
else
    echo '{}'
fi
