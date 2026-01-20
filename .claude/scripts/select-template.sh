#!/bin/bash
# scripts/select-template.sh
# Purpose: Select appropriate template based on project level
# Usage: select-template.sh <template-type> <feature-name>

set -e

TEMPLATE_TYPE=$1  # plan, design, analysis, report
FEATURE_NAME=$2

# Default level
LEVEL="Dynamic"

# Detect level from CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    DETECTED=$(grep -i "level:" CLAUDE.md | head -1 | awk '{print $2}')
    [ -n "$DETECTED" ] && LEVEL=$DETECTED
# Detect from infrastructure
elif [ -d "kubernetes" ] || [ -d "terraform" ] || [ -d "k8s" ]; then
    LEVEL="Enterprise"
# Detect from project structure
elif [ ! -f "docker-compose.yml" ] && [ ! -d "api" ] && [ ! -d "backend" ]; then
    # No backend indicators = likely Starter
    if [ -f "package.json" ]; then
        # Check if it's a simple frontend project
        if ! grep -q "bkend\|@supabase\|firebase" package.json 2>/dev/null; then
            LEVEL="Starter"
        fi
    else
        LEVEL="Starter"
    fi
fi

# Template directory
TEMPLATE_DIR="templates"
PLUGIN_TEMPLATE_DIR="${CLAUDE_PROJECT_DIR:-/Users/popup-kay/Documents/GitHub/popup/bkit-claude-code}/templates"

# Use plugin templates if available, fallback to local
if [ -d "$PLUGIN_TEMPLATE_DIR" ]; then
    TEMPLATE_DIR="$PLUGIN_TEMPLATE_DIR"
fi

# Determine template file based on level
case $LEVEL in
    Starter|starter)
        TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}-starter.template.md"
        ;;
    Enterprise|enterprise)
        TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}-enterprise.template.md"
        ;;
    *)
        TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}.template.md"
        ;;
esac

# Fallback to default template if level-specific doesn't exist
if [ ! -f "$TEMPLATE_FILE" ]; then
    TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}.template.md"
fi

# Final fallback
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "ERROR: Template not found: ${TEMPLATE_TYPE}.template.md" >&2
    exit 1
fi

# Output the selected template path
echo "$TEMPLATE_FILE"

# If feature name is provided, also output variables that can be used
if [ -n "$FEATURE_NAME" ]; then
    DATE=$(date +%Y-%m-%d)
    PROJECT_NAME=""
    VERSION=""

    # Try to get project name from package.json or CLAUDE.md
    if [ -f "package.json" ]; then
        PROJECT_NAME=$(jq -r '.name // ""' package.json 2>/dev/null)
        VERSION=$(jq -r '.version // ""' package.json 2>/dev/null)
    fi

    if [ -f "CLAUDE.md" ] && [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME=$(grep -m1 "^#" CLAUDE.md | sed 's/^# //')
    fi

    # Output as JSON for easy parsing
    cat << EOF
{
  "template": "$TEMPLATE_FILE",
  "level": "$LEVEL",
  "feature": "$FEATURE_NAME",
  "date": "$DATE",
  "project": "$PROJECT_NAME",
  "version": "$VERSION"
}
EOF
fi
