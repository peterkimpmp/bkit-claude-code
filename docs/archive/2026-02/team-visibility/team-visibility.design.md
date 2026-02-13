# Team Visibility Design Document

> **Summary**: bkit 플러그인의 팀 상태를 디스크에 영속화하여 bkit Studio가 실시간 팀 데이터를 표시할 수 있도록 하는 state-writer 모듈 및 훅 통합 설계
>
> **Project**: bkit-claude-code
> **Version**: 1.5.3
> **Author**: CTO Team (code-analyzer, qa-strategist, frontend-architect)
> **Date**: 2026-02-09
> **Status**: Draft
> **Planning Doc**: [team-visibility.plan.md](../01-plan/features/team-visibility.plan.md)

---

## 1. Overview

### 1.1 Design Goals

1. **실시간 상태 영속화**: lib/team/ 모듈의 인메모리 상태(taskAssignments Map, 메시지 객체)를 `.bkit/agent-state.json`에 기록
2. **Studio 독립성**: bkit Studio 미설치 환경에서도 기능 장애 없이 동작 (파일 기록은 수행, Studio 폴링 없어도 정상)
3. **무중단 통합**: 기존 훅 동작(stdout 출력)에 영향 없이 state-writer 호출 추가
4. **안전한 파일 I/O**: 원자적 쓰기(tmp + rename), 비차단, 실패 시 graceful degradation

### 1.2 Design Principles

- **Non-blocking First**: 모든 state-writer 호출은 훅의 주 기능(stdout 출력)을 차단하지 않음
- **Fail-silent**: 디스크 I/O 실패 시 debugLog 기록 후 계속 실행, 절대 throw 하지 않음
- **Convention Over Configuration**: 기존 lib/pdca/status.js의 패턴(lazy require, globalCache, try-catch)을 그대로 준수
- **Schema Contract**: Plan 문서 Section 2의 JSON 스키마를 정확히 구현, Studio와의 계약 준수

---

## 2. Architecture

### 2.1 Component Diagram

```
┌──────────────────────────────────────────────────────────┐
│                  Claude Code Runtime                       │
│                                                            │
│  Hook Events:                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐   │
│  │SubagentStart │  │SubagentStop  │  │ TeammateIdle  │   │
│  └──────┬───────┘  └──────┬───────┘  └───────┬───────┘   │
│         │                 │                   │            │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌───────┴───────┐   │
│  │subagent-     │  │subagent-     │  │team-idle-     │   │
│  │start-handler │  │stop-handler  │  │handler.js     │   │
│  └──────┬───────┘  └──────┬───────┘  └───────┬───────┘   │
│         │                 │                   │            │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌───────┴───────┐   │
│  │TaskCompleted │  │  Stop        │  │               │   │
│  └──────┬───────┘  └──────┬───────┘  │               │   │
│  ┌──────┴───────┐  ┌──────┴───────┐  │               │   │
│  │pdca-task-    │  │unified-stop  │  │               │   │
│  │completed.js  │  │→team-stop.js │  │               │   │
│  └──────┬───────┘  │→cto-stop.js  │  │               │   │
│         │          └──────┬───────┘  │               │   │
│         └────────┬────────┴──────────┘               │   │
│                  ▼                                     │   │
│  ┌─────────────────────────────────┐                  │   │
│  │  lib/team/state-writer.js       │  ◀── NEW MODULE  │   │
│  │  ─────────────────────────      │                  │   │
│  │  initAgentState()               │                  │   │
│  │  addTeammate()                  │                  │   │
│  │  updateTeammateStatus()         │                  │   │
│  │  removeTeammate()               │                  │   │
│  │  updateProgress()               │                  │   │
│  │  addRecentMessage()             │                  │   │
│  │  cleanupAgentState()            │                  │   │
│  │  readAgentState()               │                  │   │
│  │  getAgentStatePath()            │                  │   │
│  └──────────┬──────────────────────┘                  │   │
│             │                                          │   │
│             ▼                                          │   │
│  ┌─────────────────────────────┐                      │   │
│  │ .bkit/agent-state.json      │ ◀── DISK FILE        │   │
│  │ (atomic write: tmp+rename)  │                      │   │
│  └─────────────┬───────────────┘                      │   │
│                │                                       │   │
└────────────────┼───────────────────────────────────────┘
                 │  (File system polling)
                 ▼
┌─────────────────────────────────┐
│  bkit Studio (Optional)         │
│  ─────────────────────          │
│  Tauri IPC: read_agent_state    │
│  Polling: 2s interval           │
│  UI: Team roster, progress,     │
│      messages panel             │
└─────────────────────────────────┘
```

### 2.2 Data Flow

```
Hook Event (stdin JSON)
  → Hook Handler Script (scripts/*.js)
    → Parse hookContext
    → Execute primary hook logic (stdout output)
    → Call state-writer (non-blocking, try-catch wrapped)
      → readAgentState() (disk read or in-memory cache)
      → Modify state object
      → writeAgentState() (atomic: tmp file → rename)
    → process.exit(0)
```

### 2.3 Dependencies

| Component | Depends On | Purpose |
|-----------|-----------|---------|
| `state-writer.js` | `lib/core` (PROJECT_DIR, debugLog) | 경로 resolve, 디버그 로깅 |
| `state-writer.js` | `fs`, `path` (Node.js built-in) | 파일 I/O |
| `state-writer.js` | `lib/team/task-queue` (getTeamProgress) | 진행률 데이터 |
| `state-writer.js` | `lib/pdca/status` (getPdcaStatusFull) | PDCA 상태 컨텍스트 |
| `subagent-start-handler.js` | `state-writer`, `lib/common.js` | 상태 기록 + 훅 I/O |
| `subagent-stop-handler.js` | `state-writer`, `lib/common.js` | 상태 기록 + 훅 I/O |
| All existing hooks | `state-writer` (optional, lazy) | 상태 업데이트 추가 |

---

## 3. Data Model

### 3.1 Agent State Schema (v1.0)

```typescript
/**
 * .bkit/agent-state.json 스키마
 * Plan 문서 Section 2 계약 준수
 */
interface AgentState {
  /** 스키마 버전. 항상 "1.0" */
  version: "1.0";

  /** 팀 세션 활성 여부. false = 비활성 (Studio에서 "Inactive" 표시) */
  enabled: boolean;

  /** 팀 이름 (TeamCreate의 team_name) */
  teamName: string;

  /** PDCA feature 이름 */
  feature: string;

  /** 현재 PDCA 단계 */
  pdcaPhase: "plan" | "design" | "do" | "check" | "act";

  /** 오케스트레이션 패턴 */
  orchestrationPattern: "leader" | "swarm" | "council" | "watchdog";

  /** CTO 에이전트 모델 이름 */
  ctoAgent: string;

  /** 세션 시작 시각 (ISO 8601) */
  startedAt: string;

  /** 마지막 업데이트 시각 (ISO 8601) */
  lastUpdated: string;

  /** 팀원 목록 (spawn 순서, 최대 10명) */
  teammates: Teammate[];

  /** 작업 진행률 */
  progress: Progress;

  /** 최근 메시지 (링 버퍼, 최대 50건) */
  recentMessages: Message[];

  /** Claude Code 세션 ID */
  sessionId: string;
}

interface Teammate {
  /** 팀원 이름 (agent_id 또는 agent name) */
  name: string;

  /** 역할 (e.g., "code-analyzer", "developer", "qa") */
  role: string;

  /** 모델 ("opus" | "sonnet" | "haiku") */
  model: "opus" | "sonnet" | "haiku";

  /** 현재 상태 */
  status: "spawning" | "working" | "idle" | "completed" | "failed";

  /** 현재 수행 중인 태스크 (null = 없음) */
  currentTask: string | null;

  /** 태스크 ID (null = 없음) */
  taskId: string | null;

  /** 팀원 시작 시각 (ISO 8601) */
  startedAt: string;

  /** 마지막 활동 시각 (ISO 8601) */
  lastActivityAt: string;
}

interface Progress {
  totalTasks: number;
  completedTasks: number;
  inProgressTasks: number;
  failedTasks: number;
  pendingTasks: number;
}

interface Message {
  from: string;
  to: string;
  content: string;
  timestamp: string;  // ISO 8601
}
```

### 3.2 Default State Object

```javascript
function createDefaultAgentState() {
  const now = new Date().toISOString();
  return {
    version: "1.0",
    enabled: false,
    teamName: "",
    feature: "",
    pdcaPhase: "plan",
    orchestrationPattern: "leader",
    ctoAgent: "opus",
    startedAt: now,
    lastUpdated: now,
    teammates: [],
    progress: {
      totalTasks: 0,
      completedTasks: 0,
      inProgressTasks: 0,
      failedTasks: 0,
      pendingTasks: 0,
    },
    recentMessages: [],
    sessionId: "",
  };
}
```

### 3.3 File Lifecycle

```
1. CREATE: SubagentStart (첫 번째 subagent spawn 시)
   → initAgentState() → agent-state.json 생성 (enabled: true)

2. UPDATE: 각 Hook event 발생 시
   → readAgentState() → modify → writeAgentState()

3. CLEANUP: Stop hook (세션 종료 시)
   → cleanupAgentState() → enabled: false, teammates: []

4. STALE: 프로세스 비정상 종료 시
   → lastUpdated가 5분 이상 경과 → Studio에서 stale 감지
```

---

## 4. Module API Specification

### 4.1 `lib/team/state-writer.js` - Core Module

#### 4.1.1 `getAgentStatePath()`

```javascript
/**
 * agent-state.json 파일 경로 반환
 * @returns {string} 절대 경로
 */
function getAgentStatePath() {
  const { PROJECT_DIR } = getCore();
  return path.join(PROJECT_DIR, '.bkit', 'agent-state.json');
}
```

**구현 노트**:
- `PROJECT_DIR`은 `lib/core`에서 lazy require
- `.bkit/` 디렉토리는 `PROJECT_DIR` 기준 (프로젝트 로컬)

---

#### 4.1.2 `readAgentState()`

```javascript
/**
 * 디스크에서 현재 agent state 읽기
 * @returns {Object|null} AgentState 객체 또는 null (파일 미존재 시)
 */
function readAgentState() {
  const statePath = getAgentStatePath();
  try {
    if (!fs.existsSync(statePath)) return null;
    const content = fs.readFileSync(statePath, 'utf8');
    return JSON.parse(content);
  } catch (e) {
    debugLog('StateWriter', 'Failed to read agent state', { error: e.message });
    return null;
  }
}
```

**구현 노트**:
- `fs.existsSync` 체크 후 읽기 (TOCTOU 위험 낮음 - 단일 프로세스 환경)
- JSON 파싱 실패 시 null 반환 (손상된 파일 대응)
- 인메모리 캐시 미사용 (훅은 독립 프로세스로 실행되어 캐시 공유 불가)

---

#### 4.1.3 `writeAgentState(state)`

```javascript
/**
 * agent state를 디스크에 원자적으로 기록
 * @param {Object} state - AgentState 객체
 * @private (내부 전용 - 다른 함수들이 호출)
 */
function writeAgentState(state) {
  const statePath = getAgentStatePath();
  const stateDir = path.dirname(statePath);
  const tmpPath = statePath + '.tmp';

  try {
    // 디렉토리 확인/생성
    if (!fs.existsSync(stateDir)) {
      fs.mkdirSync(stateDir, { recursive: true });
    }

    // 타임스탬프 업데이트
    state.lastUpdated = new Date().toISOString();

    // 원자적 쓰기: tmp 파일 작성 후 rename
    fs.writeFileSync(tmpPath, JSON.stringify(state, null, 2));
    fs.renameSync(tmpPath, statePath);

    debugLog('StateWriter', 'Agent state written', {
      enabled: state.enabled,
      teammateCount: state.teammates.length,
    });
  } catch (e) {
    debugLog('StateWriter', 'Failed to write agent state (non-fatal)', {
      error: e.message,
    });
    // tmp 파일 정리 시도
    try {
      if (fs.existsSync(tmpPath)) fs.unlinkSync(tmpPath);
    } catch (_) { /* ignore */ }
  }
}
```

**구현 노트**:
- **원자적 쓰기**: `writeFileSync(tmp)` → `renameSync(tmp, target)`
  - rename은 같은 파일시스템 내에서 원자적 연산
  - Studio가 폴링 중 부분 JSON을 읽는 것을 방지
- **tmp 파일 정리**: 실패 시 `.tmp` 파일이 남지 않도록 정리
- **2-space 인덴트**: 기존 패턴 (`JSON.stringify(state, null, 2)`) 준수
- **non-export**: 외부에 노출하지 않음 (다른 public 함수가 내부적으로 호출)

---

#### 4.1.4 `initAgentState(teamName, feature, options)`

```javascript
/**
 * 팀 세션 시작 시 초기 agent state 생성
 * @param {string} teamName - 팀 이름
 * @param {string} feature - PDCA feature 이름
 * @param {Object} [options] - 추가 옵션
 * @param {string} [options.pdcaPhase] - 현재 PDCA 단계 (기본: "plan")
 * @param {string} [options.orchestrationPattern] - 오케스트레이션 패턴 (기본: "leader")
 * @param {string} [options.ctoAgent] - CTO 에이전트 모델 (기본: "opus")
 * @param {string} [options.sessionId] - Claude Code 세션 ID
 */
function initAgentState(teamName, feature, options = {}) {
  const state = createDefaultAgentState();

  state.enabled = true;
  state.teamName = teamName || '';
  state.feature = feature || '';
  state.pdcaPhase = options.pdcaPhase || 'plan';
  state.orchestrationPattern = options.orchestrationPattern || 'leader';
  state.ctoAgent = options.ctoAgent || 'opus';
  state.sessionId = options.sessionId || '';
  state.startedAt = new Date().toISOString();

  writeAgentState(state);

  debugLog('StateWriter', 'Agent state initialized', {
    teamName,
    feature,
    pdcaPhase: state.pdcaPhase,
  });
}
```

**호출 시점**: SubagentStart 훅에서 첫 번째 subagent spawn 감지 시
**멱등성**: 기존 파일이 있으면 덮어쓰기 (새 세션 시작으로 간주)

---

#### 4.1.5 `addTeammate(teammateInfo)`

```javascript
/**
 * 팀원 추가 (roster에 append)
 * @param {Object} teammateInfo
 * @param {string} teammateInfo.name - 팀원 이름/ID
 * @param {string} [teammateInfo.role] - 역할 (기본: "agent")
 * @param {string} [teammateInfo.model] - 모델 (기본: "sonnet")
 * @param {string} [teammateInfo.currentTask] - 현재 태스크
 * @param {string} [teammateInfo.taskId] - 태스크 ID
 */
function addTeammate(teammateInfo) {
  const state = readAgentState();
  if (!state) {
    debugLog('StateWriter', 'Cannot add teammate - no agent state file');
    return;
  }

  // 중복 방지: 같은 이름이면 업데이트
  const existingIdx = state.teammates.findIndex(t => t.name === teammateInfo.name);
  const now = new Date().toISOString();

  const teammate = {
    name: teammateInfo.name,
    role: teammateInfo.role || 'agent',
    model: teammateInfo.model || 'sonnet',
    status: 'spawning',
    currentTask: teammateInfo.currentTask || null,
    taskId: teammateInfo.taskId || null,
    startedAt: now,
    lastActivityAt: now,
  };

  if (existingIdx >= 0) {
    // 기존 팀원 정보 업데이트 (startedAt 유지)
    teammate.startedAt = state.teammates[existingIdx].startedAt;
    state.teammates[existingIdx] = teammate;
  } else {
    // 최대 10명 제한
    if (state.teammates.length >= 10) {
      debugLog('StateWriter', 'Max teammates (10) reached, skipping add');
      return;
    }
    state.teammates.push(teammate);
  }

  writeAgentState(state);
}
```

**최대 팀원 수**: 10 (Plan 스키마 규칙 3)
**중복 처리**: 같은 name이면 기존 항목 업데이트 (startedAt 보존)

---

#### 4.1.6 `updateTeammateStatus(name, status, taskInfo)`

```javascript
/**
 * 팀원 상태 업데이트
 * @param {string} name - 팀원 이름
 * @param {string} status - 새 상태 ("spawning"|"working"|"idle"|"completed"|"failed")
 * @param {Object|null} [taskInfo] - 태스크 정보
 * @param {string} [taskInfo.task] - 태스크 제목
 * @param {string} [taskInfo.taskId] - 태스크 ID
 */
function updateTeammateStatus(name, status, taskInfo) {
  const state = readAgentState();
  if (!state) return;

  const teammate = state.teammates.find(t => t.name === name);
  if (!teammate) {
    debugLog('StateWriter', 'Teammate not found for status update', { name });
    return;
  }

  teammate.status = status;
  teammate.lastActivityAt = new Date().toISOString();

  if (taskInfo) {
    teammate.currentTask = taskInfo.task || null;
    teammate.taskId = taskInfo.taskId || null;
  } else if (status === 'idle' || status === 'completed') {
    teammate.currentTask = null;
    teammate.taskId = null;
  }

  writeAgentState(state);
}
```

**상태 전이**:
```
spawning → working (태스크 할당 시)
working → idle (태스크 완료 후 대기)
working → completed (모든 작업 완료)
working → failed (오류 발생)
idle → working (새 태스크 할당)
```

---

#### 4.1.7 `removeTeammate(name)`

```javascript
/**
 * 팀원 제거 (SubagentStop 시)
 * @param {string} name - 팀원 이름
 */
function removeTeammate(name) {
  const state = readAgentState();
  if (!state) return;

  const beforeCount = state.teammates.length;
  state.teammates = state.teammates.filter(t => t.name !== name);

  if (state.teammates.length < beforeCount) {
    writeAgentState(state);
    debugLog('StateWriter', 'Teammate removed', { name });
  }
}
```

**참고**: Plan에서는 removeTeammate를 정의했으나, 실제로는 `updateTeammateStatus(name, 'completed')` 후 유지하는 것이 Studio UI에 더 유용할 수 있음. 두 가지 방식 모두 지원.

---

#### 4.1.8 `updateProgress(progressData)`

```javascript
/**
 * 작업 진행률 업데이트
 * @param {Object} progressData - getTeamProgress() 반환값과 동일한 형식
 * @param {number} progressData.total
 * @param {number} progressData.completed
 * @param {number} progressData.inProgress
 * @param {number} progressData.pending
 * @param {number} [progressData.failed] - 실패 수 (기본: 0)
 */
function updateProgress(progressData) {
  const state = readAgentState();
  if (!state) return;

  state.progress = {
    totalTasks: progressData.total || 0,
    completedTasks: progressData.completed || 0,
    inProgressTasks: progressData.inProgress || 0,
    failedTasks: progressData.failed || 0,
    pendingTasks: progressData.pending || 0,
  };

  writeAgentState(state);
}
```

**데이터 소스**: `lib/team/task-queue.js`의 `getTeamProgress(feature, phase)` 반환값을 직접 전달

---

#### 4.1.9 `addRecentMessage(message)`

```javascript
/**
 * 최근 메시지 추가 (링 버퍼, 최대 50건)
 * @param {Object} message
 * @param {string} message.from - 발신자
 * @param {string} message.to - 수신자
 * @param {string} message.content - 메시지 내용
 */
function addRecentMessage(message) {
  const state = readAgentState();
  if (!state) return;

  const entry = {
    from: message.from || 'unknown',
    to: message.to || 'all',
    content: message.content || '',
    timestamp: new Date().toISOString(),
  };

  state.recentMessages.push(entry);

  // 링 버퍼: 50건 초과 시 가장 오래된 항목 제거
  const MAX_MESSAGES = 50;
  if (state.recentMessages.length > MAX_MESSAGES) {
    state.recentMessages = state.recentMessages.slice(-MAX_MESSAGES);
  }

  writeAgentState(state);
}
```

**링 버퍼**: `Array.slice(-50)`으로 구현 (Plan 스키마 규칙 4)

---

#### 4.1.10 `cleanupAgentState()`

```javascript
/**
 * 세션 종료 시 agent state 정리
 * - enabled: false
 * - teammates: [] (비움)
 * - progress, recentMessages: 유지 (Studio 최종 상태 표시용)
 * - lastUpdated: 현재 시각
 */
function cleanupAgentState() {
  const state = readAgentState();
  if (!state) return;

  state.enabled = false;
  state.teammates = [];
  // progress와 recentMessages는 유지 (Plan R10 요구사항)

  writeAgentState(state);

  debugLog('StateWriter', 'Agent state cleaned up', {
    feature: state.feature,
    preservedMessages: state.recentMessages.length,
  });
}
```

**파일 삭제 안 함**: Studio가 여전히 폴링 중일 수 있으므로 `enabled: false`로 설정만 함

---

### 4.2 Module Export Structure

```javascript
// lib/team/state-writer.js exports
module.exports = {
  initAgentState,
  updateTeammateStatus,
  addTeammate,
  removeTeammate,
  updateProgress,
  addRecentMessage,
  cleanupAgentState,
  getAgentStatePath,
  readAgentState,
};
```

### 4.3 Index.js Export 추가

```javascript
// lib/team/index.js 에 추가할 내용
const stateWriter = require('./state-writer');

module.exports = {
  // ... existing 30 exports ...

  // State Writer (9 exports) -- NEW
  initAgentState: stateWriter.initAgentState,
  updateTeammateStatus: stateWriter.updateTeammateStatus,
  addTeammate: stateWriter.addTeammate,
  removeTeammate: stateWriter.removeTeammate,
  updateProgress: stateWriter.updateProgress,
  addRecentMessage: stateWriter.addRecentMessage,
  cleanupAgentState: stateWriter.cleanupAgentState,
  getAgentStatePath: stateWriter.getAgentStatePath,
  readAgentState: stateWriter.readAgentState,
};
```

---

## 5. Hook Integration Specification

### 5.1 SubagentStart Hook Handler (NEW)

**파일**: `scripts/subagent-start-handler.js`
**Hook 이벤트**: `SubagentStart`
**타임아웃**: 5000ms

```javascript
#!/usr/bin/env node
/**
 * subagent-start-handler.js - SubagentStart Hook Handler
 *
 * Subagent가 spawn될 때:
 * 1. agent-state.json이 없으면 initAgentState() 호출
 * 2. addTeammate()로 새 팀원 등록
 * 3. status: "spawning"
 */

const {
  readStdinSync,
  debugLog,
  outputAllow,
  getPdcaStatusFull,
} = require('../lib/common.js');

function main() {
  debugLog('SubagentStart', 'Hook started');

  let hookContext = {};
  try {
    const input = readStdinSync();
    hookContext = typeof input === 'string' ? JSON.parse(input) : input;
  } catch (e) {
    debugLog('SubagentStart', 'Failed to parse context', { error: e.message });
    outputAllow('SubagentStart processed.', 'SubagentStart');
    return;
  }

  // State writer는 lazy load (team module에서)
  let stateWriter = null;
  try {
    const teamModule = require('../lib/team');
    stateWriter = {
      initAgentState: teamModule.initAgentState,
      addTeammate: teamModule.addTeammate,
      readAgentState: teamModule.readAgentState,
    };
  } catch (e) {
    debugLog('SubagentStart', 'State writer not available', { error: e.message });
    outputAllow('SubagentStart processed.', 'SubagentStart');
    return;
  }

  // Hook context에서 agent 정보 추출
  const agentName = hookContext.agent_name
    || hookContext.agent_id
    || hookContext.tool_input?.name
    || 'unknown';
  const agentType = hookContext.agent_type
    || hookContext.tool_input?.subagent_type
    || 'agent';
  const teamName = hookContext.team_name
    || hookContext.tool_input?.team_name
    || '';
  const sessionId = hookContext.session_id || '';

  // 모델 매핑: subagent_type 또는 model 필드에서 추출
  const modelRaw = hookContext.model
    || hookContext.tool_input?.model
    || 'sonnet';
  const model = ['opus', 'sonnet', 'haiku'].includes(modelRaw)
    ? modelRaw
    : 'sonnet';

  // agent-state.json이 없으면 초기화
  const existingState = stateWriter.readAgentState();
  if (!existingState || !existingState.enabled) {
    const pdcaStatus = getPdcaStatusFull();
    const feature = pdcaStatus?.primaryFeature || '';
    const featureData = pdcaStatus?.features?.[feature];

    stateWriter.initAgentState(teamName, feature, {
      pdcaPhase: featureData?.phase || 'plan',
      orchestrationPattern: 'leader',  // default
      ctoAgent: 'opus',
      sessionId,
    });
  }

  // 팀원 추가
  try {
    stateWriter.addTeammate({
      name: agentName,
      role: agentType,
      model: model,
      currentTask: hookContext.tool_input?.prompt
        ? hookContext.tool_input.prompt.substring(0, 100)
        : null,
    });
  } catch (e) {
    debugLog('SubagentStart', 'Failed to add teammate (non-fatal)', {
      error: e.message,
    });
  }

  const response = {
    systemMessage: `Subagent ${agentName} spawned`,
    hookSpecificOutput: {
      hookEventName: "SubagentStart",
      agentName,
      agentType,
      teamName,
    }
  };

  console.log(JSON.stringify(response));
  process.exit(0);
}

main();
```

**hookContext 필드 매핑**:

| hookContext 필드 | 매핑 대상 | 폴백 |
|-----------------|----------|------|
| `agent_name` / `agent_id` / `tool_input.name` | `teammate.name` | "unknown" |
| `agent_type` / `tool_input.subagent_type` | `teammate.role` | "agent" |
| `model` / `tool_input.model` | `teammate.model` | "sonnet" |
| `team_name` / `tool_input.team_name` | `state.teamName` | "" |
| `session_id` | `state.sessionId` | "" |

---

### 5.2 SubagentStop Hook Handler (NEW)

**파일**: `scripts/subagent-stop-handler.js`
**Hook 이벤트**: `SubagentStop`
**타임아웃**: 5000ms

```javascript
#!/usr/bin/env node
/**
 * subagent-stop-handler.js - SubagentStop Hook Handler
 *
 * Subagent가 종료될 때:
 * 1. updateTeammateStatus(name, "completed"|"failed")
 * 2. updateProgress() 호출
 * 3. 모든 팀원 완료 시 세션 종료 여부 확인
 */

const {
  readStdinSync,
  debugLog,
  outputAllow,
} = require('../lib/common.js');

function main() {
  debugLog('SubagentStop', 'Hook started');

  let hookContext = {};
  try {
    const input = readStdinSync();
    hookContext = typeof input === 'string' ? JSON.parse(input) : input;
  } catch (e) {
    debugLog('SubagentStop', 'Failed to parse context', { error: e.message });
    outputAllow('SubagentStop processed.', 'SubagentStop');
    return;
  }

  let teamModule = null;
  try {
    teamModule = require('../lib/team');
  } catch (e) {
    outputAllow('SubagentStop processed.', 'SubagentStop');
    return;
  }

  const agentName = hookContext.agent_name
    || hookContext.agent_id
    || 'unknown';

  // 종료 상태 결정 (transcript_path 존재 = 정상 종료)
  const isSuccess = hookContext.transcript_path != null
    || hookContext.exit_code === 0
    || hookContext.exit_code === undefined;  // exit_code 없으면 정상으로 간주
  const status = isSuccess ? 'completed' : 'failed';

  // 상태 업데이트
  try {
    teamModule.updateTeammateStatus(agentName, status, null);
  } catch (e) {
    debugLog('SubagentStop', 'Status update failed (non-fatal)', { error: e.message });
  }

  // 진행률 업데이트
  try {
    const state = teamModule.readAgentState();
    if (state && state.feature) {
      const progress = teamModule.getTeamProgress(state.feature, state.pdcaPhase);
      teamModule.updateProgress(progress);
    }
  } catch (e) {
    debugLog('SubagentStop', 'Progress update failed (non-fatal)', { error: e.message });
  }

  const response = {
    systemMessage: `Subagent ${agentName} stopped (${status})`,
    hookSpecificOutput: {
      hookEventName: "SubagentStop",
      agentName,
      status,
    }
  };

  console.log(JSON.stringify(response));
  process.exit(0);
}

main();
```

---

### 5.3 TeammateIdle Hook Modification

**파일**: `scripts/team-idle-handler.js`
**변경 위치**: `main()` 함수 내, `handleTeammateIdle()` 호출 직후 (line 53 이후)

```javascript
// === 기존 코드 (line 53) ===
const idleResult = teamModule.handleTeammateIdle(teammateId, pdcaStatus);

// === 추가할 코드 (line 54) ===
// State writer: idle 상태 기록
try {
  teamModule.updateTeammateStatus(teammateId, 'idle', null);
} catch (e) {
  debugLog('TeammateIdle', 'State write failed (non-fatal)', { error: e.message });
}

// === 기존 코드 계속 (line 55~) ===
const response = { ... };
```

**영향**: 기존 stdout 출력(`response` JSON)에 영향 없음. state-writer 호출이 먼저 실행된 후 기존 로직 진행.

---

### 5.4 TaskCompleted Hook Modification

**파일**: `scripts/pdca-task-completed.js`
**변경 위치**: team assignment 생성 블록 직후 (line 126 이후, `console.log` 이전)

```javascript
// === 기존 코드 (line 109-126) ===
if (teamModule && teamModule.isTeamModeAvailable()) {
  // ... team assignment logic ...
}

// === 추가할 코드 (line 127) ===
// State writer: 진행률 업데이트 + 메시지 기록
try {
  if (teamModule && teamModule.updateProgress) {
    const progress = teamModule.getTeamProgress(featureName, detectedPhase);
    teamModule.updateProgress(progress);

    // Phase transition 시 메시지 기록
    if (response.hookSpecificOutput.autoAdvanced) {
      teamModule.addRecentMessage({
        from: 'system',
        to: 'all',
        content: `Phase ${detectedPhase} → ${response.hookSpecificOutput.nextPhase} (auto-advanced)`,
      });
    }
  }
} catch (e) {
  debugLog('TaskCompleted', 'State write failed (non-fatal)', { error: e.message });
}

// === 기존 코드 (line 128) ===
console.log(JSON.stringify(response));
```

---

### 5.5 Stop Hook Modifications

#### 5.5.1 `scripts/team-stop.js`

**변경 위치**: `run()` 함수 내, `addPdcaHistory()` 호출 직후 (line 31 이후)

```javascript
// === 기존 코드 (line 25-31) ===
if (feature) {
  addPdcaHistory({ action: 'team_session_ended', ... });
}

// === 추가할 코드 (line 32) ===
try {
  const teamModule = require('../lib/team');
  if (teamModule.cleanupAgentState) {
    teamModule.cleanupAgentState();
  }
} catch (e) {
  debugLog('TeamStop', 'Agent state cleanup failed (non-fatal)', { error: e.message });
}

// === 기존 코드 (line 33) ===
outputAllow('Team session ended...', 'Stop');
```

#### 5.5.2 `scripts/cto-stop.js`

**변경 위치**: `run()` 함수 내, `addPdcaHistory()` 호출 직후 (line 41 이후)

```javascript
// === 기존 코드 (line 35-41) ===
addPdcaHistory({ action: 'cto_session_ended', ... });
debugLog('CTOStop', 'Team state saved', { ... });

// === 추가할 코드 (line 42) ===
try {
  if (teamModule.cleanupAgentState) {
    teamModule.cleanupAgentState();
  }
} catch (e) {
  debugLog('CTOStop', 'Agent state cleanup failed (non-fatal)', { error: e.message });
}

// === 기존 코드 (line 50) ===
outputAllow('CTO session ended...', 'CTOStop');
```

#### 5.5.3 `scripts/unified-stop.js`

**변경 위치**: `clearActiveContext()` 호출 직후 (line 212 이후)에 fallback cleanup 추가

```javascript
// === 기존 코드 (line 212) ===
clearActiveContext();

// === 추가할 코드 (line 213) ===
// Fallback: 어떤 handler도 cleanup하지 않았을 경우를 대비
if (!handled) {
  try {
    const teamModule = require('../lib/team');
    const state = teamModule.readAgentState ? teamModule.readAgentState() : null;
    if (state && state.enabled) {
      teamModule.cleanupAgentState();
      debugLog('UnifiedStop', 'Fallback agent state cleanup executed');
    }
  } catch (e) {
    // Silent - not all stops need agent state cleanup
  }
}

// === 기존 코드 (line 215) ===
if (!handled) {
  outputAllow('Stop event processed.', 'Stop');
}
```

---

### 5.6 hooks.json Registration

```json
{
  "hooks": {
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
}
```

**삽입 위치**: `TaskCompleted` 이후, `TeammateIdle` 이전 (논리적 순서)

---

## 6. Error Handling

### 6.1 Error Handling Matrix

| 시나리오 | 발생 위치 | 처리 방법 | 영향 |
|----------|----------|----------|------|
| `.bkit/` 디렉토리 없음 | writeAgentState | `fs.mkdirSync(recursive: true)` 자동 생성 | 없음 |
| 디스크 꽉 참 | writeAgentState | debugLog 기록, 계속 실행 | state 미기록 |
| 파일 권한 거부 | writeAgentState | debugLog 기록, 계속 실행 | state 미기록 |
| JSON 파싱 실패 | readAgentState | null 반환 | 새로 initAgentState 호출됨 |
| 동시 쓰기 경합 | writeAgentState | 원자적 쓰기(rename)로 방지 | 마지막 쓰기 승리 |
| tmp 파일 잔존 | writeAgentState | catch 블록에서 unlink 시도 | 다음 쓰기에서 덮어쓰기 |
| 프로세스 비정상 종료 | N/A | `enabled: true` + stale `lastUpdated` | Studio에서 5분 타임아웃으로 stale 감지 |
| hookContext 필드 누락 | 각 handler | 폴백 값 사용 (e.g., "unknown", "sonnet") | 부분적 데이터 |
| team module require 실패 | 각 handler | try-catch, outputAllow로 기본 응답 | state 미기록 |
| Hook 타임아웃 (5000ms) | 모든 handler | writeFileSync는 ~5ms, 1000x 여유 | 발생 가능성 극히 낮음 |

### 6.2 Error Handling Pattern (모든 훅 공통)

```javascript
// 패턴: Non-fatal state write
try {
  stateWriter.someFunction(args);
} catch (e) {
  debugLog('HookName', 'State write failed (non-fatal)', { error: e.message });
  // NEVER throw - continue to existing hook logic
}
```

### 6.3 Studio 미설치 시 동작

bkit Studio가 설치되지 않은 환경에서의 동작:

| 동작 | Studio 설치됨 | Studio 미설치 |
|------|:---:|:---:|
| `.bkit/agent-state.json` 생성 | O | O |
| 파일 업데이트 | O | O |
| 파일 폴링 | O (2초 간격) | X (아무도 읽지 않음) |
| 파일 정리 (cleanup) | O | O |
| 디스크 사용량 | ~2KB | ~2KB (무시 가능) |
| 성능 영향 | 없음 | 없음 |
| 기능 장애 | 없음 | 없음 |

**결론**: Studio 미설치 시에도 agent-state.json은 정상적으로 생성/업데이트/정리됨. 파일 크기가 ~2KB로 매우 작아 디스크 부담 없음. 어떤 코드 경로에서도 Studio 존재 여부를 확인하지 않음.

---

## 7. Security Considerations

- [x] **파일 경로 인젝션 방지**: `getAgentStatePath()`가 고정 경로 반환 (사용자 입력으로 경로 구성 안 함)
- [x] **민감 정보 미포함**: agent-state.json에 토큰, 키, 비밀번호 등 미포함. 팀 구성과 진행률만 기록
- [x] **recentMessages 내용 제한**: 메시지 content는 PDCA 상태 전환 알림 등 시스템 메시지만 포함
- [x] **`.bkit/` gitignore**: `.gitignore`에 `.bkit/` 추가하여 agent-state.json이 소스 관리에 포함되지 않도록 함
- [x] **원자적 쓰기**: tmp + rename으로 파일 손상 방지

---

## 8. Test Plan

### 8.1 Test Scope

| 유형 | 대상 | 방법 |
|------|------|------|
| Unit | state-writer.js 9개 함수 | 수동 검증 (Zero Script QA) |
| Integration | Hook → state-writer 연동 | CTO Team 세션 실행 후 파일 확인 |
| E2E | Plugin → agent-state.json → Studio | Studio 설치 환경에서 통합 테스트 |

### 8.2 Test Cases

#### Unit Test (state-writer.js)

| # | TC | 검증 항목 | 기대 결과 |
|---|------|----------|----------|
| 1 | initAgentState 호출 | `.bkit/agent-state.json` 생성 | enabled: true, teammates: [] |
| 2 | addTeammate 호출 | teammates 배열에 추가 | 1개 항목, status: "spawning" |
| 3 | addTeammate 중복 | 같은 name으로 2번 호출 | 1개 항목 (업데이트) |
| 4 | addTeammate 최대 10명 | 11번째 추가 시도 | 10개까지만, 11번째 무시 |
| 5 | updateTeammateStatus | idle로 변경 | status: "idle", currentTask: null |
| 6 | updateProgress | progress 데이터 전달 | progress 필드 업데이트 |
| 7 | addRecentMessage 51건 | 51개 메시지 추가 | 50개만 유지 (링 버퍼) |
| 8 | cleanupAgentState | 세션 종료 | enabled: false, teammates: [], progress 유지 |
| 9 | readAgentState 파일 없음 | 파일 미존재 시 | null 반환 |
| 10 | writeAgentState 원자적 쓰기 | tmp + rename 확인 | .tmp 파일 잔존 없음 |

#### Integration Test (Hook 연동)

| # | TC | 검증 항목 | 기대 결과 |
|---|------|----------|----------|
| 11 | SubagentStart 첫 호출 | initAgentState + addTeammate | 파일 생성, 1팀원 |
| 12 | SubagentStart 추가 호출 | 기존 state에 addTeammate | 2팀원 |
| 13 | TeammateIdle 호출 | updateTeammateStatus("idle") | 해당 팀원 idle |
| 14 | TaskCompleted 호출 | updateProgress + addRecentMessage | progress 업데이트 |
| 15 | SubagentStop 호출 | updateTeammateStatus("completed") | 해당 팀원 completed |
| 16 | Stop 호출 (team-stop) | cleanupAgentState | enabled: false |
| 17 | Stop 호출 (cto-stop) | cleanupAgentState | enabled: false |
| 18 | 기존 훅 동작 보존 | stdout 출력 확인 | 기존 JSON 출력 변경 없음 |

#### Edge Case Test

| # | TC | 검증 항목 | 기대 결과 |
|---|------|----------|----------|
| 19 | .bkit/ 디렉토리 없음 | 자동 생성 | 에러 없이 파일 생성 |
| 20 | hookContext 빈 객체 | 폴백 값 사용 | "unknown" agent, "sonnet" model |
| 21 | Studio 미설치 | 전체 flow 실행 | 정상 동작 (파일만 생성, 폴링 없음) |
| 22 | 프로세스 비정상 종료 | lastUpdated 5분+ 경과 | Studio stale 감지 가능 |

---

## 9. Configuration Changes

### 9.1 bkit.config.json

```json
{
  "team": {
    "enabled": true,   // CHANGED: false → true
    // ... rest unchanged
  }
}
```

**근거**: Plan R7. Studio의 `isAvailable` 체크가 이 값을 참조. `enabled: true`로 변경하면 Studio가 팀 상태를 자동 감지.

### 9.2 .gitignore 추가

```gitignore
# bkit runtime state (agent-state.json)
.bkit/
```

---

## 10. Coding Convention Reference

### 10.1 이 기능에 적용되는 컨벤션

| 항목 | 적용 컨벤션 |
|------|------------|
| 모듈 구조 | `lib/team/state-writer.js` (단일 파일 모듈) |
| 함수 네이밍 | camelCase (`initAgentState`, `updateTeammateStatus`) |
| 상수 네이밍 | 없음 (MAX_MESSAGES = 50은 함수 내 로컬) |
| import 패턴 | Lazy require (circular dependency 방지) |
| export 패턴 | `module.exports = { fn1, fn2, ... }` |
| 에러 처리 | try-catch + debugLog, never throw |
| 파일 I/O | Sync (writeFileSync), 원자적 (tmp + rename) |
| JSDoc | 모든 public 함수에 JSDoc 타입 주석 |

### 10.2 기존 패턴 준수 사항

```javascript
// 1. Lazy require (lib/core에서와 동일)
let _core = null;
function getCore() {
  if (!_core) { _core = require('../core'); }
  return _core;
}

// 2. debugLog 패턴
const { debugLog } = getCore();
debugLog('StateWriter', 'Message', { key: value });

// 3. 디렉토리 생성 패턴
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

// 4. JSON 쓰기 패턴
fs.writeFileSync(path, JSON.stringify(data, null, 2));
```

---

## 11. Implementation Guide

### 11.1 File Structure

```
lib/team/
├── index.js              ← MODIFY: state-writer exports 추가
├── state-writer.js       ← NEW: 핵심 모듈 (~180 lines)
├── coordinator.js
├── strategy.js
├── task-queue.js
├── communication.js
├── orchestrator.js
├── cto-logic.js
└── hooks.js

scripts/
├── subagent-start-handler.js  ← NEW: SubagentStart 핸들러 (~80 lines)
├── subagent-stop-handler.js   ← NEW: SubagentStop 핸들러 (~70 lines)
├── team-idle-handler.js       ← MODIFY: +5 lines (state write)
├── pdca-task-completed.js     ← MODIFY: +15 lines (progress + message)
├── unified-stop.js            ← MODIFY: +10 lines (fallback cleanup)
├── team-stop.js               ← MODIFY: +6 lines (cleanup call)
└── cto-stop.js                ← MODIFY: +6 lines (cleanup call)

hooks/
└── hooks.json                 ← MODIFY: +SubagentStart, +SubagentStop entries

bkit.config.json               ← MODIFY: team.enabled: false → true
.gitignore                     ← MODIFY: +.bkit/ entry
```

### 11.2 Implementation Order

1. **Phase 1: Core Module** (블로킹 없음)
   - [ ] `lib/team/state-writer.js` 작성 (9개 함수)
   - [ ] `lib/team/index.js`에 state-writer exports 추가
   - [ ] 단위 테스트: initAgentState, readAgentState, writeAgentState 검증

2. **Phase 2: New Hook Handlers** (기존 코드 변경 없음)
   - [ ] `scripts/subagent-start-handler.js` 작성
   - [ ] `scripts/subagent-stop-handler.js` 작성
   - [ ] `hooks/hooks.json`에 SubagentStart, SubagentStop 등록
   - [ ] 통합 테스트: subagent spawn/stop 시 agent-state.json 확인

3. **Phase 3: Existing Hook Modifications** (최소 변경)
   - [ ] `scripts/team-idle-handler.js`: updateTeammateStatus 호출 추가 (+5 lines)
   - [ ] `scripts/pdca-task-completed.js`: updateProgress + addRecentMessage 추가 (+15 lines)
   - [ ] `scripts/unified-stop.js`: fallback cleanup 추가 (+10 lines)
   - [ ] `scripts/team-stop.js`: cleanupAgentState 호출 추가 (+6 lines)
   - [ ] `scripts/cto-stop.js`: cleanupAgentState 호출 추가 (+6 lines)
   - [ ] 통합 테스트: 기존 훅 stdout 출력 변경 없음 확인

4. **Phase 4: Config & Cleanup**
   - [ ] `bkit.config.json`: team.enabled → true
   - [ ] `.gitignore`: .bkit/ 추가
   - [ ] E2E 테스트: CTO 팀 세션 전체 lifecycle

---

## 12. File Change Summary

### New Files (3)

| File | Lines | Description |
|------|-------|-------------|
| `lib/team/state-writer.js` | ~180 | Core state writing module (9 exports) |
| `scripts/subagent-start-handler.js` | ~80 | SubagentStart hook handler |
| `scripts/subagent-stop-handler.js` | ~70 | SubagentStop hook handler |

### Modified Files (8)

| File | Lines Changed | Description |
|------|:---:|-------------|
| `lib/team/index.js` | +10 | state-writer require + 9 exports 추가 |
| `hooks/hooks.json` | +18 | SubagentStart, SubagentStop entries |
| `scripts/team-idle-handler.js` | +5 | updateTeammateStatus("idle") 호출 |
| `scripts/pdca-task-completed.js` | +15 | updateProgress + addRecentMessage |
| `scripts/unified-stop.js` | +10 | Fallback cleanupAgentState |
| `scripts/team-stop.js` | +6 | cleanupAgentState 호출 |
| `scripts/cto-stop.js` | +6 | cleanupAgentState 호출 |
| `bkit.config.json` | 1 | team.enabled: false → true |
| `.gitignore` | +2 | .bkit/ entry |

### Total: 3 new + 9 modified = 12 files, ~400 lines added

---

## 13. Cross-Reference

### Studio-Side Contract

이 설계서의 `agent-state.json` 스키마(Section 3.1)는 Studio-side plan과 **동일한 계약**을 구현합니다:
- Studio는 `{project}/.bkit/agent-state.json`을 2초 간격으로 폴링
- `enabled: true` → Team UI 활성화
- `enabled: false` → "Session Ended" 표시 (progress/messages 유지)
- 파일 없음 → "Agents Team Mode Inactive"
- `lastUpdated` 5분+ 경과 → "Stale Session" 경고

### Plan Document Traceability

| Plan 요구사항 | Design Section | 구현 위치 |
|:---:|:---:|---|
| R1 (state-writer) | Section 4 | lib/team/state-writer.js |
| R2 (SubagentStart) | Section 5.1 | scripts/subagent-start-handler.js |
| R3 (SubagentStop) | Section 5.2 | scripts/subagent-stop-handler.js |
| R4 (TeammateIdle) | Section 5.3 | scripts/team-idle-handler.js 수정 |
| R5 (TaskCompleted) | Section 5.4 | scripts/pdca-task-completed.js 수정 |
| R6 (Stop) | Section 5.5 | team-stop.js, cto-stop.js, unified-stop.js 수정 |
| R7 (Config) | Section 9.1 | bkit.config.json 수정 |
| R8 (Non-blocking) | Section 6 | 모든 훅에서 try-catch 패턴 |
| R9 (File path) | Section 4.1.1 | getAgentStatePath() |
| R10 (Graceful cleanup) | Section 4.1.10 | cleanupAgentState() |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-09 | Initial draft - CTO Team analysis | CTO Team (code-analyzer, qa-strategist, frontend-architect) |
