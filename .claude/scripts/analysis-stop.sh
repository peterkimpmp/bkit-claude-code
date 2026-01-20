#!/bin/bash
# scripts/analysis-stop.sh
# Purpose: Guide report generation after gap analysis
# Hook: Stop for analysis-patterns skill

set -e

cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📊 Gap Analysis completed.\n\nNext steps:\n1. Save report to docs/03-analysis/\n2. If match rate < 70%: Run /pdca-iterate for auto-fix\n3. If match rate >= 90%: Proceed to next phase\n4. Update design doc if implementation differs intentionally"}}
EOF
