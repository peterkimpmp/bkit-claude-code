#!/bin/bash
# scripts/gap-detector-post.sh
# Purpose: Guide next steps after Gap Analysis completion
# Hook: PostToolUse (Write) for gap-detector agent

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Check if this is an analysis report file
if [[ "$FILE_PATH" == *".analysis.md" ]] || [[ "$FILE_PATH" == *"-analysis.md" ]]; then
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "Gap Analysis completed.\n\nIf match rate is below 70%, run /pdca-iterate to automatically improve the implementation."}}
EOF
else
    echo '{}'
fi
