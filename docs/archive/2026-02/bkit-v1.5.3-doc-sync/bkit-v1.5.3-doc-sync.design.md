# bkit v1.5.3 Documentation Synchronization Design

> **Feature**: bkit-v1.5.3-doc-sync
> **Level**: Dynamic
> **Date**: 2026-02-10
> **Author**: CTO Lead (Claude Opus 4.6)
> **Status**: Approved
> **Plan**: docs/01-plan/features/bkit-v1.5.3-doc-sync.plan.md

---

## 1. Change Specification

### 1.1 README.md

| Line | Current | Change To |
|:----:|---------|-----------|
| 5 | `Version-1.5.2-green` | `Version-1.5.3-green` |
| 39 | `165 Functions` | `241 Functions` |
| 50 | `Scripts (43 modules)` | `Scripts (45 modules)` |
| 62 | (v1.5.1 features) | Add v1.5.3 features (state-writer, outputStyles, 10 hooks) |
| 76 | `43 Scripts` | `45 Scripts` |
| 77 | `165 Utility Functions` ... `5 modular libraries` | `241 Utility Functions` ... `5 modular libraries` |

### 1.2 CHANGELOG.md - New v1.5.3 Entry

Insert before `## [1.5.2]`:

```markdown
## [1.5.3] - 2026-02-10

### Added
- **Team Visibility (State Writer)**
  - `lib/team/state-writer.js`: 9 new functions for Agent Teams state management
  - `initAgentState`, `updateTeammateStatus`, `addTeammate`, `removeTeammate`, `updateProgress`, `addRecentMessage`, `cleanupAgentState`, `getAgentStatePath`, `readAgentState`
  - `.bkit/agent-state.json` schema v1.0 for Studio IPC
  - Atomic write pattern (tmp + rename) for concurrent safety
  - MAX_TEAMMATES=10, MAX_MESSAGES=50 ring buffer
- **SubagentStart/SubagentStop Hooks**
  - 2 new hook event types in `hooks.json` (8 → 10 events)
  - `scripts/subagent-start.js`, `scripts/subagent-stop.js`
  - Auto-init agent state, name extraction, model validation
- **Output Styles Auto-Discovery**
  - `outputStyles` field in `plugin.json` for Claude Code auto-discovery
  - 4th output style: `bkit-pdca-enterprise` added
  - `/output-style-setup` command for menu visibility
- **bkend Documentation Enhancement**
  - Official Documentation (Live Reference) sections in 5 bkend skills + agent
  - `bkend-quickstart` MCP step-by-step guide expansion
  - Agent Memory file for bkend-expert
- **CLAUDE.md Strategy Documentation**
  - `commands/bkit.md` expanded with CLAUDE.md strategy sections
  - v1.5.3 Features table in bkit help command

### Changed
- **Hook Events**: 8 → 10 (added SubagentStart, SubagentStop)
- **Library Functions**: 232 → 241 (+9 state-writer)
- **common.js exports**: 171 → 180 (+9 state-writer bridge)
- **team/index.js exports**: 31 → 40 (+9 state-writer)
- **Output Styles**: 3 → 4 (added bkit-pdca-enterprise)
- **team.enabled**: Default changed from false to true
- **session-start.js**: 4 output styles + /output-style-setup guide

### Fixed
- **GAP-01**: common.js missing 9 state-writer re-exports (171 → 180)

### Quality
- Comprehensive Test: 685 TC, 646 PASS, 39 SKIP (100% excl. SKIP)
- Enhancement Test: 31/31 PASS (100%)
- Final QA: 736/736 PASS (100%)
```

### 1.3 CUSTOMIZATION-GUIDE.md

| Target | Current | Change To |
|--------|---------|-----------|
| `(v1.5.2)` references (15+ 곳) | v1.5.2 | v1.5.3 |
| `43` scripts | 43 | 45 |
| `8 events` | 8 | 10 |
| `165 functions` | 165 | 241 |
| `3` output styles | 3 | 4 |
| `5 modules` | 5 | 5 (dirs unchanged) |
| `30 exports` (team) | 30 | 40 |
| `8 files` (team) | 8 | 9 |
| output-styles/ listing | 3 items | Add bkit-pdca-enterprise |
| lib/team/ listing | 8 files | Add state-writer.js |

### 1.4 AI-NATIVE-DEVELOPMENT.md

| Target | Current | Change To |
|--------|---------|-----------|
| `165 funcs` (line 143) | 165 | 241 |
| `v1.5.2` (line 230) | v1.5.2 | v1.5.3 |

### 1.5 bkit-system/README.md

| Target | Current | Change To |
|--------|---------|-----------|
| `8 events` | 8 | 10 |
| `43` scripts (3곳) | 43 | 45 |
| `165 functions` | 165 | 241 |
| `3 style files` | 3 | 4 |
| `4 files` (team) | 4 | 9 |

### 1.6 bkit-system/philosophy/ (4 files)

| File | Target | Change |
|------|--------|--------|
| core-mission.md | `v1.5.1` → `v1.5.3`, `43` → `45`, `165` → `241` |
| context-engineering.md | `28` → `45`, `43` → `45`, `165` → `241`, `v1.5.1` → `v1.5.3` |
| ai-native-principles.md | `v1.5.1` → `v1.5.3` |
| pdca-methodology.md | `v1.5.1` → `v1.5.3` |

### 1.7 bkit-system/_GRAPH-INDEX.md

| Target | Current | Change To |
|--------|---------|-----------|
| `43 scripts` | 43 | 45 |
| `5 modules (165 functions)` | 5/165 | 5 dirs/241 |

### 1.8 bkit-system/components/ (4 files)

| File | Target | Change |
|------|--------|--------|
| scripts/_scripts-overview.md | `43` → `45`, `v1.5.2` → `v1.5.3`, `165` → `241`, `3 styles` → `4 styles`, Add bkit-pdca-enterprise |
| skills/_skills-overview.md | `v1.5.2` → `v1.5.3` |
| agents/_agents-overview.md | `v1.5.2` → `v1.5.3` |
| hooks/_hooks-overview.md | `6 events` → `10 events`, `28 scripts` → `45 scripts`, Add 4 missing events |

## 2. Implementation Order

1. CHANGELOG.md (v1.5.3 엔트리 추가)
2. README.md (배지 + 수치 + 기능 목록)
3. CUSTOMIZATION-GUIDE.md (15+ 참조)
4. AI-NATIVE-DEVELOPMENT.md (2 참조)
5. bkit-system/README.md (8+ 참조)
6. bkit-system/philosophy/ (4 파일)
7. bkit-system/_GRAPH-INDEX.md
8. bkit-system/components/ (4 파일)

## 3. Verification

- 모든 파일에서 `1.5.2` 검색 → 0건 (archive/ 제외)
- 모든 파일에서 `165 function` 검색 → 0건
- 모든 파일에서 `43 script` 검색 → 0건
- 모든 파일에서 `8 event` 검색 → 0건 (archive/ 제외)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-10 | Initial design |
