#!/bin/bash

# =============================================================================
# bkit Plugin Validation Script
# =============================================================================
# Validates plugin structure, YAML frontmatter, and compatibility with
# Claude Code official specifications.
#
# Usage:
#   ./scripts/validate-plugin.sh [options]
#
# Options:
#   --verbose       Show detailed output
#   --fix           Attempt to fix common issues (not implemented)
#   --claude-version VERSION  Check against specific Claude Code version
#
# Official Field Reference (Claude Code v2.1.x):
#   Skills: name, description, allowed-tools, user-invocable, agent, context, hooks
#   Agents: name, description, tools, model, skills, permissionMode, hooks
#   Commands: description, allowed-tools
#
# Author: POPUP STUDIO PTE. LTD.
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Counters
ERRORS=0
WARNINGS=0
PASSED=0

# Options
VERBOSE=false
FIX_MODE=false
CLAUDE_VERSION=""

# Official fields (Claude Code v2.1.x)
SKILL_OFFICIAL_FIELDS="name description allowed-tools user-invocable agent context hooks"
AGENT_OFFICIAL_FIELDS="name description tools model skills permissionMode hooks"
COMMAND_OFFICIAL_FIELDS="description allowed-tools"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --claude-version)
            CLAUDE_VERSION="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++)) || true
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++)) || true
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((ERRORS++)) || true
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "       $1"
    fi
}

log_detail() {
    echo -e "       ${CYAN}→${NC} $1"
}

# Extract YAML frontmatter from a markdown file (only first block)
extract_frontmatter() {
    local file="$1"
    # Only extract if file starts with ---
    if ! head -1 "$file" | grep -q "^---$"; then
        return
    fi
    # Extract content between line 1 (---) and next ---
    awk 'NR==1 && /^---$/ {start=1; next} start && /^---$/ {exit} start {print}' "$file"
}

# Get all top-level fields from YAML frontmatter (not indented)
get_yaml_fields() {
    local file="$1"
    extract_frontmatter "$file" | grep -E "^[a-zA-Z][a-zA-Z0-9_-]*:" | sed 's/:.*//' | tr '\n' ' '
}

# Check if a field is in the official list
is_official_field() {
    local field="$1"
    local official_list="$2"
    echo "$official_list" | grep -qw "$field"
}

# =============================================================================
# Validation Functions
# =============================================================================

check_claude_version() {
    log_info "Checking Claude Code version..."

    if command -v claude &> /dev/null; then
        local installed_version=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

        if [ -n "$installed_version" ]; then
            log_pass "Claude Code version: $installed_version"

            # Check minimum version (2.1.0)
            local major=$(echo "$installed_version" | cut -d. -f1)
            local minor=$(echo "$installed_version" | cut -d. -f2)

            if [ "$major" -lt 2 ] || ([ "$major" -eq 2 ] && [ "$minor" -lt 1 ]); then
                log_warn "bkit requires Claude Code 2.1.0+, you have $installed_version"
            fi
        else
            log_warn "Could not determine Claude Code version"
        fi
    else
        log_warn "Claude Code CLI not found"
    fi
}

validate_plugin_json() {
    log_info "Checking plugin.json..."

    local plugin_json="$PROJECT_ROOT/.claude-plugin/plugin.json"

    if [ ! -f "$plugin_json" ]; then
        log_error "plugin.json not found at .claude-plugin/plugin.json"
        return
    fi

    # Check JSON syntax
    if ! python3 -c "import json; json.load(open('$plugin_json'))" 2>/dev/null; then
        log_error "Invalid JSON syntax in plugin.json"
        return
    fi

    # Check required fields
    local required_fields=("name" "version" "description")
    for field in "${required_fields[@]}"; do
        if ! grep -q "\"$field\"" "$plugin_json"; then
            log_error "Missing required field '$field' in plugin.json"
        else
            log_verbose "Found field: $field"
        fi
    done

    # Check version format
    local version=$(grep -o '"version":\s*"[^"]*"' "$plugin_json" | cut -d'"' -f4)
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_warn "Version '$version' doesn't follow semver format (x.y.z)"
    else
        log_pass "plugin.json is valid (version: $version)"
    fi
}

validate_commands() {
    log_info "Checking commands (YAML frontmatter)..."

    # Check only root folder (avoid duplicate checking)
    local cmd_dirs=("$PROJECT_ROOT/commands")
    local cmd_count=0
    local field_errors=0

    for cmd_dir in "${cmd_dirs[@]}"; do
        if [ -d "$cmd_dir" ]; then
            for cmd_file in "$cmd_dir"/*.md; do
                [ -f "$cmd_file" ] || continue
                ((cmd_count++)) || true

                local filename=$(basename "$cmd_file")
                log_verbose "Checking command: $filename"

                # Check YAML frontmatter exists
                if ! head -1 "$cmd_file" | grep -q "^---$"; then
                    log_error "Command '$filename' missing YAML frontmatter"
                    continue
                fi

                # Check required field: description
                if ! grep -q "^description:" "$cmd_file"; then
                    log_warn "Command '$filename' missing 'description' field"
                fi

                # Check for unofficial fields
                local fields=$(get_yaml_fields "$cmd_file")
                for field in $fields; do
                    if ! is_official_field "$field" "$COMMAND_OFFICIAL_FIELDS"; then
                        log_warn "Command '$filename': unofficial field '$field'"
                        log_detail "Official fields: $COMMAND_OFFICIAL_FIELDS"
                        ((field_errors++)) || true
                    fi
                done
            done
        fi
    done

    if [ $cmd_count -gt 0 ]; then
        if [ $field_errors -eq 0 ]; then
            log_pass "Found $cmd_count command(s) - all fields valid"
        else
            log_pass "Found $cmd_count command(s) - $field_errors field warning(s)"
        fi
    else
        log_warn "No commands found"
    fi
}

validate_agents() {
    log_info "Checking agents (YAML frontmatter)..."

    # Check only root folder (avoid duplicate checking)
    local agent_dirs=("$PROJECT_ROOT/agents")
    local agent_count=0
    local field_errors=0

    for agent_dir in "${agent_dirs[@]}"; do
        if [ -d "$agent_dir" ]; then
            for agent_file in "$agent_dir"/*.md; do
                [ -f "$agent_file" ] || continue
                ((agent_count++)) || true

                local filename=$(basename "$agent_file")
                log_verbose "Checking agent: $filename"

                # Check YAML frontmatter
                if ! head -1 "$agent_file" | grep -q "^---$"; then
                    log_error "Agent '$filename' missing YAML frontmatter"
                    continue
                fi

                # Check required fields
                local required=("name" "description")
                for field in "${required[@]}"; do
                    if ! grep -q "^$field:" "$agent_file"; then
                        log_error "Agent '$filename' missing required field '$field'"
                    fi
                done

                # Check model field (should be valid)
                if grep -q "^model:" "$agent_file"; then
                    local model=$(grep "^model:" "$agent_file" | awk '{print $2}')
                    if [[ ! "$model" =~ ^(sonnet|opus|haiku)$ ]]; then
                        log_warn "Agent '$filename': model '$model' invalid (expected: sonnet, opus, haiku)"
                    fi
                fi

                # Check for unofficial fields
                local fields=$(get_yaml_fields "$agent_file")
                for field in $fields; do
                    if ! is_official_field "$field" "$AGENT_OFFICIAL_FIELDS"; then
                        log_warn "Agent '$filename': unofficial field '$field'"
                        log_detail "Official fields: $AGENT_OFFICIAL_FIELDS"
                        ((field_errors++)) || true
                    fi
                done
            done
        fi
    done

    if [ $agent_count -gt 0 ]; then
        if [ $field_errors -eq 0 ]; then
            log_pass "Found $agent_count agent(s) - all fields valid"
        else
            log_pass "Found $agent_count agent(s) - $field_errors field warning(s)"
        fi
    else
        log_warn "No agents found"
    fi
}

validate_skills() {
    log_info "Checking skills (YAML frontmatter)..."

    # Check only root folder (avoid duplicate checking)
    local skill_dirs=("$PROJECT_ROOT/skills")
    local skill_count=0
    local field_errors=0

    for skill_dir in "${skill_dirs[@]}"; do
        if [ -d "$skill_dir" ]; then
            for skill_folder in "$skill_dir"/*/; do
                [ -d "$skill_folder" ] || continue

                local skill_file="$skill_folder/SKILL.md"
                if [ ! -f "$skill_file" ]; then
                    log_warn "Skill folder '$(basename "$skill_folder")' missing SKILL.md"
                    continue
                fi

                ((skill_count++)) || true
                local skill_name=$(basename "$skill_folder")
                log_verbose "Checking skill: $skill_name"

                # Check YAML frontmatter
                if ! head -1 "$skill_file" | grep -q "^---$"; then
                    log_error "Skill '$skill_name' missing YAML frontmatter"
                    continue
                fi

                # Check required fields
                if ! grep -q "^name:" "$skill_file"; then
                    log_error "Skill '$skill_name' missing 'name' field"
                fi
                if ! grep -q "^description:" "$skill_file"; then
                    log_error "Skill '$skill_name' missing 'description' field"
                fi

                # Check context field (if present, should be valid)
                if grep -q "^context:" "$skill_file"; then
                    local context=$(grep "^context:" "$skill_file" | awk '{print $2}')
                    if [[ ! "$context" =~ ^(default|fork)$ ]]; then
                        log_warn "Skill '$skill_name': context '$context' invalid (expected: default, fork)"
                    fi
                fi

                # Check user-invocable field (if present, should be boolean)
                if grep -q "^user-invocable:" "$skill_file"; then
                    local invocable=$(grep "^user-invocable:" "$skill_file" | awk '{print $2}')
                    if [[ ! "$invocable" =~ ^(true|false)$ ]]; then
                        log_warn "Skill '$skill_name': user-invocable '$invocable' invalid (expected: true, false)"
                    fi
                fi

                # Check for unofficial fields
                local fields=$(get_yaml_fields "$skill_file")
                for field in $fields; do
                    if ! is_official_field "$field" "$SKILL_OFFICIAL_FIELDS"; then
                        log_warn "Skill '$skill_name': unofficial field '$field'"
                        log_detail "Official fields: $SKILL_OFFICIAL_FIELDS"
                        ((field_errors++)) || true
                    fi
                done
            done
        fi
    done

    if [ $skill_count -gt 0 ]; then
        if [ $field_errors -eq 0 ]; then
            log_pass "Found $skill_count skill(s) - all fields valid"
        else
            log_pass "Found $skill_count skill(s) - $field_errors field warning(s)"
        fi
    else
        log_warn "No skills found"
    fi
}

validate_hooks() {
    log_info "Checking hooks..."

    local hooks_files=(
        "$PROJECT_ROOT/hooks/hooks.json"
        "$PROJECT_ROOT/.claude/hooks/hooks.json"
        "$PROJECT_ROOT/.claude/settings.json"
    )

    local hooks_found=false
    local valid_events=("SessionStart" "PreToolUse" "PostToolUse" "Stop" "SubagentStop" "PreCompact" "Notification" "UserPromptSubmit" "SessionEnd")

    for hooks_file in "${hooks_files[@]}"; do
        if [ -f "$hooks_file" ]; then
            hooks_found=true
            log_verbose "Checking: $hooks_file"

            # Validate JSON syntax
            if ! python3 -c "import json; json.load(open('$hooks_file'))" 2>/dev/null; then
                log_error "Invalid JSON in $hooks_file"
                continue
            fi

            # Check for valid hook event names (if hooks key exists)
            if grep -q '"hooks"' "$hooks_file" 2>/dev/null; then
                for event in "${valid_events[@]}"; do
                    if grep -q "\"$event\"" "$hooks_file"; then
                        log_verbose "Found hook event: $event"
                    fi
                done
            fi
        fi
    done

    if [ "$hooks_found" = true ]; then
        log_pass "Hooks configuration found and valid"
    else
        log_warn "No hooks configuration found"
    fi
}

validate_settings() {
    log_info "Checking settings.json..."

    local settings_file="$PROJECT_ROOT/.claude/settings.json"

    if [ ! -f "$settings_file" ]; then
        log_warn "settings.json not found at .claude/settings.json"
        return
    fi

    # Validate JSON syntax
    if ! python3 -c "import json; json.load(open('$settings_file'))" 2>/dev/null; then
        log_error "Invalid JSON in settings.json"
        return
    fi

    # Check permissions structure
    if grep -q '"permissions"' "$settings_file"; then
        if grep -q '"allow"' "$settings_file" && grep -q '"deny"' "$settings_file"; then
            log_pass "settings.json has valid permissions structure"
        else
            log_warn "permissions should have 'allow' and 'deny' arrays"
        fi
    else
        log_pass "settings.json is valid (no permissions defined)"
    fi
}

validate_templates() {
    log_info "Checking templates..."

    # Check only root folder (avoid duplicate checking)
    local template_dirs=("$PROJECT_ROOT/templates")
    local template_count=0

    for template_dir in "${template_dirs[@]}"; do
        if [ -d "$template_dir" ]; then
            for template_file in "$template_dir"/*.md "$template_dir"/*.template.md; do
                [ -f "$template_file" ] || continue
                ((template_count++)) || true
            done
        fi
    done

    if [ $template_count -gt 0 ]; then
        log_pass "Found $template_count template(s)"
    else
        log_warn "No templates found"
    fi
}

validate_file_sync() {
    log_info "Checking .claude/ and root folder sync..."

    local components=("agents" "commands" "templates")
    local sync_issues=0
    local content_diffs=0

    # Check agents, commands, templates (direct .md files)
    for component in "${components[@]}"; do
        local claude_dir="$PROJECT_ROOT/.claude/$component"
        local root_dir="$PROJECT_ROOT/$component"

        if [ -d "$claude_dir" ] && [ -d "$root_dir" ]; then
            # Count files
            local claude_count=$(find "$claude_dir" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
            local root_count=$(find "$root_dir" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')

            if [ "$claude_count" != "$root_count" ]; then
                log_warn "$component: file count mismatch (.claude/=$claude_count, root=$root_count)"
                ((sync_issues++)) || true
            fi

            # Check content diff for each file
            for root_file in "$root_dir"/*.md; do
                [ -f "$root_file" ] || continue
                local filename=$(basename "$root_file")
                local claude_file="$claude_dir/$filename"

                if [ ! -f "$claude_file" ]; then
                    log_warn "$component/$filename: exists in root but missing in .claude/"
                    ((sync_issues++)) || true
                elif ! diff -q "$root_file" "$claude_file" > /dev/null 2>&1; then
                    log_warn "$component/$filename: content differs between .claude/ and root"
                    ((content_diffs++)) || true
                    if [ "$VERBOSE" = true ]; then
                        log_detail "Run: diff .claude/$component/$filename $component/$filename"
                    fi
                fi
            done

            # Check for files in .claude/ but not in root
            for claude_file in "$claude_dir"/*.md; do
                [ -f "$claude_file" ] || continue
                local filename=$(basename "$claude_file")
                local root_file="$root_dir/$filename"

                if [ ! -f "$root_file" ]; then
                    log_warn "$component/$filename: exists in .claude/ but missing in root"
                    ((sync_issues++)) || true
                fi
            done
        fi
    done

    # Check skills (folder structure with SKILL.md)
    local claude_skills="$PROJECT_ROOT/.claude/skills"
    local root_skills="$PROJECT_ROOT/skills"

    if [ -d "$claude_skills" ] && [ -d "$root_skills" ]; then
        # Check each skill folder
        for root_skill in "$root_skills"/*/; do
            [ -d "$root_skill" ] || continue
            local skill_name=$(basename "$root_skill")
            local claude_skill="$claude_skills/$skill_name"

            if [ ! -d "$claude_skill" ]; then
                log_warn "skills/$skill_name: exists in root but missing in .claude/"
                ((sync_issues++)) || true
                continue
            fi

            # Compare SKILL.md content
            local root_skill_file="$root_skill/SKILL.md"
            local claude_skill_file="$claude_skill/SKILL.md"

            if [ -f "$root_skill_file" ] && [ -f "$claude_skill_file" ]; then
                if ! diff -q "$root_skill_file" "$claude_skill_file" > /dev/null 2>&1; then
                    log_warn "skills/$skill_name/SKILL.md: content differs"
                    ((content_diffs++)) || true
                fi
            fi
        done

        # Check for skills in .claude/ but not in root
        for claude_skill in "$claude_skills"/*/; do
            [ -d "$claude_skill" ] || continue
            local skill_name=$(basename "$claude_skill")
            local root_skill="$root_skills/$skill_name"

            if [ ! -d "$root_skill" ]; then
                log_warn "skills/$skill_name: exists in .claude/ but missing in root"
                ((sync_issues++)) || true
            fi
        done
    fi

    # Summary
    local total_issues=$((sync_issues + content_diffs))
    if [ $total_issues -eq 0 ]; then
        log_pass "All folders in sync (content identical)"
    else
        log_warn "Sync issues: $sync_issues missing, $content_diffs content diffs"
        log_detail "Run './scripts/sync-folders.sh' to sync (if available)"
    fi
}

print_field_reference() {
    echo ""
    echo -e "${CYAN}Official Field Reference (Claude Code v2.1.x):${NC}"
    echo -e "  ${BLUE}Skills:${NC}   $SKILL_OFFICIAL_FIELDS"
    echo -e "  ${BLUE}Agents:${NC}   $AGENT_OFFICIAL_FIELDS"
    echo -e "  ${BLUE}Commands:${NC} $COMMAND_OFFICIAL_FIELDS"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

echo ""
echo "=============================================="
echo "  bkit Plugin Validation Script"
echo "  POPUP STUDIO PTE. LTD."
echo "=============================================="
echo ""

cd "$PROJECT_ROOT"

# Run validations
check_claude_version
echo ""
validate_plugin_json
echo ""
validate_commands
echo ""
validate_agents
echo ""
validate_skills
echo ""
validate_hooks
echo ""
validate_settings
echo ""
validate_templates
echo ""
validate_file_sync
echo ""

# Print field reference if there were warnings
if [ $WARNINGS -gt 0 ]; then
    print_field_reference
fi

# Summary
echo "=============================================="
echo "  Validation Summary"
echo "=============================================="
echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "  ${RED}Errors:${NC}   $ERRORS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Validation passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
fi
