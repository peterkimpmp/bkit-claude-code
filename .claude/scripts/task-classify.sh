#!/bin/bash
# scripts/task-classify.sh
# Purpose: Classify task type and apply appropriate PDCA guidance
# Hook: PreToolUse (Write|Edit) for task-classification skill

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')

# Calculate content size (rough estimation)
CONTENT_LENGTH=${#CONTENT}

# Classification thresholds
QUICK_FIX_THRESHOLD=50       # < 50 chars = typo, comment fix
MINOR_CHANGE_THRESHOLD=200   # < 200 chars = small fix
FEATURE_THRESHOLD=1000       # < 1000 chars = single feature
# > 1000 chars = Major Feature

# Skip non-source files
if [[ ! "$FILE_PATH" == src/* ]] && \
   [[ ! "$FILE_PATH" == lib/* ]] && \
   [[ ! "$FILE_PATH" == app/* ]] && \
   [[ ! "$FILE_PATH" == components/* ]] && \
   [[ ! "$FILE_PATH" == pages/* ]]; then
    echo '{}'
    exit 0
fi

if [ "$CONTENT_LENGTH" -lt "$QUICK_FIX_THRESHOLD" ]; then
    # Quick Fix - no PDCA needed
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "Task Classification: Quick Fix (${CONTENT_LENGTH} chars). No PDCA documentation required."}}
EOF
elif [ "$CONTENT_LENGTH" -lt "$MINOR_CHANGE_THRESHOLD" ]; then
    # Minor Change - optional PDCA
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "Task Classification: Minor Change (${CONTENT_LENGTH} chars). Check /pdca-status if needed."}}
EOF
elif [ "$CONTENT_LENGTH" -lt "$FEATURE_THRESHOLD" ]; then
    # Feature - PDCA recommended
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "Task Classification: Feature (${CONTENT_LENGTH} chars). Design documentation recommended.\n\nRun /pdca-plan [feature-name] or /pdca-design [feature-name] first."}}
EOF
else
    # Major Feature - PDCA required
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "Task Classification: Major Feature (${CONTENT_LENGTH} chars). PDCA documentation is essential.\n\nStart with /pdca-plan [feature-name] to begin planning."}}
EOF
fi
