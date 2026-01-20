#!/bin/bash
# bkit Vibecoding Kit - SessionStart Hook
# .claude folder installation users (command type)

# Environment Persistence: Detect project level and persist to CLAUDE_ENV_FILE
detect_project_level() {
    local level="starter"

    # Check for Enterprise level indicators
    if [[ -d "infra/terraform" ]] || [[ -d "infra/k8s" ]] || [[ -f "docker-compose.yml" && -d "services" ]]; then
        level="enterprise"
    # Check for Dynamic level indicators
    elif [[ -f ".env" || -f ".env.local" ]] && grep -q "NEXT_PUBLIC_\|DATABASE_\|AUTH_" .env* 2>/dev/null; then
        level="dynamic"
    elif [[ -d "src/features" ]] || [[ -d "src/services" ]] || [[ -f "package.json" && $(grep -c "prisma\|mongoose\|@tanstack/react-query" package.json 2>/dev/null) -gt 0 ]]; then
        level="dynamic"
    fi

    echo "$level"
}

# Detect current PDCA phase from docs/.pdca-status.json
detect_pdca_phase() {
    local phase="1"

    if [[ -f "docs/.pdca-status.json" ]]; then
        phase=$(grep -o '"currentPhase"[[:space:]]*:[[:space:]]*[0-9]*' docs/.pdca-status.json 2>/dev/null | grep -o '[0-9]*' | head -1)
        [[ -z "$phase" ]] && phase="1"
    fi

    echo "$phase"
}

# Persist environment variables if CLAUDE_ENV_FILE is available
if [[ -n "$CLAUDE_ENV_FILE" ]]; then
    DETECTED_LEVEL=$(detect_project_level)
    DETECTED_PHASE=$(detect_pdca_phase)

    echo "export BKIT_LEVEL=$DETECTED_LEVEL" >> "$CLAUDE_ENV_FILE"
    echo "export BKIT_PDCA_PHASE=$DETECTED_PHASE" >> "$CLAUDE_ENV_FILE"
fi

cat << 'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Welcome to bkit Vibecoding Kit!\n\n## PDCA Core Rules (Always Apply)\n- New feature request → Check/create design doc first\n- Don't guess → Check docs → Ask user\n- After implementation → Suggest Gap analysis\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\nUse AskUserQuestion tool to ask:\n\n**Question**: \"What kind of help do you need?\"\n**Header**: \"Help Type\"\n**Options**:\n1. bkit Introduction - Learn what bkit is\n2. Learn Development Process - 9-stage pipeline learning\n3. Learn Claude Code - Setup and usage\n4. Continue Work - Resume previous work\n5. Start New Project - Setup from scratch\n\n**Actions by Selection**:\n- Option 1 → Explain bkit features (PDCA, Pipeline, Levels, Agents, Zero Script QA)\n- Option 2 → Run /pipeline-start or teach 9 stages\n- Option 3 → Run /learn-claude-code\n- Option 4 → Check PDCA status (docs/.pdca-status.json or scan docs/), guide next step\n- Option 5 → Ask level selection, run /init-*\n\n**Important**: End response with 'Claude is not perfect. Always verify important decisions.'"
  }
}
JSON

exit 0
