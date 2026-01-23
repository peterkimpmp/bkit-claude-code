# bkit Core Mission & Philosophy

> bkit의 핵심 사명과 3가지 철학

## Core Mission

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         bkit's Core Mission                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   "Enable all developers using Claude Code to naturally adopt           │
│    'document-driven development' and 'continuous improvement'           │
│    even without knowing commands or PDCA methodology"                   │
│                                                                         │
│   In essence: AI guides humans toward good development practices        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Three Core Philosophies

| Philosophy | Description | Implementation |
|------------|-------------|----------------|
| **Automation First** | Claude automatically applies PDCA even if user doesn't know commands | `bkit-rules` skill + PreToolUse hooks |
| **No Guessing** | If unsure, check docs → If not in docs, ask user (never guess) | Design-first workflow, gap-detector agent |
| **Docs = Code** | Design first, implement later (maintain design-implementation sync) | PDCA workflow + `/pdca-analyze` command |

---

## User Journey

### Stage 1: Session Start

SessionStart Hook이 자동으로 환영 메시지를 표시:

```
사용자 선택:
1. 첫 프로젝트 → /first-claude-code
2. Claude Code 학습 → /learn-claude-code
3. 프로젝트 설정 → /setup-claude-code
4. 설정 업그레이드 → /upgrade-claude-code
```

### Stage 2: Level Detection

Claude가 프로젝트를 분석하여 자동으로 레벨 감지:

| Level | Detection Conditions | Target Users |
|-------|---------------------|--------------|
| **Starter** | Only index.html, simple structure | Beginners, static web |
| **Dynamic** | Next.js + .mcp.json, BaaS integration | Intermediate, fullstack apps |
| **Enterprise** | services/ + infra/ folders, K8s | Advanced, MSA architecture |

### Stage 3: PDCA Auto-Apply

사용자가 "기능 만들어줘" 요청 시:

```
1. Plan 확인 → docs/01-plan/features/{feature}.plan.md 존재?
2. Design 확인 → docs/02-design/features/{feature}.design.md 존재?
3. 없으면 생성 제안 → 있으면 참조하여 구현
4. 구현 완료 후 → Gap Analysis 제안
```

### Stage 4: Continuous Improvement

Gap Analysis 결과에 따라:

| Match Rate | Next Action |
|------------|-------------|
| >= 90% | "PDCA 완료, 보고서 생성할까요?" |
| < 70% | "자동 수정(iterate) 실행할까요?" |

---

## Value by Level

### Starter Level (Beginners)

```
Before: "I don't know where to start"
After:  4 options at session start → Natural beginning

Before: "Just write code, docs later..."
After:  Auto-generate simple plan/design docs → Habit formation

Before: "I keep making the same mistakes"
After:  Rules accumulate in CLAUDE.md → Cross-session learning
```

### Dynamic Level (Intermediate)

```
Before: "Setting up config files is tedious"
After:  /setup-claude-code → Auto-generation

Before: "Writing design docs is annoying"
After:  Templates + auto-generation → Design doc in 5 minutes

Before: "Code and docs don't match"
After:  /pdca-analyze → Auto gap analysis and sync suggestions
```

### Enterprise Level (Advanced)

```
Before: "Each team member uses Claude differently"
After:  Share plugin → Standardize entire team

Before: "Knowledge is volatile"
After:  PDCA docs + Git management → Permanent accumulation

Before: "Onboarding takes too long"
After:  /learn-claude-code → Systematic training
```

---

## Current Implementation (v1.4.0)

> **v1.4.0**: Dual Platform Support (Claude Code + Gemini CLI)

### Component Counts

| Component | Count | Location |
|-----------|-------|----------|
| Skills | 18 | `skills/*/SKILL.md` |
| Agents | 11 | `agents/*.md` |
| Commands | 20 (×2) | `commands/*.md` (Claude), `commands/gemini/*.toml` (Gemini) |
| Scripts | 26 | `scripts/*.js` |
| Templates | 20 | `templates/*.md` |
| lib/common.js | 80+ functions | `lib/common.js` |

### Key Features

- **Language Tier System**: 4-tier classification (AI-Native, Mainstream, Domain, Legacy)
- **Unified Hook System**: PreToolUse/PostToolUse hooks in skill frontmatter
- **Task Classification**: Quick Fix/Minor Change/Feature/Major Feature
- **Multi-Language Support**: 30+ file extensions supported

---

## Related Documents

- [[ai-native-principles]] - AI-Native 핵심 역량
- [[pdca-methodology]] - PDCA 방법론 상세
- [[../README]] - 시스템 개요
- [[../_GRAPH-INDEX]] - Obsidian 그래프 허브
