#!/bin/bash
# scripts/phase4-api-stop.sh
# Purpose: Guide Zero Script QA after API implementation
# Hook: Stop for phase-4-api skill

set -e

cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "🎯 API Phase completed.\n\nNext steps:\n1. Run Zero Script QA to validate APIs: /zero-script-qa\n2. Ensure all endpoints return proper JSON logs\n3. Proceed to Phase 5 (Design System) after QA passes"}}
EOF
