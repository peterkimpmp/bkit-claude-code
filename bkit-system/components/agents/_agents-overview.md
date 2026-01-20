# Agents Overview

> bkit에 정의된 11개 Agents 목록과 각각의 역할

## Agents란?

Agents는 **특정 작업에 특화된 AI 서브에이전트**입니다.
- Task tool로 호출되어 독립적으로 작업 수행
- 각자의 allowed-tools와 전문 프롬프트 보유
- Frontmatter hooks로 특정 동작 트리거

## 전체 목록

### Level-Based Agents (4개)

프로젝트 레벨에 따라 자동 추천되는 에이전트들:

| Agent | 대상 레벨 | 역할 | Hooks |
|-------|----------|------|-------|
| [[starter-guide]] | Starter | 초보자 친화적 가이드 | - |
| [[bkend-expert]] | Dynamic | BaaS/풀스택 전문가 | - |
| [[enterprise-expert]] | Enterprise | CTO급 아키텍처 가이드 | - |
| [[infra-architect]] | Enterprise | AWS/K8s/Terraform 전문가 | - |

### Task-Based Agents (7개)

특정 작업에 따라 자동 호출되는 에이전트들:

| Agent | 트리거 조건 | 역할 | Hooks |
|-------|-----------|------|-------|
| [[pipeline-guide]] | "뭐부터", "어디서부터" | 9단계 파이프라인 안내 | - |
| [[gap-detector]] | "갭 분석", "설계-구현 비교" | 설계 vs 구현 갭 분석 | PostToolUse |
| [[design-validator]] | "설계 검증", "스펙 확인" | 설계 문서 검증 | PreToolUse |
| [[code-analyzer]] | "코드 분석", "품질 검사" | 코드 품질/보안 분석 | PreToolUse (block) |
| [[qa-monitor]] | "QA", "테스트", "로그 분석" | Zero Script QA 실행 | PostToolUse |
| [[pdca-iterator]] | "고쳐줘", "개선해줘", "반복" | 자동 반복 개선 | - |
| [[report-generator]] | "보고서", "요약", "완료" | PDCA 보고서 생성 | - |

---

## Agent 자동 호출 규칙

`auto-trigger-agents.md` instruction에 정의된 규칙:

### Rule 1: Level-Based Selection

```
사용자가 기능 개발 요청 시:
1. 프로젝트 레벨 감지
2. 레벨에 맞는 Agent 준비
   - Starter → starter-guide
   - Dynamic → bkend-expert
   - Enterprise → enterprise-expert 또는 infra-architect
```

### Rule 2: Task-Based Selection

```
키워드 매칭:
- "code review", "security scan" → code-analyzer
- "gap analysis" → gap-detector
- "QA", "test", "log analysis" → qa-monitor
- "report", "summary" → report-generator
```

### Rule 3: Proactive Suggestions

```
코드 구현 후 → "코드 품질 분석할까요? (code-analyzer)"
설계 문서 작성 후 → "설계 검증할까요? (design-validator)"
기능 완료 후 → "갭 분석할까요? (gap-detector)"
PDCA 사이클 후 → "완료 보고서 생성할까요? (report-generator)"
```

---

## Agent Frontmatter 구조

```yaml
---
name: agent-name
description: |
  Agent 설명.

  Use proactively when user...

  Triggers: keyword1, keyword2, 한글키워드

  Do NOT use for: 제외 조건
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - LSP
  - TodoWrite
hooks:
  PreToolUse:
    - matcher: "Write"
      script: "./scripts/script-name.sh"
  PostToolUse:
    - matcher: "Write"
      script: "./scripts/script-name.sh"
---
```

---

## Agent별 Hooks

| Agent | PreToolUse | PostToolUse |
|-------|-----------|-------------|
| [[gap-detector]] | - | `gap-detector-post.sh` |
| [[design-validator]] | `design-validator-pre.sh` | - |
| [[code-analyzer]] | Block (read-only) | - |
| [[qa-monitor]] | - | `qa-monitor-post.sh` |

---

## Agent vs Skill 차이

| 구분 | Skill | Agent |
|------|-------|-------|
| 역할 | 지식/컨텍스트 제공 | 독립적 작업 수행 |
| 호출 | 자동 활성화 | Task tool로 명시적 호출 |
| 범위 | 현재 대화에 컨텍스트 추가 | 별도 대화로 작업 후 결과 반환 |
| 예시 | phase-4-api → API 설계 지식 | qa-monitor → 실제 QA 수행 |

---

## Skill → Agent 연결

| Skill | 연결된 Agent |
|-------|-------------|
| starter | starter-guide |
| dynamic | bkend-expert |
| enterprise | enterprise-expert, infra-architect |
| development-pipeline | pipeline-guide |
| zero-script-qa | qa-monitor |
| evaluator-optimizer | pdca-iterator |
| analysis-patterns | code-analyzer, gap-detector |
| document-standards | design-validator |

---

## Agent 소스 위치

```
.claude/agents/
├── starter-guide.md
├── bkend-expert.md
├── enterprise-expert.md
├── infra-architect.md
├── pipeline-guide.md
├── gap-detector.md
├── design-validator.md
├── code-analyzer.md
├── qa-monitor.md
├── pdca-iterator.md
└── report-generator.md
```

---

## 관련 문서

- [[../skills/_skills-overview]] - Skill 상세
- [[../hooks/_hooks-overview]] - Hook 이벤트 상세
- [[../../triggers/trigger-matrix]] - 트리거 매트릭스
