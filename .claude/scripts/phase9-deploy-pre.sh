#!/bin/bash
# scripts/phase9-deploy-pre.sh
# Purpose: Validate environment before deployment
# Hook: PreToolUse (Bash) for phase-9-deployment skill

set -e

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Check if this is a deployment command
if [[ "$COMMAND" == *"vercel"* ]] || [[ "$COMMAND" == *"deploy"* ]] || [[ "$COMMAND" == *"kubectl apply"* ]]; then
    # Check for .env.example
    if [ ! -f ".env.example" ]; then
        cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "⚠️ Pre-deployment Check:\n- Missing .env.example file\n- Ensure all required environment variables are documented\n- Verify CI/CD secrets are configured"}}
EOF
    else
        cat << 'EOF'
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "✅ Pre-deployment Check:\n- .env.example found\n- Verify CI/CD secrets match .env.example\n- Run scripts/check-env.sh if available"}}
EOF
    fi
else
    echo '{}'
fi
