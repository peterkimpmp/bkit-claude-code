# bkit v1.5.3 Enhancement Plan

> **Feature**: bkit-v1.5.3-enhancement
> **Level**: Dynamic
> **Date**: 2026-02-10
> **PDCA Phase**: Plan
> **Team**: CTO Lead (orchestrator), bkend-expert, frontend-architect, code-analyzer
> **Analysis Reference**: `docs/03-analysis/claude-code-v2.1.38-impact-analysis.md`, `docs/03-analysis/bkit-output-styles-plugin-integration.analysis.md`
> **Test Reference**: `docs/03-analysis/bkit-v1.5.3-comprehensive-test.analysis.md`

---

## 1. Problem Statement

bkit v1.5.3에는 team-visibility (state-writer + SubagentStart/Stop hooks)가 성공적으로 구현되어 646/646 TC PASS (39 SKIP)를 달성했으나, Claude Code v2.1.38 호환성 분석에서 식별된 **핵심 구조적 문제들**이 미해결 상태다:

| 문제 | 현황 | 영향 |
|------|------|------|
| plugin.json 불완전 | 메타데이터만 있고 컴포넌트 경로 미선언 | Output Styles 자동 발견 실패, 마켓플레이스 등록 불가 |
| Output Styles 배포 불가 | plugin.json에 `outputStyles` 필드 없음 | `/output-style` 메뉴에 bkit 스타일 미표시 |
| bkend MCP 미번들 | 사용자가 직접 MCP 설정 필요 | Dynamic 프로젝트 초기 설정 복잡 |
| bkend 문서 참조 한계 | 에이전트가 최신 bkend 문서 실시간 참조 불가 | 오래된 정보로 가이드 제공 위험 |
| 버전/수치 불일치 | hooks.json(v1.5.2), bkit.config.json(v1.5.2), marketplace.json(21 skills/11 agents) | 내부 일관성 부재 |

---

## 2. Scope & Goals

### 2.1 In Scope (v1.5.3 Enhancement)

| # | 항목 | Priority | ENH Ref |
|---|------|:--------:|:-------:|
| S-01 | plugin.json 컴포넌트 경로 보완 | Critical | ENH-01 |
| S-02 | Output Styles 배포 메커니즘 구현 | Critical | ENH-01 |
| S-03 | bkend MCP 번들링 (인증 제외) | High | ENH-12 |
| S-04 | bkend 문서 실시간 참조 체계 | High | New |
| S-05 | 버전/수치 동기화 (전체) | Medium | ENH-13 |
| S-06 | marketplace.json 최신화 | Medium | ENH-01 |
| S-07 | CLAUDE.md 전략 결정 | Medium | New |

### 2.2 Out of Scope (v1.6.0+)

| 항목 | 사유 |
|------|------|
| SessionEnd 훅 추가 (ENH-03) | v1.6.0 대상 |
| Prompt-based Hook (ENH-04) | v1.7.0 대상 |
| Async Hook 적용 (ENH-05) | v1.6.1 대상 |
| PostToolUseFailure 훅 (ENH-06) | v1.6.1 대상 |
| CLAUDE_ENV_FILE 활용 (ENH-07) | v1.6.0 대상 |
| 마켓플레이스 공식 등록 (ENH-02) | v1.7.0 대상 (ENH-01 전제) |
| LSP 서버 통합 (ENH-08) | v1.7.0 대상 |

---

## 3. Key Decisions

### 3.1 CLAUDE.md - 플러그인 제공 불필요

**결론: 플러그인에서 CLAUDE.md를 제공하지 않는다.**

| 관점 | 분석 |
|------|------|
| CLAUDE.md 역할 | 프로젝트별 정적 컨텍스트 (코딩 표준, 아키텍처 규칙, 라이브러리 사용법) |
| bkit의 접근법 | 동적 컨텍스트 (SessionStart hook으로 PDCA 상태/레벨/컨텍스트 주입) |
| 중복 위험 | bkit이 CLAUDE.md를 제공하면 사용자의 프로젝트 CLAUDE.md와 충돌/중복 |
| Context Token 효율 | CLAUDE.md는 모든 턴에 user message로 주입 (토큰 비효율). bkit은 SessionStart에서 1회 주입 |
| 공식 권장 | Anthropic은 CLAUDE.md를 "프로젝트 소유자"가 작성하도록 설계 |

**대신 bkit이 제공하는 Context Engineering 채널:**

```
bkit Context Stack (CLAUDE.md보다 효율적)
├── SessionStart Hook      → PDCA 상태, 레벨, 팀 설정, 트리거 테이블
├── UserPromptSubmit Hook   → 의도 감지, 에이전트 자동 트리거
├── Output Styles           → 시스템 프롬프트 교체 (가장 강력)
├── Skills (26개)           → 온디맨드 전문 지식 로딩
├── Agent Memory (16개)     → 에이전트별 지속적 학습
└── PreCompact Hook         → 컨텍스트 압축 시 PDCA 보존
```

**사용자 CLAUDE.md 권장 사항:**
- bkit 사용자에게는 프로젝트 고유 규칙만 CLAUDE.md에 작성하도록 가이드
- `/claude-code-learning` 스킬에서 CLAUDE.md 작성법 안내 (이미 포함)

### 3.2 bkend MCP - 인증 제외 번들링 가능

**결론: `.mcp.json` 템플릿과 setup command를 제공한다. 단, 인증은 사용자가 직접 설정한다.**

| 항목 | 분석 |
|------|------|
| bkend MCP 인증 방식 | OAuth 2.1 + PKCE (브라우저 기반 자동 인증) |
| 인증 데이터 위치 | 사용자 로컬 (~/.bkend/ 또는 OS keychain) |
| 플러그인에 포함 가능 항목 | MCP endpoint URL, transport type, 기본 설정 |
| 플러그인에 포함 불가 항목 | OAuth tokens, API keys, 사용자 credentials |
| 현재 bkend MCP 도구 | 19개 (Guide 8 + API 11) |

**구현 방안:**

**A. plugin.json에 mcpServers 선언 (자동 설정)**
```json
{
  "mcpServers": {
    "bkend": {
      "transport": "http",
      "url": "https://api.bkend.ai/mcp"
    }
  }
}
```

> **주의**: Claude Code plugin.json의 `mcpServers` 필드가 `.mcp.json`처럼 자동 설정을 지원하는지 공식 문서 확인 필요. 현재 plugins-reference에서 `mcpServers` 컴포넌트 경로만 지원할 수 있으며, 이 경우 `.mcp.json` 파일을 번들하는 방식이 필요.

**B. bkend-setup command 제공 (사용자 주도)**
```
/bkit bkend-setup  →  사용자 프로젝트에 .mcp.json 생성 + OAuth 안내
```

**권장: B안 (bkend-setup command)**

이유:
1. MCP 인증은 프로젝트별로 다른 bkend Organization/Project/Environment를 사용
2. 자동 번들 시 모든 프로젝트에 bkend MCP가 연결되어 불필요한 인증 프롬프트 발생
3. 사용자가 bkend를 사용하겠다고 명시적으로 결정한 후 설정하는 것이 UX적으로 적절
4. 현재 session-start.js가 `.mcp.json` 존재 여부로 bkend 상태를 감지하므로 이 로직과 호환

**bkend 전문가 에이전트 의견:**
- bkend MCP는 OAuth 2.1 PKCE 기반으로 브라우저 인증이 필수
- `claude mcp add bkend --transport http https://api.bkend.ai/mcp` 한 줄로 설정 가능
- 플러그인 자동 번들보다 사용자 주도 설정이 적절 (프로젝트별 환경이 다름)
- bkend-quickstart 스킬이 이미 MCP 설정 가이드를 제공 중

### 3.3 bkend 문서 실시간 참조

**결론: bkend-expert 에이전트에 WebFetch 기반 문서 참조 패턴을 강화한다.**

| 항목 | 분석 |
|------|------|
| bkend 문서 위치 | https://github.com/popup-studio-ai/bkend-docs/blob/main/SUMMARY.md |
| 현재 에이전트 도구 | Read, Write, Edit, Glob, Grep, Bash, **WebFetch** |
| WebFetch 가능 여부 | GitHub raw URL은 WebFetch로 접근 가능 |
| 문서 구조 | 9개 대분류, 60+ 페이지 (Getting Started ~ Troubleshooting + Cookbook 4종) |

**구현 방안:**

1. **bkend-expert 에이전트 Memory에 문서 인덱스 저장**
   - `.claude/agent-memory/bkit-bkend-expert/MEMORY.md`에 SUMMARY.md 구조 캐시
   - 에이전트 시작 시 자동으로 최신 인덱스 확인

2. **bkend 스킬에 문서 참조 URL 패턴 추가**
   - 각 bkend 스킬(auth, data, storage, cookbook)에 해당 섹션의 GitHub URL 명시
   - 에이전트가 최신 정보 필요 시 WebFetch로 특정 페이지 조회

3. **문서 참조 URL 매핑**
```
Base URL: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/

인증 → src/authentication/
데이터 → src/database/
스토리지 → src/storage/
보안 → src/security/
AI Tools → src/ai-tools/
Cookbook → src/cookbooks/
```

**제약 사항:**
- WebFetch는 공개 URL만 접근 가능 (GitHub raw 파일은 public repo라 가능)
- 대용량 문서 전체를 한번에 로드하면 컨텍스트 소모가 크므로 필요한 섹션만 선택적 조회
- GitHub API rate limit 고려 (인증 없이 시간당 60회)

### 3.4 Output Styles 배포 전략

**결론: 이중 전략 - plugin.json 공식 선언(A안) + 수동 복사 커맨드(B안 확장)**

**기존 분석 결과 요약** (from `bkit-output-styles-plugin-integration.analysis.md`):

| 문제 | Root Cause |
|------|-----------|
| `/output-style` 메뉴에 bkit 스타일 미표시 | plugin.json에 `outputStyles` 필드 미선언 |
| 개발환경에서만 동작 | session-start.js hook이 additionalContext로 우회 주입 |
| 4개 스타일 모두 `keep-coding-instructions: true` | 확인 완료 (모두 설정됨) |

**이중 전략 상세:**

**전략 1: plugin.json `outputStyles` 필드 추가 (공식 메커니즘)**
```json
{
  "name": "bkit",
  "version": "1.5.3",
  "outputStyles": "./output-styles/"
}
```
- 플러그인 설치 시 자동으로 `/output-style` 메뉴에 표시
- 사용자가 `/output-style bkit:bkit-pdca-guide` 형태로 선택 가능
- 플러그인 캐시에 자동 복사

**전략 2: `/bkit output-style-setup` 커맨드 (수동 대안)**

사용자가 플러그인 설치 없이도 output styles를 사용할 수 있도록 커맨드 제공:

```
/bkit output-style-setup
→ 1. output-styles/ 파일들을 ~/.claude/output-styles/ 또는 .claude/output-styles/로 복사
→ 2. 사용 가능한 스타일 목록 표시
→ 3. 프로젝트 레벨에 맞는 스타일 추천
```

**구현 세부 사항:**

| 항목 | 전략 1 (자동) | 전략 2 (수동) |
|------|:----------:|:----------:|
| 적용 시점 | 플러그인 설치 시 | 사용자 명령 시 |
| 복사 위치 | 플러그인 캐시 → 자동 발견 | `~/.claude/output-styles/` (user level) 또는 `.claude/output-styles/` (project level) |
| 네임스페이스 | `bkit:bkit-pdca-guide` | `bkit-pdca-guide` (직접) |
| 업데이트 | 플러그인 업데이트 시 자동 | 커맨드 재실행 필요 |
| 대상 사용자 | 플러그인 마켓플레이스 사용자 | Git clone 사용자 |

**session-start.js 중복 방지:**
- 현재 session-start.js에서 output style 내용을 additionalContext로 주입하는 로직이 있음
- plugin.json outputStyles 적용 후에도 이 로직이 남으면 중복 주입 발생
- 해결: output style 활성화 여부를 감지하여 조건 분기
  ```javascript
  // session-start.js에서 output style 중복 방지
  // Claude Code가 output style을 적용했으면 hook에서 중복 주입하지 않음
  // 판단 기준: settings.local.json의 outputStyle 값이 bkit 스타일이면 skip
  ```

---

## 4. Implementation Plan

### 4.1 Unit 1: plugin.json 컴포넌트 경로 보완 (S-01)

**Target File**: `.claude-plugin/plugin.json`

**현재:**
```json
{
  "name": "bkit",
  "version": "1.5.2",
  "description": "Vibecoding Kit - PDCA methodology + CTO-Led Agent Teams + Claude Code mastery for AI-native development",
  "author": { "name": "POPUP STUDIO PTE. LTD.", "email": "contact@popupstudio.ai", "url": "https://popupstudio.ai" },
  "repository": "https://github.com/popup-studio-ai/bkit-claude-code",
  "license": "Apache-2.0",
  "keywords": ["vibecoding", "pdca", "development-pipeline", "ai-native", "agentic", "agent", "automation", "workflow", "fullstack", "multilingual", "baas", "enterprise"]
}
```

**변경:**
```json
{
  "name": "bkit",
  "version": "1.5.3",
  "description": "Vibecoding Kit - PDCA methodology + CTO-Led Agent Teams + Claude Code mastery for AI-native development",
  "author": { "name": "POPUP STUDIO PTE. LTD.", "email": "contact@popupstudio.ai", "url": "https://popupstudio.ai" },
  "repository": "https://github.com/popup-studio-ai/bkit-claude-code",
  "license": "Apache-2.0",
  "keywords": ["vibecoding", "pdca", "development-pipeline", "ai-native", "agentic", "agent", "automation", "workflow", "fullstack", "multilingual", "baas", "enterprise"],
  "outputStyles": "./output-styles/"
}
```

**변경 내역:**
1. `version`: "1.5.2" → "1.5.3"
2. `outputStyles`: 추가 - Output Styles 자동 발견 BUG 해결

**주의 사항:**
- `hooks`, `skills`, `agents`는 Claude Code가 기본 위치(`hooks/hooks.json`, `skills/`, `agents/`)를 자동 발견하므로 명시 불필요
- `outputStyles`만 기본 위치가 없어 명시적 선언 필수
- `commands`도 기본 위치(`commands/`)를 자동 발견

### 4.2 Unit 2: Output Styles 배포 (S-02)

#### 4.2.1 output-style-setup 커맨드 생성

**New File**: `commands/output-style-setup.md`

커맨드 내용:
```markdown
---
name: output-style-setup
description: Copy bkit output styles to your project or user directory
user-invocable: true
---

# Output Style Setup

bkit의 4가지 Output Style을 설치합니다.

## 설치 대상 스타일

| Style | Level | Description |
|-------|-------|-------------|
| bkit-learning | Starter | 학습 모드 - PDCA를 배우며 개발 |
| bkit-pdca-guide | Dynamic | PDCA 워크플로우 가이드 + 체크리스트 |
| bkit-enterprise | Enterprise | CTO 관점 아키텍처/보안/성능 |
| bkit-pdca-enterprise | Enterprise | PDCA + CTO 통합 |

## 설치 방법

1. 프로젝트 레벨 설치 (현재 프로젝트에만 적용):
   - `${CLAUDE_PLUGIN_ROOT}/output-styles/` → `.claude/output-styles/`로 복사

2. 사용자 레벨 설치 (모든 프로젝트에 적용):
   - `${CLAUDE_PLUGIN_ROOT}/output-styles/` → `~/.claude/output-styles/`로 복사

3. 설치 후 `/output-style`로 스타일 선택

## 레벨별 추천

- Starter 프로젝트: `bkit-learning`
- Dynamic 프로젝트: `bkit-pdca-guide`
- Enterprise 프로젝트: `bkit-enterprise` 또는 `bkit-pdca-enterprise`
```

#### 4.2.2 session-start.js 중복 방지

output style이 정상 적용된 경우 hook에서 중복 주입하지 않도록 조건 분기 추가.
현재 session-start.js의 output style 권장 메시지는 유지하되, additionalContext로 스타일 내용을 직접 주입하는 부분이 있다면 제거 또는 조건 분기.

### 4.3 Unit 3: bkend 문서 참조 체계 (S-04)

#### 4.3.1 bkend-expert 에이전트 Memory 업데이트

**Target File**: `.claude/agent-memory/bkit-bkend-expert/MEMORY.md` (신규 생성)

```markdown
# bkend Expert Agent Memory

## Documentation Reference
- Summary: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- Base URL: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/

## Section URLs
- Authentication: src/authentication/
- Database: src/database/
- Storage: src/storage/
- Security: src/security/
- AI Tools: src/ai-tools/
- Cookbooks: src/cookbooks/
- Guides: src/guides/
- Troubleshooting: src/troubleshooting/

## Usage Pattern
- 최신 정보 필요 시 WebFetch로 해당 섹션의 raw URL 조회
- SUMMARY.md로 전체 구조 먼저 확인 후 필요한 페이지만 선택적 조회
- Rate limit: 인증 없이 시간당 60회 (충분)
```

#### 4.3.2 bkend 스킬 문서 참조 섹션 추가

5개 bkend 스킬(bkend-quickstart, bkend-auth, bkend-data, bkend-storage, bkend-cookbook)에 각각 해당하는 공식 문서 URL 섹션 추가.

**추가 내용 패턴:**
```markdown
## Official Documentation Reference
최신 정보가 필요한 경우 다음 URL을 WebFetch로 조회하세요:
- 공식 문서: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/{section}/
- 전체 목차: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
```

| Skill | Section Path |
|-------|-------------|
| bkend-quickstart | src/getting-started/ |
| bkend-auth | src/authentication/ |
| bkend-data | src/database/ |
| bkend-storage | src/storage/ |
| bkend-cookbook | src/cookbooks/ |

### 4.4 Unit 4: bkend MCP 설정 가이드 강화 (S-03)

#### 4.4.1 bkend-quickstart 스킬에 MCP 설정 원클릭 가이드 보강

현재 bkend-quickstart 스킬이 MCP 설정을 안내하고 있으나, 더 명확한 단계별 가이드로 보강:

```
Step 1: bkend 계정 확인 (console.bkend.ai)
Step 2: claude mcp add bkend --transport http https://api.bkend.ai/mcp
Step 3: OAuth 브라우저 인증 (자동 팝업)
Step 4: 프로젝트/환경 선택 확인
```

#### 4.4.2 .mcp.json 템플릿 제공

**기존 파일**: `templates/shared/bkend-patterns.md`에 이미 `.mcp.json` 템플릿 포함

```json
{
  "mcpServers": {
    "bkend": {
      "type": "http",
      "url": "https://api.bkend.ai/mcp"
    }
  }
}
```

session-start.js의 기존 bkend MCP 감지 로직과 호환되므로 추가 변경 불필요.

### 4.5 Unit 5: 버전/수치 동기화 (S-05, S-06)

#### 4.5.1 버전 동기화 대상

| File | Field | 현재 값 | 변경 값 |
|------|-------|--------|--------|
| `.claude-plugin/plugin.json` | version | "1.5.2" | "1.5.3" |
| `bkit.config.json` | version | "1.5.2" | "1.5.3" |
| `hooks/hooks.json` | description | "v1.5.2" | "v1.5.3" |
| `.claude-plugin/marketplace.json` | version (root) | "1.5.2" | "1.5.3" |
| `.claude-plugin/marketplace.json` | plugins[1].version | "1.5.2" | "1.5.3" |
| `lib/common.js` | @version comment | "1.5.3" | "1.5.3" (유지) |

#### 4.5.2 marketplace.json 수치 최신화

**현재 (오래된 수치):**
```
"21 skills, 11 agents, 39 scripts, and 6 unified hooks"
```

**변경 (v1.5.3 실제 수치):**
```
"26 skills, 16 agents, 45 scripts, 10 hook events, and 4 output styles"
```

#### 4.5.3 hooks.json description 업데이트

**현재:** `"description": "bkit Vibecoding Kit v1.5.2 - Claude Code"`
**변경:** `"description": "bkit Vibecoding Kit v1.5.3 - Claude Code"`

### 4.6 Unit 6: CLAUDE.md 전략 문서화 (S-07)

CLAUDE.md를 제공하지 않기로 결정했으므로, 사용자 가이드에 이 전략을 명확히 문서화:

#### 4.6.1 commands/bkit.md 업데이트

CLAUDE.md 섹션 추가:
```markdown
## CLAUDE.md와 bkit

bkit은 CLAUDE.md를 제공하지 않습니다. 이유:
- bkit은 Hook, Skill, Agent, Output Style로 동적 컨텍스트를 제공합니다
- CLAUDE.md는 프로젝트 고유 규칙을 위한 것입니다
- 사용자가 직접 프로젝트 CLAUDE.md를 작성하세요

CLAUDE.md 작성이 필요하면 `/claude-code-learning`을 참고하세요.
```

---

## 5. File Change Summary

### 5.1 수정 파일 (7개)

| # | File | Change Type | Description |
|---|------|:-----------:|-------------|
| 1 | `.claude-plugin/plugin.json` | Edit | version 1.5.3 + outputStyles 필드 추가 |
| 2 | `.claude-plugin/marketplace.json` | Edit | version 1.5.3 + description 수치 최신화 |
| 3 | `bkit.config.json` | Edit | version 1.5.3 |
| 4 | `hooks/hooks.json` | Edit | description v1.5.3 |
| 5 | `commands/bkit.md` | Edit | CLAUDE.md 전략 + output-style-setup 안내 추가 |
| 6 | `skills/bkend-quickstart/SKILL.md` | Edit | 문서 참조 URL + MCP 설정 가이드 보강 |
| 7 | `skills/bkend-auth/SKILL.md` | Edit | 문서 참조 URL 추가 |

### 5.2 수정 파일 (추가 4개)

| # | File | Change Type | Description |
|---|------|:-----------:|-------------|
| 8 | `skills/bkend-data/SKILL.md` | Edit | 문서 참조 URL 추가 |
| 9 | `skills/bkend-storage/SKILL.md` | Edit | 문서 참조 URL 추가 |
| 10 | `skills/bkend-cookbook/SKILL.md` | Edit | 문서 참조 URL 추가 |
| 11 | `agents/bkend-expert.md` | Edit | 문서 참조 패턴 + SUMMARY.md URL 추가 |

### 5.3 신규 파일 (2개)

| # | File | Description |
|---|------|-------------|
| 12 | `commands/output-style-setup.md` | Output Style 수동 설치 커맨드 |
| 13 | `.claude/agent-memory/bkit-bkend-expert/MEMORY.md` | bkend 에이전트 문서 참조 메모리 |

### 5.4 변경 없음 (확인만)

| File | Status | Note |
|------|--------|------|
| `output-styles/*.md` | 유지 | 4개 모두 `keep-coding-instructions: true` 확인 완료 |
| `lib/common.js` | 유지 | v1.5.3 state-writer 9개 re-export 이미 완료 (GAP-01 수정 완료) |
| `.mcp.json` | 미생성 | 사용자가 직접 생성하는 것으로 결정 |
| `CLAUDE.md` | 미생성 | 플러그인에서 제공하지 않기로 결정 |

---

## 6. Test Plan

### 6.1 신규 TC (Unit별)

| TC ID | Unit | Test Case | Expected |
|-------|:----:|-----------|----------|
| ENH-U1-01 | 1 | plugin.json에 outputStyles 필드 존재 | `"outputStyles": "./output-styles/"` |
| ENH-U1-02 | 1 | plugin.json version이 "1.5.3" | PASS |
| ENH-U1-03 | 1 | plugin.json의 outputStyles 경로에 4개 .md 파일 존재 | 4 files |
| ENH-U2-01 | 2 | commands/output-style-setup.md 존재 | PASS |
| ENH-U2-02 | 2 | output-style-setup이 user-invocable: true | PASS |
| ENH-U2-03 | 2 | 4개 output style 모두 keep-coding-instructions: true | PASS |
| ENH-U3-01 | 3 | bkend-expert MEMORY.md에 문서 참조 URL 포함 | PASS |
| ENH-U3-02 | 3 | 5개 bkend 스킬에 문서 참조 섹션 존재 | 5/5 PASS |
| ENH-U3-03 | 3 | bkend-expert.md에 SUMMARY.md URL 포함 | PASS |
| ENH-U3-04 | 3 | WebFetch로 SUMMARY.md 접근 가능 | HTTP 200 |
| ENH-U4-01 | 4 | bkend-quickstart에 MCP 설정 단계별 가이드 포함 | PASS |
| ENH-U5-01 | 5 | 모든 5개 파일의 version이 "1.5.3" | 5/5 PASS |
| ENH-U5-02 | 5 | marketplace.json description에 "26 skills, 16 agents" | PASS |
| ENH-U5-03 | 5 | hooks.json description에 "v1.5.3" | PASS |
| ENH-U6-01 | 6 | commands/bkit.md에 CLAUDE.md 전략 섹션 존재 | PASS |
| ENH-U6-02 | 6 | CLAUDE.md 파일이 프로젝트 루트에 없음 | 없음 (의도적) |

### 6.2 회귀 TC (기존 기능 보존)

| TC ID | Test Case | Expected |
|-------|-----------|----------|
| REG-01 | common.js exports >= 180 | PASS |
| REG-02 | 26 skills 존재 | PASS |
| REG-03 | 16 agents 존재 | PASS |
| REG-04 | 10 hook events 존재 | PASS |
| REG-05 | 모든 hook script 경로 유효 | PASS |
| REG-06 | team.enabled: true | PASS |
| REG-07 | state-writer 9 exports in team/index.js | PASS |
| REG-08 | SubagentStart/Stop in hooks.json | PASS |
| REG-09 | 4 output styles 존재 | PASS |
| REG-10 | session-start.js 로드 성공 | PASS |

### 6.3 TC 요약

| Category | Count |
|----------|:-----:|
| 신규 TC (Unit 1-6) | 16 |
| 회귀 TC | 10 |
| **Total** | **26** |
| 목표 Pass Rate | >= 100% |

---

## 7. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|:----------:|:------:|------------|
| plugin.json outputStyles가 플러그인 캐시에서 동작하지 않음 | Low | High | 설치 후 `/output-style` 메뉴 검증, 수동 대안(커맨드) 존재 |
| bkend docs GitHub raw URL 접근 실패 | Very Low | Medium | 스킬 내 정적 내용이 이미 충분, WebFetch는 보충 수단 |
| 버전 동기화 누락 | Low | Low | TC ENH-U5-01로 5개 파일 모두 검증 |
| output-style-setup 커맨드와 plugin.json 중복 | Low | Low | 두 방법은 대상 사용자가 다름 (마켓플레이스 vs git clone) |
| session-start.js output style 중복 주입 | Medium | Medium | 기존 hook 로직 분석 후 조건 분기 추가 |

---

## 8. Dependencies

```
Unit 1 (plugin.json)     ← 독립 (최우선)
Unit 2 (Output Styles)   ← Unit 1 완료 후
Unit 3 (bkend docs)      ← 독립
Unit 4 (bkend MCP)       ← 독립
Unit 5 (버전 동기화)     ← Unit 1 완료 후 (version 포함)
Unit 6 (CLAUDE.md 전략)  ← 독립
```

**병렬 실행 가능:**
- Unit 1 + Unit 3 + Unit 4 + Unit 6 (병렬)
- Unit 2 + Unit 5 (Unit 1 완료 후 병렬)

---

## 9. v1.5.3 Release Checklist

- [ ] Unit 1: plugin.json outputStyles 필드 추가 + version 1.5.3
- [ ] Unit 2: output-style-setup 커맨드 생성
- [ ] Unit 3: bkend 문서 참조 체계 구축 (에이전트 Memory + 스킬 5개 + 에이전트 1개)
- [ ] Unit 4: bkend MCP 설정 가이드 보강
- [ ] Unit 5: 전체 버전/수치 동기화 (5개 파일)
- [ ] Unit 6: CLAUDE.md 전략 문서화
- [ ] 전체 TC 실행 (26 TC, 100% 목표)
- [ ] GAP-01 수정 확인 (common.js state-writer re-exports - 이미 완료)
- [ ] Git commit + tag v1.5.3

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-10 | Initial plan - 7 scope items, 6 units, 26 TC | CTO Lead (Claude Opus 4.6) |
