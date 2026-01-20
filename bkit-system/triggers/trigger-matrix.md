# Trigger Matrix

> 이벤트별로 어떤 컴포넌트가 발동되는지 정리한 핵심 매트릭스

## Hook Event Matrix

### PreToolUse (도구 사용 전)

| Tool | Skill/Agent | Script | 동작 |
|------|-------------|--------|------|
| `Write\|Edit` | [[components/skills/bkit-rules]] | `pdca-pre-write.sh` | PDCA 문서 존재 여부 체크, 가이드 제공 |
| `Write\|Edit` | [[components/skills/task-classification]] | `task-classify.sh` | 작업 크기 분류 (Quick Fix/Minor/Feature/Major) |
| `Write\|Edit` | [[components/skills/phase-2-convention]] | `phase2-convention-pre.sh` | 코딩 컨벤션 리마인드 |
| `Write` | [[components/agents/design-validator]] | `design-validator-pre.sh` | 설계 문서 작성 시 체크리스트 |
| `Write\|Edit` | [[components/agents/code-analyzer]] | (block) | 코드 분석 에이전트는 read-only |
| `Bash` | [[components/skills/zero-script-qa]] | `qa-pre-bash.sh` | 파괴적 명령어 차단 |
| `Bash` | [[components/skills/phase-9-deployment]] | `phase9-deploy-pre.sh` | 배포 전 환경 검증 |

### PostToolUse (도구 사용 후)

| Tool | Skill/Agent | Script | 동작 |
|------|-------------|--------|------|
| `Write` | [[components/skills/bkit-rules]] | `pdca-post-write.sh` | Gap Analysis 안내 |
| `Write` | [[components/skills/phase-5-design-system]] | `phase5-design-post.sh` | 디자인 토큰 사용 검증 |
| `Write` | [[components/skills/phase-6-ui-integration]] | `phase6-ui-post.sh` | UI 레이어 분리 검증 |
| `Write` | [[components/agents/gap-detector]] | `gap-detector-post.sh` | 분석 완료 후 iterate 안내 |
| `Write` | [[components/agents/qa-monitor]] | `qa-monitor-post.sh` | Critical 이슈 발견 시 알림 |

### Stop (세션/스킬 종료 시)

| Skill | Script | 동작 |
|-------|--------|------|
| [[components/skills/phase-4-api]] | `phase4-api-stop.sh` | Zero Script QA 안내 |
| [[components/skills/phase-8-review]] | `phase8-review-stop.sh` | 리뷰 완료 요약 |
| [[components/skills/analysis-patterns]] | `analysis-stop.sh` | 갭 분석 결과 안내 |
| [[components/skills/zero-script-qa]] | `qa-stop.sh` | QA 세션 완료 안내 |
| [[components/skills/development-pipeline]] | `echo` | 파이프라인 종료 |

### SessionStart (세션 시작 시)

| Source | Script | 동작 |
|--------|--------|------|
| `settings.json` | `session-start.sh` | 초기 인사 + 레벨 감지 + 옵션 제시 |

---

## Write/Edit 시 발동 순서 (예상)

사용자가 소스 코드 파일을 Write/Edit 할 때:

```
1. PreToolUse 단계
   ├── bkit-rules (pdca-pre-write.sh)
   │   └── 해당 feature의 design doc 존재 여부 체크
   ├── task-classification (task-classify.sh)
   │   └── 변경 크기에 따른 분류 (Quick Fix ~ Major Feature)
   └── phase-2-convention (phase2-convention-pre.sh)
       └── 파일 타입별 컨벤션 리마인드

2. 실제 Write/Edit 실행

3. PostToolUse 단계
   ├── bkit-rules (pdca-post-write.sh)
   │   └── Gap Analysis 안내 (design doc 있는 경우)
   ├── phase-5-design-system (phase5-design-post.sh)
   │   └── 컴포넌트 파일인 경우 디자인 토큰 검증
   └── phase-6-ui-integration (phase6-ui-post.sh)
       └── UI 레이어 파일인 경우 레이어 분리 검증
```

---

## Skill Description Triggers (키워드 기반)

Skills와 Agents는 description의 "Triggers:" 키워드로도 활성화됩니다.

### Level Skills

| Skill | Trigger Keywords |
|-------|------------------|
| [[components/skills/starter]] | static website, portfolio, landing page, beginner, 정적 웹, 초보자, 静的サイト |
| [[components/skills/dynamic]] | fullstack, BaaS, bkend, authentication, login, 풀스택, 인증, 로그인 |
| [[components/skills/enterprise]] | microservices, kubernetes, terraform, k8s, AWS, 마이크로서비스 |

### Phase Skills

| Skill | Trigger Keywords |
|-------|------------------|
| [[components/skills/phase-1-schema]] | schema, terminology, data model, 스키마, データモデル |
| [[components/skills/phase-2-convention]] | convention, coding style, naming rules, 컨벤션, コンベンション |
| [[components/skills/phase-3-mockup]] | mockup, prototype, wireframe, 목업, モックアップ |
| [[components/skills/phase-4-api]] | API design, REST API, backend, endpoint, API 설계 |
| [[components/skills/phase-5-design-system]] | design system, component library, design tokens, shadcn |
| [[components/skills/phase-6-ui-integration]] | UI implementation, API integration, state management |
| [[components/skills/phase-7-seo-security]] | SEO, security, meta tags, XSS, CSRF, 보안 |
| [[components/skills/phase-8-review]] | code review, architecture review, quality check, 코드 리뷰 |
| [[components/skills/phase-9-deployment]] | deployment, CI/CD, production, Vercel, Kubernetes, 배포 |

### Core/Specialized Skills

| Skill | Trigger Keywords |
|-------|------------------|
| [[components/skills/bkit-rules]] | bkit, PDCA, develop, implement, feature, bug, code, 개발, 기능, 버그 |
| [[components/skills/zero-script-qa]] | zero script qa, log-based testing, docker logs, 제로 스크립트 QA |
| [[components/skills/evaluator-optimizer]] | iterate, optimize, auto-fix, 반복 개선, 자동 수정, イテレーション |
| [[components/skills/development-pipeline]] | development pipeline, phase, where to start, 뭐부터, 어디서부터 |

---

## Agent Auto-Trigger (키워드 기반)

| Agent | Trigger Keywords |
|-------|------------------|
| [[components/agents/starter-guide]] | beginner, first project, learn to code, 초보자, 입문, 처음 |
| [[components/agents/bkend-expert]] | bkend, BaaS, login, signup, database, 인증, 로그인, 데이터베이스 |
| [[components/agents/enterprise-expert]] | CTO, AI Native, microservices, architecture, 전략, 아키텍처 |
| [[components/agents/infra-architect]] | AWS, Kubernetes, Terraform, CI/CD, 인프라, 클라우드 |
| [[components/agents/pipeline-guide]] | development pipeline, phase, where to start, 개발 파이프라인 |
| [[components/agents/gap-detector]] | gap analysis, design-implementation check, 갭 분석, 설계-구현 비교 |
| [[components/agents/design-validator]] | design validation, document review, spec check, 설계 검증 |
| [[components/agents/code-analyzer]] | code analysis, quality check, security scan, 코드 분석, 품질 검사 |
| [[components/agents/qa-monitor]] | zero script qa, QA, testing, log analysis, 테스트, 로그 분석 |
| [[components/agents/pdca-iterator]] | iterate, optimize, auto-fix, 반복 개선, 고쳐줘, 개선해줘 |
| [[components/agents/report-generator]] | PDCA report, completion report, summary, PDCA 보고서, 완료 보고서 |

---

## Skill → Agent 연결

각 Skill은 특정 Agent와 연결되어 있습니다:

| Skill | Connected Agent |
|-------|-----------------|
| `starter` | [[components/agents/starter-guide]] |
| `dynamic` | [[components/agents/bkend-expert]] |
| `enterprise` | [[components/agents/enterprise-expert]] |
| `enterprise` | [[components/agents/infra-architect]] |
| `development-pipeline` | [[components/agents/pipeline-guide]] |
| `zero-script-qa` | [[components/agents/qa-monitor]] |
| `evaluator-optimizer` | [[components/agents/pdca-iterator]] |
| `analysis-patterns` | [[components/agents/code-analyzer]] |
| `pdca-methodology` | [[components/agents/design-validator]] |
| `document-standards` | [[components/agents/design-validator]] |

---

## 관련 문서

- [[triggers/priority-rules]] - 충돌 시 우선순위
- [[scenarios/scenario-write-code]] - Write/Edit 시나리오 상세
- [[_GRAPH-INDEX]] - 전체 인덱스
