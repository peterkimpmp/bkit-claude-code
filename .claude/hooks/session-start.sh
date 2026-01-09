#!/bin/bash
# bkit Vibecoding Kit - SessionStart Hook
# Adds onboarding instructions to context when Claude Code session starts

cat << 'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "## bkit Vibecoding Kit Session Start\n\nGreet the user and ask the following using AskUserQuestion tool:\n\n**Question**: \"What kind of help do you need?\"\n**Options**:\n1. Start a project - New project initial setup\n2. Learn Claude Code - Learn how to use it\n3. Start working - Already configured\n4. Upgrade settings - Improve existing settings\n\n**Guidance by selection**:\n- Start project → Ask level (Starter/Dynamic/Enterprise), then run /init-* and mention \"I'll use the appropriate expert agent for your level\"\n- Learn → Run /learn-claude-code with learning mode\n- Start working → Auto-detect level via level-detection.md rules, inform user \"Based on your project structure, I detect [level]. I'll use [agent-name] to help.\"\n- Upgrade → Run /upgrade-claude-code\n\n**Proactive Agent Guidance**:\nAfter determining user intent, always mention which agent/skill will be auto-activated:\n- Starter level → \"I'll use starter-guide for beginner-friendly explanations\"\n- Dynamic level → \"I'll use bkend-expert for BaaS integration\"\n- Enterprise level → \"I'll use enterprise-expert and infra-architect for architecture guidance\"\n\n**Auto-Trigger Reminder**: Reference .claude/instructions/auto-trigger-agents.md for agent selection rules.\n\n**Important**: At the end of response, mention 'Claude is not perfect. Always verify important decisions.'"
  }
}
JSON

exit 0
