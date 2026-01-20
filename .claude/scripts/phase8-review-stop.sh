#!/bin/bash
# scripts/phase8-review-stop.sh
# Purpose: Generate quality review summary after review phase
# Hook: Stop for phase-8-review skill

set -e

cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📋 Code Review Phase completed.\n\nReview Summary:\n1. Check docs/03-analysis/ for review reports\n2. Ensure all refactoring items are addressed\n3. Run /pdca-analyze for final gap analysis\n\nNext: Phase 9 (Deployment) when review passes"}}
EOF
