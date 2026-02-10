# bkit v1.5.3 Comprehensive Functional Test Plan

> **Summary**: bkit v1.5.3 전체 기능 종합 테스트 (신규 team-visibility + 기존 전체 기능)
>
> **Project**: bkit-claude-code
> **Version**: 1.5.3
> **Author**: CTO Team (qa-strategist, code-analyzer, gap-detector)
> **Date**: 2026-02-09
> **Status**: Draft
> **Previous Test**: v1.5.2 (673 TC, 603 PASS, 3 FAIL, 67 SKIP, 99.5%)
> **Environment**: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1, claude --plugin-dir .
> **Branch**: feature/v1.5.3-cto-team-agent-enhancement

---

## 1. Background

### 1.1 Test Necessity

bkit v1.5.3은 v1.5.2 이후 다음 변경을 포함합니다:

| 변경 항목 | 상세 |
|-----------|------|
| team-visibility 신규 모듈 | lib/team/state-writer.js (9 exports) |
| SubagentStart Hook 추가 | scripts/subagent-start-handler.js |
| SubagentStop Hook 추가 | scripts/subagent-stop-handler.js |
| TeammateIdle Hook 개선 | state-writer 연동 추가 |
| hooks.json 확장 | 10 hook events (기존 8 + SubagentStart/SubagentStop 2개 추가) |
| team/index.js 확장 | state-writer 9 exports 추가 (31 -> 40) |
| common.js bridge 확장 | team state-writer 9 exports 추가 (162 -> 171) |
| bkit.config.json | team.enabled: true 기본값 변경 |
| unified-stop.js 개선 | team-stop.js 연동 |
| pdca-task-completed.js 개선 | state-writer progress 연동 |

### 1.2 Previous Test Results (v1.5.2)

| Metric | Value |
|--------|-------|
| Total TC | 673 |
| PASS | 603 |
| FAIL | 3 (BUG-01: confidence `> 0.8` vs `>= 0.8`, FIXED in v1.5.2) |
| SKIP | 67 (runtime-only 28, plan spec mismatch 14, file read limit 15, unimplemented 10) |
| Pass Rate (excl. SKIP) | 99.5% |

### 1.3 v1.5.3 Full Component Inventory

| Component | Count | Delta from v1.5.2 |
|-----------|:-----:|:---------:|
| Skills | 26 (21 core + 5 bkend) | 0 |
| Agents | 16 | 0 |
| Hook Events | 10 (hooks.json entries: 11) | +2 (SubagentStart, SubagentStop) |
| Scripts | 47 | +3 (subagent-start-handler, subagent-stop-handler, team-stop) |
| Library Functions (modular) | 241 across 11 modules | +9 (state-writer) |
| common.js bridge exports | 171 | +9 |
| Templates | 27 | 0 |
| Output Styles | 4 | +1 (bkit-pdca-enterprise) |
| Config Files | 2 (bkit.config.json + .bkit-memory.json) | 0 |

### 1.4 CTO Team Composition

| Role | Agent | Responsibility |
|------|-------|---------------|
| QA Strategist | qa-strategist | TC 설계, 테스트 전략, 커버리지 분석 |
| Code Analyzer | code-analyzer | 코드 정적 분석, 함수 시그니처 검증 |
| Gap Detector | gap-detector | Design vs Implementation gap 분석 |

Orchestration Pattern: Council (Check phase)

---

## 2. Goals

### 2.1 Must (P0)

| ID | Goal | Description | TC |
|:--:|------|-------------|:--:|
| G-01 | v1.5.3 New Feature Test | state-writer 9 exports + SubagentStart/Stop hooks | 45 |
| G-02 | Library Unit Test | 241 functions across 11 modules | 220 |
| G-03 | Hook Integration Test | 10 hook events, 11 entries, 47 scripts | 65 |
| G-04 | Agent Functional Test | 16 agents trigger, tools, delegation | 64 |
| G-05 | Skill Functional Test | 26 skills load, trigger, content | 80 |
| G-06 | PDCA Workflow Test | Plan-Design-Do-Check-Act-Report-Archive | 35 |

### 2.2 Should (P1)

| ID | Goal | Description | TC |
|:--:|------|-------------|:--:|
| G-07 | UX Flow Test | 4 user journeys (Onboarding/Dev/QA/Completion) | 40 |
| G-08 | Config & Template Test | bkit.config.json, templates, output-styles | 25 |
| G-09 | CTO Team Orchestration Test | Team composition, patterns, task queue | 30 |
| G-10 | Multi-Language Test | 8-language triggers + ambiguity detection | 24 |

### 2.3 Could (P2)

| ID | Goal | Description | TC |
|:--:|------|-------------|:--:|
| G-11 | Performance & Edge Case | Hook timeout, caching, error handling | 20 |
| G-12 | Regression Test | v1.5.2 FAIL/SKIP items re-verification | 10 |

### 2.4 TC Summary

| Priority | TC Count | Ratio |
|:--------:|:--------:|:-----:|
| P0 (Must) | 509 | 74% |
| P1 (Should) | 119 | 17% |
| P2 (Could) | 30 | 4% |
| **Total** | **658** | - |
| + Regression | 30 | 4% |
| **Grand Total** | **688** | **100%** |

---

## 3. Test Categories

### 3.1 TC-NEW: v1.5.3 New Feature Tests (45 TC)

#### TC-NEW-SW: State Writer Module (25 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| NEW-SW-01 | getAgentStatePath() returns correct path | (none) | `{PROJECT_DIR}/.bkit/agent-state.json` | P0 |
| NEW-SW-02 | readAgentState() returns null when no file | No agent-state.json | null | P0 |
| NEW-SW-03 | readAgentState() returns parsed JSON | Valid agent-state.json exists | AgentState object | P0 |
| NEW-SW-04 | readAgentState() returns null on invalid JSON | Corrupted file | null (graceful) | P0 |
| NEW-SW-05 | initAgentState() creates file with defaults | teamName="test", feature="feat" | File created, enabled=true, version="1.0" | P0 |
| NEW-SW-06 | initAgentState() sets pdcaPhase from options | options.pdcaPhase="design" | pdcaPhase="design" | P0 |
| NEW-SW-07 | initAgentState() sets orchestrationPattern | options.orchestrationPattern="swarm" | orchestrationPattern="swarm" | P0 |
| NEW-SW-08 | initAgentState() creates .bkit directory | .bkit/ not exists | Directory created recursively | P0 |
| NEW-SW-09 | addTeammate() appends to roster | teammateInfo with name/role/model | teammates array length +1 | P0 |
| NEW-SW-10 | addTeammate() sets status "spawning" | New teammate | status="spawning" | P0 |
| NEW-SW-11 | addTeammate() updates existing by name | Same name, different role | Updated in-place, startedAt preserved | P0 |
| NEW-SW-12 | addTeammate() enforces MAX_TEAMMATES=10 | 11th teammate | Skipped, array stays at 10 | P0 |
| NEW-SW-13 | addTeammate() without agent state | No init called | No crash, debugLog warning | P0 |
| NEW-SW-14 | updateTeammateStatus() changes status | name="agent-1", status="working" | teammate.status="working" | P0 |
| NEW-SW-15 | updateTeammateStatus() with taskInfo | taskInfo={task:"Plan"} | currentTask="Plan" | P0 |
| NEW-SW-16 | updateTeammateStatus() idle clears task | status="idle" | currentTask=null, taskId=null | P0 |
| NEW-SW-17 | updateTeammateStatus() unknown teammate | name="nonexistent" | No crash, debugLog warning | P0 |
| NEW-SW-18 | removeTeammate() removes by name | name="agent-1" | teammates.length -1 | P0 |
| NEW-SW-19 | removeTeammate() no-op for unknown | name="nonexistent" | No change, no crash | P0 |
| NEW-SW-20 | updateProgress() writes progress data | {total:10, completed:5} | progress.totalTasks=10, completedTasks=5 | P0 |
| NEW-SW-21 | addRecentMessage() appends message | {from:"cto", to:"all", content:"start"} | recentMessages.length +1 | P0 |
| NEW-SW-22 | addRecentMessage() ring buffer limit 50 | 51 messages | recentMessages.length = 50, oldest removed | P0 |
| NEW-SW-23 | cleanupAgentState() sets enabled=false | Active state | enabled=false, teammates=[] | P0 |
| NEW-SW-24 | cleanupAgentState() preserves progress | Active state with progress | progress and recentMessages retained | P0 |
| NEW-SW-25 | Atomic write (tmp + rename) | Concurrent access | No partial writes, .tmp cleaned up | P1 |

#### TC-NEW-HK: SubagentStart/Stop Hooks (15 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| NEW-HK-01 | subagent-start-handler.js loads | (execution) | No require errors | P0 |
| NEW-HK-02 | SubagentStart extracts agent_name | hookContext.agent_name="detector" | agentName="detector" | P0 |
| NEW-HK-03 | SubagentStart fallback to agent_id | agent_name missing, agent_id="id-1" | agentName="id-1" | P0 |
| NEW-HK-04 | SubagentStart model mapping | model="opus" | model="opus" (valid) | P0 |
| NEW-HK-05 | SubagentStart invalid model fallback | model="gpt-4" | model="sonnet" (default) | P0 |
| NEW-HK-06 | SubagentStart auto-init state | No existing agent-state.json | initAgentState() called | P0 |
| NEW-HK-07 | SubagentStart skip init if active | Existing enabled state | No re-init, addTeammate only | P0 |
| NEW-HK-08 | SubagentStart outputs JSON response | (execution) | JSON with hookEventName="SubagentStart" | P0 |
| NEW-HK-09 | subagent-stop-handler.js loads | (execution) | No require errors | P0 |
| NEW-HK-10 | SubagentStop success detection | transcript_path present | status="completed" | P0 |
| NEW-HK-11 | SubagentStop failure detection | exit_code=1 | status="failed" | P0 |
| NEW-HK-12 | SubagentStop updates teammate status | agentName="agent-1" | updateTeammateStatus called | P0 |
| NEW-HK-13 | SubagentStop updates progress | Active state with feature | updateProgress called | P0 |
| NEW-HK-14 | SubagentStop outputs JSON response | (execution) | JSON with hookEventName="SubagentStop" | P0 |
| NEW-HK-15 | SubagentStop graceful on no team module | require fails | outputAllow, no crash | P1 |

#### TC-NEW-INT: Integration with Existing Modules (5 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| NEW-INT-01 | team/index.js exports state-writer 9 | require('lib/team') | 40 total exports, 9 state-writer | P0 |
| NEW-INT-02 | common.js bridge includes state-writer | require('lib/common') | 171 exports, state-writer accessible | P0 |
| NEW-INT-03 | hooks.json has SubagentStart entry | Read hooks.json | SubagentStart array with command | P0 |
| NEW-INT-04 | hooks.json has SubagentStop entry | Read hooks.json | SubagentStop array with command | P0 |
| NEW-INT-05 | TeammateIdle handler writes idle status | hookContext with teammate_id | updateTeammateStatus(id, "idle") called | P0 |

---

### 3.2 TC-LIB: Library Unit Tests (220 TC)

#### TC-LIB-CORE: Core Module - 41 exports (50 TC)

##### platform.js (9 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CORE-P01 | detectPlatform() returns "claude-code" | process.env | "claude-code" | P0 |
| LIB-CORE-P02 | BKIT_PLATFORM constant | (none) | String "claude-code" | P0 |
| LIB-CORE-P03 | isClaudeCode() returns true | (none) | true | P0 |
| LIB-CORE-P04 | PLUGIN_ROOT absolute path | (none) | Valid absolute path string | P0 |
| LIB-CORE-P05 | PROJECT_DIR absolute path | (none) | Valid absolute path to project | P0 |
| LIB-CORE-P06 | BKIT_PROJECT_DIR matches PROJECT_DIR | (none) | Same as PROJECT_DIR | P0 |
| LIB-CORE-P07 | getPluginPath(rel) resolves | "skills/pdca" | Absolute path ending with skills/pdca | P0 |
| LIB-CORE-P08 | getProjectPath(rel) resolves | "docs" | Absolute path ending with docs | P0 |
| LIB-CORE-P09 | getTemplatePath(name) resolves | "plan.template.md" | Path to templates dir | P0 |
| LIB-CORE-P10 | PLUGIN_ROOT contains plugin files | (none) | skills/, agents/, hooks/ exist | P0 |

##### cache.js (7 exports, 8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CORE-C01 | set() stores value | key="test", value="data" | No error | P0 |
| LIB-CORE-C02 | get() retrieves stored value | key="test" | "data" | P0 |
| LIB-CORE-C03 | get() returns undefined for missing | key="nonexistent" | undefined | P0 |
| LIB-CORE-C04 | invalidate() removes key | key="test" | get() returns undefined | P0 |
| LIB-CORE-C05 | clear() removes all | (none) | All keys removed | P0 |
| LIB-CORE-C06 | DEFAULT_TTL is number | (none) | typeof === "number", > 0 | P0 |
| LIB-CORE-C07 | globalCache is object | (none) | typeof === "object" | P1 |
| LIB-CORE-C08 | _cache is Map | (none) | instanceof Map | P1 |

##### io.js (9 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CORE-I01 | MAX_CONTEXT_LENGTH is 500 | (none) | 500 | P0 |
| LIB-CORE-I02 | truncateContext() short string | "hello" (5 chars) | "hello" unchanged | P0 |
| LIB-CORE-I03 | truncateContext() long string | 600-char string | Truncated to MAX_CONTEXT_LENGTH | P0 |
| LIB-CORE-I04 | outputAllow() format | context="test", source="Hook" | JSON with decision/message | P0 |
| LIB-CORE-I05 | outputBlock() format | reason="denied" | JSON with block decision | P0 |
| LIB-CORE-I06 | outputEmpty() format | (none) | Empty/minimal JSON output | P0 |
| LIB-CORE-I07 | parseHookInput() valid JSON | '{"tool":"Write"}' | Parsed object | P0 |
| LIB-CORE-I08 | parseHookInput() invalid JSON | "not json" | Graceful handling | P0 |
| LIB-CORE-I09 | xmlSafeOutput() escapes entities | String with <>&" | Escaped output | P0 |
| LIB-CORE-I10 | readStdinSync() callable | (none) | Function exists, callable | P1 |

##### debug.js (3 exports, 4 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CORE-D01 | debugLog() no crash | module="Test", msg="ok" | No error | P0 |
| LIB-CORE-D02 | DEBUG_LOG_PATHS is object | (none) | Object with path entries | P0 |
| LIB-CORE-D03 | getDebugLogPath() returns path | (none) | String path | P0 |
| LIB-CORE-D04 | debugLog() with metadata | module="Test", msg="ok", {key:"val"} | No error | P1 |

##### config.js (5 exports, 8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CORE-CF01 | loadConfig() returns object | (none) | Object (not null) | P0 |
| LIB-CORE-CF02 | getConfig() key retrieval | "pdca.matchRateThreshold" | 90 | P0 |
| LIB-CORE-CF03 | getConfig() missing key | "nonexistent.key" | Default value | P0 |
| LIB-CORE-CF04 | getConfigArray() returns array | "sourceDirectories" | Array with "src", "lib" | P0 |
| LIB-CORE-CF05 | getBkitConfig() returns full config | (none) | Object with version, pdca, etc. | P0 |
| LIB-CORE-CF06 | safeJsonParse() valid JSON | '{"a":1}' | {a:1} | P0 |
| LIB-CORE-CF07 | safeJsonParse() invalid JSON | "broken" | null or default | P0 |
| LIB-CORE-CF08 | getBkitConfig() has team section | (none) | team.enabled, team.maxTeammates | P0 |

##### file.js (8 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CORE-F01 | TIER_EXTENSIONS is object | (none) | Keys: tier1, tier2, etc. | P0 |
| LIB-CORE-F02 | isSourceFile() .js | "app.js" | true | P0 |
| LIB-CORE-F03 | isSourceFile() .md | "README.md" | false | P0 |
| LIB-CORE-F04 | isCodeFile() .ts | "index.ts" | true | P0 |
| LIB-CORE-F05 | isUiFile() .tsx | "App.tsx" | true | P0 |
| LIB-CORE-F06 | isUiFile() .py | "main.py" | false | P0 |
| LIB-CORE-F07 | isEnvFile() .env | ".env" | true | P0 |
| LIB-CORE-F08 | extractFeature() from path | "docs/01-plan/features/auth.plan.md" | "auth" | P0 |
| LIB-CORE-F09 | DEFAULT_EXCLUDE_PATTERNS array | (none) | Array with "node_modules" etc. | P0 |
| LIB-CORE-F10 | DEFAULT_FEATURE_PATTERNS array | (none) | Array with feature patterns | P1 |

#### TC-LIB-PDCA: PDCA Module - 54 exports (60 TC)

##### tier.js (8 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-PDCA-T01 | getLanguageTier("javascript") | "javascript" | 1 (Tier 1) | P0 |
| LIB-PDCA-T02 | getLanguageTier("go") | "go" | 2 (Tier 2) | P0 |
| LIB-PDCA-T03 | getLanguageTier("swift") | "swift" | 3 (Tier 3) | P0 |
| LIB-PDCA-T04 | getLanguageTier("cobol") | "cobol" | 4 (Tier 4) | P0 |
| LIB-PDCA-T05 | isTier1("typescript") | "typescript" | true | P0 |
| LIB-PDCA-T06 | isTier2("rust") | "rust" | true | P0 |
| LIB-PDCA-T07 | isTier3("kotlin") | "kotlin" | true | P0 |
| LIB-PDCA-T08 | isTier4("fortran") | "fortran" | true | P0 |
| LIB-PDCA-T09 | isExperimentalTier() | (varies) | Boolean | P1 |
| LIB-PDCA-T10 | getTierDescription(1) | 1 | String description | P1 |

##### level.js (7 exports, 12 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-PDCA-L01 | detectLevel() Dynamic | Project with lib/bkend/ | "Dynamic" | P0 |
| LIB-PDCA-L02 | detectLevel() Enterprise | Project with kubernetes/ | "Enterprise" | P0 |
| LIB-PDCA-L03 | detectLevel() Starter | Empty project | "Starter" | P0 |
| LIB-PDCA-L04 | LEVEL_PHASE_MAP has 3 levels | (none) | Starter, Dynamic, Enterprise keys | P0 |
| LIB-PDCA-L05 | canSkipPhase() Starter phase 4 | "Starter", 4 | true (API skip) | P0 |
| LIB-PDCA-L06 | canSkipPhase() Enterprise phase 4 | "Enterprise", 4 | false (all phases) | P0 |
| LIB-PDCA-L07 | getRequiredPhases("Starter") | "Starter" | Subset of 9 phases | P0 |
| LIB-PDCA-L08 | getRequiredPhases("Enterprise") | "Enterprise" | All 9 phases | P0 |
| LIB-PDCA-L09 | getNextPhaseForLevel() | "Dynamic", 3 | Next valid phase | P0 |
| LIB-PDCA-L10 | isPhaseApplicable() | "Starter", 8 | false (review skip) | P0 |
| LIB-PDCA-L11 | getLevelPhaseGuide() | "Dynamic" | Guide string | P1 |
| LIB-PDCA-L12 | detectLevel() with .mcp.json | .mcp.json present | "Dynamic" | P0 |

##### phase.js (9 exports, 12 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-PDCA-PH01 | PDCA_PHASES constant | (none) | Array ["plan","design","do","check","act"] | P0 |
| LIB-PDCA-PH02 | getPhaseNumber("plan") | "plan" | 1 | P0 |
| LIB-PDCA-PH03 | getPhaseNumber("act") | "act" | 5 | P0 |
| LIB-PDCA-PH04 | getPhaseName(1) | 1 | "plan" | P0 |
| LIB-PDCA-PH05 | getNextPdcaPhase("design") | "design" | "do" | P0 |
| LIB-PDCA-PH06 | getPreviousPdcaPhase("check") | "check" | "do" | P0 |
| LIB-PDCA-PH07 | findDesignDoc() with existing doc | Feature with design doc | Path to design doc | P0 |
| LIB-PDCA-PH08 | findPlanDoc() with existing doc | Feature with plan doc | Path to plan doc | P0 |
| LIB-PDCA-PH09 | checkPhaseDeliverables(number) | Phase 1 | Deliverables list | P0 |
| LIB-PDCA-PH10 | checkPhaseDeliverables(string) | "plan" | Deliverables list | P0 |
| LIB-PDCA-PH11 | validatePdcaTransition() valid | "plan" -> "design" | {valid: true} | P0 |
| LIB-PDCA-PH12 | validatePdcaTransition() invalid | "plan" -> "check" | {valid: false} | P0 |

##### status.js (19 exports, 16 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-PDCA-S01 | getPdcaStatusPath() | (none) | Path to .pdca-status.json | P0 |
| LIB-PDCA-S02 | createInitialStatusV2() | (none) | V2 status with version:"2.0" | P0 |
| LIB-PDCA-S03 | getPdcaStatusFull() | (none) | Full status object | P0 |
| LIB-PDCA-S04 | loadPdcaStatus() | (none) | Status object or null | P0 |
| LIB-PDCA-S05 | savePdcaStatus() | Status object | File written | P0 |
| LIB-PDCA-S06 | getFeatureStatus() existing | "pdca" | Feature status object | P0 |
| LIB-PDCA-S07 | getFeatureStatus() missing | "nonexistent" | null or undefined | P0 |
| LIB-PDCA-S08 | updatePdcaStatus() | feature, phase, file | Updated status | P0 |
| LIB-PDCA-S09 | addPdcaHistory() | feature, phase, action | History entry added | P0 |
| LIB-PDCA-S10 | setActiveFeature() | "new-feature" | primaryFeature updated | P0 |
| LIB-PDCA-S11 | addActiveFeature() | "feature-x" | activeFeatures includes "feature-x" | P0 |
| LIB-PDCA-S12 | removeActiveFeature() | "feature-x" | activeFeatures excludes "feature-x" | P0 |
| LIB-PDCA-S13 | getActiveFeatures() | (none) | Array of feature names | P0 |
| LIB-PDCA-S14 | switchFeatureContext() | "other-feature" | primaryFeature changed | P0 |
| LIB-PDCA-S15 | readBkitMemory() | (none) | .bkit-memory.json contents | P0 |
| LIB-PDCA-S16 | writeBkitMemory() | Updated memory | File written | P0 |

##### automation.js (11 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-PDCA-A01 | getAutomationLevel() | (none) | "manual"/"semi-auto"/"full-auto" | P0 |
| LIB-PDCA-A02 | isFullAutoMode() | (none) | Boolean | P0 |
| LIB-PDCA-A03 | shouldAutoAdvance() plan | "plan" phase completed | true (advance to design) | P0 |
| LIB-PDCA-A04 | shouldAutoAdvance() check 90% | check, matchRate=95 | true (to report) | P0 |
| LIB-PDCA-A05 | shouldAutoAdvance() check <70% | check, matchRate=60 | true (to act) | P0 |
| LIB-PDCA-A06 | generateAutoTrigger() | Phase context | Trigger suggestion | P0 |
| LIB-PDCA-A07 | formatAskUserQuestion() | Question text | Formatted question | P0 |
| LIB-PDCA-A08 | detectPdcaFromTaskSubject() | "[Plan] auth" | {phase:"plan", feature:"auth"} | P0 |
| LIB-PDCA-A09 | getNextPdcaActionAfterCompletion() | "plan", feature | "design" suggestion | P0 |
| LIB-PDCA-A10 | shouldAutoStartPdca() | User prompt context | Boolean | P1 |

#### TC-LIB-INTENT: Intent Module - 19 exports (30 TC)

##### language.js (6 exports, 12 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-INT-L01 | SUPPORTED_LANGUAGES count | (none) | 8 languages | P0 |
| LIB-INT-L02 | SUPPORTED_LANGUAGES includes "ko" | (none) | true | P0 |
| LIB-INT-L03 | detectLanguage("hello") | "hello world" | "en" | P0 |
| LIB-INT-L04 | detectLanguage("안녕") | "안녕하세요" | "ko" | P0 |
| LIB-INT-L05 | detectLanguage("hola") | "hola mundo" | "es" | P0 |
| LIB-INT-L06 | AGENT_TRIGGER_PATTERNS count | (none) | 7+ agent patterns | P0 |
| LIB-INT-L07 | SKILL_TRIGGER_PATTERNS count | (none) | 4+ skill patterns | P0 |
| LIB-INT-L08 | getAllPatterns() | (none) | Combined patterns object | P0 |
| LIB-INT-L09 | matchMultiLangPattern() Korean | "코드 리뷰해줘" | code-analyzer match | P0 |
| LIB-INT-L10 | matchMultiLangPattern() Japanese | "設計レビュー" | design-validator match | P1 |
| LIB-INT-L11 | matchMultiLangPattern() Chinese | "安全扫描" | security-architect match | P1 |
| LIB-INT-L12 | matchMultiLangPattern() German | "Sicherheitscheck" | Appropriate match | P2 |

##### trigger.js (5 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-INT-TR01 | matchImplicitAgentTrigger() Korean | "검증해줘" | {agent:"gap-detector", confidence>=0.8} | P0 |
| LIB-INT-TR02 | matchImplicitAgentTrigger() English | "review the code" | {agent:"code-analyzer"} | P0 |
| LIB-INT-TR03 | matchImplicitAgentTrigger() confidence | "bkend" | confidence >= 0.8 | P0 |
| LIB-INT-TR04 | matchImplicitAgentTrigger() no match | "hello world" | null or low confidence | P0 |
| LIB-INT-TR05 | matchImplicitSkillTrigger() | "API 설계" | {skill:"phase-4-api"} | P0 |
| LIB-INT-TR06 | matchImplicitSkillTrigger() no match | "random text" | null or low confidence | P0 |
| LIB-INT-TR07 | detectNewFeatureIntent() positive | "새 기능 만들어줘" | {isNewFeature:true} | P0 |
| LIB-INT-TR08 | detectNewFeatureIntent() negative | "이 버그 수정해줘" | {isNewFeature:false} | P0 |
| LIB-INT-TR09 | extractFeatureNameFromRequest() | "로그인 기능 추가" | "login" or similar | P0 |
| LIB-INT-TR10 | NEW_FEATURE_PATTERNS constant | (none) | Array of pattern objects | P0 |

##### ambiguity.js (8 exports, 8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-INT-AM01 | calculateAmbiguityScore() clear | "login 페이지 src/app/login에 만들어" | score < 50 | P0 |
| LIB-INT-AM02 | calculateAmbiguityScore() ambiguous | "이거 좀 고쳐줘" | score >= 50, shouldClarify | P0 |
| LIB-INT-AM03 | containsFilePath() positive | "src/app/page.tsx 수정" | true | P0 |
| LIB-INT-AM04 | containsTechnicalTerms() positive | "REST API endpoint" | true | P0 |
| LIB-INT-AM05 | hasSpecificNouns() positive | "LoginButton component" | true | P0 |
| LIB-INT-AM06 | hasScopeDefinition() positive | "src/ 폴더 내" | true | P0 |
| LIB-INT-AM07 | hasMultipleInterpretations() | "이거 바꿔줘" | true (ambiguous) | P0 |
| LIB-INT-AM08 | generateClarifyingQuestions() | Ambiguous text | Array of questions | P0 |

#### TC-LIB-TASK: Task Module - 26 exports (30 TC)

##### classification.js (6 exports, 8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TASK-CL01 | classifyTask() quick fix | "fix typo" (8 chars) | "quickFix" | P0 |
| LIB-TASK-CL02 | classifyTask() minor change | 100-char description | "minorChange" | P0 |
| LIB-TASK-CL03 | classifyTask() feature | 500-char description | "feature" | P0 |
| LIB-TASK-CL04 | classifyTask() major feature | 1200-char description | "majorFeature" | P0 |
| LIB-TASK-CL05 | classifyTaskByLines() | 5 lines | Appropriate classification | P0 |
| LIB-TASK-CL06 | CLASSIFICATION_THRESHOLDS | (none) | {quickFix:50, minorChange:200, feature:1000} | P0 |
| LIB-TASK-CL07 | getPdcaLevel() | "feature" classification | "Standard" | P0 |
| LIB-TASK-CL08 | getPdcaGuidance() | "majorFeature" | Guidance string | P0 |

##### context.js (7 exports, 7 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TASK-CX01 | setActiveSkill() | "pdca" | No error | P0 |
| LIB-TASK-CX02 | getActiveSkill() | After setActiveSkill | "pdca" | P0 |
| LIB-TASK-CX03 | setActiveAgent() | "gap-detector" | No error | P0 |
| LIB-TASK-CX04 | getActiveAgent() | After setActiveAgent | "gap-detector" | P0 |
| LIB-TASK-CX05 | clearActiveContext() | After setting | getActiveSkill()=null | P0 |
| LIB-TASK-CX06 | getActiveContext() | With active skill | {skill, agent} | P0 |
| LIB-TASK-CX07 | hasActiveContext() | With active agent | true | P0 |

##### creator.js (6 exports, 8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TASK-CR01 | generatePdcaTaskSubject() | "plan", "auth" | "[Plan] auth" | P0 |
| LIB-TASK-CR02 | generatePdcaTaskSubject() design | "design", "auth" | "[Design] auth" | P0 |
| LIB-TASK-CR03 | generatePdcaTaskDescription() | phase, feature | Description string | P0 |
| LIB-TASK-CR04 | getPdcaTaskMetadata() | phase, feature | {phase, feature, ...} | P0 |
| LIB-TASK-CR05 | generateTaskGuidance() | phase context | Guidance text | P0 |
| LIB-TASK-CR06 | createPdcaTaskChain() | feature | Array of task objects | P0 |
| LIB-TASK-CR07 | autoCreatePdcaTask() | phase, feature | Task created | P0 |
| LIB-TASK-CR08 | createPdcaTaskChain() blockedBy | feature | Chain with dependencies | P0 |

##### tracker.js (7 exports, 7 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TASK-TK01 | savePdcaTaskId() | feature, phase, id | Stored | P0 |
| LIB-TASK-TK02 | getPdcaTaskId() | feature, phase | Stored ID | P0 |
| LIB-TASK-TK03 | getTaskChainStatus() | feature | Chain status object | P0 |
| LIB-TASK-TK04 | updatePdcaTaskStatus() | feature, phase, status | Updated | P0 |
| LIB-TASK-TK05 | triggerNextPdcaAction() | feature, current phase | Next action suggestion | P0 |
| LIB-TASK-TK06 | findPdcaStatus() | feature | Status object | P0 |
| LIB-TASK-TK07 | getCurrentPdcaPhase() | feature | Current phase string | P0 |

#### TC-LIB-TEAM: Team Module - 40 exports (50 TC)

##### coordinator.js (5 exports, 7 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-CO01 | isTeamModeAvailable() | ENV var set | true | P0 |
| LIB-TEAM-CO02 | isTeamModeAvailable() | ENV var unset | false | P0 |
| LIB-TEAM-CO03 | getTeamConfig() | (none) | {enabled, maxTeammates, ...} | P0 |
| LIB-TEAM-CO04 | generateTeamStrategy("Dynamic") | "Dynamic" | {teammates:3, roles:[...]} | P0 |
| LIB-TEAM-CO05 | generateTeamStrategy("Enterprise") | "Enterprise" | {teammates:5, roles:[...]} | P0 |
| LIB-TEAM-CO06 | formatTeamStatus() | (none) | Formatted status string | P0 |
| LIB-TEAM-CO07 | suggestTeamMode() | Long prompt | {suggest:true/false, reason} | P0 |

##### strategy.js (2 exports, 5 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-ST01 | TEAM_STRATEGIES has 4 patterns | (none) | leader, council, swarm, watchdog | P0 |
| LIB-TEAM-ST02 | getTeammateRoles("Dynamic") | "Dynamic" | 3 roles | P0 |
| LIB-TEAM-ST03 | getTeammateRoles("Enterprise") | "Enterprise" | 5 roles | P0 |
| LIB-TEAM-ST04 | getTeammateRoles("Starter") | "Starter" | Empty/null (no team) | P0 |
| LIB-TEAM-ST05 | TEAM_STRATEGIES structure | (none) | Each has description, roles | P1 |

##### hooks.js (2 exports, 4 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-HK01 | assignNextTeammateWork() | teammateId, pdcaStatus | Task assignment or null | P0 |
| LIB-TEAM-HK02 | assignNextTeammateWork() no tasks | All tasks done | null | P0 |
| LIB-TEAM-HK03 | handleTeammateIdle() with tasks | Idle teammate, pending tasks | Next task info | P0 |
| LIB-TEAM-HK04 | handleTeammateIdle() no tasks | All complete | Cleanup suggestion | P0 |

##### orchestrator.js (6 exports, 8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-OR01 | PHASE_PATTERN_MAP structure | (none) | 5 phases mapped to patterns | P0 |
| LIB-TEAM-OR02 | selectOrchestrationPattern() Dynamic plan | "Dynamic", "plan" | "leader" | P0 |
| LIB-TEAM-OR03 | selectOrchestrationPattern() Enterprise check | "Enterprise", "check" | "council" | P0 |
| LIB-TEAM-OR04 | composeTeamForPhase() | "Dynamic", "do" | Team composition | P0 |
| LIB-TEAM-OR05 | generateSpawnTeamCommand() | Team config | Command string | P0 |
| LIB-TEAM-OR06 | createPhaseContext() | Phase, feature | Context object | P0 |
| LIB-TEAM-OR07 | shouldRecomposeTeam() | Phase change | Boolean | P0 |
| LIB-TEAM-OR08 | selectOrchestrationPattern() Enterprise do | "Enterprise", "do" | "swarm" | P0 |

##### communication.js (6 exports, 6 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-CM01 | MESSAGE_TYPES constant | (none) | Has directive, broadcast, etc. | P0 |
| LIB-TEAM-CM02 | createMessage() | from, to, content | Message object | P0 |
| LIB-TEAM-CM03 | createBroadcast() | from, content | Broadcast to all | P0 |
| LIB-TEAM-CM04 | createPhaseTransitionNotice() | from, newPhase | Transition notice | P0 |
| LIB-TEAM-CM05 | createPlanDecision() | decision, reason | Decision object | P0 |
| LIB-TEAM-CM06 | createDirective() | from, to, directive | Directive message | P0 |

##### task-queue.js (5 exports, 6 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-TQ01 | createTeamTasks() | feature, phase | Array of tasks | P0 |
| LIB-TEAM-TQ02 | assignTaskToRole() | task, role | Assignment | P0 |
| LIB-TEAM-TQ03 | getTeamProgress() | feature | {total, completed, ...} | P0 |
| LIB-TEAM-TQ04 | findNextAvailableTask() | feature | Next pending task | P0 |
| LIB-TEAM-TQ05 | findNextAvailableTask() none | All done | null | P0 |
| LIB-TEAM-TQ06 | isPhaseComplete() | feature, phase | Boolean | P0 |

##### cto-logic.js (5 exports, 5 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-TEAM-CL01 | decidePdcaPhase() | Check results | Phase recommendation | P0 |
| LIB-TEAM-CL02 | evaluateDocument() | Document content | Quality score | P0 |
| LIB-TEAM-CL03 | evaluateCheckResults() >=90% | matchRate=95 | "proceed to report" | P0 |
| LIB-TEAM-CL04 | selectAgentsForRole() | "qa" | Agent list | P0 |
| LIB-TEAM-CL05 | recommendTeamComposition() | Feature context | Composition plan | P0 |

##### state-writer.js (9 exports) -- covered in TC-NEW-SW above

#### TC-LIB-STANDALONE: Standalone Modules (30 TC)

##### skill-orchestrator.js (12 exports, 10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-SO-01 | parseSkillFrontmatter() valid | YAML frontmatter content | {frontmatter, body} | P0 |
| LIB-SO-02 | parseSkillFrontmatter() no frontmatter | Plain markdown | {frontmatter:{}, body} | P0 |
| LIB-SO-03 | getSkillConfig() existing skill | "pdca" | Config object with name, imports | P0 |
| LIB-SO-04 | getSkillConfig() missing skill | "nonexistent" | null | P0 |
| LIB-SO-05 | parseAgentsField() multi-binding | agents:{analyze:"gap-detector"} | {_isMultiBinding:true} | P0 |
| LIB-SO-06 | parseAgentsField() single | agent:"starter-guide" | {default:"starter-guide"} | P0 |
| LIB-SO-07 | getAgentForAction() | "pdca", "analyze" | "gap-detector" | P0 |
| LIB-SO-08 | getLinkedAgents() | "pdca" | Array of agent names | P0 |
| LIB-SO-09 | isMultiBindingSkill() | "pdca" | true | P0 |
| LIB-SO-10 | SKILL_CACHE_TTL value | (none) | 30000 (30s) | P1 |

##### context-fork.js (9 exports, 6 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CF-01 | forkContext() creates fork | "gap-detector" | {forkId, context} | P0 |
| LIB-CF-02 | getForkedContext() retrieves | forkId | Forked state object | P0 |
| LIB-CF-03 | isForkedExecution() true | Active forkId | true | P0 |
| LIB-CF-04 | discardFork() removes | forkId | isForkedExecution=false | P0 |
| LIB-CF-05 | getActiveForks() lists all | Multiple forks | Array of fork metadata | P0 |
| LIB-CF-06 | clearAllForks() | (none) | All forks removed | P0 |

##### context-hierarchy.js (10 exports, 6 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-CH-01 | LEVEL_PRIORITY order | (none) | plugin=1 < user=2 < project=3 < session=4 | P0 |
| LIB-CH-02 | getContextHierarchy() | (none) | {levels, merged, conflicts} | P0 |
| LIB-CH-03 | getHierarchicalConfig() | "pdca.matchRateThreshold" | 90 | P0 |
| LIB-CH-04 | setSessionContext() / get | key, value | Stored and retrieved | P0 |
| LIB-CH-05 | clearSessionContext() | (none) | All session context cleared | P0 |
| LIB-CH-06 | invalidateCache() | (none) | Cache cleared | P1 |

##### import-resolver.js (10 exports, 4 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-IR-01 | resolveVariables() PLUGIN_ROOT | "${PLUGIN_ROOT}/templates" | Absolute path | P0 |
| LIB-IR-02 | detectCircularImport() | Same file twice | true | P0 |
| LIB-IR-03 | processMarkdownWithImports() | Skill file with imports | {content, errors:[]} | P0 |
| LIB-IR-04 | IMPORT_CACHE_TTL value | (none) | 30000 (30s) | P1 |

##### memory-store.js (10 exports, 4 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-MS-01 | getMemory() / setMemory() | key, value | Stored and retrieved | P0 |
| LIB-MS-02 | deleteMemory() | existing key | true, key removed | P0 |
| LIB-MS-03 | getAllMemory() | (none) | Full memory object | P0 |
| LIB-MS-04 | hasMemory() | existing key | true | P0 |

##### permission-manager.js (10 exports, 4 TC) -- SKIP not available in all tests

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| LIB-PM-01 | checkPermission("Write") | "Write" | "allow" | P0 |
| LIB-PM-02 | checkPermission("Bash", "rm -rf /") | "Bash", "rm -rf /" | "deny" | P0 |
| LIB-PM-03 | shouldBlock("Bash", "rm -rf /") | "Bash", "rm -rf /" | {blocked:true} | P0 |
| LIB-PM-04 | PERMISSION_LEVELS structure | (none) | {deny:0, ask:1, allow:2} | P0 |

---

### 3.3 TC-HK: Hooks Integration Tests (65 TC)

#### TC-HK-SS: SessionStart (8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-SS-01 | once: true execution | Session start | Executes once per session | P0 |
| HK-SS-02 | detectLevel() accuracy | Project structure | Correct level detection | P0 |
| HK-SS-03 | Enhanced onboarding branch | Existing PDCA vs new | Correct option presentation | P0 |
| HK-SS-04 | Trigger table generation | (none) | Agent + Skill trigger keywords | P0 |
| HK-SS-05 | bkend MCP status check | Dynamic level | MCP connection status displayed | P0 |
| HK-SS-06 | Agent Teams notice | (none) | CTO Team availability shown | P0 |
| HK-SS-07 | Output Style suggestion | (none) | Level-appropriate style suggested | P0 |
| HK-SS-08 | Session count increment | (none) | sessionCount +1 in .bkit-memory.json | P0 |

#### TC-HK-UP: UserPromptSubmit (10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-UP-01 | New feature detection | "새 기능 만들어줘" | /pdca plan suggestion | P0 |
| HK-UP-02 | Agent trigger confidence >= 0.8 | "검증해줘" | Agent suggestion (BUG-01 regression) | P0 |
| HK-UP-03 | Skill trigger confidence > 0.75 | "API 설계" | Skill suggestion | P0 |
| HK-UP-04 | bkend MCP recommendation | Dynamic + no MCP | MCP setup guide | P0 |
| HK-UP-05 | Ambiguity score >= 50 | "이거 고쳐줘" | Clarification suggestion | P0 |
| HK-UP-06 | Ambiguity score < 50 | Clear specific request | No clarification needed | P0 |
| HK-UP-07 | Team mode suggestion | Long prompt (>=1000) | suggestTeamMode() triggered | P0 |
| HK-UP-08 | Short prompt skip | "hi" (2 chars) | outputEmpty, no processing | P0 |
| HK-UP-09 | checkBkendMcpConfig() | .mcp.json with bkend | true | P0 |
| HK-UP-10 | 3000ms timeout compliance | (execution) | Completes within timeout | P1 |

#### TC-HK-PTU: PreToolUse (8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-PTU-01 | pre-write.js on Write | Write tool event | Script executes | P0 |
| HK-PTU-02 | pre-write.js on Edit | Edit tool event | Script executes | P0 |
| HK-PTU-03 | Task classification by lines | Code file write | Task size classification | P0 |
| HK-PTU-04 | Design doc check | Feature without design | Design creation suggestion | P0 |
| HK-PTU-05 | Non-blocking (Automation First) | (any) | Suggest only, never block | P0 |
| HK-PTU-06 | unified-bash-pre.js | Bash tool event | Safety check executed | P0 |
| HK-PTU-07 | Destructive command detection | "rm -rf /" | Block or warn | P0 |
| HK-PTU-08 | Phase 9 deploy safety | "kubectl delete" | Block | P0 |

#### TC-HK-POTU: PostToolUse (8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-POTU-01 | unified-write-post.js | Write completed | PDCA tracking updated | P0 |
| HK-POTU-02 | pdca-post-write.js | Write to source file | PDCA status updated | P0 |
| HK-POTU-03 | unified-bash-post.js | Bash completed | Post-processing | P0 |
| HK-POTU-04 | skill-post.js | Skill executed | Next step suggestion | P0 |
| HK-POTU-05 | Active context set | Skill execution | setActiveSkill() called | P0 |
| HK-POTU-06 | Phase 5 design tracking | Design file write | phase5-design-post.js | P1 |
| HK-POTU-07 | Phase 6 UI tracking | UI file write | phase6-ui-post.js | P1 |
| HK-POTU-08 | QA command tracking | QA execution | qa-monitor-post.js | P1 |

#### TC-HK-STOP: Stop Hook (10 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-STOP-01 | unified-stop.js handler registry | (none) | 10+ Skill + 6+ Agent handlers | P0 |
| HK-STOP-02 | Skill handler dispatch | Active skill="pdca" | pdca-skill-stop.js executed | P0 |
| HK-STOP-03 | Agent handler dispatch | Active agent="gap-detector" | gap-detector-stop.js executed | P0 |
| HK-STOP-04 | gap-detector-stop.js | Match rate data | Phase transition logic | P0 |
| HK-STOP-05 | iterator-stop.js | Iteration result | Iteration status check | P0 |
| HK-STOP-06 | cto-stop.js | Team state | Team state saved | P0 |
| HK-STOP-07 | team-stop.js (v1.5.3) | Team session | cleanupAgentState() called | P0 |
| HK-STOP-08 | clearActiveContext() | Stop event | Context cleaned | P0 |
| HK-STOP-09 | 10000ms timeout compliance | (execution) | Completes within timeout | P1 |
| HK-STOP-10 | No active context | No skill/agent active | Default handler, no error | P0 |

#### TC-HK-TASK: TaskCompleted + TeammateIdle (8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-TASK-01 | PDCA task pattern detection | "[Plan] auth" completed | Phase extracted | P0 |
| HK-TASK-02 | Feature name extraction | Task subject | Feature name | P0 |
| HK-TASK-03 | shouldAutoAdvance() check | Phase completion | Auto-advance decision | P0 |
| HK-TASK-04 | Plan to Design auto-advance | Plan completed | Design suggestion | P0 |
| HK-TASK-05 | Check to Act/Report branch | Match rate | Correct branch | P0 |
| HK-TASK-06 | TeammateIdle detection | Idle teammate event | State updated to "idle" | P0 |
| HK-TASK-07 | Next task assignment | Idle + pending tasks | findNextAvailableTask() | P0 |
| HK-TASK-08 | All tasks complete | No pending | Cleanup suggestion | P0 |

#### TC-HK-SA: SubagentStart/Stop (covered in TC-NEW-HK, 0 additional)

#### TC-HK-OTHER: PreCompact + Misc (5 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-OTHER-01 | context-compaction.js | PreCompact event | PDCA snapshot preserved | P0 |
| HK-OTHER-02 | Snapshot restoration | Session restart | State restored | P0 |
| HK-OTHER-03 | Unified hooks pattern | GitHub #9354 | No duplicate execution | P0 |
| HK-OTHER-04 | Active context tracking | Multiple tool uses | Consistent context | P0 |
| HK-OTHER-05 | Hook timeout compliance | All hooks | Within 5000ms/10000ms | P1 |

#### TC-HK-JSON: hooks.json Validation (8 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| HK-JSON-01 | Valid JSON schema | hooks.json | Parses without error | P0 |
| HK-JSON-02 | 10 hook event types | hooks.json keys | SessionStart, PreToolUse, PostToolUse, Stop, UserPromptSubmit, PreCompact, TaskCompleted, SubagentStart, SubagentStop, TeammateIdle | P0 |
| HK-JSON-03 | 11 hook entries total | All entries | Count = 11 (PreToolUse 2, PostToolUse 3, others 1 each) | P0 |
| HK-JSON-04 | All command paths valid | Each command path | Script file exists | P0 |
| HK-JSON-05 | SessionStart once:true | SessionStart config | once: true | P0 |
| HK-JSON-06 | PreToolUse matchers correct | Write/Edit, Bash | Matcher patterns valid | P0 |
| HK-JSON-07 | PostToolUse matchers correct | Write, Bash, Skill | 3 matcher entries | P0 |
| HK-JSON-08 | Timeout values present | All entries | timeout: 3000-10000 | P0 |

---

### 3.4 TC-AG: Agent Functional Tests (64 TC)

#### TC-AG-CORE: Core Agents (20 TC)

| ID | Agent | Test Case | Expected Result | Priority |
|----|-------|-----------|-----------------|:--------:|
| AG-CORE-01 | gap-detector | Trigger "검증해줘" | confidence >= 0.8 | P0 |
| AG-CORE-02 | gap-detector | Design vs Implementation compare | Match Rate calculated | P0 |
| AG-CORE-03 | gap-detector | context:fork isolation | Main context unaffected | P0 |
| AG-CORE-04 | gap-detector | Stop hook execution | gap-detector-stop.js runs | P0 |
| AG-CORE-05 | pdca-iterator | Trigger "개선해줘" | confidence >= 0.8 | P0 |
| AG-CORE-06 | pdca-iterator | Auto iteration max 5 | Respects maxIterations | P0 |
| AG-CORE-07 | pdca-iterator | skills_preload | pdca + bkit-rules loaded | P0 |
| AG-CORE-08 | pdca-iterator | Stop hook | iterator-stop.js runs | P0 |
| AG-CORE-09 | code-analyzer | Trigger "분석해줘" | confidence >= 0.8 | P0 |
| AG-CORE-10 | code-analyzer | Read-only permissions | Write/Edit blocked | P0 |
| AG-CORE-11 | code-analyzer | skills_preload 3 | convention, review, code-review | P0 |
| AG-CORE-12 | report-generator | Trigger "보고서 작성" | confidence >= 0.8 | P0 |
| AG-CORE-13 | report-generator | Report generation | report.template.md based | P0 |
| AG-CORE-14 | report-generator | haiku model | Model = haiku | P0 |
| AG-CORE-15 | design-validator | Design doc validation | Section completeness check | P0 |
| AG-CORE-16 | design-validator | context:fork isolation | Independent execution | P0 |
| AG-CORE-17 | starter-guide | Trigger "도움" | confidence >= 0.8 | P0 |
| AG-CORE-18 | starter-guide | user scope memory | Cross-project persistence | P0 |
| AG-CORE-19 | pipeline-guide | Pipeline guidance | 9-phase order | P0 |
| AG-CORE-20 | pipeline-guide | user scope memory | Cross-project persistence | P0 |

#### TC-AG-BK: bkend Expert Agent (12 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| AG-BK-01 | Trigger "백엔드 서비스" | 2-word phrase | confidence >= 0.8 | P0 |
| AG-BK-02 | Trigger "bkend" | Direct keyword | Exact match | P0 |
| AG-BK-03 | 6 skills binding | Agent file | dynamic + 5 bkend skills | P0 |
| AG-BK-04 | skills_preload 3 | Agent file | bkend-data, auth, storage | P0 |
| AG-BK-05 | 19 MCP tools documented | Agent content | Guide 8 + API 11 | P0 |
| AG-BK-06 | REST API 23+ endpoints | Agent content | Auth + Data + Storage | P0 |
| AG-BK-07 | RBAC 4 levels | Agent content | admin/user/self/guest | P0 |
| AG-BK-08 | Troubleshooting 12+ items | Agent content | Error scenarios | P0 |
| AG-BK-09 | Agent delegation 5 items | Agent content | infra/enterprise/security/frontend/code-analyzer | P0 |
| AG-BK-10 | Do NOT use for boundaries | Agent content | static/infra/K8s/CI-CD | P0 |
| AG-BK-11 | OAuth 2.1 + PKCE | Agent content | No API key | P0 |
| AG-BK-12 | MCP setup guide | Agent content | `claude mcp add bkend` | P0 |

#### TC-AG-CTO: CTO Team Agents (16 TC)

| ID | Agent | Test Case | Expected Result | Priority |
|----|-------|-----------|-----------------|:--------:|
| AG-CTO-01 | cto-lead | opus model | model: opus | P0 |
| AG-CTO-02 | cto-lead | acceptEdits permission | Edit tools accessible | P0 |
| AG-CTO-03 | cto-lead | 11+ Task tools | Expert agent invocation | P0 |
| AG-CTO-04 | cto-lead | Trigger "팀 구성" | confidence >= 0.8 | P0 |
| AG-CTO-05 | product-manager | Plan writing capability | Read/Write/Edit tools | P0 |
| AG-CTO-06 | product-manager | skills: pdca, bkit-templates | Binding verified | P0 |
| AG-CTO-07 | frontend-architect | sonnet model, acceptEdits | UI design/implementation | P0 |
| AG-CTO-08 | frontend-architect | Phase 3/5/6 binding | linked-from-skills correct | P0 |
| AG-CTO-09 | security-architect | opus model, plan mode | Security review | P0 |
| AG-CTO-10 | security-architect | Phase 7 binding | linked-from-skills correct | P0 |
| AG-CTO-11 | qa-strategist | Task delegation 3 agents | qa-monitor, gap-detector, code-analyzer | P0 |
| AG-CTO-12 | qa-strategist | Phase 8 binding | linked-from-skills correct | P0 |
| AG-CTO-13 | enterprise-expert | opus, acceptEdits | AI Native strategy | P0 |
| AG-CTO-14 | infra-architect | opus, Bash tool | Infrastructure design | P0 |
| AG-CTO-15 | qa-monitor | haiku, Bash tool | Log monitoring | P0 |
| AG-CTO-16 | All 16 agents | 8-language triggers | All agents have multilang | P0 |

#### TC-AG-DEL: Agent Delegation (16 TC)

| ID | From | To | Test Case | Priority |
|----|------|-----|-----------|:--------:|
| AG-DEL-01 | cto-lead | product-manager | Plan delegation | P0 |
| AG-DEL-02 | cto-lead | frontend-architect | Design delegation | P0 |
| AG-DEL-03 | cto-lead | bkend-expert | Implementation delegation | P0 |
| AG-DEL-04 | cto-lead | qa-strategist | QA delegation | P0 |
| AG-DEL-05 | cto-lead | report-generator | Report delegation | P0 |
| AG-DEL-06 | qa-strategist | qa-monitor | Log verification | P0 |
| AG-DEL-07 | qa-strategist | gap-detector | Gap analysis | P0 |
| AG-DEL-08 | qa-strategist | code-analyzer | Code analysis | P0 |
| AG-DEL-09 | enterprise-expert | infra-architect | Infra delegation | P0 |
| AG-DEL-10 | bkend-expert | infra-architect | K8s/Docker delegation | P0 |
| AG-DEL-11 | bkend-expert | enterprise-expert | Microservices delegation | P0 |
| AG-DEL-12 | bkend-expert | code-analyzer | Code quality delegation | P0 |
| AG-DEL-13 | pdca-iterator | gap-detector | Re-verification | P0 |
| AG-DEL-14 | security-architect | code-analyzer | Code security | P0 |
| AG-DEL-15 | gap-detector | (none) | No delegation (read-only) | P0 |
| AG-DEL-16 | report-generator | (none) | No delegation (report only) | P0 |

---

### 3.5 TC-SK: Skills Functional Tests (80 TC)

#### TC-SK-LV: Level Skills (9 TC)

| ID | Skill | Test Case | Expected Result | Priority |
|----|-------|-----------|-----------------|:--------:|
| SK-LV-01 | starter | Frontmatter valid | name, description, agent, allowed-tools | P0 |
| SK-LV-02 | starter | 8-language trigger | Static website, 정적 웹, 静的サイト | P0 |
| SK-LV-03 | starter | user-invocable: true | Direct user invocation | P0 |
| SK-LV-04 | dynamic | Frontmatter valid | agent: bkend-expert | P0 |
| SK-LV-05 | dynamic | MCP config type:http | .mcp.json type:"http" | P0 |
| SK-LV-06 | dynamic | REST bkendFetch pattern | OAuth 2.1 client pattern | P0 |
| SK-LV-07 | enterprise | agents multi-binding | default, infra, security, architecture | P0 |
| SK-LV-08 | enterprise | 8-language trigger | Microservices keywords | P0 |
| SK-LV-09 | enterprise | AI Native 10-Day | Development methodology | P0 |

#### TC-SK-PL: Pipeline Phase Skills (27 TC)

| ID | Phase | Test Case | Expected Result | Priority |
|----|-------|-----------|-----------------|:--------:|
| SK-PL-01 | phase-1-schema | next-skill: phase-2 | Pipeline link | P0 |
| SK-PL-02 | phase-1-schema | Template import | Content loaded | P0 |
| SK-PL-03 | phase-1-schema | pdca-phase: plan | PDCA mapping | P0 |
| SK-PL-04 | phase-2-convention | next-skill: phase-3 | Pipeline link | P0 |
| SK-PL-05 | phase-2-convention | Clean Architecture | Layer guide included | P0 |
| SK-PL-06 | phase-2-convention | Naming conventions | Shared import loaded | P0 |
| SK-PL-07 | phase-3-mockup | agents multi-binding | pipeline-guide + frontend-architect | P0 |
| SK-PL-08 | phase-3-mockup | WebSearch tool | UI/UX trend research | P0 |
| SK-PL-09 | phase-3-mockup | pdca-phase: design | PDCA mapping | P0 |
| SK-PL-10 | phase-4-api | agent: qa-monitor | QA agent binding | P0 |
| SK-PL-11 | phase-4-api | BaaS implementation guide | Dynamic 5-step section | P0 |
| SK-PL-12 | phase-4-api | Zero Script QA | Log-based verification | P0 |
| SK-PL-13 | phase-5-design-system | Platform-agnostic | shadcn/ui, tokens | P0 |
| SK-PL-14 | phase-5-design-system | agents multi-binding | pipeline + frontend | P0 |
| SK-PL-15 | phase-5-design-system | pdca-phase: do | PDCA mapping | P0 |
| SK-PL-16 | phase-6-ui-integration | API Client Architecture | Service pattern | P0 |
| SK-PL-17 | phase-6-ui-integration | State Management | Zustand/Context guide | P0 |
| SK-PL-18 | phase-6-ui-integration | agents multi-binding | pipeline + frontend | P0 |
| SK-PL-19 | phase-7-seo-security | agents multi-binding | code-analyzer + security | P0 |
| SK-PL-20 | phase-7-seo-security | OWASP Top 10 | Security checklist | P0 |
| SK-PL-21 | phase-7-seo-security | SEO Meta Tags | SEO guide included | P0 |
| SK-PL-22 | phase-8-review | 5-agent binding | code-analyzer, design-validator, gap-detector, qa-strategist, cto-lead | P0 |
| SK-PL-23 | phase-8-review | Cross-phase verification | Architecture consistency | P0 |
| SK-PL-24 | phase-8-review | pdca-phase: check | PDCA mapping | P0 |
| SK-PL-25 | phase-9-deployment | agent: infra-architect | Deploy expert binding | P0 |
| SK-PL-26 | phase-9-deployment | CI/CD guide | GitHub Actions, Docker | P0 |
| SK-PL-27 | phase-9-deployment | pdca-phase: act | PDCA mapping | P0 |

#### TC-SK-BK: bkend Expert Skills (20 TC)

| ID | Skill | Test Case | Expected Result | Priority |
|----|-------|-----------|-----------------|:--------:|
| SK-BK-01 | bkend-quickstart | Frontmatter valid | user-invocable:false, agent:bkend-expert | P0 |
| SK-BK-02 | bkend-quickstart | imports bkend-patterns.md | Shared template reference | P0 |
| SK-BK-03 | bkend-quickstart | MCP setup guide | `claude mcp add bkend --transport http` | P0 |
| SK-BK-04 | bkend-quickstart | Resource hierarchy | Org/Project/Environment | P0 |
| SK-BK-05 | bkend-data | mcp__bkend__* allowed-tools | MCP wildcard tools | P0 |
| SK-BK-06 | bkend-data | 7 column types | String through Mixed | P0 |
| SK-BK-07 | bkend-data | 11 MCP DB tools | backend_table_create etc. | P0 |
| SK-BK-08 | bkend-data | REST Data API 5 endpoints | CRUD operations | P0 |
| SK-BK-09 | bkend-data | Filtering 8 operators | eq, ne, gt, gte, lt, lte, in, nin | P0 |
| SK-BK-10 | bkend-auth | 4 auth methods | Email, Google, GitHub, Magic Link | P0 |
| SK-BK-11 | bkend-auth | JWT token structure | Access 1h, Refresh 7d | P0 |
| SK-BK-12 | bkend-auth | RBAC 4 groups | admin, user, self, guest | P0 |
| SK-BK-13 | bkend-auth | REST Auth API 18 endpoints | signup through sessions | P0 |
| SK-BK-14 | bkend-storage | 3 upload methods | Single, Multiple, Multipart | P0 |
| SK-BK-15 | bkend-storage | 4 visibility levels | public, private, protected, shared | P0 |
| SK-BK-16 | bkend-storage | Size limits | Image 10MB, Video 100MB, Doc 20MB | P0 |
| SK-BK-17 | bkend-storage | Presigned URL flow | 3-step upload | P0 |
| SK-BK-18 | bkend-cookbook | 10 single project guides | Todo through SaaS | P0 |
| SK-BK-19 | bkend-cookbook | 4 full guide projects | Blog, Recipe, Shopping, Social | P0 |
| SK-BK-20 | bkend-cookbook | Troubleshooting 8 errors | 401 through MCP errors | P0 |

#### TC-SK-UT: Utility & Meta Skills (24 TC)

| ID | Skill | Test Case | Expected Result | Priority |
|----|-------|-----------|-----------------|:--------:|
| SK-UT-01 | pdca | plan command | Plan template generation | P0 |
| SK-UT-02 | pdca | design command | Level-specific design template | P0 |
| SK-UT-03 | pdca | analyze command | gap-detector routing | P0 |
| SK-UT-04 | pdca | iterate command | pdca-iterator routing | P0 |
| SK-UT-05 | pdca | report command | report-generator routing | P0 |
| SK-UT-06 | pdca | archive command | Archive process execution | P0 |
| SK-UT-07 | pdca | cleanup command | Archive cleanup | P0 |
| SK-UT-08 | pdca | status command | Current status display | P0 |
| SK-UT-09 | pdca | next command | Next phase guidance | P0 |
| SK-UT-10 | pdca | team command | CTO Team creation | P0 |
| SK-UT-11 | development-pipeline | Pipeline start | 9-phase guide | P0 |
| SK-UT-12 | development-pipeline | Phase progression | next-skill auto-link | P0 |
| SK-UT-13 | code-review | Execution | code-analyzer binding | P0 |
| SK-UT-14 | code-review | Result format | Quality/Security/Performance | P0 |
| SK-UT-15 | zero-script-qa | Execution | qa-monitor binding | P0 |
| SK-UT-16 | zero-script-qa | Log-based verification | Docker logs monitoring | P0 |
| SK-UT-17 | mobile-app | Mobile guide | React Native/Flutter/Expo | P1 |
| SK-UT-18 | desktop-app | Desktop guide | Electron/Tauri | P1 |
| SK-UT-19 | bkit-rules | Auto-apply | PDCA, Level, Agent rules | P0 |
| SK-UT-20 | bkit-templates | Template provision | Plan/Design/Analysis/Report | P0 |
| SK-UT-21 | claude-code-learning | Learning start | 6-step learning course | P1 |
| SK-UT-22 | claude-code-learning | Learning progress | Level-specific curriculum | P1 |
| SK-UT-23 | All Skills | 8-language triggers | All skills have multilang | P0 |
| SK-UT-24 | All Skills | allowed-tools consistency | Only specified tools accessible | P0 |

---

### 3.6 TC-PDCA: PDCA Workflow Tests (35 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| PDCA-01 | Plan to Design transition | Plan completed | Design suggestion | P0 |
| PDCA-02 | Design to Do transition | Design completed | Implementation guide | P0 |
| PDCA-03 | Do to Check transition | Implementation done | Gap Analysis suggestion | P0 |
| PDCA-04 | Check to Act (< 70%) | matchRate=60 | pdca-iterator strong recommendation | P0 |
| PDCA-05 | Check to Act (70-89%) | matchRate=80 | 3 options presented | P0 |
| PDCA-06 | Check to Report (>= 90%) | matchRate=95 | Report suggestion | P0 |
| PDCA-07 | Act to Check re-run | Iterator done | gap-detector re-execution | P0 |
| PDCA-08 | Report to Archive | Report done | Archive execution | P0 |
| PDCA-09 | Archive to Cleanup | Archived | Cleanup execution | P0 |
| PDCA-10 | Max 5 iterations | 5 iterations | Stops at maxIterations | P0 |
| PDCA-11 | Task chain auto-creation | Feature start | [Plan]->[Design]->[Do]->[Check]->[Act] | P0 |
| PDCA-12 | Task blockedBy dependency | Chain creation | Correct ordering | P0 |
| PDCA-13 | Multi-feature support | 2+ features | Simultaneous tracking | P0 |
| PDCA-14 | Feature switching | setActiveFeature() | Context switches | P0 |
| PDCA-15 | Status display | /pdca status | Phase + Rate + Tasks | P0 |
| PDCA-16 | Starter plan template | Starter level | Simplified plan | P0 |
| PDCA-17 | Dynamic design template | Dynamic level | design.template.md | P0 |
| PDCA-18 | Enterprise design template | Enterprise level | design-enterprise.template.md | P0 |
| PDCA-19 | Analysis template | Gap analysis | analysis.template.md | P0 |
| PDCA-20 | Report template | Report generation | report.template.md | P0 |
| PDCA-21 | Pipeline phase PDCA | Phase = PDCA cycle | Each phase is PDCA | P0 |
| PDCA-22 | Pipeline phase order | Phase 1-9 | next-skill chain intact | P0 |
| PDCA-23 | Pipeline level branching | Starter/Dynamic/Enterprise | Different phase sets | P0 |
| PDCA-24 | Pipeline status display | /pipeline-status | Current phase shown | P0 |
| PDCA-25 | Pipeline next progression | /pipeline-next | Next phase guidance | P0 |
| PDCA-26 | Plan doc BaaS option | Dynamic level | BaaS integration mention | P1 |
| PDCA-27 | Design doc BaaS architecture | Dynamic level | BaaS diagram included | P1 |
| PDCA-28 | Design doc MongoDB schema | Dynamic level | Collection schema | P1 |
| PDCA-29 | Phase-4 BaaS guide | Dynamic level | 5-step implementation | P1 |
| PDCA-30 | .bkit-memory.json tracking | Phase change | Auto-update | P0 |
| PDCA-31 | History recording | PDCA action | Timestamp + action + details | P0 |
| PDCA-32 | Archive --summary option | Archive with flag | Metrics preserved | P0 |
| PDCA-33 | Archive index update | Archive execution | _INDEX.md created | P0 |
| PDCA-34 | Cleanup all | /pdca cleanup all | All archived removed | P0 |
| PDCA-35 | Cleanup selective | /pdca cleanup {feature} | Specific feature removed | P0 |

---

### 3.7 TC-UX: User Experience Flow Tests (40 TC)

#### TC-UX-ON: Onboarding Flow (10 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| UX-ON-01 | First session start | Welcome message with options | P1 |
| UX-ON-02 | Returning user with PDCA | Continue/New/Status options | P1 |
| UX-ON-03 | New user guidance | Learn/Setup/Start options | P1 |
| UX-ON-04 | Level detection display | Level explicitly shown | P1 |
| UX-ON-05 | Trigger keyword table | Agent + Skill triggers listed | P1 |
| UX-ON-06 | Agent Teams notice | Team availability shown | P1 |
| UX-ON-07 | Output Style suggestion | Level-matched style | P1 |
| UX-ON-08 | Agent Memory notice | Auto-active confirmation | P1 |
| UX-ON-09 | bkend MCP status (Dynamic) | Connection status shown | P1 |
| UX-ON-10 | bkit feature usage report | Response footer with features | P1 |

#### TC-UX-DEV: Development Flow (10 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| UX-DEV-01 | Feature request recognition | PDCA Plan suggestion | P1 |
| UX-DEV-02 | Plan auto-generation | Template-based document | P1 |
| UX-DEV-03 | Design auto-generation | Level-specific template | P1 |
| UX-DEV-04 | Implementation guide | Design-based order | P1 |
| UX-DEV-05 | Convention auto-apply | Naming rule hints | P1 |
| UX-DEV-06 | Task classification | Size-based PDCA level | P1 |
| UX-DEV-07 | PDCA status tracking | Phase auto-update | P1 |
| UX-DEV-08 | Next phase guidance | Accurate next step | P1 |
| UX-DEV-09 | Pipeline phase order | next-skill progression | P1 |
| UX-DEV-10 | Skill trigger detection | "API 설계" -> phase-4-api | P1 |

#### TC-UX-QA: QA & Verification Flow (10 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| UX-QA-01 | Gap Analysis execution | gap-detector runs | P1 |
| UX-QA-02 | Match Rate display | 0-100% with item detail | P1 |
| UX-QA-03 | 90%+ completion path | Report suggestion | P1 |
| UX-QA-04 | 70-89% options path | 3 choices presented | P1 |
| UX-QA-05 | <70% strong recommendation | pdca-iterator urged | P1 |
| UX-QA-06 | Auto-iteration execution | Max 5 iterations | P1 |
| UX-QA-07 | Post-iteration re-check | gap-detector re-runs | P1 |
| UX-QA-08 | Code review execution | code-analyzer runs | P1 |
| UX-QA-09 | Zero Script QA | qa-monitor log verification | P1 |
| UX-QA-10 | Design validation | design-validator runs | P1 |

#### TC-UX-COMP: Completion Flow (10 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| UX-COMP-01 | Report generation | report-generator runs | P1 |
| UX-COMP-02 | Report completeness | Plan/Design/Impl/Analysis | P1 |
| UX-COMP-03 | Archive execution | docs/archive/ move | P1 |
| UX-COMP-04 | Archive --summary | Metrics preserved | P1 |
| UX-COMP-05 | Cleanup execution | Archive cleanup | P1 |
| UX-COMP-06 | Status display | Progress visualization | P1 |
| UX-COMP-07 | Version history | Document history updated | P1 |
| UX-COMP-08 | Memory completion | phase="completed" | P1 |
| UX-COMP-09 | Next feature transition | Previous state maintained | P1 |
| UX-COMP-10 | Cross-session persistence | State restored on restart | P1 |

---

### 3.8 TC-CFG: Config & Template Tests (25 TC)

#### TC-CFG-MAIN: bkit.config.json (15 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| CFG-MAIN-01 | version field | "1.5.2" (or updated) | P1 |
| CFG-MAIN-02 | sourceDirectories 7 entries | src, lib, app, components, pages, features, services | P1 |
| CFG-MAIN-03 | codeExtensions 8 types | .ts, .tsx, .js, .jsx, .py, .go, .rs, .java | P1 |
| CFG-MAIN-04 | pdca.matchRateThreshold | 90 | P0 |
| CFG-MAIN-05 | pdca.maxIterations | 5 | P0 |
| CFG-MAIN-06 | pdca.autoIterate | true | P0 |
| CFG-MAIN-07 | team.enabled | true | P0 |
| CFG-MAIN-08 | team.maxTeammates | 5 | P0 |
| CFG-MAIN-09 | team.ctoAgent | "cto-lead" | P0 |
| CFG-MAIN-10 | team.orchestrationPatterns Dynamic | plan:leader, do:swarm, check:council | P0 |
| CFG-MAIN-11 | team.orchestrationPatterns Enterprise | design:council, act:watchdog | P0 |
| CFG-MAIN-12 | automation.supportedLanguages 8 | en, ko, ja, zh, es, fr, de, it | P1 |
| CFG-MAIN-13 | permissions.Write | "allow" | P0 |
| CFG-MAIN-14 | permissions.Bash(rm -rf*) | "deny" | P0 |
| CFG-MAIN-15 | outputStyles.available 4 | pdca-guide, learning, enterprise, pdca-enterprise | P0 |

#### TC-CFG-OS: Output Styles (6 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| CFG-OS-01 | bkit-learning.md exists | File present, valid markdown | P1 |
| CFG-OS-02 | bkit-pdca-guide.md exists | File present, valid markdown | P1 |
| CFG-OS-03 | bkit-enterprise.md exists | File present, valid markdown | P1 |
| CFG-OS-04 | bkit-pdca-enterprise.md exists | File present, valid markdown | P1 |
| CFG-OS-05 | Level default mapping | Starter->learning, Dynamic->pdca-guide, Enterprise->enterprise | P1 |
| CFG-OS-06 | outputStyles directory | output-styles/ contains 4 files | P1 |

#### TC-CFG-TMPL: Templates (4 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| CFG-TMPL-01 | plan.template.md exists | Template with required sections | P1 |
| CFG-TMPL-02 | design.template.md exists | Template with required sections | P1 |
| CFG-TMPL-03 | analysis.template.md exists | Template with required sections | P1 |
| CFG-TMPL-04 | report.template.md exists | Template with required sections | P1 |

---

### 3.9 TC-TEAM: CTO Team Orchestration Tests (30 TC)

| ID | Test Case | Input | Expected Result | Priority |
|----|-----------|-------|-----------------|:--------:|
| TEAM-01 | Dynamic team: 3 teammates | Dynamic level | developer, qa, frontend | P1 |
| TEAM-02 | Enterprise team: 5 teammates | Enterprise level | architect, developer, qa, reviewer, security | P1 |
| TEAM-03 | Starter: no team | Starter level | Team mode unavailable | P1 |
| TEAM-04 | Leader pattern (Plan) | Dynamic plan phase | CTO distributes tasks | P1 |
| TEAM-05 | Swarm pattern (Do) | Dynamic do phase | Parallel implementation | P1 |
| TEAM-06 | Council pattern (Check) | Dynamic check phase | Multi-perspective review | P1 |
| TEAM-07 | Watchdog pattern (Act) | Enterprise act phase | Continuous monitoring | P1 |
| TEAM-08 | Phase transition broadcast | Phase change | All teammates notified | P1 |
| TEAM-09 | Task queue creation | Feature start | Tasks for all roles | P1 |
| TEAM-10 | Task assignment by role | Role match | Correct task routing | P1 |
| TEAM-11 | Team progress tracking | Multiple tasks | Progress percentage | P1 |
| TEAM-12 | Phase completion check | All tasks done | isPhaseComplete=true | P1 |
| TEAM-13 | Team recomposition | Phase transition | New team if needed | P1 |
| TEAM-14 | CTO plan approval | Plan submitted | approvePlan/rejectPlan | P1 |
| TEAM-15 | Quality gate enforcement | matchRate < 90% | Cannot proceed to report | P1 |
| TEAM-16 | Agent selection for role | "qa" role | qa-monitor, gap-detector, code-analyzer | P1 |
| TEAM-17 | Team composition recommendation | Feature context | Optimal team suggested | P1 |
| TEAM-18 | Message creation | 1:1 message | {from, to, content, timestamp} | P1 |
| TEAM-19 | Broadcast creation | Phase announcement | All teammates receive | P1 |
| TEAM-20 | Directive creation | CTO directive | {from, to, directive} | P1 |
| TEAM-21 | State writer init on team start | /pdca team feature | agent-state.json created | P0 |
| TEAM-22 | Teammate added on spawn | SubagentStart | addTeammate() called | P0 |
| TEAM-23 | Teammate status on work | Working state | status="working" | P0 |
| TEAM-24 | Teammate removed on stop | SubagentStop | removeTeammate() or status update | P0 |
| TEAM-25 | Progress updated on completion | Task done | updateProgress() called | P0 |
| TEAM-26 | State cleanup on session end | Session stop | cleanupAgentState() | P0 |
| TEAM-27 | decidePdcaPhase() logic | Check results | Correct phase decision | P1 |
| TEAM-28 | evaluateCheckResults() >= 90% | matchRate=95 | Proceed to report | P1 |
| TEAM-29 | evaluateCheckResults() < 70% | matchRate=60 | Consider redesign | P1 |
| TEAM-30 | recommendTeamComposition() | Enterprise feature | 5-member team | P1 |

---

### 3.10 TC-ML: Multi-Language Tests (24 TC)

| ID | Language | Test Case | Expected Result | Priority |
|----|----------|-----------|-----------------|:--------:|
| ML-01 | Korean | Agent trigger "검증해줘" | gap-detector match | P1 |
| ML-02 | Korean | Skill trigger "API 설계" | phase-4-api match | P1 |
| ML-03 | English | Agent trigger "review code" | code-analyzer match | P1 |
| ML-04 | English | Skill trigger "deploy" | phase-9-deployment match | P1 |
| ML-05 | Japanese | Agent trigger "検証して" | gap-detector match | P1 |
| ML-06 | Japanese | Skill trigger "設計" | Appropriate skill | P1 |
| ML-07 | Chinese | Agent trigger "代码审查" | code-analyzer match | P1 |
| ML-08 | Chinese | Skill trigger "部署" | phase-9 match | P1 |
| ML-09 | Spanish | Agent trigger "revisar codigo" | code-analyzer match | P1 |
| ML-10 | Spanish | Skill trigger "despliegue" | phase-9 match | P1 |
| ML-11 | French | Agent trigger "revue de code" | code-analyzer match | P1 |
| ML-12 | French | Skill trigger "deploiement" | phase-9 match | P1 |
| ML-13 | German | Agent trigger "Code Analyse" | code-analyzer match | P2 |
| ML-14 | German | Skill trigger "Bereitstellung" | phase-9 match | P2 |
| ML-15 | Italian | Agent trigger "revisione codice" | code-analyzer match | P2 |
| ML-16 | Italian | Skill trigger "distribuzione" | phase-9 match | P2 |
| ML-17 | Korean | Feature intent "새 기능" | isNewFeature=true | P1 |
| ML-18 | English | Feature intent "new feature" | isNewFeature=true | P1 |
| ML-19 | Japanese | Feature intent "新機能" | isNewFeature=true | P1 |
| ML-20 | Korean | Ambiguity "이거 바꿔줘" | High ambiguity score | P1 |
| ML-21 | English | Ambiguity "fix this" | High ambiguity score | P1 |
| ML-22 | Korean | Clear "src/login.tsx에 버튼 추가" | Low ambiguity score | P1 |
| ML-23 | English | Clear "add button to src/login.tsx" | Low ambiguity score | P1 |
| ML-24 | All 8 | SUPPORTED_LANGUAGES count | 8 languages | P0 |

---

### 3.11 TC-EDGE: Performance & Edge Cases (20 TC)

| ID | Test Case | Expected Result | Priority |
|----|-----------|-----------------|:--------:|
| EDGE-01 | Hook timeout SessionStart <= 5000ms | Completes in time | P2 |
| EDGE-02 | Hook timeout UserPromptSubmit <= 3000ms | Completes in time | P2 |
| EDGE-03 | Hook timeout Stop <= 10000ms | Completes in time | P2 |
| EDGE-04 | Cache TTL expiry (5s hierarchy) | Stale data refreshed | P2 |
| EDGE-05 | Cache TTL expiry (30s import) | Stale data refreshed | P2 |
| EDGE-06 | Circular import detection | Error logged, no crash | P2 |
| EDGE-07 | Invalid JSON config file | Graceful fallback | P2 |
| EDGE-08 | Missing .bkit-memory.json | Auto-created | P2 |
| EDGE-09 | Missing .pdca-status.json | Auto-initialized | P2 |
| EDGE-10 | Empty user prompt | outputEmpty, no crash | P2 |
| EDGE-11 | Very long prompt (10000+ chars) | Truncated properly | P2 |
| EDGE-12 | Concurrent agent-state.json writes | Atomic write (tmp+rename) | P2 |
| EDGE-13 | readStdinSync() failure | Graceful exit | P2 |
| EDGE-14 | Missing script file in hooks.json | Hook skipped, no crash | P2 |
| EDGE-15 | state-writer without .bkit directory | Directory auto-created | P2 |
| EDGE-16 | addTeammate() to disabled state | No crash (state check) | P2 |
| EDGE-17 | updateProgress() without state file | No crash, returns | P2 |
| EDGE-18 | Ring buffer overflow (51 messages) | Oldest removed, max 50 | P2 |
| EDGE-19 | removeTeammate() twice same name | Second call is no-op | P2 |
| EDGE-20 | cleanupAgentState() twice | Second call is no-op | P2 |

---

### 3.12 TC-REG: Regression Tests (10 TC)

| ID | Test Case | v1.5.2 Status | Expected v1.5.3 Result | Priority |
|----|-----------|:------------:|------------------------|:--------:|
| REG-01 | BUG-01 confidence >= 0.8 | FIXED | Still fixed (line 98) | P0 |
| REG-02 | Feature intent confidence > 0.8 | PASS (line 84) | Still > 0.8 (no change) | P0 |
| REG-03 | common.js backward compatibility | PASS | All 171 exports accessible | P0 |
| REG-04 | hooks.json schema valid | PASS | Valid with 2 new entries | P0 |
| REG-05 | Agent memory project scope (14) | PASS | Still 14 project scope | P0 |
| REG-06 | Agent memory user scope (2) | PASS | Still 2 user scope | P0 |
| REG-07 | outputBlock/outputAllow (not sandbox) | PASS | No sandbox API references | P0 |
| REG-08 | Fast mode independence | PASS | Zero /fast dependencies | P0 |
| REG-09 | Agent model specs unchanged | PASS | opus(7), sonnet(7), haiku(2) | P0 |
| REG-10 | 26 skills all loadable | PASS | All 26 load without error | P0 |

---

## 4. Test Execution Strategy

### 4.1 Execution Order

| Phase | Categories | TC Count | Method |
|:-----:|-----------|:--------:|--------|
| 1 | TC-REG (Regression) | 10 | Automated: code inspection |
| 2 | TC-NEW (v1.5.3 New) | 45 | Automated: unit + integration |
| 3 | TC-LIB (Library Unit) | 220 | Automated: function-level verification |
| 4 | TC-HK (Hooks) | 65 | Semi-auto: hooks.json + script execution |
| 5 | TC-AG (Agents) | 64 | Semi-auto: frontmatter + trigger verification |
| 6 | TC-SK (Skills) | 80 | Semi-auto: file inspection + trigger test |
| 7 | TC-PDCA (Workflow) | 35 | Manual: end-to-end scenario |
| 8 | TC-UX (User Experience) | 40 | Manual: user journey simulation |
| 9 | TC-CFG (Config) | 25 | Automated: file validation |
| 10 | TC-TEAM (Team Orchestration) | 30 | Semi-auto: team mode simulation |
| 11 | TC-ML (Multi-Language) | 24 | Automated: pattern matching |
| 12 | TC-EDGE (Edge Cases) | 20 | Automated: boundary testing |

### 4.2 Verification Methods

| Method | Description | Used For |
|--------|-------------|----------|
| Code Inspection | Read source files, verify exports/constants | LIB, REG, CFG |
| Function Call | Execute function with test input, verify output | LIB, INTENT |
| File Validation | Verify file existence, content patterns | SK, AG, HK-JSON |
| Hook Simulation | Provide stdin JSON, capture stdout | HK, NEW-HK |
| Scenario Walkthrough | End-to-end PDCA cycle | PDCA, UX |
| Pattern Matching | Regex/string match against multilang patterns | ML, INTENT |

### 4.3 Pass/Fail Criteria

| Result | Definition |
|--------|-----------|
| PASS | Expected result matches actual result |
| FAIL | Expected result does not match actual result |
| SKIP | Cannot verify (runtime-only, requires human interaction, external dependency) |

### 4.4 Success Criteria

| Metric | Target |
|--------|--------|
| Overall Pass Rate (excl. SKIP) | >= 99% |
| P0 Pass Rate | 100% |
| P1 Pass Rate | >= 95% |
| Critical Issues | 0 |
| v1.5.3 New Feature Pass Rate | 100% |

---

## 5. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|:------:|:----------:|------------|
| SubagentStart/Stop hooks require Agent Teams runtime | High | High | Mark as SKIP if AGENT_TEAMS env not set; verify code logic instead |
| state-writer atomic write race condition | Medium | Low | Test with sequential calls; concurrent test marked P2 |
| 688 TC count may exceed context window | Medium | Medium | Execute in batches by category; parallel agent execution |
| Team mode requires live Claude Code session | High | High | Verify code paths; runtime TCs marked SKIP |
| Output style files moved between versions | Low | Low | Glob search for file existence |

---

## 6. TC Count Summary

| Category | Subcategory | TC Count |
|----------|-------------|:--------:|
| TC-NEW | State Writer (SW) | 25 |
| TC-NEW | SubagentStart/Stop Hooks (HK) | 15 |
| TC-NEW | Integration (INT) | 5 |
| TC-LIB | Core Module | 50 |
| TC-LIB | PDCA Module | 60 |
| TC-LIB | Intent Module | 30 |
| TC-LIB | Task Module | 30 |
| TC-LIB | Team Module (excl state-writer) | 50 |
| TC-LIB | Standalone Modules | 30 |
| TC-HK | All hook categories | 65 |
| TC-AG | Core + bkend + CTO + Delegation | 64 |
| TC-SK | Level + Pipeline + bkend + Utility | 80 |
| TC-PDCA | Workflow | 35 |
| TC-UX | User Experience | 40 |
| TC-CFG | Config + Output Styles + Templates | 25 |
| TC-TEAM | Team Orchestration | 30 |
| TC-ML | Multi-Language | 24 |
| TC-EDGE | Performance & Edge Cases | 20 |
| TC-REG | Regression | 10 |
| | | |
| **GRAND TOTAL** | | **688** |

---

## 7. Next Steps

1. [ ] Write design document (`bkit-v1.5.3-comprehensive-test.design.md`)
2. [ ] Execute Phase 1-2: Regression + v1.5.3 New Feature tests
3. [ ] Execute Phase 3-6: Library + Hooks + Agents + Skills (parallel)
4. [ ] Execute Phase 7-12: Workflow + UX + Config + Team + ML + Edge
5. [ ] Generate analysis report (`bkit-v1.5.3-comprehensive-test.analysis.md`)
6. [ ] Generate completion report (`bkit-v1.5.3-comprehensive-test.report.md`)

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-09 | Initial draft - 688 TC across 12 categories | CTO Team |
