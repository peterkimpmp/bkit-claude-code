#!/bin/bash
# bkit Vibecoding Kit - SessionStart Hook
# .claude folder installation users (command type)
# Plugin uses UserPromptSubmit, so not synced with this file

cat << 'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Welcome to bkit Vibecoding Kit!\n\n## PDCA Core Rules (Always Apply)\n- New feature request → Check/create design doc first\n- Don't guess → Check docs → Ask user\n- After implementation → Suggest Gap analysis\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\nUse AskUserQuestion tool to ask:\n\n**Question**: \"What kind of help do you need?\"\n**Header**: \"Help Type\"\n**Options**:\n1. bkit Introduction - Learn what bkit is\n2. Learn Development Process - 9-stage pipeline learning\n3. Learn Claude Code - Setup and usage\n4. Continue Work - Resume previous work\n5. Start New Project - Setup from scratch\n\n**Actions by Selection**:\n- Option 1 → Explain bkit features (PDCA, Pipeline, Levels, Agents, Zero Script QA)\n- Option 2 → Run /pipeline-start or teach 9 stages\n- Option 3 → Run /learn-claude-code\n- Option 4 → Check PDCA status (docs/.pdca-status.json or scan docs/), guide next step\n- Option 5 → Ask level selection, run /init-*\n\n**Important**: End response with 'Claude is not perfect. Always verify important decisions.'"
  }
}
JSON

exit 0
