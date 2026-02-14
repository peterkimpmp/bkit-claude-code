# bkit v1.5.4 Document Synchronization Detailed Design

> **Feature**: bkit-v1.5.4-doc-sync
> **Level**: Dynamic
> **Date**: 2026-02-14
> **Author**: CTO Lead (Claude Opus 4.6)
> **Status**: Draft
> **Branch**: feature/v1.5.4-bkend-mcp-accuracy-fix
> **Plan**: docs/01-plan/features/bkend-mcp-accuracy-fix.plan.md
> **Design (Implementation)**: docs/02-design/features/bkend-mcp-accuracy-fix.design.md

---

## 0. Design Purpose

The core feature of v1.5.4 (bkend MCP accuracy improvement) has been implemented, but document-code synchronization in the following areas remains incomplete:

1. **Version strings** — `1.5.3` remains in plugin.json, marketplace.json, hooks.json, session-start.js, bkit.config.json, README.md, etc.
2. **CHANGELOG.md** — v1.5.4 release notes not yet written
3. **Top-level documents** — v1.5.4 changes not reflected in README.md, AI-NATIVE-DEVELOPMENT.md, CUSTOMIZATION-GUIDE.md
4. **bkit-system/ reference documents** (17 files) — Component count and version reference mismatches
5. **lib/ comment errors** — Export count comments in common.js, core/index.js, team/index.js do not match actual values

### v1.5.4 Change Summary (Implementation Complete)

| Item | v1.5.3 | v1.5.4 | Delta |
|------|:------:|:------:|:-----:|
| bkend MCP tool count | 19 (inaccurate) | 28+ (accurate) | +9 |
| bkend-patterns.md | 85 lines | 140 lines | +55 lines |
| bkend-expert.md | 231 lines | 278 lines | +47 lines |
| bkend-data SKILL | 122 lines | 150 lines | +28 lines |
| bkend-quickstart SKILL | 118 lines | 153 lines | +35 lines |
| bkend-storage SKILL | 110 lines | 127 lines | +17 lines |
| bkend-auth SKILL | 118 lines | 126 lines | +8 lines |
| session-start.js | Dynamic only | Dynamic+Enterprise | GAP-10 |
| Token budget | ~6,400 | ~7,800 | +22% |
| Comprehensive test | - | 764/765 PASS | 100% |

---

## 1. Version String Updates

### 1.1 .claude-plugin/plugin.json

| Line | Current | Change |
|:----:|------|------|
| 3 | `"version": "1.5.3"` | `"version": "1.5.4"` |

### 1.2 .claude-plugin/marketplace.json

| Line | Current | Change |
|:----:|------|------|
| 3 | `"version": "1.5.3"` | `"version": "1.5.4"` |
| 38 | `"version": "1.5.3"` (bkit plugin entry) | `"version": "1.5.4"` |

### 1.3 hooks/hooks.json

| Line | Current | Change |
|:----:|------|------|
| 3 | `"description": "bkit Vibecoding Kit v1.5.3 - Claude Code"` | `"description": "bkit Vibecoding Kit v1.5.4 - Claude Code"` |

### 1.4 hooks/session-start.js (5 locations)

| Line | Current | Change |
|:----:|------|------|
| 3 | `SessionStart Hook (v1.5.3)` | `SessionStart Hook (v1.5.4)` |
| 490 | `bkit Vibecoding Kit v1.5.3 - Session Startup` | `bkit Vibecoding Kit v1.5.4 - Session Startup` |
| 554 | `Output Styles (v1.5.3)` | `Output Styles (v1.5.4)` |
| 611 | `bkit Feature Usage Report (v1.5.3` | `bkit Feature Usage Report (v1.5.4` |
| 667 | `systemMessage: bkit Vibecoding Kit v1.5.3 activated` | `systemMessage: bkit Vibecoding Kit v1.5.4 activated` |

### 1.5 bkit.config.json

| Line | Current | Change |
|:----:|------|------|
| 3 | `"version": "1.5.3"` | `"version": "1.5.4"` |

### 1.6 README.md

| Line | Current | Change |
|:----:|------|------|
| 5 | `Version-1.5.3-green` | `Version-1.5.4-green` |

### 1.7 lib/ @version Tags (6 locations)

| File | Current @version | Change |
|------|:------------:|:----:|
| `lib/common.js` | 1.5.3 | 1.5.4 |
| `lib/core/index.js` | 1.5.1 | 1.5.4 |
| `lib/pdca/index.js` | 1.5.2 | 1.5.4 |
| `lib/intent/index.js` | 1.4.7 | 1.5.4 |
| `lib/task/index.js` | 1.4.7 | 1.5.4 |
| `lib/team/index.js` | 1.5.1 | 1.5.4 |

> **Total version string changes**: 17 locations (6 files + lib/ 6 files)

---

## 2. CHANGELOG.md — v1.5.4 Release Notes

Insert before `## [1.5.3]`:

```markdown
## [1.5.4] - 2026-02-14

### Added
- **bkend MCP Accuracy Improvement (10 GAPs)**
  - MCP tool coverage: 19 (partial) → 28+ (complete)
  - MCP Fixed Tools: `get_context`, `search_docs`, `get_operation_schema`
  - MCP Project Management Tools: 9 tools (project/environment CRUD)
  - MCP Table Management Tools: 11 tools (table/schema/index management)
  - MCP Data CRUD Tools: 5 tools (`backend_data_list/get/create/update/delete`)
  - MCP Resources: 4 URI patterns (`bkend://` scheme)
  - Searchable Docs: 8 Doc IDs (`search_docs` query support)
- **bkend-patterns.md SSOT Expansion**
  - Shared patterns document: 85 lines → 140 lines (+65%)
  - New sections: REST API response format, query parameters, file upload, MCP configuration, OAuth 2.1
- **bkend-expert Agent Full Rewrite**
  - MCP tools categorized into 4 categories (Fixed/Project/Table/Data CRUD)
  - Dynamic Base URL (obtained from `get_context`, no hardcoding)
  - MCP Resources (`bkend://` URI) references added
  - Live Reference URL: `src/` → `en/` path structure transition

### Changed
- **bkend-data/SKILL.md**: ID field `_id` → `id` fix, Data CRUD tools added, filter operator `$` prefix added
- **bkend-auth/SKILL.md**: MCP Auth Workflow pattern introduced, REST endpoints 18 → 12 core streamlined, social login endpoints consolidated
- **bkend-storage/SKILL.md**: MCP Storage Workflow added, Multipart Upload 4 endpoints added, `download-url` method GET → POST fix
- **bkend-quickstart/SKILL.md**: Numbered tool names → real names transition, Project Management 9 tools + Resources 4 URIs added
- **bkend-cookbook/SKILL.md**: Live Reference URL `src/` → `en/` path fix
- **session-start.js**: bkend MCP status check `Dynamic` → `Dynamic || Enterprise` expansion (GAP-10)
- **All Live Reference URLs**: `src/` directory paths → `en/` specific file paths unified

### Removed
- **bkend-expert.md**: Deprecated numbered Guide Tools references (`0_get_context` ~ `7_code_examples_data`)
- **bkend-auth/SKILL.md**: Account Lifecycle section (replaced by search_docs)
- **bkend-data/SKILL.md**: `backend_table_update` tool (non-existent tool)

### Quality
- Comprehensive Test Round 1: 708 TC, 705 PASS, 0 FAIL, 3 SKIP (100%)
- Comprehensive Test Round 2: 765 TC, 764 PASS, 0 FAIL, 1 SKIP (100%)
- bkend MCP Accuracy Fix: 10/10 GAPs, 42/42 items, 100% match rate

---
```

---

## 3. README.md Detailed Changes

### 3.1 Version Badge (Line 5)

```
Current: [![Version](https://img.shields.io/badge/Version-1.5.3-green.svg)](CHANGELOG.md)
Change:  [![Version](https://img.shields.io/badge/Version-1.5.4-green.svg)](CHANGELOG.md)
```

### 3.2 Feature Description Addition (Around Line 61)

Add v1.5.4 item to the list where the first feature is currently `Team Visibility & State Writer (v1.5.3)`:

```markdown
- **bkend MCP Accuracy Fix (v1.5.4)** - MCP tool coverage 19→28+, accurate tool names, dynamic Base URL, search_docs workflow
```

> **Note**: The remaining component counts in README.md (26 Skills, 16 Agents, 45 Scripts, 241 Functions) are unchanged in v1.5.4. Only the version badge and feature list are updated.

---

## 4. AI-NATIVE-DEVELOPMENT.md Changes

### 4.1 Component Counts (Confirmed No Changes)

No changes to skill/agent/script/function counts in v1.5.4. No version reference updates needed.
This document is a **methodology document** that does not specify particular version numbers, so no changes are necessary.

### 4.2 v1.5.4 Related Additions (Optional)

None. Since the bkend MCP accuracy improvement is a content accuracy improvement rather than a methodology-level change, AI-NATIVE-DEVELOPMENT.md is not a modification target.

---

## 5. CUSTOMIZATION-GUIDE.md Changes

### 5.1 Component Inventory Table (Lines 131~143)

| Current | Change Required | Reason |
|------|:--------:|------|
| `Agents: 16` | Keep | No change |
| `Skills: 26` | Keep | No change |
| `Scripts: 45` | Keep | No change |
| `Templates: 27` | Keep | No change |
| `Hooks: 10 events` | Keep | No change |
| `lib/: 5 modules (241 functions)` | Keep | No change |
| `Output Styles: 4` | Keep | No change |

### 5.2 Version Reference (Line 201)

```
Current: > **v1.5.3**: Claude Code Exclusive with CTO-Led Agent Teams...
Change:  > **v1.5.4**: Claude Code Exclusive with CTO-Led Agent Teams (16 agents), bkend MCP Accuracy Fix (28+ tools), Output Styles, Agent Memory, and Team Visibility
```

### 5.3 Compatibility Section (If Applicable)

```
Current: - **Claude Code**: Minimum v2.1.15, Recommended v2.1.33
Change:  - **Claude Code**: Minimum v2.1.33+, Recommended v2.1.41
```

> **Rationale**: TeammateIdle/TaskCompleted hook events are supported from v2.1.33. Prevents hooks.json loading failures.

---

## 6. lib/ Comment Error Fixes

### 6.1 lib/common.js — Export Count Comment Fix

| Line | Current Comment | Actual | Change |
|:----:|----------|:----:|------|
| ~29 | `Core Module (37 exports)` | 41 | `Core Module (41 exports)` |
| ~86 | `PDCA Module (50 exports)` | 54 | `PDCA Module (54 exports)` |
| ~221 | `Team Module (39 exports)` | 40 | `Team Module (40 exports)` |

**Total sum comment also updated**: `180 exports` maintained (41+54+19+26+40=180, bridge export count accurate)

### 6.2 lib/core/index.js — Category Comment Fix

| Category | Current Comment | Actual | Change |
|----------|----------|:----:|------|
| Platform | `(8 exports)` | 9 | `(9 exports)` |
| Cache | `(6 exports)` | 7 | `(7 exports)` |

### 6.3 lib/team/index.js — Category Comment Fix

| Category | Current Comment | Actual | Change |
|----------|----------|:----:|------|
| Orchestrator | `(5 exports)` | 6 | `(6 exports)` |

### 6.4 lib/pdca/index.js — Header Comment Fix

| Current | Actual | Change |
|------|:----:|------|
| `PDCA Module - 50 exports` (header) | 54 | `PDCA Module - 54 exports` |

> **Note**: `readBkitMemory` and `writeBkitMemory` were added to the Status category in pdca/index.js in v1.5.3, but the total count in the header was not updated.

---

## 7. bkit-system/ Document Synchronization (17 Files)

### 7.1 Change Target Classification

**Since no metrics actually changed in v1.5.4** (skill/agent/script/function counts remain the same), the main tasks for bkit-system/ documents are **adding version history** and **correcting existing inaccurate metrics**.

#### Priority 1: Version History Addition (5 Files)

| File | Change Content |
|------|----------|
| `bkit-system/README.md` | Add v1.5.4 release entry (bkend MCP accuracy fix) |
| `bkit-system/_GRAPH-INDEX.md` | Add v1.5.4 entry |
| `bkit-system/components/skills/_skills-overview.md` | Reflect bkend skills v1.5.4 changes (MCP tool name transition) |
| `bkit-system/components/hooks/_hooks-overview.md` | Record v1.5.4 session-start.js GAP-10 fix |
| `bkit-system/testing/test-checklist.md` | Add v1.5.4 test cases (bkend MCP 55 TC) |

#### Priority 2: Existing Inaccurate Metrics Correction (7 Files)

| File | Correction Target | Current | Correct Value |
|------|----------|:----:|:---------:|
| `README.md` (bkit-system) | Hook event count (architecture diagram) | 5-6 | 10 |
| `_GRAPH-INDEX.md` | bkend specialist skills mention | Not listed | Specify 5 |
| `components/agents/_agents-overview.md` | Agent detailed list | Only 11 listed | List all 16 |
| `components/scripts/_scripts-overview.md` | Function count (v1.4.7 reference) | 132 | 241 (v1.5.3~) |
| `scenarios/scenario-discover-features.md` | Output Styles count | 3 | 4 (bkit-pdca-enterprise added) |
| `scenarios/scenario-discover-features.md` | Agent Teams teammate count | Dynamic: 2 | Dynamic: 3 |
| `triggers/trigger-matrix.md` | Hook event count | 6 | 10 |

#### Priority 3: v1.5.4 Specific Content Addition (5 Files)

| File | Addition Content |
|------|----------|
| `philosophy/core-mission.md` | Add bkend MCP accuracy as a "No Guessing" philosophy example |
| `philosophy/context-engineering.md` | Add Context Engineering significance of MCP tool accuracy |
| `scenarios/scenario-new-feature.md` | Add team-based feature implementation scenario |
| `scenarios/scenario-qa.md` | Add team-based QA execution scenario |
| `triggers/priority-rules.md` | Add bkend MCP trigger priority rules |

---

## 8. File-by-File Detailed Change Specification

### 8.1 bkit-system/README.md

**Add v1.5.4 row to version history table:**

```markdown
| v1.5.4 | bkend MCP Accuracy Fix | MCP tools 19→28+, accurate tool names, dynamic Base URL, search_docs workflow |
```

**Correct Hook event count in architecture diagram:**

```
Current: Layer 1: hooks.json (Global) → SessionStart, UserPromptSubmit, PreCompact, PreToolUse, PostToolUse, Stop
Change:  Layer 1: hooks.json (Global) → SessionStart, UserPromptSubmit, PreCompact, PreToolUse, PostToolUse, Stop, SubagentStart, SubagentStop, TaskCompleted, TeammateIdle
```

### 8.2 bkit-system/_GRAPH-INDEX.md

**Add v1.5.4 entry (after v1.5.3):**

```markdown
### v1.5.4 (2026-02-14) - bkend MCP Accuracy Fix
- bkend MCP tool coverage: 19 → 28+ (Fixed 3 + Project 9 + Table 11 + Data CRUD 5)
- 5 bkend specialist skills updated (tool names/endpoints/workflow accuracy)
- bkend-patterns.md SSOT expansion: 85 lines → 140 lines
- session-start.js: Enterprise level bkend MCP status check added
- Comprehensive test: 764/765 PASS (100%)
```

### 8.3 bkit-system/components/agents/_agents-overview.md

**Complete the full list of 16 agents (currently only 11 listed):**

5 agents to add:
```markdown
| cto-lead | opus | acceptEdits | CTO Team orchestration, PDCA workflow management |
| frontend-architect | sonnet | plan | UI/UX design, component architecture |
| product-manager | sonnet | plan | Requirements analysis, feature prioritization |
| qa-strategist | sonnet | plan | Test strategy, quality metrics coordination |
| security-architect | opus | plan | Vulnerability analysis, auth design review |
```

**Correct model distribution:**

```
Current: (incomplete)
Change:  7 opus / 7 sonnet / 2 haiku, 9 acceptEdits / 7 plan
```

### 8.4 bkit-system/components/skills/_skills-overview.md

**Add bkend specialist skills v1.5.4 changes:**

```markdown
### v1.5.4 Changes (bkend MCP Accuracy Fix)
- Numbered tool names → real names transition (`0_get_context` → `get_context`)
- MCP tools categorized into 4 categories: Fixed(3), Project(9), Table(11), Data CRUD(5)
- Live Reference URL: `src/` → `en/` path structure transition
- New concepts: MCP Resources (`bkend://` URI), Searchable Docs (Doc ID)
```

### 8.5 bkit-system/components/hooks/_hooks-overview.md

**v1.5.4 change record:**

```markdown
### v1.5.4 Changes
- `session-start.js`: bkend MCP status check condition expanded (Dynamic → Dynamic || Enterprise)
```

### 8.6 bkit-system/components/scripts/_scripts-overview.md

**Function count correction:**

```
Current: v1.4.7 reference value 132 functions
Change:  241 functions (v1.5.3~v1.5.4)
```

**Export details (runtime verified values):**

| Module | Comment | Actual |
|------|:----:|:----:|
| core | 37 | **41** |
| pdca | 50 | **54** |
| intent | 19 | **19** |
| task | 26 | **26** |
| team | 39 | **40** |
| **bridge** | **180** | **180** |

### 8.7 bkit-system/testing/test-checklist.md

**Add v1.5.4 test section:**

```markdown
## v1.5.4 Tests (bkend MCP Accuracy)

### TC-V154: bkend MCP Change Verification (55 TC)

| ID | Test | Priority |
|----|--------|:--------:|
| V154-01 | Verify bkend-expert.md MCP tool count 28+ | P0 |
| V154-02 | MCP Fixed Tools (get_context, search_docs, get_operation_schema) exist | P0 |
| V154-03 | 9 MCP Project Management Tools exist | P0 |
| V154-04 | 11 MCP Table Management Tools exist | P0 |
| V154-05 | 5 MCP Data CRUD Tools exist | P0 |
| V154-06 | bkend-data SKILL: id (NOT _id) notation | P0 |
| V154-07 | bkend-data SKILL: filter operator $ prefix | P1 |
| V154-08 | bkend-auth SKILL: MCP Auth Workflow pattern exists | P0 |
| V154-09 | bkend-auth SKILL: 12 REST core endpoints | P1 |
| V154-10 | bkend-auth SKILL: single social login endpoint | P1 |
| V154-11 | bkend-storage SKILL: MCP Storage Workflow exists | P0 |
| V154-12 | bkend-storage SKILL: download-url POST method | P0 |
| V154-13 | bkend-storage SKILL: Multipart 4 endpoints | P1 |
| V154-14 | bkend-quickstart SKILL: real tool names (no numbered) | P0 |
| V154-15 | bkend-quickstart SKILL: Project Management 9 tools | P1 |
| V154-16 | bkend-quickstart SKILL: Resources 4 URIs | P1 |
| V154-17 | bkend-cookbook SKILL: en/ path URLs | P2 |
| V154-18 | bkend-patterns.md: 140+ lines | P1 |
| V154-19 | bkend-patterns.md: dynamic Base URL (no hardcoding) | P0 |
| V154-20 | session-start.js: Dynamic || Enterprise condition | P0 |
| V154-21~55 | Verify all Live Reference URLs use en/ paths (35 URLs) | P2 |
```

### 8.8 bkit-system/scenarios/scenario-discover-features.md

**Output Styles count correction:**

```
Current: 3 styles (bkit-learning, bkit-pdca-guide, bkit-enterprise)
Change:  4 styles (bkit-learning, bkit-pdca-guide, bkit-enterprise, bkit-pdca-enterprise)
```

**Agent Teams teammate count correction:**

```
Current: Dynamic (2 teammates), Enterprise (4 teammates)
Change:  Dynamic (3 teammates), Enterprise (5 teammates)
```

### 8.9 bkit-system/triggers/trigger-matrix.md

**Hook event count correction:**

```
Current: 6 main events (SessionStart, PreToolUse, PostToolUse, Stop, UserPromptSubmit, PreCompact)
Change:  10 events (+SubagentStart, SubagentStop, TaskCompleted, TeammateIdle)
```

---

## 9. Implementation Priority and Execution Plan

### Phase 1: Critical — Version Strings (Immediate)

| Order | File | Change Count |
|:----:|------|:------:|
| 1 | `.claude-plugin/plugin.json` | 1 |
| 2 | `.claude-plugin/marketplace.json` | 2 |
| 3 | `bkit.config.json` | 1 |
| 4 | `hooks/hooks.json` | 1 |
| 5 | `hooks/session-start.js` | 5 |
| 6 | `README.md` (badge only) | 1 |

**Subtotal: 6 files, 11 locations**

### Phase 2: High — CHANGELOG + Top-Level Documents

| Order | File | Change Content |
|:----:|------|----------|
| 7 | `CHANGELOG.md` | Add v1.5.4 release notes |
| 8 | `README.md` | Add v1.5.4 feature item |
| 9 | `CUSTOMIZATION-GUIDE.md` | Version reference + Compatibility update |

**Subtotal: 3 files**

### Phase 3: Medium — lib/ Comment Fixes

| Order | File | Comment Fix Count |
|:----:|------|:----------:|
| 10 | `lib/common.js` | 3 (module counts) + @version |
| 11 | `lib/core/index.js` | 2 (Platform, Cache) + @version |
| 12 | `lib/pdca/index.js` | 1 (header) + @version |
| 13 | `lib/intent/index.js` | @version only |
| 14 | `lib/task/index.js` | @version only |
| 15 | `lib/team/index.js` | 1 (Orchestrator) + @version |

**Subtotal: 6 files, 7 comments + 6 @version**

### Phase 4: Low — bkit-system/ Document Synchronization

| Order | File | Priority |
|:----:|------|:--------:|
| 16 | `bkit-system/README.md` | P1 |
| 17 | `bkit-system/_GRAPH-INDEX.md` | P1 |
| 18 | `bkit-system/components/agents/_agents-overview.md` | P1 |
| 19 | `bkit-system/components/skills/_skills-overview.md` | P1 |
| 20 | `bkit-system/components/hooks/_hooks-overview.md` | P2 |
| 21 | `bkit-system/components/scripts/_scripts-overview.md` | P2 |
| 22 | `bkit-system/testing/test-checklist.md` | P2 |
| 23 | `bkit-system/scenarios/scenario-discover-features.md` | P2 |
| 24 | `bkit-system/triggers/trigger-matrix.md` | P2 |
| 25 | `bkit-system/philosophy/core-mission.md` | P3 |
| 26 | `bkit-system/philosophy/context-engineering.md` | P3 |
| 27 | `bkit-system/scenarios/scenario-new-feature.md` | P3 |
| 28 | `bkit-system/scenarios/scenario-qa.md` | P3 |
| 29 | `bkit-system/triggers/priority-rules.md` | P3 |
| 30 | `bkit-system/philosophy/ai-native-principles.md` | P3 |
| 31 | `bkit-system/philosophy/pdca-methodology.md` | P3 |
| 32 | `bkit-system/scenarios/scenario-write-code.md` | P3 |

**Subtotal: 17 files (P1: 4, P2: 5, P3: 8)**

---

## 10. Verification Checklist

### 10.1 Version String Verification

```bash
# Check for remaining "1.5.3" across all files (excluding implementation files)
grep -r "1\.5\.3" --include="*.json" --include="*.js" --include="*.md" \
  --exclude-dir=docs --exclude-dir=node_modules \
  . | grep -v "CHANGELOG\|archive\|\.git"
```

**Expected result**: 0 matches (all `1.5.3` → `1.5.4` transitions complete)

### 10.2 Component Count Consistency

| Item | Verification Method | Expected Value |
|------|----------|:------:|
| Skills | `ls skills/*/SKILL.md \| wc -l` | 26 |
| Agents | `ls agents/*.md \| wc -l` | 16 |
| Scripts | `ls scripts/*.js \| wc -l` | 45 |
| Hook Events | `hooks.json` key count | 10 |
| lib/ exports | `node -e "console.log(Object.keys(require('./lib/common')).length)"` | 180 |
| Output Styles | `ls output-styles/*.md \| wc -l` | 4 |

### 10.3 lib/ Comment vs Actual Export Count Match Verification

```bash
# Actual export count for each module
node -e "console.log('core:', Object.keys(require('./lib/core')).length)"
node -e "console.log('pdca:', Object.keys(require('./lib/pdca')).length)"
node -e "console.log('intent:', Object.keys(require('./lib/intent')).length)"
node -e "console.log('task:', Object.keys(require('./lib/task')).length)"
node -e "console.log('team:', Object.keys(require('./lib/team')).length)"
```

**Expected result**: core:41, pdca:54, intent:19, task:26, team:40

### 10.4 bkit-system/ Document Synchronization Verification

| Verification Item | Target File Count | Verification Method |
|----------|:----------:|----------|
| v1.5.4 mention exists | 5 (P1) | grep "v1.5.4" |
| 10 Hook events | 3+ | grep "10 events\|10 hook" |
| All 16 Agents listed | 1 | Check agents-overview |
| 4 Output Styles | 2+ | grep "4 styles\|4 output" |

---

## 11. Risks and Considerations

### 11.1 No-Change Items Confirmation

The following items are **explicitly confirmed as unchanged** in v1.5.4:

| Item | Value | Same as v1.5.3 |
|------|:--:|:----------:|
| Skills count | 26 | YES |
| Agents count | 16 | YES |
| Scripts count | 45 | YES |
| Hook Events count | 10 | YES |
| common.js exports | 180 | YES |
| lib/ total function count | 241 | YES |
| Output Styles count | 4 | YES |
| Templates count | 27+1 | YES |

### 11.2 Agent Distribution Data Correction

**MEMORY.md correction needed** (based on comprehensive test report):

| Item | MEMORY.md (old) | Test Report (correct) | Correction |
|------|:-------------:|:----------------:|:----:|
| Agent model | "7 opus / 7 sonnet / 2 haiku" | 7/7/2 | Match |
| Permission mode | "9 acceptEdits / 7 plan" | 9/7 | Match |

### 11.3 Deferred Items (v1.5.5 and Later)

4 items carried over from the v1.5.4 completion report:

| ID | Content | Reason |
|----|------|------|
| GAP-A | bkend provider detection in `detectLevel` config | Out of scope |
| GAP-C | UserPromptHandler `> 0.8` vs `>= 0.8` comparison | Low severity |
| DEF-01 | bkend trigger pattern multilingual enhancement (EN 9 vs others 5) | Separate feature |
| DEF-02 | Magic Words (`!hotfix`, `!prototype`) implementation | Kept unimplemented |

---

## 12. Change Impact Analysis

### 12.1 Token Impact

| Target | Change | Token Impact |
|------|------|:---------:|
| Implementation files (8) | Already complete | +1,400 tokens |
| Version strings (17 locations) | Character substitution | 0 (same length) |
| CHANGELOG.md | ~60 lines added | +500 tokens |
| lib/ comments | Numbers only changed | 0 |
| bkit-system/ (17 files) | Sections/rows added | +800 tokens |
| **Total additional tokens** | | **~2,700 tokens** |

### 12.2 File Impact Matrix

```
Total changed files: 32
├── Phase 1 (Version strings): 6 ← Immediate
├── Phase 2 (CHANGELOG+top-level): 3 ← High
├── Phase 3 (lib/ comments): 6 ← Medium
└── Phase 4 (bkit-system/): 17 ← Low
    ├── P1: 4
    ├── P2: 5
    └── P3: 8
```

---

## Appendix A: Complete Changed File List

| # | File Path | Phase | Change Type |
|:-:|----------|:-----:|----------|
| 1 | `.claude-plugin/plugin.json` | 1 | Version 1.5.3→1.5.4 |
| 2 | `.claude-plugin/marketplace.json` | 1 | Version 1.5.3→1.5.4 (2 locations) |
| 3 | `bkit.config.json` | 1 | Version 1.5.3→1.5.4 |
| 4 | `hooks/hooks.json` | 1 | Description v1.5.3→v1.5.4 |
| 5 | `hooks/session-start.js` | 1 | v1.5.3→v1.5.4 (5 locations) |
| 6 | `README.md` | 1+2 | Badge+feature |
| 7 | `CHANGELOG.md` | 2 | v1.5.4 release notes |
| 8 | `CUSTOMIZATION-GUIDE.md` | 2 | Version reference+Compatibility |
| 9 | `lib/common.js` | 3 | 3 comment locations + @version |
| 10 | `lib/core/index.js` | 3 | 2 comment locations + @version |
| 11 | `lib/pdca/index.js` | 3 | Header comment + @version |
| 12 | `lib/intent/index.js` | 3 | @version |
| 13 | `lib/task/index.js` | 3 | @version |
| 14 | `lib/team/index.js` | 3 | 1 comment location + @version |
| 15 | `bkit-system/README.md` | 4-P1 | v1.5.4 history+Hook count |
| 16 | `bkit-system/_GRAPH-INDEX.md` | 4-P1 | v1.5.4 entry |
| 17 | `bkit-system/components/agents/_agents-overview.md` | 4-P1 | Full 16 agents listed |
| 18 | `bkit-system/components/skills/_skills-overview.md` | 4-P1 | v1.5.4 changes |
| 19 | `bkit-system/components/hooks/_hooks-overview.md` | 4-P2 | v1.5.4 change record |
| 20 | `bkit-system/components/scripts/_scripts-overview.md` | 4-P2 | Function count correction |
| 21 | `bkit-system/testing/test-checklist.md` | 4-P2 | v1.5.4 TC addition |
| 22 | `bkit-system/scenarios/scenario-discover-features.md` | 4-P2 | Metrics correction |
| 23 | `bkit-system/triggers/trigger-matrix.md` | 4-P2 | Hook event count correction |
| 24 | `bkit-system/philosophy/core-mission.md` | 4-P3 | "No Guessing" example |
| 25 | `bkit-system/philosophy/context-engineering.md` | 4-P3 | MCP accuracy significance |
| 26 | `bkit-system/philosophy/ai-native-principles.md` | 4-P3 | Agent distribution addition |
| 27 | `bkit-system/philosophy/pdca-methodology.md` | 4-P3 | Team PDCA mention |
| 28 | `bkit-system/scenarios/scenario-new-feature.md` | 4-P3 | Team scenario |
| 29 | `bkit-system/scenarios/scenario-qa.md` | 4-P3 | Team QA scenario |
| 30 | `bkit-system/scenarios/scenario-write-code.md` | 4-P3 | Agent Memory mention |
| 31 | `bkit-system/triggers/priority-rules.md` | 4-P3 | bkend trigger rules |
| 32 | `bkit-system/triggers/trigger-matrix.md` | 4-P2 | (Same as #23 above) |

**Unique file count: 31** (trigger-matrix.md duplicate removed)

---

## Appendix B: Runtime Verified Export Count

```
┌─────────────────────────────────────────────────────┐
│ lib/ Module Export Count (Runtime Verified)          │
├──────────┬──────────┬──────────┬───────────────────┤
│ Module   │ Comment  │ Actual   │ Stale?            │
├──────────┼──────────┼──────────┼───────────────────┤
│ core     │ 37       │ 41       │ YES (+4)          │
│ pdca     │ 50       │ 54       │ YES (+4)          │
│ intent   │ 19       │ 19       │ NO                │
│ task     │ 26       │ 26       │ NO                │
│ team     │ 39       │ 40       │ YES (+1)          │
├──────────┼──────────┼──────────┼───────────────────┤
│ TOTAL    │ 171      │ 180      │ Bridge correct    │
│ common.js│ 180      │ 180      │ NO (bridge OK)    │
└──────────┴──────────┴──────────┴───────────────────┘

Category details:
core/index.js:
  Platform: 8→9 (+isClaudeCode or getTemplatePath missing)
  Cache:    6→7 (+DEFAULT_TTL)
  IO:       9=9 (accurate)
  Debug:    3=3 (accurate)
  Config:   5=5 (accurate)
  File:     8=8 (accurate) [Total: 9+7+9+3+5+8=41]

pdca/index.js:
  Tier:        8=8
  Level:       7=7
  Phase:       9=9
  Status:      17→19 (+readBkitMemory, +writeBkitMemory)
  Automation:  11=11 [Total: 8+7+9+19+11=54]

team/index.js:
  Coordinator:    5=5
  Strategy:       2=2
  Hooks:          2=2
  Orchestrator:   5→6 (+shouldRecomposeTeam)
  Communication:  6=6
  TaskQueue:      5=5
  CtoLogic:       5=5
  StateWriter:    9=9 [Total: 5+2+2+6+6+5+5+9=40]
```

---

*End of design document*
*bkit v1.5.4 - POPUP STUDIO PTE. LTD.*
