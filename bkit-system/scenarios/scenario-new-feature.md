# Scenario: New Feature Request

> 사용자가 새 기능을 요청할 때 bkit의 PDCA 플로우

## 시나리오 개요

```
사용자: "로그인 기능 만들어줘"
→ PDCA 문서 존재 확인
→ 없으면 Plan/Design 먼저 생성
→ 구현
→ Gap Analysis 제안
```

## 발동 순서 (Flow)

```
┌─────────────────────────────────────────────────────────────────┐
│  1. 사용자 요청: "로그인 기능 만들어줘"                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. Skills 활성화 (키워드 매칭)                                  │
│                                                                 │
│  [[../components/skills/bkit-rules]] 활성화                     │
│  • "기능", "만들어" 키워드 매칭                                 │
│                                                                 │
│  [[../components/skills/dynamic]] 활성화 (Level=Dynamic인 경우)  │
│  • "로그인" 키워드 매칭                                         │
│                                                                 │
│  [[../components/skills/phase-4-api]] 활성화                    │
│  • 백엔드 기능이므로 API 관련 skill 활성화                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. PDCA 문서 확인 (pdca-rules instruction)                     │
│                                                                 │
│  Claude가 확인:                                                 │
│  • docs/01-plan/features/login.plan.md 존재?                   │
│  • docs/02-design/features/login.design.md 존재?               │
│                                                                 │
│  없으면 → Design 먼저 생성 제안                                 │
│  있으면 → 바로 구현                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            ▼                                   ▼
   ┌─────────────────┐                 ┌─────────────────┐
   │ 문서 없음       │                 │ 문서 있음       │
   └─────────────────┘                 └─────────────────┘
            │                                   │
            ▼                                   ▼
┌─────────────────────────┐       ┌─────────────────────────┐
│ 4a. Design 문서 생성    │       │ 4b. 구현 시작           │
│                         │       │                         │
│ AskUserQuestion:        │       │ 기존 design doc 참조    │
│ "설계 먼저 할까요?"     │       │ 하여 구현               │
│                         │       │                         │
│ Yes → /pdca-design      │       │                         │
│ No → 바로 구현          │       │                         │
└─────────────────────────┘       └─────────────────────────┘
            │                                   │
            └─────────────────┬─────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. Write/Edit 시 Hooks 발동 ([[scenario-write-code]] 참조)     │
│                                                                 │
│  PreToolUse: pdca-pre-write, task-classify, phase2-convention  │
│  PostToolUse: pdca-post-write, phase6-ui-post                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  6. 구현 완료 후                                                 │
│                                                                 │
│  Claude 제안 (auto-trigger-agents instruction):                 │
│  "구현이 완료되었습니다. Gap Analysis를 실행할까요?"            │
│  • Yes → gap-detector agent 호출                                │
│  • No → 종료                                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  7. Gap Analysis 결과에 따라                                    │
│                                                                 │
│  Match Rate >= 90% → "PDCA 완료, 보고서 생성할까요?"            │
│  Match Rate < 70% → "자동 수정(iterate) 실행할까요?"            │
└─────────────────────────────────────────────────────────────────┘
```

## 예시: "로그인 기능 만들어줘"

### Case 1: Design 문서 없음

```
사용자: "로그인 기능 만들어줘"

Claude: 로그인 기능을 구현하겠습니다.

먼저 설계 문서가 없는 것 같습니다.
PDCA 방법론에 따라 설계 문서를 먼저 작성하면
나중에 Gap Analysis로 검증할 수 있습니다.

설계 문서를 먼저 작성할까요?
1. 네, 설계 먼저 (/pdca-design login)
2. 아니오, 바로 구현

[사용자: 1 선택]

Claude: 로그인 기능 설계 문서를 작성합니다.
[design template 적용하여 docs/02-design/features/login.design.md 생성]

설계가 완료되었습니다. 이제 구현을 시작할까요?
```

### Case 2: Design 문서 있음

```
사용자: "로그인 기능 만들어줘"

Claude: 로그인 기능을 구현하겠습니다.

기존 설계 문서를 참조합니다:
- docs/02-design/features/login.design.md

[설계 문서 내용 요약]
- POST /api/auth/login
- POST /api/auth/logout
- GET /api/auth/me

이 설계대로 구현하겠습니다.

[구현 진행...]

구현이 완료되었습니다.
Gap Analysis를 실행하여 설계-구현 일치 여부를 확인할까요?
```

---

## Level별 동작 차이

### Starter Level

```
특징:
- BaaS 없음 (정적 웹)
- 로그인 기능 자체가 Level 초과

동작:
Claude: "로그인 기능은 Dynamic 레벨에서 가능합니다.
레벨 업그레이드가 필요합니다. /upgrade-level dynamic"
```

### Dynamic Level

```
특징:
- bkend.ai BaaS 사용
- 로그인 = bkend.ai 인증 API 연동

동작:
Claude: bkend-expert agent 활성화 가능
설계 시 bkend.ai collection 구조 포함
```

### Enterprise Level

```
특징:
- 자체 백엔드
- 마이크로서비스 가능

동작:
Claude: enterprise-expert 또는 infra-architect 활성화 가능
설계 시 서비스 분리, K8s 배포 고려
```

---

## Agent 자동 호출 시점

| 시점 | 호출 가능 Agent |
|------|----------------|
| 기능 요청 초기 | starter-guide, bkend-expert, enterprise-expert (Level별) |
| 설계 문서 작성 후 | design-validator |
| 구현 완료 후 | gap-detector, code-analyzer |
| 갭 분석 후 (< 70%) | pdca-iterator |
| PDCA 완료 후 | report-generator |

---

## 테스트 체크리스트

- [ ] "기능 만들어줘" 요청 시 bkit-rules skill 활성화 확인
- [ ] design doc 없을 때 생성 제안 확인
- [ ] design doc 있을 때 바로 구현 시작 확인
- [ ] 구현 완료 후 Gap Analysis 제안 확인
- [ ] Level별 적절한 agent 제안 확인

---

## 관련 문서

- [[scenario-write-code]] - 코드 작성 시나리오
- [[scenario-qa]] - QA 실행 시나리오
- [[../triggers/trigger-matrix]] - 트리거 매트릭스
- [[../components/agents/_agents-overview]] - Agent 자동 호출 규칙
