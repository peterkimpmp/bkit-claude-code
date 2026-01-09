# bkit 바이브코딩 Kit - 플러그인화 설계서

> **목표**: `.claude/` 폴더 전체를 Claude Code 플러그인으로 패키징하여
> 단일 명령어로 설치 가능하게 만들기

---

## 1. 플러그인화 가능성 분석

### 1.1 결론: **플러그인화 가능** (일부 구조 재설계 필요)

| 현재 컴포넌트 | 개수 | 플러그인 지원 | 마이그레이션 방안 |
|---------------|------|:------------:|------------------|
| **commands/** | 17개 | ✅ 완전 지원 | 그대로 이전 |
| **agents/** | 9개 | ✅ 완전 지원 | 그대로 이전 |
| **skills/** | 19개 | ✅ 완전 지원 | 그대로 이전 |
| **hooks** | 6종 | ✅ 지원 | hooks/hooks.json으로 변환 |
| **instructions/** | 5개 | ⚠️ 미지원 | skills에 통합 |
| **templates/** | 7개 | ⚠️ 미지원 | skills에 임베드 |
| **docs/** | 26개 | ⚠️ 미지원 | skills 참조 또는 별도 배포 |
| **settings.json** | 1개 | ⚠️ 부분 지원 | hooks/permissions만 이전 |

### 1.2 공식 플러그인 구조 vs 현재 .claude/ 구조

```
공식 플러그인 구조                 현재 .claude/ 구조
==================                ===================
.claude-plugin/                   (신규 생성 필요)
├── plugin.json    ←────────────  settings.json (변환)
commands/          ←────────────  commands/ ✅
agents/            ←────────────  agents/ ✅
skills/            ←────────────  skills/ ✅
hooks/                            hooks/
└── hooks.json     ←────────────  settings.json의 hooks 섹션
.mcp.json          ←────────────  .mcp.json (프로젝트 루트)
README.md          ←────────────  docs/CLAUDE-CODE-MASTERY.md

(지원 안 됨)       ←────────────  instructions/ (skills에 통합)
(지원 안 됨)       ←────────────  templates/ (skills에 임베드)
(지원 안 됨)       ←────────────  docs/ (별도 처리)
```

### 1.3 주요 변경점

#### 1.3.1 명령어 네임스페이싱

```
현재: /learn-claude-code
플러그인 후: /bkit:learn-claude-code

현재: /pdca-plan
플러그인 후: /bkit:pdca-plan
```

#### 1.3.2 Hooks 포맷 변환

**현재 (settings.json)**:
```json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "Write", "hooks": [...] }]
  }
}
```

**플러그인 (hooks/hooks.json)**:
```json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "Write", "hooks": [...] }]
  }
}
```

(포맷은 동일, 파일 위치만 변경)

---

## 2. 플러그인 아키텍처 설계

### 2.1 플러그인 디렉토리 구조

```
bkit/
├── .claude-plugin/
│   └── plugin.json              # 플러그인 매니페스트
│
├── commands/                     # 17개 커맨드
│   ├── learn-claude-code.md
│   ├── setup-claude-code.md
│   ├── upgrade-claude-code.md
│   ├── pdca-plan.md
│   ├── pdca-design.md
│   ├── pdca-analyze.md
│   ├── pdca-report.md
│   ├── pdca-status.md
│   ├── pdca-next.md
│   ├── pipeline-start.md
│   ├── pipeline-status.md
│   ├── pipeline-next.md
│   ├── init-starter.md
│   ├── init-dynamic.md
│   ├── init-enterprise.md
│   ├── upgrade-level.md
│   └── zero-script-qa.md
│
├── agents/                       # 9개 에이전트
│   ├── starter-guide.md
│   ├── pipeline-guide.md
│   ├── bkend-expert.md
│   ├── infra-architect.md
│   ├── code-analyzer.md
│   ├── design-validator.md
│   ├── gap-detector.md
│   ├── report-generator.md
│   └── qa-monitor.md
│
├── skills/                       # 19개 + 통합 스킬
│   ├── starter/SKILL.md
│   ├── dynamic/SKILL.md
│   ├── enterprise/SKILL.md
│   ├── pdca-methodology/SKILL.md
│   ├── document-standards/SKILL.md
│   ├── analysis-patterns/SKILL.md
│   ├── development-pipeline/SKILL.md
│   ├── phase-1-schema/SKILL.md
│   ├── phase-2-convention/SKILL.md
│   ├── phase-3-mockup/SKILL.md
│   ├── phase-4-api/SKILL.md
│   ├── phase-5-design-system/SKILL.md
│   ├── phase-6-ui-integration/SKILL.md
│   ├── phase-7-seo-security/SKILL.md
│   ├── phase-8-review/SKILL.md
│   ├── phase-9-deployment/SKILL.md
│   ├── mobile-app/SKILL.md
│   ├── desktop-app/SKILL.md
│   ├── zero-script-qa/SKILL.md
│   │
│   ├── bkit-rules/SKILL.md       # [신규] instructions/ 통합
│   └── bkit-templates/SKILL.md   # [신규] templates/ 통합
│
├── hooks/
│   └── hooks.json                # settings.json 훅 이전
│
├── docs/                         # [선택] 문서 포함 시
│   └── (mastery, pdca, levels...)
│
└── README.md                     # 설치/사용 가이드
```

### 2.2 plugin.json 설계

```json
{
  "name": "bkit",
  "version": "1.4.0",
  "description": "바이브코딩 Kit - PDCA 방법론 + Claude Code 마스터리",
  "author": {
    "name": "Popup Studio",
    "url": "https://bkamp.ai"
  },
  "homepage": "https://github.com/bkit/vibecoding-kit",
  "repository": {
    "type": "git",
    "url": "https://github.com/bkit/vibecoding-kit.git"
  },
  "license": "MIT",
  "claude": {
    "minVersion": "2.1.1"
  },
  "keywords": [
    "vibecoding",
    "pdca",
    "development-pipeline",
    "baas",
    "fullstack"
  ],
  "permissions": {
    "allow": [
      "Read(**)",
      "Glob(**)",
      "Grep(**)",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(pnpm *)",
      "WebSearch",
      "WebFetch(domain:docs.anthropic.com)",
      "WebFetch(domain:code.claude.com)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(sudo *)"
    ]
  }
}
```

### 2.3 hooks/hooks.json 설계

```json
{
  "hooks": {
    "SessionStart": [
      {
        "once": true,
        "hooks": [
          {
            "type": "prompt",
            "prompt": "bkit 바이브코딩 Kit이 활성화되었습니다. /bkit:learn-claude-code로 학습을 시작하거나, 바로 개발을 시작하세요. PDCA가 자동 적용됩니다.",
            "timeout": 5000
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "PDCA 규칙 검증: docs/02-design/ 관련 설계가 있는지 확인하세요. {\"decision\": \"approve\", \"reason\": \"...\"}",
            "timeout": 10000
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "완료 전 확인: 1) 태스크 완료 2) 설계-구현 일치 3) 문서 업데이트. {\"decision\": \"approve\", \"reason\": \"...\"}",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```

---

## 3. instructions/ 통합 전략

### 3.1 문제점

플러그인 공식 구조에 `instructions/` 폴더가 없음.

### 3.2 해결책: bkit-rules 스킬로 통합

**skills/bkit-rules/SKILL.md**:

```markdown
---
name: bkit-rules
description: |
  bkit 바이브코딩 Kit 핵심 규칙.
  모든 작업에 자동 적용되는 PDCA 방법론 및 코드 품질 규칙.

  Trigger keywords:
  - EN: pdca, vibecoding, development rules, code quality
  - KO: PDCA, 바이브코딩, 개발 규칙, 코드 품질
---

# bkit 핵심 규칙

## 자동 적용 규칙 (기존 instructions/ 통합)

### 1. PDCA 규칙 (pdca-rules.md)

기능 요청 시:
1. docs/02-design/ 확인 → 설계 먼저
2. 설계 기반 구현
3. 완료 후 Gap 분석 제안

### 2. 코드 품질 규칙 (code-quality-rules.md)

- 보안 취약점 금지 (OWASP Top 10)
- 테스트 없이 배포 금지
- 타입 안전성 유지

### 3. 레벨 감지 규칙 (level-detection.md)

| 감지 조건 | 레벨 |
|-----------|------|
| index.html만 | Starter |
| Next.js + .mcp.json | Dynamic |
| services/ + infra/ | Enterprise |

### 4. Zero Script QA 규칙 (zero-script-qa-rules.md)

테스트 스크립트 대신 구조화된 로그로 검증.

### 5. 타임라인 인식 (timeline-awareness.md)

시간 예측 금지. 구체적 단계만 제시.
```

---

## 4. templates/ 통합 전략

### 4.1 문제점

플러그인 공식 구조에 `templates/` 폴더가 없음.

### 4.2 해결책: bkit-templates 스킬로 통합

**skills/bkit-templates/SKILL.md**:

```markdown
---
name: bkit-templates
description: |
  PDCA 문서 템플릿 모음.
  계획/설계/분석/보고 문서 작성 시 자동 참조.

  Trigger keywords:
  - EN: template, plan document, design document, report
  - KO: 템플릿, 계획서, 설계서, 보고서
---

# bkit 문서 템플릿

## Plan 템플릿

사용 시점: `/bkit:pdca-plan` 실행 시

```markdown
# {기능명} 계획서

## 목표
-

## 범위
- 포함:
- 제외:

## 성공 기준
1.
```

## Design 템플릿

사용 시점: `/bkit:pdca-design` 실행 시

```markdown
# {기능명} 설계서

## 데이터 모델

## API 설계

## UI 설계

## 구현 순서
```

(... 이하 생략)
```

---

## 5. docs/ 처리 전략

### 5.1 옵션 비교

| 옵션 | 장점 | 단점 |
|------|------|------|
| **A. 플러그인에 포함** | 올인원 설치 | 플러그인 크기 증가 |
| **B. 별도 웹 호스팅** | 가벼운 플러그인 | 두 번 접근 필요 |
| **C. README.md에 요약** | 간단 | 상세 내용 누락 |
| **D. skills에 분산** | 컨텍스트 자동 로딩 | 문서 구조 파편화 |

### 5.2 권장: 하이브리드 (A + B)

```
플러그인 내 포함:
- README.md (빠른 시작 가이드)
- skills/에 핵심 내용 임베드

별도 웹 호스팅:
- 상세 마스터리 가이드
- PDCA 상세 문서
- 레벨별 심화 가이드

연결 방식:
- skills에서 웹 URL 참조
- /bkit:learn-claude-code에서 웹으로 안내
```

---

## 6. 기존 배포 방식 vs 플러그인 배포 비교

### 6.1 기존 배포 제안서 (docs/04-BKIT-VIBECODING-KIT-배포-제안서.md)

```
Phase 1: ZIP 다운로드 + 랜딩페이지 (5시간)
Phase 2: GitHub Template Repository (1주)
Phase 3: npx 설치 도구 (2주)
Phase 4: VS Code 확장 (1달)
```

### 6.2 플러그인 배포

```
설치: claude plugin install bkit
또는: claude plugin install https://github.com/bkit/vibecoding-kit
완료!
```

### 6.3 비교표

| 항목 | ZIP/npx 배포 | 플러그인 배포 |
|------|-------------|--------------|
| **설치 복잡도** | 3-5단계 | 1단계 |
| **업데이트** | 수동 재다운로드 | `claude plugin update bkit` |
| **충돌 위험** | .claude/ 덮어쓰기 | 네임스페이스 분리 |
| **버전 관리** | 수동 | 자동 |
| **팀 배포** | 각자 설치 | Marketplace 중앙 관리 |
| **기존 설정** | 충돌 가능 | 공존 가능 |
| **개발 비용** | S3, 랜딩페이지, npx | plugin.json만 |

### 6.4 결론

**플러그인 배포가 압도적으로 유리**.

기존 제안서의 4단계 계획을 **1단계로 단축** 가능:

```
기존: ZIP → GitHub Template → npx → VS Code 확장
변경: 플러그인 1개로 끝
```

---

## 7. 구현 계획

### 7.1 Phase 1: 플러그인 구조 생성 (1일)

```
□ bkit/ 디렉토리 생성
□ .claude-plugin/plugin.json 작성
□ commands/ 이전 (17개)
□ agents/ 이전 (9개)
□ skills/ 이전 (19개)
□ hooks/hooks.json 변환
```

### 7.2 Phase 2: 통합 스킬 생성 (0.5일)

```
□ skills/bkit-rules/SKILL.md 생성 (instructions 통합)
□ skills/bkit-templates/SKILL.md 생성 (templates 통합)
□ skills 간 상호 참조 확인
```

### 7.3 Phase 3: 로컬 테스트 (0.5일)

```bash
# 테스트
claude --plugin-dir ./bkit

# 명령어 테스트
/bkit:learn-claude-code
/bkit:pdca-plan 로그인 기능

# 에이전트 테스트
# 스킬 자동 활성화 테스트
```

### 7.4 Phase 4: 문서 및 배포 (0.5일)

```
□ README.md 작성
□ GitHub 리포지토리 생성 (bkit/vibecoding-kit)
□ 릴리즈 태그 (v1.4.0)
□ Marketplace 등록 (선택)
```

### 7.5 총 소요 시간

```
기존 배포 계획: 1달+ (ZIP → npx → VS Code)
플러그인 배포: 2.5일

시간 절감: 약 90%
```

---

## 8. 마이그레이션 가이드

### 8.1 기존 .claude/ 사용자

```bash
# 1. 플러그인 설치
claude plugin install bkit

# 2. 기존 .claude/ 백업 (선택)
mv .claude .claude.backup

# 3. 사용
/bkit:learn-claude-code
```

### 8.2 신규 사용자

```bash
# 설치 끝
claude plugin install bkit

# 시작
/bkit:learn-claude-code
```

### 8.3 명령어 매핑

| 기존 (직접 설치) | 플러그인 설치 후 |
|-----------------|-----------------|
| `/learn-claude-code` | `/bkit:learn-claude-code` |
| `/pdca-plan` | `/bkit:pdca-plan` |
| `/pipeline-start` | `/bkit:pipeline-start` |
| `/init-starter` | `/bkit:init-starter` |

---

## 9. 제한사항 및 고려사항

### 9.1 플러그인 제한사항

```
⚠️ 네임스페이스 필수 (/bkit:command)
⚠️ settings.json의 language 설정은 사용자 설정으로 유지
⚠️ .mcp.json은 프로젝트별 설정 (플러그인에 포함 불가)
⚠️ 문서 크기가 크면 플러그인 로딩 시간 증가
```

### 9.2 해결 방안

```
✅ 네임스페이스: 사용자에게 안내 (습관화)
✅ language: 설치 후 안내 또는 별도 설정 파일 생성
✅ .mcp.json: /bkit:init-* 시 자동 생성
✅ 문서 크기: 핵심만 포함, 상세는 웹 참조
```

---

## 10. 다국어 대응 전략

### 10.1 현재 다국어 대응 방식

현재 `.claude/skills/`와 `.claude/agents/`에서 다국어 트리거 키워드를 지원:

**Skills (description의 Trigger keywords)**:
```yaml
# skills/starter/SKILL.md
description: |
  Static web development skill for beginners...

  Trigger keywords:
  - EN: static website, portfolio, beginner
  - KO: 정적 웹, 포트폴리오, 초보자
  - JA: 静的サイト, ポートフォリオ, 初心者
  - ZH: 静态网站, 作品集, 初学者
  - ES: sitio web estático, portafolio, principiante
  - FR: site web statique, portfolio, débutant
  - DE: statische Webseite, Portfolio, Anfänger
  - IT: sito web statico, portfolio, principiante
```

**Agents (description의 Triggers)**:
```yaml
# agents/starter-guide.md
description: |
  Friendly guide agent for non-developers...

  Triggers:
  - EN: beginner, non-developer, first time
  - KO: 초보자, 비개발자, 처음
  - JA: 初心者, 非開発者, 初めて
  ...
```

### 10.2 플러그인에서 다국어 작동 여부

| 항목 | 작동 여부 | 설명 |
|------|:--------:|------|
| **Skill 트리거** | ✅ 작동 | description 시맨틱 매칭 그대로 유지 |
| **Agent 트리거** | ✅ 작동 | description 시맨틱 매칭 그대로 유지 |
| **Command 실행** | ✅ 작동 | 네임스페이스만 변경 (/bkit:command) |
| **응답 언어** | ⚠️ 별도 설정 | settings.json language는 사용자 설정 |

### 10.3 트리거 vs 응답 언어

```
┌─────────────────────────────────────────────────────────────┐
│ 사용자 입력: "정적 웹사이트 만들어줘"                           │
│                    ↓                                        │
│ Skills 매칭: "KO: 정적 웹" 키워드 감지 → starter 스킬 활성화 ✅ │
│                    ↓                                        │
│ 응답 언어: settings.json의 language 설정에 따름              │
│            - language: korean → 한국어 응답                 │
│            - language 없음 → 영어 응답 (기본값)              │
└─────────────────────────────────────────────────────────────┘
```

### 10.4 문제점: language 설정 미포함

```json
// settings.json (현재)
{
  "language": "korean"  // ← 사용자 개인 설정이라 플러그인에 포함 불가
}
```

**결과**:
- 플러그인 설치만 하면: 트리거는 다국어 OK, 응답은 **영어** (기본값)
- 한국어 응답 원하면: 사용자가 직접 설정 필요

### 10.5 해결 방안

| 옵션 | 방법 | 장단점 |
|------|------|--------|
| **A. 설치 후 안내** | SessionStart 훅에서 language 설정 안내 | 사용자 선택권 보장 |
| **B. init 시 생성** | `/bkit:init-*` 시 settings.json 생성 | 자동화, 덮어쓰기 위험 |
| **C. README 명시** | 설치 후 설정 방법 문서화 | 가장 안전 |
| **D. 설치 시 질문** | 설치 중 언어 선택 프롬프트 | UX 좋음, 구현 복잡 |

**권장: A + C 조합**

### 10.6 구현: SessionStart 훅 수정

```json
// hooks/hooks.json
{
  "hooks": {
    "SessionStart": [
      {
        "once": true,
        "hooks": [
          {
            "type": "prompt",
            "prompt": "bkit 바이브코딩 Kit이 활성화되었습니다.\n\n💡 한국어 응답을 원하시면 ~/.claude/settings.json에 다음을 추가하세요:\n{\"language\": \"korean\"}\n\n/bkit:learn-claude-code로 학습을 시작하거나 바로 개발을 시작하세요.",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

### 10.7 README.md에 언어 설정 가이드 추가

```markdown
## 설치 후 언어 설정

### 한국어 응답 설정

~/.claude/settings.json 파일에 추가:

\`\`\`json
{
  "language": "korean"
}
\`\`\`

### 지원 언어

| 언어 | 설정값 | 트리거 키워드 |
|------|--------|--------------|
| 한국어 | korean | 정적 웹, 초보자, API 설계... |
| 일본어 | japanese | 静的サイト, 初心者... |
| 중국어 | chinese | 静态网站, 初学者... |
| 영어 | english (기본) | static website, beginner... |
```

### 10.8 다국어 트리거 테스트 체크리스트

```
□ 한국어 트리거 테스트
  "정적 웹사이트 만들어줘" → starter 스킬 활성화?
  "API 설계해줘" → phase-4-api 스킬 활성화?

□ 일본어 트리거 테스트
  "静的サイトを作って" → starter 스킬 활성화?

□ 영어 트리거 테스트
  "Create a static website" → starter 스킬 활성화?

□ 응답 언어 테스트
  language: korean 설정 후 → 한국어 응답?
  language 미설정 → 영어 응답?
```

---

## 11. 패시브 자동 활성화 분석 (핵심!)

### 11.1 원래 설계 철학 (docs/03-CLAUDE-TEMPLATE-IMPROVEMENT-PROPOSAL.md)

```
"자동화 우선, 명령어는 단축키"

| 구성요소 | 역할 | 사용자가 알아야 하나? |
|----------|------|----------------------|
| Instructions | Claude가 **항상** 따르는 PDCA 규칙 | ❌ 몰라도 됨 (자동 적용) |
| Skills | Claude가 **필요시** 참조하는 지식 | ❌ 몰라도 됨 (자동 참조) |
| Agents | Claude가 **필요시** 호출하는 전문가 | ❌ 몰라도 됨 (자동 호출) |
| Hooks | 특정 이벤트에 **자동** 트리거 | ❌ 몰라도 됨 (자동 실행) |
| Commands | **파워유저용** 단축키 | ⚪ 선택사항 (알면 편함) |
```

### 11.2 플러그인에서 패시브 자동 활성화 가능 여부

| 구성요소 | 활성화 방식 | 패시브 자동 | 플러그인 지원 |
|----------|------------|:-----------:|:------------:|
| **Skills** | Model-invoked (Claude가 판단) | ✅ | ✅ |
| **Hooks** | Event-driven (이벤트 자동 트리거) | ✅ | ✅ |
| **Agents** | Task tool로 자동 호출 | ✅ | ✅ |
| **Commands** | 명시적 호출 필요 (/bkit:*) | ❌ | ✅ |
| **Instructions** | 항상 적용 (always-on) | ✅ | ❌ **미지원!** |

### 11.3 ⚠️ 중대한 제약: Instructions 미지원

**원래 설계의 핵심**:
```
Instructions가 핵심 - Claude가 **항상** 따르는 PDCA 규칙
```

**플러그인 공식 문서**:
> "There is no documented mechanism for plugins to inject 'always-on' background instructions/rules"

**결과**:
- 플러그인에 `instructions/` 폴더를 포함해도 **자동 적용되지 않음**
- 원래 설계의 "항상 PDCA 규칙 적용" 기능이 **약화됨**

### 11.4 Skills vs Instructions 비교

```
Instructions (원래):
┌──────────────────────────────────────────┐
│ 항상 Claude 컨텍스트에 포함됨            │
│ 모든 요청에 PDCA 규칙 자동 적용          │
│ 사용자가 몰라도 100% 작동               │
└──────────────────────────────────────────┘

Skills (플러그인):
┌──────────────────────────────────────────┐
│ Claude가 "필요하다고 판단할 때" 참조     │
│ description 시맨틱 매칭에 의존           │
│ PDCA와 무관한 요청 시 활성화 안 될 수 있음 │
└──────────────────────────────────────────┘
```

### 11.5 우회 방안 (3가지)

#### 방안 1: SessionStart Hook으로 규칙 주입 (권장)

```json
// hooks/hooks.json
{
  "hooks": {
    "SessionStart": [
      {
        "once": true,
        "hooks": [
          {
            "type": "prompt",
            "prompt": "[BKIT PDCA 핵심 규칙]\n\n**항상 적용**:\n- 새 기능 요청 → docs/02-design/ 확인 → 설계 먼저\n- 추측 금지 → 모르면 문서 확인 → 질문\n- SoR: 코드 > CLAUDE.md > docs/\n- 구현 완료 → Gap 분석 제안\n\n위 규칙을 이 세션 동안 항상 준수하세요.",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

**장점**: 세션 시작 시 규칙이 Claude 컨텍스트에 주입됨
**단점**: 매 세션 시작 시 메시지 출력, 프롬프트 크기 제한

#### 방안 2: PreToolUse Hook으로 규칙 강제

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "PDCA 규칙 체크:\n1. 이 파일 관련 설계가 docs/02-design/에 있는가?\n2. 없다면 설계 먼저 작성해야 함\n\n{\"decision\": \"approve\"|\"block\", \"reason\": \"...\"}",
            "timeout": 10000
          }
        ]
      }
    ]
  }
}
```

**장점**: 파일 작성 시 강제 체크
**단점**: 매번 검사로 속도 저하

#### 방안 3: 핵심 스킬 description 최적화

```yaml
# skills/bkit-rules/SKILL.md
description: |
  bkit 바이브코딩 Kit 핵심 규칙. **모든 개발 작업에 필수 적용**.

  Trigger keywords (매우 넓은 범위):
  - EN: code, develop, implement, build, create, make, fix, modify, feature, function, API, UI, component, page, database, deploy, test
  - KO: 코드, 개발, 구현, 만들어, 생성, 수정, 기능, 함수, API, UI, 컴포넌트, 페이지, 데이터베이스, 배포, 테스트, 버그, 에러
```

**장점**: 대부분의 개발 요청에 스킬 활성화
**단점**: 100% 보장은 불가

### 11.6 권장 구현: 하이브리드 (방안 1 + 3)

```
┌─────────────────────────────────────────────────────────┐
│ SessionStart Hook (방안 1)                              │
│ → 세션 시작 시 핵심 PDCA 규칙 주입                        │
│ → "항상 적용" 효과의 80% 달성                            │
└─────────────────────────────────────────────────────────┘
                         +
┌─────────────────────────────────────────────────────────┐
│ bkit-rules 스킬 (방안 3)                                │
│ → 넓은 트리거 키워드로 대부분 상황 커버                    │
│ → 상세 규칙 및 템플릿 제공                               │
└─────────────────────────────────────────────────────────┘
                         =
┌─────────────────────────────────────────────────────────┐
│ 원래 instructions의 약 90% 기능 복원                     │
│ (100%는 아니지만, 실용적 수준)                           │
└─────────────────────────────────────────────────────────┘
```

### 11.7 결론: 패시브 자동 활성화

| 기능 | 원래 .claude/ | 플러그인 |
|------|:------------:|:--------:|
| Skills 자동 참조 | ✅ | ✅ 동일 |
| Hooks 자동 트리거 | ✅ | ✅ 동일 |
| Agents 자동 호출 | ✅ | ✅ 동일 |
| Instructions 항상 적용 | ✅ | ⚠️ Hook으로 대체 (90%) |
| **총합** | 100% | **~95%** |

**최종 답변**:

> 플러그인화하더라도 사용자가 명령어를 몰라도 Skills, Agents, Hooks는 **패시브로 자동 작동**합니다.
> 단, Instructions(항상 적용되는 규칙)는 SessionStart Hook으로 대체해야 하며, 원래의 100%가 아닌 약 95% 수준의 자동화를 달성할 수 있습니다.

---

## 12. 결론 및 권장사항

### 12.1 핵심 결론

```
.claude/ 전체를 bkit 플러그인으로 변환 가능!
기존 배포 제안서의 ZIP/npx/VS Code 계획보다 훨씬 효율적.
```

### 12.2 권장 액션

```
1. 즉시 플러그인 구조로 전환
2. 기존 배포 제안서 (Phase 1-4) 폐기
3. 플러그인 Marketplace 또는 GitHub URL 배포
4. 랜딩페이지는 플러그인 설치 안내로 단순화
```

### 12.3 예상 효과

| 항목 | 기존 계획 | 플러그인 전환 |
|------|----------|--------------|
| 개발 시간 | 1달+ | 2.5일 |
| 설치 복잡도 | 3-5단계 | 1단계 |
| 유지보수 | S3/npm 관리 | GitHub 릴리즈만 |
| 사용자 경험 | 수동 다운로드 | 한 줄 명령어 |

---

## 부록: 빠른 시작 (플러그인 버전)

```bash
# 설치
claude plugin install bkit

# 시작
/bkit:learn-claude-code

# 프로젝트 초기화
/bkit:init-dynamic

# 개발 시작
"로그인 기능 만들어줘"  # PDCA 자동 적용!
```

---

**작성일**: 2025-01-09
**작성자**: Claude (with Kay)
**버전**: v1.0
**상태**: 설계 완료 → 구현 대기

---

## 참고 자료

- [Claude Code 공식 플러그인 문서](https://code.claude.com/docs/en/plugins)
- [공식 플러그인 GitHub](https://github.com/anthropics/claude-code/tree/main/plugins)
- [플러그인 Marketplace](https://github.com/anthropics/claude-plugins-official)
- [커뮤니티 플러그인 레지스트리](https://claude-plugins.dev/)
