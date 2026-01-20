#!/bin/bash
# scripts/pdca-post-write.sh
# Purpose: Guide next steps after Write operation
# Hook: PostToolUse (Write) for bkit-rules skill

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Skip non-source files
if [[ ! "$FILE_PATH" == src/* ]] && \
   [[ ! "$FILE_PATH" == lib/* ]] && \
   [[ ! "$FILE_PATH" == app/* ]] && \
   [[ ! "$FILE_PATH" == components/* ]] && \
   [[ ! "$FILE_PATH" == pages/* ]]; then
    echo '{}'
    exit 0
fi

# Extract feature name
FEATURE=$(echo "$FILE_PATH" | sed -n 's/.*\/\([^\/]*\)\/[^\/]*$/\1/p')
if [ -z "$FEATURE" ]; then
    FEATURE=$(basename "$(dirname "$FILE_PATH")")
fi

# Skip common non-feature directories
if [[ "$FEATURE" == "src" ]] || \
   [[ "$FEATURE" == "lib" ]] || \
   [[ "$FEATURE" == "app" ]] || \
   [[ "$FEATURE" == "components" ]] || \
   [[ "$FEATURE" == "pages" ]] || \
   [[ "$FEATURE" == "." ]]; then
    echo '{}'
    exit 0
fi

# Check if design doc exists for gap analysis suggestion
DESIGN_DOC="docs/02-design/features/${FEATURE}.design.md"
DESIGN_DOC_ALT="docs/02-design/${FEATURE}.design.md"

if [ -f "$DESIGN_DOC" ] || [ -f "$DESIGN_DOC_ALT" ]; then
    cat << EOF
{"hookSpecificOutput": {"additionalContext": "Write completed: ${FILE_PATH}\n\nWhen implementation is finished, run /pdca-analyze ${FEATURE} to verify design-implementation alignment."}}
EOF
else
    echo '{}'
fi
