#!/bin/bash
# scripts/qa-stop.sh
# Purpose: Guide next steps after QA session completion
# Hook: Stop for zero-script-qa skill

set -e

# Output completion guidance
cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "QA Session completed.\\n\\nNext steps:\\n1. Review logs for any missed issues\\n2. Document findings in docs/03-analysis/\\n3. Run /pdca-iterate if issues found need fixing"}}
EOF
