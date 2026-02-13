# bkit v1.5.3 Final QA Test Plan

> **Feature**: bkit-v1.5.3-final-qa
> **Level**: Dynamic
> **Date**: 2026-02-10
> **Author**: CTO Team (qa-strategist, code-analyzer, gap-detector)
> **Status**: Approved
> **Previous Tests**:
>   - v1.5.3 comprehensive (team-visibility): 685 TC, 646 PASS, 39 SKIP (100%)
>   - v1.5.3 enhancement: 31 TC, 31/31 PASS (100%)
> **Branch**: feature/v1.5.3-cto-team-agent-enhancement

---

## 1. Background

### 1.1 Test Necessity

v1.5.3 enhancement 적용 후 전체 코드베이스에 대한 최종 통합 QA가 필요합니다:

| 변경 영역 | 상세 | 영향 범위 |
|-----------|------|----------|
| plugin.json outputStyles | 새 필드 추가 | 플러그인 로딩, output-style 메뉴 |
| output-style-setup 커맨드 | 신규 파일 | 커맨드 시스템, 스킬 목록 |
| bkend docs 참조 체계 | Agent Memory + 5 Skills + 1 Agent 수정 | bkend 에이전트 동작, 스킬 내용 |
| bkend MCP 가이드 강화 | bkend-quickstart 스킬 대폭 확장 | MCP 설정 가이드 |
| 버전/수치 동기화 | 5+ 파일 버전 변경 | 전체 내부 일관성 |
| CLAUDE.md 전략 문서화 | bkit.md 확장 | 사용자 가이드 |
| session-start.js 수정 | 7곳 변경 | 세션 시작 경험 전체 |

### 1.2 테스트 범위

기존 685 TC + enhancement 31 TC + 신규 UX/철학 TC를 통합한 최종 QA:

| 범주 | TC 수 | 출처 |
|------|:-----:|------|
| 기존 라이브러리/모듈 | ~245 | 기존 comprehensive test |
| 기존 스킬/에이전트/훅 | ~209 | 기존 comprehensive test |
| 기존 PDCA/팀/UX/ML/Edge/Regression | ~195 | 기존 comprehensive test |
| Enhancement 전용 | 31 | enhancement design TCs |
| 신규 UX 시나리오 | 20 | 사용자 경험 검증 |
| 철학 정합성 | 15 | bkit-system/philosophy 기준 |
| **Total** | **~715** | |

### 1.3 CTO Team Composition

| Role | Agent Type | Responsibility | Model |
|------|-----------|---------------|-------|
| QA Lead | qa-strategist | 테스트 전략, TC 분배, 결과 통합 | sonnet |
| Library Tester | code-analyzer | lib/ 11모듈 241함수 + common.js 180 exports | opus |
| Integration Tester | gap-detector | Skills/Agents/Hooks/Config 통합 검증 | opus |
| UX Tester | general-purpose | 사용자 경험 + 철학 정합성 + enhancement | sonnet |

Orchestration Pattern: Council (Check phase)

---

## 2. Goals

### P0 (Must)

| ID | Goal | TC |
|:--:|------|:--:|
| G-01 | 라이브러리 전체 테스트 (11 modules, 241+ functions) | ~245 |
| G-02 | 스킬 전체 테스트 (26 skills) | 80 |
| G-03 | 에이전트 전체 테스트 (16 agents) | 64 |
| G-04 | 훅 시스템 테스트 (10 events) | 65 |
| G-05 | Enhancement 회귀 테스트 (31 TC) | 31 |

### P1 (Should)

| ID | Goal | TC |
|:--:|------|:--:|
| G-06 | PDCA 워크플로우 테스트 | 35 |
| G-07 | CTO 팀 오케스트레이션 | 30 |
| G-08 | 다국어 트리거 테스트 | 24 |
| G-09 | Config/Template 테스트 | 25 |
| G-10 | 사용자 경험 시나리오 | 20 |

### P2 (Could)

| ID | Goal | TC |
|:--:|------|:--:|
| G-11 | 철학 정합성 검증 | 15 |
| G-12 | Edge Case/Performance | 20 |
| G-13 | 이전 FAIL/SKIP 회귀 | 10 |

---

## 3. Philosophy Alignment Test Cases

bkit-system/philosophy/ 4문서 기준:

### 3.1 Core Mission (core-mission.md)

| TC | Verification | Expected |
|----|-------------|----------|
| PHIL-01 | SessionStart hook이 존재하고 자동 실행됨 | hooks.json에 SessionStart 있음 |
| PHIL-02 | 레벨 감지(Starter/Dynamic/Enterprise) 코드 존재 | detectLevel() 함수 존재 |
| PHIL-03 | PDCA 자동 적용 (bkit-rules 스킬 존재) | skills/bkit-rules/SKILL.md 존재 |
| PHIL-04 | 반복 개선 루프 (gap-detector → pdca-iterator) | 두 에이전트 존재 + stop hooks |

### 3.2 AI-Native Principles (ai-native-principles.md)

| TC | Verification | Expected |
|----|-------------|----------|
| PHIL-05 | 16 AI agents 존재 (팀 구조 대체) | agents/ 16개 파일 |
| PHIL-06 | Language Tier System 구현 | TIER_EXTENSIONS 또는 equivalent 존재 |
| PHIL-07 | Zero Script QA 스킬 존재 | skills/zero-script-qa/SKILL.md |
| PHIL-08 | Task Classification 구현 | classifyTask 함수 존재 |

### 3.3 Context Engineering (context-engineering.md)

| TC | Verification | Expected |
|----|-------------|----------|
| PHIL-09 | Multi-Level Context Hierarchy (FR-01) | lib/context-hierarchy.js 존재 |
| PHIL-10 | @import Directive (FR-02) | lib/import-resolver.js 존재 |
| PHIL-11 | Permission Hierarchy (FR-05) | lib/permission-manager.js 존재 |
| PHIL-12 | Context Compaction Hook (FR-07) | PreCompact in hooks.json |

### 3.4 PDCA Methodology (pdca-methodology.md)

| TC | Verification | Expected |
|----|-------------|----------|
| PHIL-13 | 9-Phase Pipeline 스킬 존재 | phase-1 ~ phase-9 스킬 9개 |
| PHIL-14 | PDCA 문서 템플릿 존재 | templates/plan,design,analysis,report |
| PHIL-15 | Archive 기능 구현 | pdca 스킬에 archive 액션 |

---

## 4. UX Scenario Test Cases

### 4.1 Enhancement UX Scenarios

| TC | Scenario | Verification |
|----|----------|-------------|
| UX-ENH-01 | /output-style-setup 커맨드 인식 | commands/output-style-setup.md에 user-invocable: true |
| UX-ENH-02 | session-start에서 4개 output style 안내 | bkit-pdca-enterprise 포함 |
| UX-ENH-03 | session-start에서 /output-style-setup 안내 | 문자열 포함 확인 |
| UX-ENH-04 | bkend-expert 에이전트가 docs URL 참조 가능 | Official Documentation 섹션 존재 |
| UX-ENH-05 | bkit.md에서 v1.5.3 Features 확인 가능 | 테이블 존재 |
| UX-ENH-06 | bkit.md에서 CLAUDE.md 전략 확인 가능 | 섹션 존재 |
| UX-ENH-07 | 모든 버전 참조가 1.5.3 | 12개 참조 모두 일치 |
| UX-ENH-08 | marketplace.json 수치 정확 | 26 skills, 16 agents, etc. |
| UX-ENH-09 | bkend-quickstart에 Step-by-Step 가이드 | 존재 확인 |
| UX-ENH-10 | bkend 에이전트 Memory 파일 존재 | .claude/agent-memory/bkit-bkend-expert/MEMORY.md |

### 4.2 User Journey Scenarios

| TC | Journey | Verification |
|----|---------|-------------|
| UX-JRN-01 | 초보자가 /bkit 입력 시 도움말 표시 | commands/bkit.md 존재, user-invocable |
| UX-JRN-02 | /pdca status로 현재 상태 확인 가능 | pdca 스킬에 status 액션 |
| UX-JRN-03 | /pdca plan으로 계획 시작 가능 | pdca 스킬에 plan 액션 |
| UX-JRN-04 | /output-style로 스타일 변경 가능 | output-styles/ 4개 파일 존재 |
| UX-JRN-05 | /code-review로 코드 리뷰 가능 | skills/code-review/SKILL.md 존재 |
| UX-JRN-06 | bkend MCP 설정 가이드 접근 가능 | bkend-quickstart 스킬에 MCP 섹션 |
| UX-JRN-07 | /claude-code-learning으로 학습 가능 | skills/claude-code-learning/SKILL.md |
| UX-JRN-08 | /development-pipeline으로 파이프라인 시작 | skills/development-pipeline/SKILL.md |
| UX-JRN-09 | Agent Memory 자동 동작 | .claude/agent-memory/ 디렉토리 존재 |
| UX-JRN-10 | CTO 팀 시작 가능 (/pdca team) | pdca 스킬에 team 액션 + cto-lead 에이전트 |

---

## 5. Execution Strategy

### 5.1 병렬 실행 계획

```
CTO Lead (Coordinator)
├── Agent 1: Library Tester (code-analyzer)
│   └── lib/ 11 modules, common.js 180 exports
│   └── ~245 TC
│
├── Agent 2: Integration Tester (gap-detector)
│   └── Skills (26) + Agents (16) + Hooks (10) + Config
│   └── ~234 TC
│
└── Agent 3: UX & Philosophy Tester
    └── Enhancement 31 TC + UX 20 TC + Philosophy 15 TC + PDCA/Team/ML/Edge/Regression
    └── ~236 TC
```

### 5.2 합격 기준

| Metric | Target |
|--------|--------|
| Overall Pass Rate (excl. SKIP) | 100% |
| P0 Pass Rate | 100% |
| Enhancement TC | 100% (31/31) |
| Philosophy TC | 100% (15/15) |
| UX TC | 100% (20/20) |
| Critical Issues | 0 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-10 | Initial plan | CTO Lead (Claude Opus 4.6) |
