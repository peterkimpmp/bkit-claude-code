#!/bin/bash

# =============================================================================
# bkit Folder Sync Script
# =============================================================================
# Synchronizes .claude/ (source of truth) to root folders for plugin compatibility.
#
# Usage:
#   ./scripts/sync-folders.sh [options]
#
# Options:
#   --dry-run       Show what would be changed without making changes
#   --force         Overwrite without confirmation
#   --interactive   Ask for confirmation on each file
#   --reverse       Sync from root/ to .claude/ (use with caution)
#   --verbose       Show detailed output including skipped files
#
# Sync Targets:
#   .claude/commands/  → commands/
#   .claude/agents/    → agents/
#   .claude/skills/    → skills/
#   .claude/templates/ → templates/
#   .claude/hooks/     → hooks/
#
# NOT Synced (by design):
#   .claude/instructions/  → Integrated into skills/bkit-rules
#   .claude/docs/          → Separate documentation
#   .claude/settings.json  → User settings only
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
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Counters
NEW_COUNT=0
UPDATE_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

# Options
DRY_RUN=false
FORCE=false
INTERACTIVE=false
REVERSE=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --reverse)
            REVERSE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: ./scripts/sync-folders.sh [options]"
            echo ""
            echo "Options:"
            echo "  --dry-run       Show what would be changed without making changes"
            echo "  --force         Overwrite without confirmation"
            echo "  --interactive   Ask for confirmation on each file"
            echo "  --reverse       Sync from root/ to .claude/ (use with caution)"
            echo "  --verbose       Show detailed output including skipped files"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# =============================================================================
# Helper Functions
# =============================================================================

log_new() {
    echo -e "${GREEN}[NEW]${NC}    $1"
    ((NEW_COUNT++)) || true
}

log_update() {
    echo -e "${YELLOW}[UPDATE]${NC} $1"
    ((UPDATE_COUNT++)) || true
}

log_skip() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[SKIP]${NC}   $1 (identical)"
    fi
    ((SKIP_COUNT++)) || true
}

log_error() {
    echo -e "${RED}[ERROR]${NC}  $1"
    ((ERROR_COUNT++)) || true
}

log_info() {
    echo -e "${CYAN}[INFO]${NC}   $1"
}

# Ask for confirmation
confirm() {
    local message="$1"
    if [ "$FORCE" = true ]; then
        return 0
    fi
    if [ "$INTERACTIVE" = true ]; then
        read -p "  → $message (y/n)? " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
        return $?
    fi
    return 0
}

# Copy file with logging
copy_file() {
    local src="$1"
    local dst="$2"
    local rel_path="$3"

    if [ "$DRY_RUN" = true ]; then
        return 0
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dst")"

    if cp "$src" "$dst"; then
        return 0
    else
        log_error "Failed to copy $rel_path"
        return 1
    fi
}

# Copy directory with logging
copy_dir() {
    local src="$1"
    local dst="$2"
    local rel_path="$3"

    if [ "$DRY_RUN" = true ]; then
        return 0
    fi

    if cp -r "$src" "$dst"; then
        return 0
    else
        log_error "Failed to copy $rel_path"
        return 1
    fi
}

# =============================================================================
# Sync Functions
# =============================================================================

# Sync .md files in a directory (commands, agents, templates)
sync_md_files() {
    local component="$1"
    local src_dir dst_dir

    if [ "$REVERSE" = true ]; then
        src_dir="$PROJECT_ROOT/$component"
        dst_dir="$PROJECT_ROOT/.claude/$component"
    else
        src_dir="$PROJECT_ROOT/.claude/$component"
        dst_dir="$PROJECT_ROOT/$component"
    fi

    if [ ! -d "$src_dir" ]; then
        log_info "$component: source directory not found, skipping"
        return
    fi

    # Create destination if not exists
    if [ ! -d "$dst_dir" ] && [ "$DRY_RUN" = false ]; then
        mkdir -p "$dst_dir"
    fi

    # Sync each .md file
    for src_file in "$src_dir"/*.md; do
        [ -f "$src_file" ] || continue

        local filename=$(basename "$src_file")
        local dst_file="$dst_dir/$filename"
        local rel_path="$component/$filename"

        if [ ! -f "$dst_file" ]; then
            # New file
            log_new "$rel_path"
            if confirm "Copy new file"; then
                copy_file "$src_file" "$dst_file" "$rel_path"
            fi
        elif ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
            # Content differs
            log_update "$rel_path"
            if confirm "Update file"; then
                copy_file "$src_file" "$dst_file" "$rel_path"
            fi
        else
            # Identical
            log_skip "$rel_path"
        fi
    done
}

# Sync skills (folder structure with SKILL.md)
sync_skills() {
    local src_dir dst_dir

    if [ "$REVERSE" = true ]; then
        src_dir="$PROJECT_ROOT/skills"
        dst_dir="$PROJECT_ROOT/.claude/skills"
    else
        src_dir="$PROJECT_ROOT/.claude/skills"
        dst_dir="$PROJECT_ROOT/skills"
    fi

    if [ ! -d "$src_dir" ]; then
        log_info "skills: source directory not found, skipping"
        return
    fi

    # Create destination if not exists
    if [ ! -d "$dst_dir" ] && [ "$DRY_RUN" = false ]; then
        mkdir -p "$dst_dir"
    fi

    # Sync each skill folder
    for src_skill in "$src_dir"/*/; do
        [ -d "$src_skill" ] || continue

        local skill_name=$(basename "$src_skill")
        local dst_skill="$dst_dir/$skill_name"
        local src_skill_file="$src_skill/SKILL.md"
        local dst_skill_file="$dst_skill/SKILL.md"
        local rel_path="skills/$skill_name/SKILL.md"

        if [ ! -f "$src_skill_file" ]; then
            continue
        fi

        if [ ! -d "$dst_skill" ]; then
            # New skill folder
            log_new "skills/$skill_name/ (new folder)"
            if confirm "Copy new skill folder"; then
                copy_dir "$src_skill" "$dst_skill" "skills/$skill_name"
            fi
        elif [ ! -f "$dst_skill_file" ]; then
            # Folder exists but SKILL.md missing
            log_new "$rel_path"
            if confirm "Copy SKILL.md"; then
                copy_file "$src_skill_file" "$dst_skill_file" "$rel_path"
            fi
        elif ! diff -q "$src_skill_file" "$dst_skill_file" > /dev/null 2>&1; then
            # SKILL.md content differs
            log_update "$rel_path"
            if confirm "Update SKILL.md"; then
                copy_file "$src_skill_file" "$dst_skill_file" "$rel_path"
            fi
        else
            # Identical
            log_skip "$rel_path"
        fi
    done
}

# Sync hooks (hooks.json)
sync_hooks() {
    local src_dir dst_dir

    if [ "$REVERSE" = true ]; then
        src_dir="$PROJECT_ROOT/hooks"
        dst_dir="$PROJECT_ROOT/.claude/hooks"
    else
        src_dir="$PROJECT_ROOT/.claude/hooks"
        dst_dir="$PROJECT_ROOT/hooks"
    fi

    local src_file="$src_dir/hooks.json"
    local dst_file="$dst_dir/hooks.json"
    local rel_path="hooks/hooks.json"

    if [ ! -f "$src_file" ]; then
        log_info "hooks: source hooks.json not found, skipping"
        return
    fi

    # Create destination if not exists
    if [ ! -d "$dst_dir" ] && [ "$DRY_RUN" = false ]; then
        mkdir -p "$dst_dir"
    fi

    if [ ! -f "$dst_file" ]; then
        log_new "$rel_path"
        if confirm "Copy hooks.json"; then
            copy_file "$src_file" "$dst_file" "$rel_path"
        fi
    elif ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
        log_update "$rel_path"
        if confirm "Update hooks.json"; then
            copy_file "$src_file" "$dst_file" "$rel_path"
        fi
    else
        log_skip "$rel_path"
    fi
}

# Sync scripts (.sh files)
sync_scripts() {
    local src_dir dst_dir

    if [ "$REVERSE" = true ]; then
        src_dir="$PROJECT_ROOT/scripts"
        dst_dir="$PROJECT_ROOT/.claude/scripts"
    else
        src_dir="$PROJECT_ROOT/.claude/scripts"
        dst_dir="$PROJECT_ROOT/scripts"
    fi

    if [ ! -d "$src_dir" ]; then
        log_info "scripts: source directory not found, skipping"
        return
    fi

    # Create destination if not exists
    if [ ! -d "$dst_dir" ] && [ "$DRY_RUN" = false ]; then
        mkdir -p "$dst_dir"
    fi

    # Sync each .sh file (excluding infrastructure scripts)
    for src_file in "$src_dir"/*.sh; do
        [ -f "$src_file" ] || continue

        local filename=$(basename "$src_file")

        # Skip infrastructure scripts (only sync hook scripts)
        if [[ "$filename" == "sync-folders.sh" ]] || [[ "$filename" == "validate-plugin.sh" ]]; then
            continue
        fi

        local dst_file="$dst_dir/$filename"
        local rel_path="scripts/$filename"

        if [ ! -f "$dst_file" ]; then
            # New file
            log_new "$rel_path"
            if confirm "Copy new script"; then
                copy_file "$src_file" "$dst_file" "$rel_path"
                chmod +x "$dst_file" 2>/dev/null || true
            fi
        elif ! diff -q "$src_file" "$dst_file" > /dev/null 2>&1; then
            # Content differs
            log_update "$rel_path"
            if confirm "Update script"; then
                copy_file "$src_file" "$dst_file" "$rel_path"
                chmod +x "$dst_file" 2>/dev/null || true
            fi
        else
            # Identical
            log_skip "$rel_path"
        fi
    done
}

# =============================================================================
# Main
# =============================================================================

echo ""
echo "=============================================="
echo "  bkit Folder Sync Script"
echo "  POPUP STUDIO PTE. LTD."
echo "=============================================="
echo ""

# Show mode
if [ "$DRY_RUN" = true ]; then
    echo -e "${MAGENTA}Mode: DRY RUN (no changes will be made)${NC}"
    echo ""
fi

if [ "$REVERSE" = true ]; then
    echo -e "${YELLOW}Direction: root/ → .claude/ (REVERSE MODE)${NC}"
    echo -e "${YELLOW}⚠️  This will overwrite .claude/ files!${NC}"
    echo ""
    if [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
        read -p "Are you sure you want to continue? (yes/no): " confirm_reverse
        if [ "$confirm_reverse" != "yes" ]; then
            echo "Aborted."
            exit 0
        fi
    fi
else
    echo -e "${CYAN}Direction: .claude/ → root/ (source of truth: .claude/)${NC}"
    echo ""
fi

cd "$PROJECT_ROOT"

# Run sync
log_info "Syncing commands..."
sync_md_files "commands"
echo ""

log_info "Syncing agents..."
sync_md_files "agents"
echo ""

log_info "Syncing skills..."
sync_skills
echo ""

log_info "Syncing templates..."
sync_md_files "templates"
echo ""

log_info "Syncing hooks..."
sync_hooks
echo ""

log_info "Syncing scripts..."
sync_scripts
echo ""

# Summary
echo "=============================================="
echo "  Sync Summary"
echo "=============================================="
echo ""
echo -e "  ${GREEN}New:${NC}     $NEW_COUNT"
echo -e "  ${YELLOW}Updated:${NC} $UPDATE_COUNT"
echo -e "  ${BLUE}Skipped:${NC} $SKIP_COUNT"
echo -e "  ${RED}Errors:${NC}  $ERROR_COUNT"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${MAGENTA}This was a dry run. No files were changed.${NC}"
    echo -e "${MAGENTA}Run without --dry-run to apply changes.${NC}"
elif [ $((NEW_COUNT + UPDATE_COUNT)) -gt 0 ]; then
    echo -e "${GREEN}Sync completed successfully!${NC}"
else
    echo -e "${BLUE}All files are already in sync.${NC}"
fi

if [ $ERROR_COUNT -gt 0 ]; then
    exit 1
fi
exit 0
