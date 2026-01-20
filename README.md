# bkit - Vibecoding Kit

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1.1+-purple.svg)](https://code.claude.com)
[![Version](https://img.shields.io/badge/Version-1.2.0-green.svg)](CHANGELOG.md)
[![Author](https://img.shields.io/badge/Author-POPUP%20STUDIO-orange.svg)](https://popupstudio.ai)

> **PDCA methodology + Claude Code mastery for AI-native development**

bkit is a Claude Code plugin that transforms how you build software with AI. It provides structured development workflows, automatic documentation, and intelligent code assistance through the PDCA (Plan-Do-Check-Act) methodology.

![bkit Introduction](images/bkit-intro.png)

---

## Features

![bkit Features](images/bkit-features.png)

- **PDCA Methodology** - Structured development workflow with automatic documentation
- **Evaluator-Optimizer Pattern** - Automatic iteration cycles from Anthropic's agent architecture
- **9-Stage Development Pipeline** - From schema design to deployment
- **3 Project Levels** - Starter (static), Dynamic (fullstack), Enterprise (microservices)
- **Multilingual Support** - 8 languages (EN, KO, JA, ZH, ES, FR, DE, IT)
- **18 Commands** - Automate common development tasks
- **26 Skills** - Domain-specific knowledge for various development scenarios
- **11 Agents** - Specialized AI assistants for different tasks
- **Skills Frontmatter Hooks** - Automatic triggers based on context (v1.2.0+)

---

### 🚀 초보자라면?

> **Claude Code가 처음이신가요?**
>
> [bkit-starter](https://github.com/popup-studio-ai/bkit-starter)로 시작하세요!
>
> - 완전한 한글 가이드
> - 프로그래밍 경험 없이도 시작 가능
> - 첫 프로젝트 만들기 체험
>
> ```bash
> /plugin enable bkit-starter
> ```
>
> bkit은 bkit-starter를 마스터한 후 사용하는 고급 확장 버전입니다.

---

## Quick Start

### Option 1: Marketplace Installation (Recommended)

The easiest way to install bkit is through the Claude Code marketplace.

```bash
# Step 1: Add bkit marketplace
/plugin marketplace add popup-studio-ai/bkit-claude-code

# Step 2: Install bkit plugin
/plugin install bkit
```

#### Managing Marketplaces

Use `/plugin` command and navigate to **Marketplaces** tab to manage your plugin sources:

![bkit Marketplace](images/bkit-marketplace.png)

- **bkit-marketplace**: Contains bkit and bkit-starter plugins
- **claude-plugins-official**: Official Anthropic plugins

#### Discovering Plugins

Navigate to **Discover** tab to browse and install available plugins:

![bkit Marketplace Plugins](images/bkit-marketplace-plugins.png)

| Plugin | Description | Best For |
|--------|-------------|----------|
| **bkit** | Full PDCA methodology + Claude Code mastery | Experienced developers |
| **bkit-starter** | Korean learning guide for beginners | First-time Claude Code users |

#### Auto-Update Configuration

Keep your plugins up-to-date automatically by configuring auto-update in your settings:

```json
// ~/.claude/settings.json
{
  "plugins": {
    "autoUpdate": true
  }
}
```

**Update Commands:**
- Press `u` in the Marketplaces view to update all plugins
- Press `r` to remove a marketplace
- Use `Space` to toggle plugin selection in Discover view

### Plugin Structure

```
bkit-claude-code/
├── .claude-plugin/
│   ├── plugin.json          # Plugin manifest
│   └── marketplace.json     # Marketplace registry
├── commands/                # Slash commands
├── agents/                  # Specialized AI agents
├── skills/                  # Domain knowledge
├── hooks/                   # Event hooks (hooks.json)
├── scripts/                 # Hook scripts
├── lib/                     # Shared utilities
├── templates/               # Document templates
└── bkit.config.json         # Centralized configuration
```

> **Note**: The `.claude/` folder is not included in this repository. Plugin elements are located at the root level.

---

## Customization

After installing bkit via the marketplace, you can customize any component by copying it to your project's `.claude/` folder.

### How It Works

Claude Code searches for configuration files in this priority order:
1. **Project `.claude/`** (highest priority - your customizations)
2. **User `~/.claude/`**
3. **Plugin installation** (default)

### Customization Steps

```bash
# Step 1: Find the plugin installation location
ls ~/.claude/plugins/bkit/

# Step 2: Copy only the files you want to customize
mkdir -p .claude/skills/starter
cp ~/.claude/plugins/bkit/skills/starter/SKILL.md .claude/skills/starter/

# Step 3: Edit the copied file in your project
# Your project's .claude/skills/starter/SKILL.md will override the plugin's version

# Step 4: Commit to version control (optional)
git add .claude/
git commit -m "feat: customize bkit starter skill"
```

### Available Components for Customization

| Component | Location | Description |
|-----------|----------|-------------|
| **Commands** | `~/.claude/plugins/bkit/commands/` | Slash commands (e.g., `/pdca-plan`) |
| **Skills** | `~/.claude/plugins/bkit/skills/` | Domain knowledge and context |
| **Agents** | `~/.claude/plugins/bkit/agents/` | Specialized AI assistants |
| **Templates** | `~/.claude/plugins/bkit/templates/` | Document templates |
| **Scripts** | `~/.claude/plugins/bkit/scripts/` | Hook scripts |
| **Config** | `~/.claude/plugins/bkit/bkit.config.json` | Central configuration |

### Important Notes

- **Customized files don't receive plugin updates.** When bkit is updated, your customized files remain unchanged while non-customized files are updated automatically.
- **Check the [CHANGELOG](CHANGELOG.md)** periodically for updates that might affect your customizations.
- **Delete a customized file** to revert to the plugin's default version.

---

## Usage

### Start Learning
```bash
/bkit:learn-claude-code
```

### Initialize a Project
```bash
/bkit:init-starter      # Static website
/bkit:init-dynamic      # Fullstack with BaaS
/bkit:init-enterprise   # Microservices with K8s
```

### PDCA Workflow
```bash
/bkit:pdca-plan {feature}    # Create plan document
/bkit:pdca-design {feature}  # Create design document
/bkit:pdca-iterate {feature} # Auto-fix with Evaluator-Optimizer pattern
/bkit:pdca-analyze           # Run gap analysis
/bkit:pdca-report            # Generate completion report
```

---

## Project Levels

| Level | Description | Stack |
|-------|-------------|-------|
| **Starter** | Static websites, portfolios | HTML, CSS, JS |
| **Dynamic** | Fullstack applications | Next.js, BaaS |
| **Enterprise** | Microservices architecture | K8s, Terraform, MSA |

---

## Is bkit Only for Development?

![bkit for Non-Development](images/to-use-non-development.png)

bkit is **primarily designed for software development**. However, some components can inspire structured workflows beyond coding:

| Component | Beyond Development Uses |
|-----------|------------------------|
| **PDCA Methodology** | Project management, process improvement |
| **Document Templates** | Planning any structured project |
| **Gap Analysis** | Comparing any plan vs. actual outcome |

> **Note**: For general writing, research, or non-technical tasks, plain Claude Code (without bkit) is better suited.

---

## Documentation

- **[Changelog](CHANGELOG.md)** - Version history and release notes
- **[Architecture & User Journey](docs/00-ARCHITECTURE.md)** - Complete system analysis and user experience guide
- **[AI-Native Transformation](docs/AI-NATIVE-TRANSFORMATION.md)** - Business value analysis for C-Level executives
- **[AI-Native Development Methodology](AI-NATIVE-DEVELOPMENT.md)** - How bkit realizes AI-Native development principles
- [Development Pipeline](skills/development-pipeline/SKILL.md)
- [Commands Reference](commands/)
- [Skills Reference](skills/)
- [Agents Reference](agents/)

---

## Language Support

bkit automatically detects your language from trigger keywords:

| Language | Trigger Keywords |
|----------|-----------------|
| English | static website, beginner, API design |
| Korean | 정적 웹, 초보자, API 설계 |
| Japanese | 静的サイト, 初心者, API設計 |
| Chinese | 静态网站, 初学者, API设计 |
| Spanish | sitio web estático, principiante |
| French | site web statique, débutant |
| German | statische Webseite, Anfänger |
| Italian | sito web statico, principiante |

### Setting Response Language

To set Claude's **response language**, add to `~/.claude/settings.json`:

```json
{
  "language": "korean"
}
```

| Language | Setting Value |
|----------|---------------|
| Korean | `"language": "korean"` |
| Japanese | `"language": "japanese"` |
| Chinese | `"language": "chinese"` |
| English | `"language": "english"` (default) |

> **Note**: Trigger keywords work in any language. The `language` setting only affects Claude's response language.

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Branch Protection

- Only `admin` team members can merge to `main`
- All changes require pull request review
- Version releases are managed through Git tags

---

## License

Copyright 2024-2026 POPUP STUDIO PTE. LTD.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

You must include the [NOTICE](NOTICE) file in any redistribution.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/popup-studio-ai/bkit-claude-code/issues)
- **Email**: contact@popupstudio.ai

---

Made with AI by [POPUP STUDIO](https://popupstudio.ai)
