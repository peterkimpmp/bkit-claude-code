# Priority Rules

> 여러 트리거가 동시에 발동될 때의 우선순위와 충돌 해결 규칙

## Hook 실행 순서

Claude Code는 여러 hooks가 동시에 매칭될 때 **모두 실행**합니다.
순서는 정의된 순서 (파일 알파벳 순 또는 frontmatter 정의 순)를 따릅니다.

### PreToolUse 실행 순서 (Write|Edit)

```
1. bkit-rules → pdca-pre-write.sh
2. task-classification → task-classify.sh
3. phase-2-convention → phase2-convention-pre.sh
4. (특정 agent 활성화 시) design-validator, code-analyzer
```

**결과 병합**: 각 hook의 `additionalContext`가 Claude에게 전달됩니다.

### Block 우선순위

`"decision": "block"` 반환 시 **즉시 중단**됩니다.

| Script | Block 조건 |
|--------|-----------|
| `qa-pre-bash.sh` | 파괴적 명령어 (rm -rf, DROP TABLE 등) |
| `code-analyzer` agent | Write/Edit 시도 (read-only agent) |

---

## Skill 활성화 우선순위

### 자동 활성화 조건

Skills는 다음 조건으로 활성화됩니다:

1. **명시적 호출**: `/skill-name` 또는 Skill tool 사용
2. **키워드 매칭**: 사용자 메시지에 Triggers 키워드 포함
3. **파일 컨텍스트**: 작업 중인 파일 경로가 skill과 연관

### 충돌 시 우선순위

여러 skill이 동시에 매칭될 때:

```
1. 명시적 호출 > 키워드 매칭 > 파일 컨텍스트
2. 더 구체적인 skill > 일반적인 skill
   예: phase-4-api > bkit-rules (API 작업 시)
3. Level skill은 항상 적용
   starter/dynamic/enterprise 중 하나는 항상 활성
```

---

## Agent 자동 호출 규칙

### 호출 조건 (auto-trigger-agents.md)

| 조건 | 호출되는 Agent |
|------|---------------|
| Level = Starter + 코딩 작업 | starter-guide |
| Level = Dynamic + 백엔드 작업 | bkend-expert |
| Level = Enterprise + 아키텍처 결정 | enterprise-expert |
| Level = Enterprise + 인프라 작업 | infra-architect |
| "code review", "security scan" 키워드 | code-analyzer |
| "gap analysis" 키워드 | gap-detector |
| "QA", "test", "log analysis" 키워드 | qa-monitor |
| "report", "summary" 키워드 | report-generator |

### 호출하지 않는 조건

- 사용자가 명시적으로 거부
- 작업이 trivial (단일 파일 수정, 사소한 fix)
- 동일 작업에 이미 agent가 호출됨

---

## Instructions vs Hooks

| 구분 | Instructions | Hooks |
|------|-------------|-------|
| 위치 | `.claude/instructions/*.md` | skill/agent frontmatter |
| 적용 방식 | Claude가 읽고 판단 | 시스템이 자동 실행 |
| 강제성 | Soft (Claude 재량) | Hard (무조건 실행) |
| 우선순위 | Hooks보다 낮음 | Instructions보다 높음 |

### 권장 사용

- **Instructions**: 일반적인 가이드라인, 스타일 규칙
- **Hooks**: 반드시 실행되어야 하는 검증, 차단, 알림

---

## 충돌 해결 예시

### 예시 1: Write + 여러 Hook

```
상황: src/features/auth/login.ts 파일 Write

발동:
1. bkit-rules → "auth feature의 design doc 확인"
2. task-classification → "Feature 크기, PDCA 권장"
3. phase-2-convention → "TypeScript 컨벤션 리마인드"

결과: 3개의 additionalContext가 모두 Claude에게 전달
Claude는 이를 종합하여 사용자에게 안내
```

### 예시 2: Block 발생

```
상황: rm -rf /tmp/* 명령 실행 (QA 중)

발동:
1. qa-pre-bash.sh → 파괴적 패턴 감지
2. "decision": "block" 반환

결과: 명령 실행 차단, 이유 안내
```

### 예시 3: Skill + Agent 동시 활성화

```
상황: "API 설계해줘"

발동:
1. phase-4-api skill 활성화 (키워드: "API 설계")
2. skill의 agent: qa-monitor 연결
3. (Level에 따라) bkend-expert 또는 infra-architect 추가 가능

결과: phase-4-api skill 컨텍스트 + 적절한 agent 조합
```

---

## 권장 사항

### 새 Hook 추가 시

1. [[triggers/trigger-matrix]]에 먼저 기록
2. 기존 hook과 충돌 여부 확인
3. `decision: "allow"` 기본, block은 최소화
4. `additionalContext`로 안내 제공

### 새 Skill 추가 시

1. Triggers 키워드가 기존 skill과 겹치지 않는지 확인
2. 연결할 Agent 명시
3. hooks 정의 시 [[triggers/trigger-matrix]] 업데이트

---

## 관련 문서

- [[triggers/trigger-matrix]] - 전체 트리거 매트릭스
- [[components/hooks/_hooks-overview]] - Hook 이벤트 상세
- [[_GRAPH-INDEX]] - 전체 인덱스
