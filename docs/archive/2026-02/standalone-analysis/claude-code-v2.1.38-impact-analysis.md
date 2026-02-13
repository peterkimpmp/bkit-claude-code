# Claude Code v2.1.38 Version Upgrade Impact Analysis & bkit Enhancement Report

> **Feature**: claude-code-v2.1.38-impact-analysis
> **Phase**: Check (PDCA Analysis)
> **Date**: 2026-02-10
> **Team**: CTO Lead (orchestrator), version-researcher, context-researcher, plugin-researcher, bkit-analyzer
> **Pattern**: Council (4 specialist agents + CTO)
> **bkit Version**: v1.5.3 (current) / v1.6.0 (target)

---

## 1. Executive Summary

| Metric | Value |
|--------|:-----:|
| v2.1.38 변경사항 | 7건 |
| bkit 영향 항목 | 3건 (Medium 1, Low 2) |
| 호환성 리스크 | **없음** (100% 하위 호환) |
| 고도화 기회 | **18건** |
| 우선순위 Critical | 2건 |
| 우선순위 High | 5건 |
| 우선순위 Medium | 6건 |
| 우선순위 Low | 5건 |
| 신규 활용 가능 API | 8개 |

### Verdict: COMPATIBLE (v2.1.38과 100% 호환, Breaking Change 없음)

bkit v1.5.3은 Claude Code v2.1.38과 완전히 호환됩니다. v2.1.38의 7가지 변경사항 중 bkit에 직접적 영향을 미치는 항목은 없으며, 오히려 bash permission matching 개선으로 bkit 훅 안정성이 향상될 수 있습니다. 다만, v2.1.32~v2.1.38에 걸쳐 도입된 새로운 API와 기능들을 활용하면 bkit을 대폭 고도화할 수 있는 18가지 기회가 식별되었습니다.

---

## 2. Claude Code v2.1.38 변경사항 상세

### 2.1 릴리스 정보

| 항목 | 내용 |
|------|------|
| 버전 | 2.1.38 |
| 릴리스 날짜 | 2026-02-10 |
| 릴리스 유형 | Maintenance (버그 수정 + 보안 개선) |
| Breaking Changes | 없음 |
| 보안 Advisory | 없음 (내부 개선만) |

### 2.2 변경사항 목록

| # | 변경사항 | 유형 | 카테고리 |
|---|---------|------|---------|
| C-01 | VS Code 터미널 scroll-to-top 회귀 수정 (v2.1.37 도입) | Bug Fix | VS Code |
| C-02 | Tab 키가 slash command를 큐잉하는 대신 자동완성하도록 수정 | Bug Fix | UX |
| C-03 | 환경변수 래퍼를 사용하는 명령의 bash permission matching 수정 | Bug Fix | Permission |
| C-04 | 스트리밍 미사용 시 도구 사용 사이 텍스트 사라짐 수정 | Bug Fix | Rendering |
| C-05 | VS Code 확장에서 세션 재개 시 중복 세션 생성 수정 | Bug Fix | VS Code |
| C-06 | heredoc delimiter 파싱 개선으로 command smuggling 방지 | Security | Sandbox |
| C-07 | Sandbox 모드에서 `.claude/skills` 디렉토리 쓰기 차단 | Security | Sandbox |

### 2.3 각 변경사항 상세 분석

#### C-01: VS Code 터미널 scroll-to-top 회귀 수정
- **원인**: v2.1.37에서 `/fast` 모드 관련 수정 시 VS Code 터미널 스크롤 위치 관리에 영향
- **bkit 영향**: 없음 (VS Code 전용 UI 이슈)

#### C-02: Tab 키 자동완성 수정
- **설명**: 이전에 Tab 키가 slash command를 큐잉하여 의도하지 않은 동작 발생
- **bkit 영향**: **Low Positive** - bkit 스킬 (`/bkit:pdca` 등) 입력 시 Tab 자동완성이 정상 동작

#### C-03: 환경변수 래퍼 bash permission matching 수정
- **설명**: `${VAR}` 등 환경변수 래퍼가 포함된 bash 명령의 권한 매칭이 정확하지 않았음
- **bkit 영향**: **Medium Positive** - bkit의 모든 훅 명령이 `${CLAUDE_PLUGIN_ROOT}` 패턴 사용
  ```json
  "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.js"
  ```
  이 수정으로 bkit 훅의 permission matching이 더 정확해짐

#### C-04: 도구 사이 텍스트 사라짐 수정
- **설명**: 스트리밍 비활성화 시 도구 호출 사이의 설명 텍스트가 누락됨
- **bkit 영향**: **Low Positive** - bkit output-styles 렌더링 안정성 개선

#### C-05: VS Code 중복 세션 수정
- **bkit 영향**: 없음 (VS Code 전용)

#### C-06: heredoc delimiter 파싱 보안 개선
- **설명**: heredoc 구문을 악용한 command smuggling 공격 벡터 차단
- **bkit 영향**: 없음 (bkit은 heredoc 기반 명령 생성하지 않음)

#### C-07: Sandbox에서 `.claude/skills` 쓰기 차단
- **설명**: Sandbox 모드에서 모델이 `.claude/skills/` 디렉토리에 파일을 작성하는 것을 차단
- **보안 맥락**: 악의적 프롬프트가 스킬을 동적으로 생성하여 향후 세션에 지속적 영향을 미치는 것 방지
- **bkit 영향**: 없음 - bkit 스킬은 플러그인 자체의 `skills/` 디렉토리에 있으며, `.claude/skills/`에 쓰기 작업을 수행하지 않음. bkit 스킬은 `${CLAUDE_PLUGIN_ROOT}/skills/`에서 로드됨

---

## 3. bkit 플러그인 아키텍처 현황 분석

### 3.1 아키텍처 개요

```
bkit-claude-code/                          # Plugin Root
├── .claude-plugin/                        # (미사용 - 레거시 구조)
├── bkit.config.json                       # 런타임 설정 (v1.5.2)
├── bkit.config.schema.json                # 설정 스키마
├── hooks/
│   ├── hooks.json                         # 훅 이벤트 정의 (10 events, 13 handlers)
│   └── session-start.js                   # SessionStart 핸들러
├── skills/                                # 26 스킬 (21 bkit + 5 bkend)
│   ├── pdca/SKILL.md                      # PDCA 통합 스킬
│   ├── starter/SKILL.md                   # 초보자 가이드
│   ├── dynamic/SKILL.md                   # 풀스택 개발
│   ├── enterprise/SKILL.md                # 엔터프라이즈 개발
│   ├── bkend-*/SKILL.md                   # bkend.ai BaaS (5)
│   ├── phase-*/SKILL.md                   # 9-Phase Pipeline (9)
│   ├── code-review/SKILL.md               # 코드 리뷰
│   ├── zero-script-qa/SKILL.md            # Zero Script QA
│   ├── claude-code-learning/SKILL.md      # Claude Code 학습
│   ├── bkit-templates/SKILL.md            # PDCA 템플릿
│   ├── bkit-rules/SKILL.md                # 코어 규칙
│   ├── development-pipeline/SKILL.md      # 개발 파이프라인
│   ├── mobile-app/SKILL.md                # 모바일 앱
│   └── desktop-app/SKILL.md               # 데스크톱 앱
├── agents/                                # 16 에이전트
│   ├── cto-lead.md                        # CTO 팀 리더
│   ├── enterprise-expert.md               # 엔터프라이즈 전문가
│   ├── frontend-architect.md              # 프론트엔드 아키텍트
│   ├── bkend-expert.md                    # 백엔드 전문가
│   ├── security-architect.md              # 보안 아키텍트
│   ├── infra-architect.md                 # 인프라 아키텍트
│   ├── product-manager.md                 # 프로덕트 매니저
│   ├── qa-strategist.md                   # QA 전략가
│   ├── qa-monitor.md                      # QA 모니터
│   ├── code-analyzer.md                   # 코드 분석기
│   ├── gap-detector.md                    # 갭 디텍터
│   ├── pdca-iterator.md                   # PDCA 반복기
│   ├── design-validator.md                # 설계 검증기
│   ├── report-generator.md                # 보고서 생성기
│   ├── pipeline-guide.md                  # 파이프라인 가이드
│   └── starter-guide.md                   # 초보자 가이드
├── output-styles/                         # 4 출력 스타일
│   ├── bkit-learning.md
│   ├── bkit-pdca-guide.md
│   ├── bkit-enterprise.md
│   └── bkit-pdca-enterprise.md
├── scripts/                               # 45 스크립트
│   ├── unified-*.js                       # 통합 핸들러 (4)
│   ├── phase*-*.js                        # 파이프라인 단계별 (15)
│   ├── *-pre.js / *-post.js / *-stop.js   # 이벤트별 핸들러 (26)
│   └── user-prompt-handler.js             # 사용자 프롬프트 처리
├── lib/                                   # 라이브러리 (180 exports)
│   ├── common.js                          # Migration Bridge (180 re-exports)
│   ├── core/                              # 핵심 유틸 (41 exports)
│   │   ├── cache.js                       # 캐시 (7)
│   │   ├── config.js                      # 설정 (5)
│   │   ├── debug.js                       # 디버그 (3)
│   │   ├── file.js                        # 파일 (8)
│   │   ├── io.js                          # I/O (9)
│   │   ├── platform.js                    # 플랫폼 (9)
│   │   └── index.js
│   ├── pdca/                              # PDCA 엔진 (50 exports)
│   │   ├── tier.js                        # 언어 티어 (8)
│   │   ├── level.js                       # 레벨 감지 (7)
│   │   ├── phase.js                       # 단계 관리 (9)
│   │   ├── status.js                      # 상태 관리 (19)
│   │   ├── automation.js                  # 자동화 (11)
│   │   └── index.js
│   ├── intent/                            # 의도 분석 (19 exports)
│   │   ├── language.js                    # 언어 감지 (6)
│   │   ├── trigger.js                     # 트리거 매칭 (5)
│   │   ├── ambiguity.js                   # 모호성 분석 (8)
│   │   └── index.js
│   ├── task/                              # 태스크 관리 (26 exports)
│   │   ├── classification.js              # 분류 (6)
│   │   ├── context.js                     # 컨텍스트 (7)
│   │   ├── creator.js                     # 생성 (6)
│   │   ├── tracker.js                     # 추적 (7)
│   │   └── index.js
│   └── team/                              # 팀 관리 (39 exports)
│       ├── coordinator.js                 # 조율 (5)
│       ├── strategy.js                    # 전략 (2)
│       ├── hooks.js                       # 훅 통합 (2)
│       ├── orchestrator.js                # 오케스트레이터 (6)
│       ├── communication.js               # 통신 (6)
│       ├── task-queue.js                  # 태스크 큐 (5)
│       ├── cto-logic.js                   # CTO 로직 (5)
│       ├── state-writer.js                # 상태 기록 (9)
│       └── index.js
├── templates/                             # PDCA 문서 템플릿
└── docs/                                  # PDCA 문서
    ├── 01-plan/                           # Plan 문서
    ├── 02-design/                         # Design 문서
    ├── 03-analysis/                       # Analysis 문서
    └── 04-report/                         # Report 문서
```

### 3.2 훅 시스템 현황 (10/14 이벤트 활용)

| 훅 이벤트 | 활용 여부 | bkit 핸들러 | 용도 |
|-----------|:--------:|------------|------|
| SessionStart | ✅ | session-start.js | PDCA 상태 복원, 컨텍스트 주입 |
| UserPromptSubmit | ✅ | user-prompt-handler.js | 의도 감지, 에이전트 자동 트리거 |
| PreToolUse (Write\|Edit) | ✅ | pre-write.js | 파일 쓰기 전 유효성 검사 |
| PreToolUse (Bash) | ✅ | unified-bash-pre.js | Bash 명령 실행 전 검사 |
| PostToolUse (Write) | ✅ | unified-write-post.js | 파일 쓰기 후 PDCA 추적 |
| PostToolUse (Bash) | ✅ | unified-bash-post.js | Bash 실행 후 처리 |
| PostToolUse (Skill) | ✅ | skill-post.js | 스킬 실행 후 PDCA 연동 |
| PreCompact | ✅ | context-compaction.js | 컨텍스트 압축 전 스냅샷 |
| Stop | ✅ | unified-stop.js | 세션 종료 시 상태 저장 |
| TaskCompleted | ✅ | pdca-task-completed.js | 태스크 완료 시 PDCA 진행 |
| SubagentStart | ✅ | subagent-start-handler.js | 팀원 스폰 추적 |
| SubagentStop | ✅ | subagent-stop-handler.js | 팀원 종료 추적 |
| TeammateIdle | ✅ | team-idle-handler.js | 팀원 유휴 상태 관리 |
| **PostToolUseFailure** | ❌ | - | 미활용 |
| **PermissionRequest** | ❌ | - | 미활용 |
| **Notification** | ❌ | - | 미활용 |
| **SessionEnd** | ❌ | - | 미활용 |

### 3.3 핵심 수치

| 구성 요소 | 수량 | 상세 |
|-----------|:----:|------|
| Skills | 26 | 21 bkit + 5 bkend |
| Agents | 16 | CTO team + 전문가 에이전트 |
| Hook Events | 10/14 | 4개 미활용 |
| Hook Handlers | 13 | hooks.json 등록 기준 |
| Scripts | 45 | 스킬/에이전트 전용 포함 |
| Library Exports | 180 | 5 modules (core/pdca/intent/task/team) |
| Output Styles | 4 | learning/pdca-guide/enterprise/pdca-enterprise |
| Templates | 4+ | plan/design/analysis/report + level variants |
| Supported Languages | 8 | en/ko/ja/zh/es/fr/de/it |
| Config Options | 60+ | bkit.config.json |

---

## 4. v2.1.38 영향 범위 분석

### 4.1 영향도 매트릭스

| 변경 ID | bkit 영향도 | 영향 방향 | 영향 대상 | 조치 필요 |
|---------|:----------:|:---------:|----------|:---------:|
| C-01 | None | - | - | 불필요 |
| C-02 | Low | Positive | 스킬 UX | 불필요 |
| C-03 | Medium | Positive | 훅 안정성 | 검증 권장 |
| C-04 | Low | Positive | 출력 안정성 | 불필요 |
| C-05 | None | - | - | 불필요 |
| C-06 | None | Neutral | - | 불필요 |
| C-07 | None | Neutral | - | 불필요 |

### 4.2 상세 영향 분석

#### 4.2.1 [Medium] C-03: bash permission matching 개선

**현상**: `${CLAUDE_PLUGIN_ROOT}` 등 환경변수 래퍼가 포함된 명령의 permission matching이 부정확했음

**bkit 관련 코드 (hooks.json)**:
```json
{
  "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.js",
  "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/pre-write.js",
  "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/unified-bash-pre.js",
  "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/unified-write-post.js",
  // ... 13 handlers 모두 동일 패턴
}
```

**분석**: bkit의 모든 13개 훅 핸들러가 `${CLAUDE_PLUGIN_ROOT}` 환경변수를 사용합니다. v2.1.38 이전에는 이러한 명령들의 permission matching이 부정확하여, 일부 환경에서 불필요한 권한 프롬프트가 표시되거나 자동 승인이 실패했을 수 있습니다.

**영향**: Positive - 수정 후 bkit 훅이 더 안정적으로 실행됩니다.

**필요 조치**: v2.1.38에서 기존 bkit 훅이 정상 동작하는지 10개 TC 기본 검증 권장

#### 4.2.2 [None] C-07: `.claude/skills` 쓰기 차단

**분석**: bkit 스킬은 플러그인 디렉토리 내부(`${CLAUDE_PLUGIN_ROOT}/skills/`)에 위치합니다. `.claude/skills/`는 프로젝트 로컬 스킬 디렉토리이며, bkit은 이 경로에 파일을 쓰지 않습니다.

**검증 결과**:
- bkit의 모든 쓰기 대상 경로:
  - `docs/.pdca-status.json` (PDCA 상태)
  - `docs/.bkit-memory.json` (메모리)
  - `.bkit/agent-state.json` (팀 상태)
  - `docs/0*-*/` (PDCA 문서)
- `.claude/skills/` 쓰기: **없음**

**결론**: 영향 없음

### 4.3 호환성 종합 평가

| 평가 항목 | 결과 | 비고 |
|-----------|:----:|------|
| 기존 기능 호환성 | ✅ 100% | Breaking change 없음 |
| 훅 시스템 호환성 | ✅ 100% | permission matching 개선으로 안정성 향상 |
| 스킬 시스템 호환성 | ✅ 100% | sandbox 변경은 `.claude/skills`만 해당 |
| 에이전트 시스템 호환성 | ✅ 100% | 변경 없음 |
| Output Styles 호환성 | ✅ 100% | 텍스트 렌더링 개선 |
| 상태 관리 호환성 | ✅ 100% | 변경 없음 |
| 라이브러리 호환성 | ✅ 100% | 변경 없음 |

**최종 호환성 판정**: ✅ **완전 호환** (v2.1.38 즉시 적용 가능)

---

## 5. Claude Code 플러그인 생태계 최신 동향

### 5.1 플러그인 시스템 주요 변화 (v2.1.32 ~ v2.1.38)

| 버전 | 플러그인 관련 변경사항 |
|------|---------------------|
| v2.1.32 | Agent Teams 리서치 프리뷰, 자동 메모리, `.claude/skills/` 자동 로드 |
| v2.1.33 | TeammateIdle/TaskCompleted 훅 이벤트, agent memory frontmatter, 플러그인 이름 표시 |
| v2.1.34 | Agent Teams 크래시 수정, sandbox 보안 수정 |
| v2.1.36 | Fast Mode (/fast) 추가 |
| v2.1.38 | bash permission matching 수정, `.claude/skills` 쓰기 차단 |

### 5.2 공식 플러그인 생태계

#### 공식 마켓플레이스
- **위치**: [github.com/anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- **구조**: `/plugins` (Anthropic 관리) + `/external_plugins` (서드파티)
- **설치**: `/plugin install {plugin-name}@claude-plugin-directory`

#### Plugin-Dev 개발 도구
- **기능**: 8단계 가이드 플러그인 생성 워크플로우
- **명령**: `/plugin-dev:create-plugin`
- **에이전트**: agent-creator, plugin-validator, skill-reviewer

#### 커뮤니티 레지스트리
- [claude-plugins.dev](https://claude-plugins.dev/) - 커뮤니티 플러그인 디스커버리

### 5.3 플러그인 시스템 신규 기능 (bkit 미활용)

| 기능 | 도입 시점 | bkit 활용 여부 | 고도화 가능성 |
|------|----------|:------------:|:----------:|
| LSP 서버 지원 | v2.1.32+ | ❌ | High |
| `type: "prompt"` 훅 | v2.1.32+ | ❌ | High |
| `type: "agent"` 훅 | v2.1.32+ | ❌ | Medium |
| Async 훅 | v2.1.32+ | ❌ | High |
| PostToolUseFailure 이벤트 | v2.1.32+ | ❌ | Medium |
| PermissionRequest 이벤트 | v2.1.32+ | ❌ | Low |
| Notification 이벤트 | v2.1.32+ | ❌ | Medium |
| SessionEnd 이벤트 | v2.1.33+ | ❌ | High |
| `CLAUDE_ENV_FILE` (SessionStart) | v2.1.33+ | ❌ | Medium |
| Plugin Marketplace 배포 | v2.1.32+ | ❌ | Critical |
| `.claude-plugin/plugin.json` | v2.1.32+ | ❌ | Critical |

---

## 6. Context Engineering 최신 동향 분석

### 6.1 Context Engineering 정의

> "Context Engineering은 LLM의 고유한 제약 조건(컨텍스트 윈도우, 어텐션 분산, 컨텍스트 로트)에 대응하여 토큰 유용성을 최적화하는 학문이다." - Anthropic Engineering Blog

### 6.2 Anthropic의 공식 컨텍스트 관리 아키텍처

```
┌─────────────────────────────────────────────────────┐
│                  Context Window                      │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  CLAUDE.md   │  │   Hooks      │  │    MCP     │ │
│  │  (Static)    │  │  (Dynamic)   │  │ (External) │ │
│  │              │  │              │  │            │ │
│  │ - 코딩 표준  │  │ - Session    │  │ - DB       │ │
│  │ - 아키텍처   │  │ - PreTool    │  │ - API      │ │
│  │ - 라이브러리 │  │ - PostTool   │  │ - Files    │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │   Skills     │  │   Memory     │  │ Compaction │ │
│  │  (On-demand) │  │ (Persistent) │  │ (Adaptive) │ │
│  │              │  │              │  │            │ │
│  │ - /command   │  │ - agent-mem  │  │ - Auto     │ │
│  │ - Auto-load  │  │ - frontmatter│  │ - Manual   │ │
│  │ - Trigger    │  │ - user/proj  │  │ - Snapshot │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────┘
```

### 6.3 bkit의 Context Engineering 현황

| 컨텍스트 소스 | bkit 활용도 | 구현 수준 |
|-------------|:----------:|:---------:|
| CLAUDE.md | ❌ 미활용 | 없음 |
| SessionStart Hook | ✅ 활용 | 높음 - PDCA 상태 주입 |
| UserPromptSubmit Hook | ✅ 활용 | 높음 - 의도 감지 + 컨텍스트 주입 |
| PreCompact Hook | ✅ 활용 | 중간 - 스냅샷 보존 |
| Skills (자동 로드) | ✅ 활용 | 높음 - 26개 스킬 |
| Agent Memory | ✅ 활용 | 높음 - 프론트매터 스코프 |
| MCP Server | ❌ 미활용 | 없음 |
| LSP Server | ❌ 미활용 | 없음 |
| Output Styles | ✅ 활용 | 높음 - 4개 스타일 |
| `CLAUDE_ENV_FILE` | ❌ 미활용 | 없음 |

### 6.4 Context Engineering 성숙도 평가

| 차원 | 현재 수준 | 목표 수준 | 갭 |
|------|:--------:|:--------:|:--:|
| 정적 컨텍스트 관리 | B | A | 1 |
| 동적 컨텍스트 주입 | A | A+ | 0.5 |
| 컨텍스트 압축 | B+ | A | 0.5 |
| 지속적 메모리 | A | A | 0 |
| 외부 도구 통합 | C | B+ | 2 |
| 에러 복구 컨텍스트 | D | B | 3 |

---

## 7. bkit 고도화 기회 분석

### 7.1 Critical Priority (즉시 실행)

#### ENH-01: `.claude-plugin/plugin.json` 컴포넌트 경로 보완 및 버전 동기화
| 항목 | 내용 |
|------|------|
| 현황 | `.claude-plugin/plugin.json` 존재하나 **메타데이터만** 포함. 컴포넌트 경로(outputStyles, hooks, skills, agents) 미선언. `marketplace.json`도 존재하나 v1.5.2 기준으로 수치 불일치 (21 skills→26, 11 agents→16, 39 scripts→45) |
| 개선 | plugin.json에 컴포넌트 경로 필드 추가, 특히 `"outputStyles": "./output-styles/"` (Known BUG 해결) |
| 구현 난이도 | Low |
| 임팩트 | Critical - output-styles 자동 발견 BUG 해결 + 플러그인 완전성 확보 |
| 필요 추가 필드 | `outputStyles`, `hooks`, `skills`, `agents` (기본 위치지만 명시적 선언 권장) |
| 비고 | marketplace.json의 description도 최신 수치(26 skills, 16 agents, 45 scripts, 13 hook handlers)로 업데이트 필요 |

#### ENH-02: 공식 마켓플레이스 등록 준비
| 항목 | 내용 |
|------|------|
| 현황 | bkit은 GitHub 저장소에서만 배포 |
| 개선 | `claude-plugins-official` 외부 플러그인으로 등록 또는 자체 마켓플레이스 생성 |
| 구현 난이도 | Medium |
| 임팩트 | Critical - `/plugin install bkit` 한 줄로 설치 가능 |
| 전제 조건 | ENH-01 완료 |

### 7.2 High Priority (다음 마이너 버전)

#### ENH-03: SessionEnd 훅 추가
| 항목 | 내용 |
|------|------|
| 현황 | bkit은 Stop 훅만 사용하며, 세션 명시적 종료 시 정리가 불완전할 수 있음 |
| 개선 | SessionEnd 훅으로 agent-state.json 정리, PDCA 상태 저장, 메모리 플러시 |
| 구현 난이도 | Low |
| 임팩트 | High - 세션 간 데이터 일관성 보장 |
| 참고 | Stop 훅은 모델 응답 완료 시, SessionEnd는 세션 자체 종료 시 발생. 모두 필요 |

#### ENH-04: Prompt-based Hook 활용 (type: "prompt")
| 항목 | 내용 |
|------|------|
| 현황 | bkit은 모든 훅에서 `type: "command"`만 사용 |
| 개선 | PDCA 단계 전환 검증, 코드 품질 게이트에 prompt-based hook 적용 |
| 적용 대상 | Stop 훅 → 모든 태스크 완료 여부 LLM 검증 |
| 구현 난이도 | Medium |
| 임팩트 | High - 더 지능적인 워크플로우 제어 |
| 예시 | `{ "type": "prompt", "prompt": "PDCA 단계에서 모든 deliverables가 완료되었는지 검증: $ARGUMENTS" }` |

#### ENH-05: Async Hook 활용
| 항목 | 내용 |
|------|------|
| 현황 | 모든 bkit 훅이 동기(blocking)로 실행 |
| 개선 | 비차단 작업(로깅, 분석, 외부 알림)에 async hook 적용 |
| 적용 대상 | PostToolUse (Write/Bash) 훅의 로깅 부분 |
| 구현 난이도 | Low |
| 임팩트 | High - 훅 실행 시간으로 인한 지연 제거 |

#### ENH-06: PostToolUseFailure 훅 추가
| 항목 | 내용 |
|------|------|
| 현황 | 도구 실행 실패 시 bkit의 추적/복구 기능 없음 |
| 개선 | 실패 시 에러 컨텍스트 주입, PDCA 상태 업데이트, 자동 복구 안내 |
| 구현 난이도 | Medium |
| 임팩트 | High - 에러 복구 경험 대폭 개선 |

#### ENH-07: CLAUDE_ENV_FILE 활용
| 항목 | 내용 |
|------|------|
| 현황 | SessionStart에서 환경변수를 설정하지 않음 |
| 개선 | bkit 환경변수 (BKIT_LEVEL, BKIT_PDCA_PHASE, BKIT_FEATURE 등) 설정 |
| 구현 난이도 | Low |
| 임팩트 | High - 모든 Bash 명령에서 bkit 컨텍스트 사용 가능 |
| 구현 | session-start.js에서 `CLAUDE_ENV_FILE`에 환경변수 출력 |

### 7.3 Medium Priority (계획적 개선)

#### ENH-08: LSP 서버 통합
| 항목 | 내용 |
|------|------|
| 현황 | bkit은 LSP 서버를 제공하지 않음 |
| 개선 | Dynamic/Enterprise 프로젝트에서 TypeScript/Python LSP 설정 자동 구성 |
| 구현 난이도 | Medium |
| 임팩트 | Medium - 코드 인텔리전스 향상 |

#### ENH-09: Notification 훅 활용
| 항목 | 내용 |
|------|------|
| 현황 | 권한 프롬프트, 유휴 알림 등을 감지하지 않음 |
| 개선 | 권한 요청 자동 추적, 유휴 시 PDCA 안내 |
| 구현 난이도 | Low |
| 임팩트 | Medium - UX 개선 |

#### ENH-10: Agent-based Hook 활용 (type: "agent")
| 항목 | 내용 |
|------|------|
| 현황 | 모든 훅이 shell command 기반 |
| 개선 | 복잡한 검증 (gap analysis, 코드 리뷰)에 에이전트 훅 적용 |
| 적용 대상 | TaskCompleted → 에이전트가 코드 품질 검증 후 완료 허용 |
| 구현 난이도 | High |
| 임팩트 | Medium - 더 깊은 자동화된 품질 검증 |

#### ENH-11: PermissionRequest 훅으로 스마트 권한 관리
| 항목 | 내용 |
|------|------|
| 현황 | bkit.config.json의 정적 permissions만 사용 |
| 개선 | PDCA 단계/레벨에 따른 동적 권한 정책 |
| 구현 난이도 | Medium |
| 임팩트 | Medium - 보안 + 편의성 향상 |

#### ENH-12: MCP 서버 번들링
| 항목 | 내용 |
|------|------|
| 현황 | bkit은 MCP 서버를 번들하지 않음 |
| 개선 | PDCA 상태 조회/관리를 위한 경량 MCP 서버 제공 |
| 구현 난이도 | High |
| 임팩트 | Medium - PDCA 데이터를 MCP 리소스로 노출 |

#### ENH-13: bkit.config.json 버전 동기화
| 항목 | 내용 |
|------|------|
| 현황 | bkit.config.json은 "version": "1.5.2"로 hooks.json과 불일치 |
| 개선 | plugin.json 도입 시 단일 버전 소스로 통합 |
| 구현 난이도 | Low |
| 임팩트 | Medium - 버전 관리 일관성 |

### 7.4 Low Priority (향후 고려)

#### ENH-14: 스킬 프론트매터 훅 활용
| 항목 | 내용 |
|------|------|
| 현황 | 스킬별 훅이 hooks.json에 중앙 집중화 |
| 개선 | 각 스킬 SKILL.md 프론트매터에 전용 훅 정의 |
| 구현 난이도 | Medium |
| 임팩트 | Low - 코드 조직성 개선 |

#### ENH-15: Context Compaction 고도화
| 항목 | 내용 |
|------|------|
| 현황 | PreCompact에서 기본적인 스냅샷만 수행 |
| 개선 | PDCA 컨텍스트 우선순위 기반 선택적 보존 |
| 구현 난이도 | Medium |
| 임팩트 | Low - 장기 세션 안정성 개선 |

#### ENH-16: 플러그인 캐싱 호환성 검증
| 항목 | 내용 |
|------|------|
| 현황 | bkit의 심볼릭 링크/외부 참조 동작이 플러그인 캐시 시스템과 호환되는지 미검증 |
| 개선 | 마켓플레이스 배포 시 캐시 복사 후에도 모든 경로가 정상 작동하는지 TC 추가 |
| 구현 난이도 | Low |
| 임팩트 | Low - 마켓플레이스 배포 전제 조건 |

#### ENH-17: additionalContext 반환 표준화
| 항목 | 내용 |
|------|------|
| 현황 | 일부 훅에서 일반 stdout 출력만 사용 |
| 개선 | 모든 훅에서 `hookSpecificOutput.additionalContext` JSON 반환으로 표준화 |
| 구현 난이도 | Medium |
| 임팩트 | Low - 컨텍스트 주입 신뢰성 향상 |

#### ENH-18: 다국어 에러 메시지 훅 통합
| 항목 | 내용 |
|------|------|
| 현황 | 훅 에러 메시지가 영어 고정 |
| 개선 | 8개 언어 지원 에러 메시지 (intent/language.js 활용) |
| 구현 난이도 | Medium |
| 임팩트 | Low - 국제화 UX 개선 |

---

## 8. 고도화 로드맵

### 8.1 우선순위 매트릭스

```
            High Impact
                 │
      ENH-07    ENH-03    ENH-06
      ENH-05    ENH-04
                 │
  ───────────────┼────────────────
     Low Effort  │  High Effort
                 │
      ENH-09    ENH-01    ENH-08
      ENH-13    ENH-02    ENH-10
                 │         ENH-12
                 │
            Low Impact
```

### 8.2 릴리스 로드맵

#### v1.6.0 (Next Minor - 즉시)
| 항목 | ENH | 예상 작업량 |
|------|-----|:--------:|
| `.claude-plugin/plugin.json` 생성 | ENH-01 | 2h |
| SessionEnd 훅 추가 | ENH-03 | 3h |
| CLAUDE_ENV_FILE 활용 | ENH-07 | 2h |
| bkit.config.json 버전 동기화 | ENH-13 | 1h |

#### v1.6.1 (패치)
| 항목 | ENH | 예상 작업량 |
|------|-----|:--------:|
| PostToolUseFailure 훅 추가 | ENH-06 | 4h |
| Async 훅 적용 (로깅) | ENH-05 | 3h |
| Notification 훅 활용 | ENH-09 | 2h |

#### v1.7.0 (Feature)
| 항목 | ENH | 예상 작업량 |
|------|-----|:--------:|
| Prompt-based Hook 적용 | ENH-04 | 6h |
| 마켓플레이스 등록 | ENH-02 | 4h |
| LSP 서버 통합 | ENH-08 | 8h |

#### v2.0.0 (Major - 향후)
| 항목 | ENH | 예상 작업량 |
|------|-----|:--------:|
| Agent-based Hook | ENH-10 | 10h |
| MCP 서버 번들링 | ENH-12 | 12h |
| PermissionRequest 훅 | ENH-11 | 6h |
| 스킬 프론트매터 훅 | ENH-14 | 8h |

---

## 9. 리스크 평가

### 9.1 기술적 리스크

| 리스크 | 확률 | 영향 | 대응 |
|--------|:----:|:----:|------|
| v2.1.38 호환성 문제 | Very Low | Medium | 10 TC 기본 검증으로 확인 |
| 플러그인 캐시 경로 문제 | Low | High | ENH-16으로 사전 검증 |
| Prompt-based hook 비용 증가 | Medium | Low | 빠른 모델(Haiku) 기본 사용 |
| Async hook 출력 누락 | Low | Medium | 중요 로직은 동기 유지 |
| LSP 서버 바이너리 의존성 | Medium | Medium | 선택적 설치로 제공 |

### 9.2 호환성 리스크

| 항목 | 리스크 수준 | 세부 |
|------|:----------:|------|
| v2.1.38 즉시 적용 | ✅ 안전 | Breaking change 없음 |
| v2.1.37 하위 호환 | ✅ 유지 | 기존 코드 변경 없음 |
| v2.1.36 하위 호환 | ✅ 유지 | Fast Mode는 사용자 기능 |
| v2.1.34 하위 호환 | ✅ 유지 | sandbox 수정은 bkit 무관 |
| v2.1.33 하위 호환 | ✅ 유지 | hook events 추가만 |

---

## 10. 참고 자료

### 10.1 공식 문서
- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [Claude Code GitHub Releases](https://github.com/anthropics/claude-code/releases)

### 10.2 Context Engineering
- [Effective Context Engineering for AI Agents - Anthropic Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude's Context Engineering Secrets](https://01.me/en/2025/12/context-engineering-from-claude/)
- [Context Engineering with Claude Code](https://tbtki.com/2025/12/21/context-engineering-with-claude-code/)

### 10.3 플러그인 생태계
- [Official Claude Code Plugins Directory](https://github.com/anthropics/claude-plugins-official)
- [Anthropic Plugin Announcement](https://www.anthropic.com/news/claude-code-plugins)
- [Community Plugin Registry](https://claude-plugins.dev/)
- [Plugin-Dev Toolkit](https://deepwiki.com/anthropics/claude-plugins-official/6.1.3-context7)

### 10.4 Claude Code 최신 동향
- [Claude Opus 4.6 Release](https://www.marktechpost.com/2026/02/05/anthropic-releases-claude-opus-4-6-with-1m-context-agentic-coding-adaptive-reasoning-controls-and-expanded-safety-tooling-capabilities/)
- [Building Agents with Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Claude Code Sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing)

---

## 11. 결론

### 11.1 핵심 발견

1. **호환성**: Claude Code v2.1.38은 bkit v1.5.3과 100% 호환됩니다. Breaking change가 없으며, bash permission matching 개선으로 bkit 훅의 안정성이 오히려 향상됩니다.

2. **고도화 기회**: v2.1.32~v2.1.38에 걸쳐 도입된 새로운 API들을 활용하면 bkit을 대폭 개선할 수 있는 18가지 기회가 있으며, 특히 `.claude-plugin/plugin.json` 매니페스트 추가(ENH-01)와 마켓플레이스 등록(ENH-02)이 가장 시급합니다.

3. **Context Engineering**: bkit은 이미 높은 수준의 Context Engineering을 구현하고 있으나, SessionEnd 훅, CLAUDE_ENV_FILE, PostToolUseFailure, Async 훅 등 4개 미활용 채널을 추가하면 성숙도를 A+ 수준으로 끌어올릴 수 있습니다.

4. **플러그인 생태계**: Claude Code의 플러그인 생태계가 공식 마켓플레이스, Plugin-Dev 도구, LSP 지원 등으로 빠르게 성장 중이며, bkit이 이 생태계에 공식 참여하면 사용자 확보와 커뮤니티 기여 효과를 극대화할 수 있습니다.

### 11.2 권장 즉시 조치

| 우선순위 | 조치 | 근거 |
|:--------:|------|------|
| 1 | v2.1.38 호환성 10 TC 검증 | C-03 (bash permission matching) 영향 확인 |
| 2 | `.claude-plugin/plugin.json` 생성 | 마켓플레이스 등록의 필수 전제 |
| 3 | SessionEnd 훅 추가 | 데이터 일관성 보장 |
| 4 | bkit.config.json 버전을 1.5.3으로 동기화 | 내부 일관성 |

---

---

## 12. 팀 조사 보충 사항 (Agent Reports)

### 12.1 bkit-analyzer 추가 발견

| 발견 | 심각도 | 조치 |
|------|:------:|------|
| `.claude-plugin/plugin.json` 이미 존재 (v1.5.2) - 메타데이터만 포함, 컴포넌트 경로 미선언 | High | ENH-01로 반영 완료 |
| `.claude-plugin/marketplace.json` 존재 - bkit-starter + bkit 2개 플러그인 등록 | Info | 마켓플레이스 배포 인프라 준비 완료 |
| `outputStyles` 필드 미선언 → output-styles 자동 발견 불가 (Known BUG) | High | ENH-01에서 해결 |
| `pdca-status.json` history 배열 무한 증가 (80+ entries) | Medium | 아카이브/정리 메커니즘 추가 필요 |
| activeFeatures에 의미 없는 feature명 잔존 (오염) | Low | 정리 유틸리티 추가 |
| marketplace.json 수치 불일치 (21 skills → 26, 11 agents → 16) | Medium | v1.6.0에서 동기화 |

### 12.2 plugin-researcher 추가 발견

| 발견 | 고도화 가치 | 비고 |
|------|:--------:|------|
| 생태계 규모: 9,000+ 플러그인 존재 | High | bkit 마켓플레이스 등록 시 높은 가시성 |
| `FORCE_AUTOUPDATE_PLUGINS` 환경 변수 추가됨 | Medium | bkit 자동 업데이트 제어 가능 |
| Git commit SHA 기반 버전 핀닝 지원 | Medium | 안정적 배포 버전 관리 |
| Prompt/Agent hook 타입이 플러그인에서도 지원 확인 | High | ENH-04, ENH-10 구현 가능 확인 |
| Skill Hot-Reload 지원 (재시작 없이 반영) | High | 개발/테스트 편의성 향상 |
| 플러그인 제출 폼 존재 (clau.de/plugin-directory-submission) | Critical | 공식 마켓플레이스 등록 경로 확보 |
| Auto Memory와 bkit memory 공존 방안 검토 필요 | Medium | CLAUDE_CODE_DISABLE_AUTO_MEMORY와의 관계 |

### 12.3 version-researcher 추가 발견

| 발견 | 관련성 | 비고 |
|------|:-----:|------|
| v2.1.38 릴리스: 2026-02-10 00:53 UTC (오늘!) | High | 최신 릴리스 직후 분석 |
| 릴리스 담당: ashwin-ant (Anthropic) | Info | |
| 관련 이슈 #15292: 환경변수 Bash 권한 (여전히 open) | Medium | 완전 해결 여부 모니터링 |
| Flatt Security: Claude Code 8가지 공격 벡터 발표 | Info | heredoc 수정의 배경 |
| Agent Teams 이슈 #24253(hang), #24309(MCP tools) 여전히 open | Medium | bkit Agent Teams 사용 시 주의 |

---

*Generated by bkit CTO Team - PDCA Analysis Phase*
*Report Date: 2026-02-10*
*Analysis Duration: ~20 minutes (4 parallel research agents + CTO synthesis)*
*Team Composition: CTO Lead (Opus), version-researcher, context-researcher, plugin-researcher, bkit-analyzer*
