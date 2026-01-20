# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-20

### Added
- **Centralized Configuration**: Added `bkit.config.json` for centralized settings
  - Task classification thresholds
  - Level detection rules
  - PDCA document paths
  - Template configurations
- **Shared Utilities**: Added `lib/common.sh` with reusable functions
  - `get_config()`: Read values from bkit.config.json
  - `is_source_file()`: Check if path is source code
  - `extract_feature()`: Extract feature name from file path
  - `classify_task()`: Classify task by content size
  - `detect_level()`: Detect project level
- **Customization Guide**: Added documentation for customizing plugin components
  - Copy from `~/.claude/plugins/bkit/` to project `.claude/`
  - Project-level overrides take priority over plugin defaults
- **Skills Frontmatter Hooks**: Added hooks directly in SKILL.md frontmatter for priority skills
  - `bkit-rules`: SessionStart, PreToolUse (Write|Edit), Stop hooks
  - `bkit-templates`: Template selection automation
- **New Shell Scripts**: Added automation scripts
  - `pre-write.sh`: Unified pre-write hook combining PDCA and task classification
  - `select-template.sh`: Template selection based on document type and level
  - `task-classify.sh`: Task size classification for PDCA guidance

### Changed
- **Repository Structure**: Removed `.claude/` folder from version control
  - Plugin elements now exist only at root level (single source of truth)
  - Local development uses symlinks from `.claude/` to root
  - Users customize by copying from `~/.claude/plugins/bkit/` to project `.claude/`
- **Zero Script QA Hooks**: Converted from `type: "prompt"` to `type: "command"`
- **Template Version**: Bumped PDCA templates from v1.0 to v1.1

### Removed
- **Deprecated Skills**: Consolidated redundant skills into core skills
  - `ai-native-development` → merged into `bkit-rules`
  - `analysis-patterns` → merged into `bkit-templates`
  - `document-standards` → merged into `bkit-templates`
  - `evaluator-optimizer` → available via `/pdca-iterate` command
  - `level-detection` → moved to `lib/common.sh`
  - `monorepo-architecture` → merged into `enterprise`
  - `pdca-methodology` → merged into `bkit-rules`
  - `task-classification` → moved to `lib/common.sh`
- **Instructions Folder**: Removed deprecated `.claude/instructions/`
  - Content migrated to respective skills

### Fixed
- **Single Source of Truth**: Eliminated dual maintenance between root and `.claude/` folders

## [1.1.4] - 2026-01-15

### Fixed
- Simplified hooks system and enhanced auto-trigger mechanisms
- Added Claude Code hooks analysis document (v2.1.7)

## [1.1.0] - 2026-01-09

### Added
- Initial public release of bkit
- PDCA methodology implementation
- 9-stage Development Pipeline
- Three project levels (Starter, Dynamic, Enterprise)
- 11 specialized agents
- 26 skills for various development phases
- Zero Script QA methodology
- Multilingual support (EN, KO, JA, ZH)
