# bkit System Architecture

> bkit 플러그인의 내부 구조와 트리거 시스템을 문서화한 아키텍처 가이드

## 이 문서의 목적

1. **예측 가능성**: 사용자 행동에 따라 어떤 기능이 발동되는지 파악
2. **테스트 가능성**: 시나리오별 예상 동작 검증
3. **기여자 가이드**: 새 기능 추가 시 기존 시스템과의 관계 이해

## Quick Links

- [[_GRAPH-INDEX]] - 옵시디안 그래프 허브 (모든 관계 시각화)
- [[triggers/trigger-matrix]] - 트리거 매트릭스 (핵심)
- [[scenarios/scenario-write-code]] - 코드 작성 시 동작 흐름

## 시스템 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                     bkit Trigger System                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   Skills     │───▶│   Agents     │───▶│   Scripts    │      │
│  │  (26개)      │    │  (11개)      │    │  (15개)      │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│         │                   │                   │               │
│         ▼                   ▼                   ▼               │
│  ┌──────────────────────────────────────────────────────┐      │
│  │                    Hooks Layer                        │      │
│  │  PreToolUse │ PostToolUse │ Stop │ SessionStart      │      │
│  └──────────────────────────────────────────────────────┘      │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │                  Claude Code Runtime                  │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 컴포넌트 요약

| 컴포넌트 | 개수 | 역할 | 상세 |
|----------|------|------|------|
| Skills | 26 | 도메인 지식 + 훅 정의 | [[components/skills/_skills-overview]] |
| Agents | 11 | 전문 작업 수행 | [[components/agents/_agents-overview]] |
| Hooks | 4종 | 이벤트 기반 트리거 | [[components/hooks/_hooks-overview]] |
| Scripts | 15 | 실제 로직 실행 | [[components/scripts/_scripts-overview]] |
| Commands | 18 | 슬래시 명령어 | `/pdca-*`, `/init-*`, 등 |
| Instructions | 7 | Soft Rules | Claude가 읽어서 적용 |

## 트리거 레이어

bkit은 6개 레이어에서 트리거가 발생합니다:

```
Layer 1: settings.json        → SessionStart hook
Layer 2: Instructions         → Claude가 읽어서 적용하는 soft rules
Layer 3: Skill Frontmatter    → hooks: PreToolUse, PostToolUse, Stop
Layer 4: Agent Frontmatter    → hooks: PreToolUse, PostToolUse
Layer 5: Description Triggers → "Triggers:" 키워드 매칭
Layer 6: Scripts              → 실제 bash 로직 실행
```

자세한 내용: [[triggers/trigger-matrix]]

## 주요 시나리오

| 시나리오 | 발동되는 것들 | 상세 |
|----------|--------------|------|
| 코드 작성 (Write/Edit) | 3-4개 hooks | [[scenarios/scenario-write-code]] |
| 새 기능 요청 | PDCA flow + agents | [[scenarios/scenario-new-feature]] |
| QA 실행 | qa-monitor + scripts | [[scenarios/scenario-qa]] |

## 폴더 구조

```
bkit-system/
├── README.md                  # 이 파일
├── _GRAPH-INDEX.md            # 옵시디안 그래프 허브
├── components/
│   ├── skills/                # Skill 상세
│   ├── agents/                # Agent 상세
│   ├── hooks/                 # Hook 이벤트 정리
│   └── scripts/               # Script 상세
├── triggers/
│   ├── trigger-matrix.md      # 트리거 매트릭스
│   └── priority-rules.md      # 우선순위 규칙
├── scenarios/                 # 사용자 시나리오별 동작
└── testing/
    └── test-checklist.md      # 테스트 체크리스트
```

## 관련 소스 위치

| 항목 | 경로 |
|------|------|
| Skills | `.claude/skills/*/SKILL.md` |
| Agents | `.claude/agents/*.md` |
| Scripts | `.claude/scripts/*.sh` |
| Commands | `.claude/commands/*.md` |
| Instructions | `.claude/instructions/*.md` |
| Templates | `.claude/templates/*.md` |
| Settings | `.claude/settings.json` |
