#!/bin/bash
# scripts/pdca-pre-write.sh
# Purpose: Detect PDCA phase and provide guidance before Write/Edit
# Hook: PreToolUse (Write|Edit) for bkit-rules skill

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Skip non-source files (only monitor actual implementation code)
if [[ ! "$FILE_PATH" == src/* ]] && \
   [[ ! "$FILE_PATH" == lib/* ]] && \
   [[ ! "$FILE_PATH" == app/* ]] && \
   [[ ! "$FILE_PATH" == components/* ]] && \
   [[ ! "$FILE_PATH" == pages/* ]]; then
    echo '{}'
    exit 0
fi

# Extract feature name from path
# Try to get parent directory name as feature
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

# Check for design document
DESIGN_DOC="docs/02-design/features/${FEATURE}.design.md"
DESIGN_DOC_ALT="docs/02-design/${FEATURE}.design.md"
PLAN_DOC="docs/01-plan/features/${FEATURE}.plan.md"
PLAN_DOC_ALT="docs/01-plan/${FEATURE}.plan.md"

# Check if design document exists
if [ -f "$DESIGN_DOC" ] || [ -f "$DESIGN_DOC_ALT" ]; then
    FOUND_DESIGN=$DESIGN_DOC
    [ -f "$DESIGN_DOC_ALT" ] && FOUND_DESIGN=$DESIGN_DOC_ALT

    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "PDCA Notice: This file belongs to the '${FEATURE}' feature.\n\nDesign doc: ${FOUND_DESIGN}\n\nRefer to the design document during implementation. After completion, run /pdca-analyze ${FEATURE} for Gap Analysis."}}
EOF
elif [ -f "$PLAN_DOC" ] || [ -f "$PLAN_DOC_ALT" ]; then
    FOUND_PLAN=$PLAN_DOC
    [ -f "$PLAN_DOC_ALT" ] && FOUND_PLAN=$PLAN_DOC_ALT

    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "PDCA Warning: Plan document exists for '${FEATURE}' but no design document found.\n\nRecommended: Run /pdca-design ${FEATURE} to create design document first."}}
EOF
else
    # No PDCA docs - allow but don't add context for quick fixes
    echo '{}'
fi
