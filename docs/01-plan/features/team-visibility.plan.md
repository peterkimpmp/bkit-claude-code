# Team Visibility Plan (bkit Plugin Side)

> **Feature**: team-visibility
> **Level**: Dynamic
> **Date**: 2026-02-09
> **Scope**: bkit plugin (bkit-claude-code) -- state writing and hook integration
> **Counterpart**: bkit Studio (bkit-studio) -- IPC reading, polling, and UI binding
> **Analysis Reference**: `bkit-studio/docs/03-analysis/features/team-visibility.analysis.md`

---

## 1. Problem Statement

bkit plugin has comprehensive team orchestration logic (8 modules, 30+ exports) but writes **zero real-time state to disk**. All team data lives in-memory only:

| Data | Current Location | Persistence |
|------|-----------------|-------------|
| Agent roster (name, role, model) | `lib/team/strategy.js` (definition), in-memory (runtime) | None -- lost on process exit |
| Agent status (idle/working/completed) | Hook stdout output only | None -- console output only |
| Task assignments | `lib/team/task-queue.js` `taskAssignments` Map | None -- in-memory Map |
| Inter-agent messages | `lib/team/communication.js` createMessage() | None -- returns object, never persisted |
| Task progress (total/completed/failed) | `getTeamProgress()` reads in-memory Map | None |
| PDCA phase + orchestration pattern | `bkit.config.json` (static config only) | Config only, no runtime state |

**Consequence**: bkit Studio's Team page permanently displays "Agents Team Mode Inactive" because there is no data source on disk for it to read.

### Break Points (from Analysis)

1. **BP-1 (Data Source)**: No file written with team runtime state
2. **BP-2 (IPC Command)**: Studio has 0 Rust IPC commands for team data (Studio-side fix)
3. **BP-3 (Config)**: `team.enabled: false` by default in bkit.config.json

This plan addresses **BP-1** and **BP-3** (plugin-side). BP-2 is addressed in the Studio-side plan.

---

## 2. Shared Interface Contract

Both bkit plugin and bkit Studio MUST agree on this exact schema. The file is written by the plugin and read by Studio.

**File Path**: `{project_root}/.bkit/agent-state.json`

```json
{
  "version": "1.0",
  "enabled": true,
  "teamName": "string",
  "feature": "string",
  "pdcaPhase": "plan|design|do|check|act",
  "orchestrationPattern": "leader|swarm|council|watchdog",
  "ctoAgent": "string (model name)",
  "startedAt": "ISO 8601",
  "lastUpdated": "ISO 8601",
  "teammates": [
    {
      "name": "string",
      "role": "string",
      "model": "opus|sonnet|haiku",
      "status": "spawning|working|idle|completed|failed",
      "currentTask": "string|null",
      "taskId": "string|null",
      "startedAt": "ISO 8601",
      "lastActivityAt": "ISO 8601"
    }
  ],
  "progress": {
    "totalTasks": 0,
    "completedTasks": 0,
    "inProgressTasks": 0,
    "failedTasks": 0,
    "pendingTasks": 0
  },
  "recentMessages": [
    {
      "from": "string",
      "to": "string",
      "content": "string",
      "timestamp": "ISO 8601"
    }
  ],
  "sessionId": "string"
}
```

### Schema Rules

1. **version**: Always `"1.0"` for this release. Future changes increment this.
2. **enabled**: `true` when a team session is active, `false` (or file deleted) when session ends.
3. **teammates**: Array ordered by spawn time. Maximum 10 entries.
4. **recentMessages**: Ring buffer, maximum 50 entries. Oldest removed when limit exceeded.
5. **lastUpdated**: Updated on every write. ISO 8601 format with timezone.
6. **File lifecycle**: Created on first SubagentStart during team mode. Updated on every hook event. Cleaned up (enabled set to false, teammates cleared) on session end.

### Schema Rationale

- `pdcaPhase` and `orchestrationPattern` are bkit-specific data that Claude Code does not provide natively
- `teammates[].model` maps from `agent_type` in hook context (subagent = sonnet, main = opus, etc.)
- `progress` is computed from the in-memory `taskAssignments` Map at write time
- `recentMessages` captures communication flow for Studio's message panel

---

## 3. Requirements

### R1: Create state-writer module

Create `lib/team/state-writer.js` with the following exports:

| Function | Signature | Description |
|----------|-----------|-------------|
| `initAgentState` | `(teamName, feature, options)` | Create initial `.bkit/agent-state.json` |
| `updateTeammateStatus` | `(name, status, taskInfo)` | Update a single teammate's status |
| `addTeammate` | `(teammateInfo)` | Add a new teammate to the roster |
| `removeTeammate` | `(name)` | Remove teammate (on SubagentStop) |
| `updateProgress` | `(progressData)` | Update task progress counters |
| `addRecentMessage` | `(message)` | Append to recentMessages (ring buffer) |
| `cleanupAgentState` | `()` | Set enabled=false, clear teammates on session end |
| `getAgentStatePath` | `()` | Return the file path for agent-state.json |
| `readAgentState` | `()` | Read current state from disk (for read-modify-write) |

**Implementation constraints**:
- All writes MUST be atomic: write to `.bkit/agent-state.json.tmp` then rename
- All functions MUST be async-safe (non-blocking). Use `fs.writeFileSync` for simplicity since hook timeout is 5000ms and writes are small (~2KB)
- The `.bkit/` directory MUST be created if it does not exist (using `fs.mkdirSync` with `recursive: true`)
- `readAgentState` MUST return `null` if file does not exist (not throw)
- All functions MUST use `debugLog` from `lib/core/debug` for traceability

### R2: Integrate with SubagentStart hook

**When**: Claude Code spawns a subagent in team mode
**Hook event**: `SubagentStart` (NEW hook registration in hooks.json)
**Action**:
1. If no agent-state.json exists, call `initAgentState()` with team context from PDCA status
2. Call `addTeammate()` with agent info extracted from hook context:
   - `hookContext.agent_id` -> `name`
   - `hookContext.agent_type` -> `model` mapping (subagent=sonnet, main=opus)
   - Role derived from task subject or team composition
3. Set teammate status to `"spawning"`

**Hook context fields** (from Claude Code):
```json
{
  "agent_id": "string",
  "agent_type": "subagent|main",
  "team_name": "string",
  "session_id": "string"
}
```

### R3: Integrate with SubagentStop hook

**When**: A subagent completes or fails
**Hook event**: `SubagentStop` (NEW hook registration in hooks.json)
**Action**:
1. Call `updateTeammateStatus(name, "completed"|"failed", null)`
2. Update `progress` counters via `updateProgress()`
3. If all teammates completed, check if session should end

**Hook context fields**:
```json
{
  "agent_id": "string",
  "agent_type": "subagent|main",
  "transcript_path": "string",
  "team_name": "string"
}
```

### R4: Integrate with TeammateIdle hook

**When**: A teammate becomes idle (no active task)
**Hook event**: `TeammateIdle` (already registered in hooks.json)
**Action**:
1. Call `updateTeammateStatus(name, "idle", null)` to persist idle state
2. Existing logic in `team-idle-handler.js` continues to suggest next task via stdout

**Current handler**: `scripts/team-idle-handler.js` -- add state-writer call before existing logic.

### R5: Integrate with TaskCompleted hook

**When**: A PDCA task is marked complete
**Hook event**: `TaskCompleted` (already registered in hooks.json)
**Action**:
1. Call `updateTeammateStatus(name, "completed", { task: subject })` if teammate identified
2. Call `updateProgress()` with latest counts from `getTeamProgress()`
3. If team assignment generated, call `addRecentMessage()` with phase transition notice

**Current handler**: `scripts/pdca-task-completed.js` -- add state-writer calls after existing PDCA logic.

### R6: Integrate with SessionEnd/Stop hook

**When**: The main session or team session ends
**Hook event**: `Stop` (already registered in hooks.json, routed via `unified-stop.js`)
**Action**:
1. Call `cleanupAgentState()` to:
   - Set `enabled` to `false`
   - Clear `teammates` array
   - Preserve `progress` and `recentMessages` for Studio to display final state
   - Update `lastUpdated` timestamp
2. Existing `team-stop.js` and `cto-stop.js` logic continues unchanged

**Current handlers**: `scripts/team-stop.js`, `scripts/cto-stop.js` -- add state-writer cleanup call.

### R7: Change team.enabled default to true

**File**: `bkit.config.json`
**Change**: `"team": { "enabled": false, ... }` -> `"team": { "enabled": true, ... }`

**Rationale**: The `enabled` flag currently prevents Studio from even checking for team state. With the new agent-state.json file, Studio can auto-detect active teams regardless of this flag. However, changing the default to `true` ensures backward compatibility with Studio's `isAvailable` check which reads config.

**Impact**: Only affects the plugin's own config file. Projects that copy this config will get `enabled: true` by default.

### R8: Ensure async hooks (non-blocking)

All state-writer calls in hooks MUST be non-blocking to the Claude Code main process:

1. Hook scripts have a 5000ms timeout (from hooks.json) -- state writes must complete well within this
2. Write operations target small JSON files (~2KB), so `fs.writeFileSync` is acceptable
3. If write fails (disk full, permissions), log error via `debugLog` and continue -- NEVER throw
4. State writes MUST NOT block the hook's primary stdout output to Claude Code

**Implementation pattern**:
```javascript
try {
  stateWriter.updateTeammateStatus(name, status, taskInfo);
} catch (e) {
  debugLog('HookName', 'State write failed (non-fatal)', { error: e.message });
}
```

### R9: File path convention

**Path**: `{PROJECT_DIR}/.bkit/agent-state.json`

Where `PROJECT_DIR` is the current working directory (`process.cwd()`), matching `lib/core`'s `PROJECT_DIR` constant.

**Rationale**:
- `.bkit/` directory is already used conceptually by the bkit plugin ecosystem
- Project-local (not user-global) so multiple projects can have independent team states
- `.bkit/` should be added to `.gitignore` by the plugin's setup process

### R10: Graceful cleanup on session end

When a team session ends (via Stop hook), the agent-state.json file MUST be cleaned up properly:

1. Set `enabled: false` (do NOT delete the file -- Studio may still be polling)
2. Clear `teammates` array to `[]`
3. Keep `progress` data intact (for Studio to show final summary)
4. Keep `recentMessages` intact (for Studio to show session history)
5. Update `lastUpdated` to session end time
6. If process exits abnormally (crash), the stale file will have `enabled: true` with an old `lastUpdated` -- Studio should detect staleness via timestamp (>5 minutes old = stale)

---

## 4. Implementation Phases

### Phase 1: State Writer Module + Schema (R1)

**Files to create**:
| File | Description |
|------|-------------|
| `lib/team/state-writer.js` | Core state-writer module with all 9 exported functions |

**Files to modify**:
| File | Change |
|------|--------|
| `lib/team/index.js` | Add state-writer exports to module barrel |

**Acceptance criteria**:
- All 9 functions implemented and exported
- Atomic writes (tmp + rename)
- Unit testable in isolation (no hook dependency)
- Schema matches Shared Interface Contract exactly

### Phase 2: Hook Integration (R2-R6, R8)

**Files to create**:
| File | Description |
|------|-------------|
| `scripts/subagent-start-handler.js` | NEW: SubagentStart hook handler |
| `scripts/subagent-stop-handler.js` | NEW: SubagentStop hook handler |

**Files to modify**:
| File | Change |
|------|--------|
| `hooks/hooks.json` | Add SubagentStart and SubagentStop hook entries |
| `scripts/team-idle-handler.js` | Add `stateWriter.updateTeammateStatus()` call |
| `scripts/pdca-task-completed.js` | Add `stateWriter.updateProgress()` and `addRecentMessage()` calls |
| `scripts/unified-stop.js` | Add `stateWriter.cleanupAgentState()` call |
| `scripts/team-stop.js` | Add `stateWriter.cleanupAgentState()` call in `run()` |
| `scripts/cto-stop.js` | Add `stateWriter.cleanupAgentState()` call in `run()` |

**Hook registration additions** (hooks.json):
```json
{
  "SubagentStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/subagent-start-handler.js",
          "timeout": 5000
        }
      ]
    }
  ],
  "SubagentStop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/subagent-stop-handler.js",
          "timeout": 5000
        }
      ]
    }
  ]
}
```

**Acceptance criteria**:
- All 6 hooks write to agent-state.json correctly
- No hook timeout failures (all writes < 100ms)
- Existing hook behavior unchanged (stdout outputs preserved)
- Error in state-writer does not break hook execution

### Phase 3: Config Update + Testing (R7, R9, R10)

**Files to modify**:
| File | Change |
|------|--------|
| `bkit.config.json` | Change `team.enabled` from `false` to `true` |

**Testing**:
1. Manual test: Start a CTO team session, verify agent-state.json is created
2. Manual test: Run with multiple teammates, verify roster updates
3. Manual test: Complete tasks, verify progress updates
4. Manual test: End session, verify cleanup
5. Edge case: Kill process, verify stale file detection by Studio

**Acceptance criteria**:
- `team.enabled` defaults to `true`
- agent-state.json lifecycle works end-to-end
- Studio can read the file and display team data (integration with Studio plan)

---

## 5. File Change Summary

### New Files (3)

| File | Size Est. | Description |
|------|-----------|-------------|
| `lib/team/state-writer.js` | ~200 lines | Core state writing module |
| `scripts/subagent-start-handler.js` | ~60 lines | SubagentStart hook handler |
| `scripts/subagent-stop-handler.js` | ~60 lines | SubagentStop hook handler |

### Modified Files (8)

| File | Change Type | Description |
|------|------------|-------------|
| `lib/team/index.js` | Add exports | Export state-writer functions |
| `hooks/hooks.json` | Add entries | Register SubagentStart, SubagentStop hooks |
| `scripts/team-idle-handler.js` | Add call | Write idle status to agent-state.json |
| `scripts/pdca-task-completed.js` | Add call | Write progress to agent-state.json |
| `scripts/unified-stop.js` | Add call | Cleanup agent-state.json on stop |
| `scripts/team-stop.js` | Add call | Cleanup agent-state.json on team stop |
| `scripts/cto-stop.js` | Add call | Cleanup agent-state.json on CTO stop |
| `bkit.config.json` | Change value | `team.enabled: false` -> `true` |

### Total: 3 new + 8 modified = 11 files

---

## 6. Cross-Reference

### Studio-Side Plan
- Location: `bkit-studio/docs/01-plan/features/team-visibility.plan.md`
- Studio reads `{project}/.bkit/agent-state.json` via Rust IPC
- Studio implements `read_agent_state` Tauri command and polling
- Studio's `use-agent-team.ts` hook activates when agent-state.json has `enabled: true`

### Shared Contract Compliance
Both plans MUST implement the **exact same JSON schema** defined in Section 2. Any schema change requires updating both plans simultaneously.

### Integration Test
The feature is complete when:
1. bkit plugin writes agent-state.json during a team session (this plan)
2. bkit Studio reads agent-state.json and displays live team data (Studio plan)
3. Studio's Team page shows real-time agent roster, progress, and messages

---

## 7. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Hook context fields differ from expected | Medium | State-writer gets wrong data | Defensive parsing with fallbacks, debugLog all context |
| File write race condition (multiple hooks fire simultaneously) | Low | Corrupted JSON | Atomic write (tmp + rename), read-modify-write pattern |
| `.bkit/` directory permissions | Low | Write fails | Create with `recursive: true`, catch and log errors |
| Hook timeout exceeded | Very Low | State not written | Writes are ~5ms, timeout is 5000ms. 1000x safety margin |
| Studio polls before first write | Medium | Empty state | Studio handles missing file as "inactive" (existing behavior) |
