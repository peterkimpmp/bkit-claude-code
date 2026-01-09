# Claude Code Mastery Guide

> **Purpose**: A universal master guide that allows Claude Code to generate optimal settings and provide training for **any project**
>
> **Version**: 1.0.0
> **Last Modified**: 2026-01-04
> **Sources**: Boris Cherny's 12 Tips + [Official Documentation](https://code.claude.com/docs) + Practical Pattern Analysis

---

## Why This Document is Needed

### Problem Recognition

When using Claude Code, you encounter the following issues:

1. **Session Disconnection Problem**: Context from previous sessions disappears when starting a new session
2. **Lack of Consistency**: Same requests produce different results each time
3. **Knowledge Volatility**: Learned rules and patterns reset with each session
4. **Repeated Training**: Must repeat the same explanations every time
5. **Fragmented Settings**: Team members use Claude Code differently

### Solution

**"Documented knowledge transcends sessions"**

- Rules recorded in CLAUDE.md apply consistently across all sessions
- Commands/Agents/Skills standardize workflows
- This master guide enables Claude Code to self-train and generate settings

### What This Document Solves

| Problem | Solution |
|---------|----------|
| Context reset per session | Permanent storage in CLAUDE.md |
| Repeated training | /learn-claude-code command |
| Manual setup per project | /setup-claude-code auto-generation |
| Difficulty tracking latest trends | /upgrade-claude-code trend analysis |
| No team knowledge accumulation | PR auto-documentation (GitHub Action) |

---

## How to Use This Document

### For Claude Code

Reading this document enables the following for **any project**:

1. **Generate Settings**: Analyze project → Generate `.claude/` matching language/structure
2. **Provide Training**: Deliver learning content matching user level
3. **Analyze Latest Trends**: Research latest usage via WebSearch
4. **Apply Best Practices**: Optimize based on Boris Cherny's tips

### For Users

```bash
# Execute via slash commands
/learn-claude-code          # Training + settings guide
/setup-claude-code          # Generate project settings
/upgrade-claude-code        # Upgrade to latest trends
```

---

## Table of Contents

Refer to individual documents in the `mastery/` folder for detailed content.

### [Core Concepts (This Document)](#core-concepts)
- Goals of Claude Code configuration
- Boris's 12 Core Principles
- Configuration file structure

### [1. Detailed Guide by Setting Element](mastery/01-settings-guide.md)
- CLAUDE.md (Required)
- Commands (Recommended)
- Agents/Subagents (Recommended)
- Skills (Optional, recommended for large projects)
- Hooks (Recommended)
- MCP (Optional)
- GitHub Action (Optional)

### [2. Language/Framework Templates](mastery/02-language-templates.md)
- TypeScript/JavaScript (npm, pnpm, Bun, Deno)
- Python (Poetry, pip, uv)
- Go, Rust, Java, C#, Ruby, PHP
- Flutter/Dart, Swift, Kotlin

### [3. Project Structure Guide](mastery/03-project-structures.md)
- Monorepo
- Microservices
- Single App
- Fullstack App

### [4. Training Curriculum](mastery/04-curriculum.md)
- Level 1: Basics (15 min)
- Level 2: Automation (30 min)
- Level 3: Specialization (45 min)
- Level 4: Team Optimization (1 hour)

### [5. Latest Trend Analysis and Execution Workflow](mastery/05-advanced.md)
- How to analyze latest trends
- Execution workflows (/learn, /setup, /upgrade)

### [6. Plugins](mastery/06-plugins.md)
- Plugin structure
- plugin.json manifest
- Installation and development

### [7. Output Styles](mastery/07-output-styles.md)
- Built-in styles
- Custom style definition

### [8. Programmatic Usage](mastery/08-programmatic.md)
- CLI SDK
- CI/CD integration
- Script automation

---

## Core Concepts

### Goals of Claude Code Configuration

```
┌─────────────────────────────────────────────────────────────┐
│               Claude Code Optimization Goals                 │
├─────────────────────────────────────────────────────────────┤
│  1. Automate repetitive tasks    → Commands, Hooks          │
│  2. Optimize context             → Skills, CLAUDE.md        │
│  3. Ensure quality               → Agents, verification loop │
│  4. Accumulate team knowledge    → Instructions, Git mgmt   │
│  5. Integrate external tools     → MCP connections          │
└─────────────────────────────────────────────────────────────┘
```

### Boris's 12 Core Principles

| # | Principle | Implementation | Applicable Languages |
|---|-----------|----------------|---------------------|
| 1 | Parallel Work | Use multiple sessions simultaneously | All languages |
| 2 | Opus 4.5 Priority | First-try accuracy > speed | All languages |
| 3 | Use CLAUDE.md | Team knowledge repository | All languages |
| 4 | PR Doc Automation | GitHub Action | All languages |
| 5 | Plan Mode First | Plan → Execute | All languages |
| 6 | Slash Commands | Automate repetitive tasks | All languages |
| 7 | Sub Agents | Specialize tasks | All languages |
| 8 | PostToolUse Hook | Automate formatting | Language-specific tools |
| 9 | Permission Whitelist | Balance security and convenience | Language-specific commands |
| 10 | MCP Connection | External tool integration | All languages |
| 11 | Background Execution | Async long tasks | All languages |
| 12 | Provide Verification | Feedback loop | Language-specific tests |

### Configuration File Structure (Universal)

```
project/
├── CLAUDE.md                          # Root: development workflow
├── .mcp.json                          # MCP server settings
├── .claude/
│   ├── settings.local.json            # Permissions + hook settings
│   ├── commands/                      # Slash commands
│   │   ├── commit-push-pr.md
│   │   └── ...
│   ├── agents/                        # Sub agents
│   │   ├── build-validator.md
│   │   └── ...
│   ├── skills/                        # Domain-specific expert context
│   │   └── {skill-name}/SKILL.md
│   ├── docs/                          # Documentation (includes this file)
│   │   ├── CLAUDE-CODE-MASTERY.md     # Master guide (table of contents)
│   │   └── mastery/                   # Detailed guides
│   │       ├── 01-settings-guide.md
│   │       ├── 02-language-templates.md
│   │       ├── 03-project-structures.md
│   │       ├── 04-curriculum.md
│   │       ├── 05-advanced.md
│   │       ├── 06-plugins.md
│   │       ├── 07-output-styles.md
│   │       └── 08-programmatic.md
│   └── instructions/                  # Project rules (optional)
│       ├── coding-conventions.md
│       └── ...
└── .github/
    └── workflows/
        └── claude-docs-update.yml     # PR auto-documentation
```

---

## Appendix

### A. Troubleshooting

| Problem | Solution |
|---------|----------|
| Hook not executing | Check `settings.local.json` path |
| Command not recognized | Check `.md` extension, filename |
| Permission denied | Add pattern to `permissions.allow` |
| MCP connection failed | Validate `.mcp.json` syntax |

### B. Reference Links

- Claude Code Official Docs: https://code.claude.com/docs
- MCP Server List: https://github.com/modelcontextprotocol/servers
- MCP Registry: https://registry.modelcontextprotocol.io/

### C. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-04 | Initial version |

---

## Execution Instructions for Claude Code

Claude Code reading this document should perform the following for **any project**:

1. **When training is requested** (`/learn-claude-code`):
   - Read this document first
   - Reference `mastery/` folder for detailed content as needed
   - Analyze current settings
   - Provide training content appropriate to level
   - Present practice guide

2. **When settings generation is requested** (`/setup-claude-code`):
   - Read this document first
   - Reference `mastery/01-settings-guide.md` and `mastery/02-language-templates.md`
   - Analyze project (language, package manager, structure)
   - Select template matching language/structure
   - Generate files and summarize results

3. **When upgrade is requested** (`/upgrade-claude-code`):
   - Read this document first
   - Reference `mastery/05-advanced.md`
   - Analyze current settings
   - Research latest trends via WebSearch
   - Suggest and apply improvements

4. **For general questions**:
   - Provide accurate answers referencing this document
   - Reference detailed documents in `mastery/` folder as needed
   - Use examples matching project language
