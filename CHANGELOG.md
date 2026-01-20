# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-20

### Added
- **Skills Frontmatter Hooks**: Added hooks directly in SKILL.md frontmatter for 4 priority skills
  - `bkit-rules`: SessionStart, PreToolUse (Write|Edit), Stop hooks
  - `task-classification`: PreToolUse (Write|Edit) hook for task size detection
  - `level-detection`: SessionStart hook for automatic project level detection
  - `development-pipeline`: SessionStart hook for pipeline guidance
- **New Shell Scripts**: Added 7 automation scripts
  - `level-detect.sh`: Automatic project level detection (Starter/Dynamic/Enterprise)
  - `pdca-pre-write.sh`: PDCA phase detection before Write/Edit
  - `pdca-post-write.sh`: Gap analysis suggestion after implementation
  - `task-classify.sh`: Task size classification for PDCA guidance
  - `gap-detector-post.sh`: Next steps after gap analysis
  - `qa-pre-bash.sh`: Safe command validation for QA testing
  - `qa-stop.sh`: QA session completion guidance
- **Semantic Matching Enhancement**: Added "Use proactively when" and "Do NOT use for" patterns to all 22 skills
- **Template Variables**: Added `{project}` and `{version}` variables to PDCA templates
- **Pipeline Checklist**: Added validation checklist to zero-script-qa template

### Changed
- **Zero Script QA Hooks**: Converted from `type: "prompt"` to `type: "command"` (per GitHub #13155)
- **Document Standards**: Integrated timeline-awareness rules into document-standards skill
- **Zero Script QA**: Integrated zero-script-qa-rules into skill with auto-apply rules
- **Template Version**: Bumped PDCA templates from v1.0 to v1.1

### Deprecated
- **Instructions Folder**: `.claude/instructions/` is now deprecated
  - Content migrated to respective skills with frontmatter hooks
  - Files kept for backward compatibility

### Fixed
- **Folder Sync**: All skills, templates now synced between `.claude/` and root

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
