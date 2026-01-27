# Commands Deprecation Notice (v1.4.4)

> **DEPRECATED**: As of v1.4.4, all commands have been migrated to Skills.
> Commands will be removed in v2.0.0.

## Migration Guide

Commands are now available as Skills with enhanced functionality:

### PDCA Commands → PDCA Skill

| Deprecated Command | New Skill Usage |
|-------------------|-----------------|
| `/pdca-plan` | `/pdca plan {feature}` |
| `/pdca-design` | `/pdca design {feature}` |
| `/pdca-analyze` | `/pdca analyze {feature}` |
| `/pdca-iterate` | `/pdca iterate {feature}` |
| `/pdca-report` | `/pdca report {feature}` |
| `/pdca-status` | `/pdca status` |
| `/pdca-next` | `/pdca next` |

### Init Commands → Level Skills

| Deprecated Command | New Skill Usage |
|-------------------|-----------------|
| `/init-starter` | `/starter init {project}` |
| `/init-dynamic` | `/dynamic init {project}` |
| `/init-enterprise` | `/enterprise init {project}` |

### Pipeline Commands → Development Pipeline Skill

| Deprecated Command | New Skill Usage |
|-------------------|-----------------|
| `/pipeline-start` | `/development-pipeline start` |
| `/pipeline-next` | `/development-pipeline next` |
| `/pipeline-status` | `/development-pipeline status` |

### Other Commands → Respective Skills

| Deprecated Command | New Skill Usage |
|-------------------|-----------------|
| `/zero-script-qa` | `/zero-script-qa` (unchanged) |
| `/archive` | `/archive` (unchanged) |
| `/github-stats` | `/github-stats` (unchanged) |
| `/learn-claude-code` | `/learn-claude-code` (unchanged) |
| `/setup-claude-code` | `/setup-claude-code` (unchanged) |
| `/upgrade-claude-code` | `/upgrade-claude-code` (unchanged) |
| `/upgrade-level` | `/upgrade-level` (unchanged) |

## Why Skills?

Skills provide:

1. **Unified Interface**: One system instead of separate commands and skills
2. **Better Orchestration**: Automatic template loading, task creation, PDCA status updates
3. **Organic Workflow**: next-skill chaining for seamless phase transitions
4. **Enhanced Context**: Imported templates provide richer context

## Backward Compatibility

During the deprecation period (v1.4.4 - v1.9.x):
- Old commands will continue to work but show deprecation warnings
- Commands internally redirect to the corresponding skills
- Users are encouraged to migrate to the new skill-based approach

## Timeline

| Version | Status |
|---------|--------|
| v1.4.4 | Commands deprecated, Skills preferred |
| v1.5.0 | Deprecation warnings added to commands |
| v2.0.0 | Commands removed, Skills only |

## Questions?

If you have questions about the migration, please:
1. Check the skill documentation in `skills/*/SKILL.md`
2. Open an issue at https://github.com/popup-studio-ai/bkit-claude-code/issues
