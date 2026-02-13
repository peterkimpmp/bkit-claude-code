# bkit v1.5.3 Enhancement - Design Document

> **Feature**: bkit-v1.5.3-enhancement
> **Level**: Dynamic
> **Date**: 2026-02-10
> **PDCA Phase**: Design
> **Plan Reference**: `docs/01-plan/features/bkit-v1.5.3-enhancement.plan.md`
> **Analysis Reference**: `docs/03-analysis/claude-code-v2.1.38-impact-analysis.md`, `docs/03-analysis/bkit-output-styles-plugin-integration.analysis.md`

---

## 1. Design Overview

v1.5.3 Enhancement는 6개 Unit으로 구성되며, 총 13개 파일 변경(수정 11 + 신규 2)을 수행한다.

```
Unit 1: plugin.json 컴포넌트 경로 보완     → .claude-plugin/plugin.json
Unit 2: Output Styles 배포 메커니즘         → commands/output-style-setup.md (신규)
Unit 3: bkend 문서 참조 체계               → agent-memory (신규) + 5 skills + 1 agent
Unit 4: bkend MCP 설정 가이드 보강          → skills/bkend-quickstart/SKILL.md
Unit 5: 버전/수치 동기화                    → 4개 config 파일
Unit 6: CLAUDE.md 전략 문서화              → commands/bkit.md
```

---

## 2. Unit 1: plugin.json 컴포넌트 경로 보완

### 2.1 파일: `.claude-plugin/plugin.json`

#### 현재 코드 (v1.5.2, 26줄)

```json
{
  "name": "bkit",
  "version": "1.5.2",
  "description": "Vibecoding Kit - PDCA methodology + CTO-Led Agent Teams + Claude Code mastery for AI-native development",
  "author": {
    "name": "POPUP STUDIO PTE. LTD.",
    "email": "contact@popupstudio.ai",
    "url": "https://popupstudio.ai"
  },
  "repository": "https://github.com/popup-studio-ai/bkit-claude-code",
  "license": "Apache-2.0",
  "keywords": [
    "vibecoding",
    "pdca",
    "development-pipeline",
    "ai-native",
    "agentic",
    "agent",
    "automation",
    "workflow",
    "fullstack",
    "multilingual",
    "baas",
    "enterprise"
  ]
}
```

#### 변경 내역

| Line | Before | After | Reason |
|:----:|--------|-------|--------|
| 3 | `"version": "1.5.2"` | `"version": "1.5.3"` | 버전 동기화 |
| 25+ | (없음) | `"outputStyles": "./output-styles/"` | Output Styles 자동 발견 활성화 |

#### 변경 후 코드

```json
{
  "name": "bkit",
  "version": "1.5.3",
  "description": "Vibecoding Kit - PDCA methodology + CTO-Led Agent Teams + Claude Code mastery for AI-native development",
  "author": {
    "name": "POPUP STUDIO PTE. LTD.",
    "email": "contact@popupstudio.ai",
    "url": "https://popupstudio.ai"
  },
  "repository": "https://github.com/popup-studio-ai/bkit-claude-code",
  "license": "Apache-2.0",
  "keywords": [
    "vibecoding",
    "pdca",
    "development-pipeline",
    "ai-native",
    "agentic",
    "agent",
    "automation",
    "workflow",
    "fullstack",
    "multilingual",
    "baas",
    "enterprise"
  ],
  "outputStyles": "./output-styles/"
}
```

#### 설계 근거

- Claude Code plugins-reference 공식 문서에 따르면 `outputStyles`는 **기본 위치가 없어** 반드시 명시 선언 필요
- `hooks`, `skills`, `agents`, `commands`는 기본 위치(`hooks/hooks.json`, `skills/`, `agents/`, `commands/`)를 자동 발견하므로 추가 선언 불필요
- `outputStyles` 값은 디렉토리 경로(string) 또는 파일 배열(array) 가능 → 디렉토리 방식 채택
- 이 한 줄 변경으로 `/output-style` 메뉴에 bkit 4개 스타일이 자동 표시됨

---

## 3. Unit 2: Output Styles 배포 메커니즘

### 3.1 신규 파일: `commands/output-style-setup.md`

#### 파일 전체 내용

```markdown
---
name: output-style-setup
description: |
  Install bkit output styles to your project or user directory.
  Copies output style files from bkit plugin to the appropriate location.

  Triggers: output style setup, install output style, setup style,
  아웃풋 스타일 설치, 스타일 설정, 出力スタイル設定,
  输出样式安装, instalar estilo, installer style,
  Stil installieren, installare stile
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - AskUserQuestion
---

# Output Style Setup

bkit의 Output Style을 설치합니다.

## Available Styles

| Style | Recommended For | Description |
|-------|----------------|-------------|
| bkit-learning | Starter | 학습 모드 - PDCA를 배우며 개발 |
| bkit-pdca-guide | Dynamic | PDCA 워크플로우 가이드 + 자동 체크리스트 |
| bkit-enterprise | Enterprise | CTO 관점 아키텍처/보안/성능 분석 |
| bkit-pdca-enterprise | Enterprise | PDCA + CTO 통합 (가장 상세) |

## Instructions

Ask the user where to install using AskUserQuestion:

**Option 1: Project level** (current project only)
- Copy from `${CLAUDE_PLUGIN_ROOT}/output-styles/*.md` to `.claude/output-styles/`
- Best for: project-specific style preference

**Option 2: User level** (all projects)
- Copy from `${CLAUDE_PLUGIN_ROOT}/output-styles/*.md` to `~/.claude/output-styles/`
- Best for: consistent style across all projects

## Setup Steps

1. Ask user: project level or user level installation
2. Create target directory if not exists
3. Copy all 4 output style files to target
4. Confirm installation with file list
5. Suggest running `/output-style` to activate

## Post-Setup

After copying, inform user:
- Use `/output-style` to select from the installed styles
- Recommended style based on project level detection
- Styles can be changed anytime during session
```

#### 설계 근거

- Plan 3.4절에서 결정한 "이중 전략"의 B안 (수동 대안) 구현
- `user-invocable: true`로 설정하여 사용자가 `/output-style-setup`으로 직접 호출 가능
- AskUserQuestion으로 project level vs user level 선택을 사용자에게 위임
- plugin.json의 `outputStyles` 필드(전략 A)와 상호 보완적 역할

#### 동작 흐름

```
사용자: /output-style-setup
  ↓
AskUserQuestion: "어디에 설치할까요?"
  ├── Project level → .claude/output-styles/
  └── User level → ~/.claude/output-styles/
  ↓
mkdir -p {target_dir}
  ↓
cp ${CLAUDE_PLUGIN_ROOT}/output-styles/*.md {target_dir}/
  ↓
"설치 완료. /output-style 로 스타일을 선택하세요."
```

### 3.2 session-start.js 수정 (Output Styles 섹션)

#### 현재 코드 (hooks/session-start.js:542-552)

```javascript
  // Output Styles suggestion based on level
  const levelStyleMap = {
    'Starter': 'bkit-learning',
    'Dynamic': 'bkit-pdca-guide',
    'Enterprise': 'bkit-enterprise'
  };
  const suggestedStyle = levelStyleMap[detectedLevel] || 'bkit-pdca-guide';
  additionalContext += `## Output Styles (v1.5.2)\n`;
  additionalContext += `- Recommended for ${detectedLevel} level: \`${suggestedStyle}\`\n`;
  additionalContext += `- Change anytime with \`/output-style\`\n`;
  additionalContext += `- Available: bkit-learning (beginners), bkit-pdca-guide (PDCA workflow), bkit-enterprise (architecture)\n\n`;
```

#### 변경 내역

| Line | Before | After | Reason |
|:----:|--------|-------|--------|
| 549 | `## Output Styles (v1.5.2)\n` | `## Output Styles (v1.5.3)\n` | 버전 동기화 |
| 552 | `Available: bkit-learning (beginners), bkit-pdca-guide (PDCA workflow), bkit-enterprise (architecture)` | `Available: bkit-learning, bkit-pdca-guide, bkit-enterprise, bkit-pdca-enterprise` + setup 안내 추가 | 4번째 스타일 누락 수정 + 설치 가이드 |

#### 변경 후 코드

```javascript
  // Output Styles suggestion based on level
  const levelStyleMap = {
    'Starter': 'bkit-learning',
    'Dynamic': 'bkit-pdca-guide',
    'Enterprise': 'bkit-enterprise'
  };
  const suggestedStyle = levelStyleMap[detectedLevel] || 'bkit-pdca-guide';
  additionalContext += `## Output Styles (v1.5.3)\n`;
  additionalContext += `- Recommended for ${detectedLevel} level: \`${suggestedStyle}\`\n`;
  additionalContext += `- Change anytime with \`/output-style\`\n`;
  additionalContext += `- Available: bkit-learning, bkit-pdca-guide, bkit-enterprise, bkit-pdca-enterprise\n`;
  additionalContext += `- If styles not visible in /output-style menu, run \`/output-style-setup\`\n\n`;
```

### 3.3 session-start.js 수정 (systemMessage 버전)

#### 현재 코드 (hooks/session-start.js:661)

```javascript
  systemMessage: `bkit Vibecoding Kit v1.5.2 activated (Claude Code)`,
```

#### 변경

```javascript
  systemMessage: `bkit Vibecoding Kit v1.5.3 activated (Claude Code)`,
```

### 3.4 session-start.js 수정 (Feature Usage Report 버전)

#### 현재 코드 (hooks/session-start.js:605)

```javascript
## 📊 bkit Feature Usage Report (v1.5.2 - Required for all responses)
```

#### 변경

```javascript
## 📊 bkit Feature Usage Report (v1.5.3 - Required for all responses)
```

---

## 4. Unit 3: bkend 문서 참조 체계

### 4.1 신규 파일: `.claude/agent-memory/bkit-bkend-expert/MEMORY.md`

#### 파일 전체 내용

```markdown
# bkend Expert Agent Memory

## Project Context
- **Role**: bkend.ai BaaS platform expert
- **Skills**: bkend-quickstart, bkend-auth, bkend-data, bkend-storage, bkend-cookbook
- **MCP Tools**: 19 (Guide 8 + API 11)

## Official Documentation Reference

### Base URL
- GitHub Pages: https://github.com/popup-studio-ai/bkend-docs/blob/main/
- Raw Content: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/

### Document Index (SUMMARY.md)
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md

### Section Map
| Section | Path | Use When |
|---------|------|----------|
| Getting Started | src/getting-started/ | New to bkend |
| Console | src/console/ | Console operations |
| AI Tools | src/ai-tools/ | MCP setup, tool integration |
| Authentication | src/authentication/ | Auth endpoints, social login, JWT |
| Database | src/database/ | CRUD, schema, filtering, indexing |
| Storage | src/storage/ | File upload, presigned URL, CDN |
| Security | src/security/ | API keys, RLS, encryption |
| Guides | src/guides/ | Migration, optimization, scaling |
| Troubleshooting | src/troubleshooting/ | Error resolution |
| Cookbooks | src/cookbooks/ | Blog, Recipe, Shopping, Social |

### Usage Pattern
- WebFetch로 필요한 섹션의 raw URL 조회 (GitHub public repo)
- SUMMARY.md로 전체 구조 먼저 확인 후 해당 페이지만 선택적 조회
- Rate limit: 인증 없이 시간당 60회 (충분)
- 대용량 문서 전체 로드 대신 필요한 페이지만 조회하여 컨텍스트 절약

## Key Technical Notes
- MCP Endpoint: https://api.bkend.ai/mcp (Streamable HTTP)
- Service API: https://api.bkend.ai/v1 (REST)
- Auth: OAuth 2.1 + PKCE (browser auto-auth, no API keys)
- RBAC: admin/user/self/guest
- JWT: Access 1h, Refresh 7d (Service API), 30d (MCP)
```

#### 설계 근거

- bkend-expert 에이전트는 `memory: project` 스코프로 설정되어 있어 `.claude/agent-memory/` 디렉토리에 메모리 저장
- 에이전트 이름은 `bkit-bkend-expert`이므로 디렉토리명은 `bkit-bkend-expert/`
- WebFetch 도구가 에이전트 tools에 이미 포함되어 있으므로 별도 도구 추가 불필요
- raw.githubusercontent.com URL은 public repo에서 인증 없이 접근 가능

### 4.2 에이전트 수정: `agents/bkend-expert.md`

#### 현재 코드 끝부분 (line 211-216)

```markdown
## Reference

- Skills: dynamic (dev guide), bkend-data, bkend-auth, bkend-storage, bkend-cookbook
- MCP Guide Tools: 0_get_context ~ 7_code_examples_data
- Docs: https://github.com/popup-studio-ai/bkend-docs
```

#### 변경 후 코드

```markdown
## Reference

- Skills: dynamic (dev guide), bkend-data, bkend-auth, bkend-storage, bkend-cookbook
- MCP Guide Tools: 0_get_context ~ 7_code_examples_data
- Docs: https://github.com/popup-studio-ai/bkend-docs

## Official Documentation (Live Reference)

When you need the latest bkend documentation, use WebFetch with these URLs:

- **Full TOC**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- **Auth**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/authentication/
- **Database**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/database/
- **Storage**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/storage/
- **Security**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/security/
- **AI Tools/MCP**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/ai-tools/
- **Cookbooks**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/cookbooks/
- **Troubleshooting**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/troubleshooting/

**Usage**: Fetch SUMMARY.md first to find the exact page, then fetch that specific page.
```

#### 변경 상세

- 기존 `## Reference` 섹션 끝에 `## Official Documentation (Live Reference)` 섹션 추가
- 섹션별 raw URL 매핑 제공
- WebFetch 사용 패턴 가이드 (SUMMARY.md → 특정 페이지 순서)

### 4.3 스킬 수정: 5개 bkend 스킬

각 스킬의 **마지막 부분**에 공식 문서 참조 섹션을 추가한다. 모든 스킬은 동일한 패턴을 따른다.

#### 4.3.1 `skills/bkend-quickstart/SKILL.md`

**추가 위치**: 파일 끝 (line 85 이후)

**추가 내용**:
```markdown

## Official Documentation (Live Reference)

For the latest bkend documentation, use WebFetch:
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- Getting Started: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/getting-started/
- AI Tools/MCP: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/ai-tools/
- Console: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/console/
```

#### 4.3.2 `skills/bkend-auth/SKILL.md`

**추가 위치**: 파일 끝

**추가 내용**:
```markdown

## Official Documentation (Live Reference)

For the latest authentication documentation, use WebFetch:
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- Authentication: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/authentication/
- Security: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/security/
```

#### 4.3.3 `skills/bkend-data/SKILL.md`

**추가 위치**: 파일 끝

**추가 내용**:
```markdown

## Official Documentation (Live Reference)

For the latest database documentation, use WebFetch:
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- Database: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/database/
- Guides: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/guides/
```

#### 4.3.4 `skills/bkend-storage/SKILL.md`

**추가 위치**: 파일 끝

**추가 내용**:
```markdown

## Official Documentation (Live Reference)

For the latest storage documentation, use WebFetch:
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- Storage: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/storage/
```

#### 4.3.5 `skills/bkend-cookbook/SKILL.md`

**추가 위치**: 파일 끝

**추가 내용**:
```markdown

## Official Documentation (Live Reference)

For the latest cookbook and troubleshooting, use WebFetch:
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- Cookbooks: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/cookbooks/
- Troubleshooting: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/src/troubleshooting/
```

---

## 5. Unit 4: bkend MCP 설정 가이드 보강

### 5.1 스킬 수정: `skills/bkend-quickstart/SKILL.md`

#### 현재 MCP Setup 섹션 (line 47-55)

```markdown
## MCP Setup (Claude Code)

```bash
claude mcp add bkend --transport http https://api.bkend.ai/mcp
```

- OAuth 2.1 + PKCE (browser auto-auth)
- No API Key needed
- Verify: "Show my connected bkend projects"
```

#### 변경 후 MCP Setup 섹션

```markdown
## MCP Setup (Claude Code)

### Quick Setup (One Command)

```bash
claude mcp add bkend --transport http https://api.bkend.ai/mcp
```

### Step-by-Step Guide

1. **Prerequisites**: bkend.ai account (signup at https://console.bkend.ai)
2. **Run setup command**: `claude mcp add bkend --transport http https://api.bkend.ai/mcp`
3. **OAuth authentication**: Browser auto-opens for OAuth 2.1 + PKCE auth (no API key needed)
4. **Verify connection**: Ask "Show my connected bkend projects" or use `0_get_context` MCP tool
5. **Create .mcp.json** (optional, for team sharing):
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

### Troubleshooting MCP Connection

| Problem | Solution |
|---------|----------|
| OAuth popup not appearing | Check browser popup blocker |
| MCP tools not visible | Run `claude mcp list` to verify, re-add if needed |
| Connection lost | Re-authenticate (automatic on next MCP call) |
| Wrong project/env | Use `0_get_context` to check current session |
```

#### 변경 상세

- 기존 3줄 설명을 **Step-by-Step Guide** + **Troubleshooting** 테이블로 확장
- `.mcp.json` 생성은 optional로 안내 (팀 공유 용도)
- session-start.js의 `.mcp.json` 감지 로직과 호환

---

## 6. Unit 5: 버전/수치 동기화

### 6.1 파일: `bkit.config.json` (line 3)

#### 변경

```
Before: "version": "1.5.2"
After:  "version": "1.5.3"
```

### 6.2 파일: `hooks/hooks.json` (line 3)

#### 변경

```
Before: "description": "bkit Vibecoding Kit v1.5.2 - Claude Code"
After:  "description": "bkit Vibecoding Kit v1.5.3 - Claude Code"
```

### 6.3 파일: `.claude-plugin/marketplace.json`

#### 변경 1: Root version (line 4)

```
Before: "version": "1.5.2"
After:  "version": "1.5.3"
```

#### 변경 2: bkit plugin description (line 36)

현재:
```json
"description": "Vibecoding Kit - PDCA methodology + Claude Code mastery for AI-native development. Includes 21 skills, 11 agents, 39 scripts, and 6 unified hooks for structured development workflows."
```

변경:
```json
"description": "Vibecoding Kit - PDCA methodology + CTO-Led Agent Teams + Claude Code mastery for AI-native development. Includes 26 skills, 16 agents, 45 scripts, 10 hook events, and 4 output styles for structured development workflows."
```

변경 상세:
| 항목 | Before | After | 실제 수치 근거 |
|------|--------|-------|--------------|
| Skills | 21 | 26 | `skills/` 디렉토리 26개 확인 |
| Agents | 11 | 16 | `agents/` 디렉토리 16개 확인 |
| Scripts | 39 | 45 | `scripts/` 디렉토리 45개 확인 |
| Hooks | 6 unified hooks | 10 hook events | `hooks.json` 10개 이벤트 |
| Output Styles | (없음) | 4 output styles | `output-styles/` 4개 파일 |
| CTO-Led Agent Teams | (없음) | 추가 | v1.5.1에서 도입 |

#### 변경 3: bkit plugin version (line 42)

```
Before: "version": "1.5.2"
After:  "version": "1.5.3"
```

### 6.4 session-start.js 버전 참조 (Unit 2에서 통합)

session-start.js의 모든 v1.5.2 참조를 v1.5.3으로 변경 (총 3곳):
- line 549: `## Output Styles (v1.5.2)` → `## Output Styles (v1.5.3)`
- line 605: `bkit Feature Usage Report (v1.5.2` → `bkit Feature Usage Report (v1.5.3`
- line 661: `bkit Vibecoding Kit v1.5.2 activated` → `bkit Vibecoding Kit v1.5.3 activated`

---

## 7. Unit 6: CLAUDE.md 전략 문서화

### 7.1 파일: `commands/bkit.md`

#### 현재 코드 끝부분 (line 161-170)

```markdown
### v1.5.1 Features

| Feature | Activation | Description |
|---------|-----------|-------------|
| Agent Teams | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Multi-agent parallel PDCA execution |
| Agent Memory | Automatic | Agents remember context across sessions |
| Output Styles | `/output-style` | Custom response formatting |
| TaskCompleted Hook | Automatic | Auto-advance PDCA phases on task completion |
| TeammateIdle Hook | Automatic | Assign work to idle teammates |
```

#### 변경: 기존 내용 유지 + 아래 섹션 추가

```markdown

### v1.5.3 Features

| Feature | Activation | Description |
|---------|-----------|-------------|
| Output Style Setup | `/output-style-setup` | Install bkit output styles to .claude/ |
| bkend Docs Reference | Automatic | bkend-expert fetches latest docs via WebFetch |
| SubagentStart/Stop | Automatic | Track team agent spawn/stop events |
| Team State Writer | Automatic | Write agent state to .bkit/agent-state.json |

### Output Styles (4 styles)

| Style | Level | Description |
|-------|-------|-------------|
| bkit-learning | Starter | Learning mode with educational insights |
| bkit-pdca-guide | Dynamic | PDCA badges, checklists, phase tracking |
| bkit-enterprise | Enterprise | CTO perspective, architecture analysis |
| bkit-pdca-enterprise | Enterprise | PDCA + CTO combined (most detailed) |

**Setup**: Styles are auto-available when bkit is installed as a plugin.
If not visible in `/output-style` menu, run `/output-style-setup`.

### CLAUDE.md and bkit

bkit does NOT provide a CLAUDE.md file. Reasons:
- bkit provides dynamic context via Hooks, Skills, Agents, and Output Styles
- CLAUDE.md is for project-specific rules that the project owner writes
- bkit's SessionStart hook injects PDCA state, level detection, and trigger tables
- This is more token-efficient than static CLAUDE.md (injected once vs every turn)

If you need help writing your project's CLAUDE.md, use `/claude-code-learning`.
```

#### 변경: Output Styles 섹션 업데이트 (line 153-159)

현재:
```markdown
### Output Styles (3, select via /output-style)

| Style | Best For | Description |
|-------|----------|-------------|
| bkit-pdca-guide | Dynamic projects | PDCA badges, gap analysis suggestions, checklists |
| bkit-learning | Starter projects | Learning points, TODO(learner) markers |
| bkit-enterprise | Enterprise projects | Architecture tradeoffs, cost analysis |
```

변경:
```markdown
### Output Styles (4, select via /output-style)

| Style | Best For | Description |
|-------|----------|-------------|
| bkit-learning | Starter projects | Learning points, educational insights |
| bkit-pdca-guide | Dynamic projects | PDCA badges, checklists, phase tracking |
| bkit-enterprise | Enterprise projects | Architecture tradeoffs, cost analysis |
| bkit-pdca-enterprise | Enterprise projects | PDCA + CTO combined perspective |
```

---

## 8. 전체 변경 파일 목록 (최종)

### 8.1 수정 파일 (11개)

| # | File | Lines Changed | Change Summary |
|---|------|:------------:|----------------|
| 1 | `.claude-plugin/plugin.json` | 2 | version 1.5.3 + outputStyles 추가 |
| 2 | `.claude-plugin/marketplace.json` | 3 | version 1.5.3 + description 수치 최신화 |
| 3 | `bkit.config.json` | 1 | version 1.5.3 |
| 4 | `hooks/hooks.json` | 1 | description v1.5.3 |
| 5 | `hooks/session-start.js` | 5 | v1.5.3 참조 3곳 + output-style 안내 + 4번째 스타일 |
| 6 | `commands/bkit.md` | ~30 | Output Styles 4종 + v1.5.3 Features + CLAUDE.md 전략 |
| 7 | `agents/bkend-expert.md` | ~12 | Official Documentation 섹션 추가 |
| 8 | `skills/bkend-quickstart/SKILL.md` | ~25 | MCP 가이드 보강 + 문서 참조 URL |
| 9 | `skills/bkend-auth/SKILL.md` | ~6 | 문서 참조 URL 추가 |
| 10 | `skills/bkend-data/SKILL.md` | ~6 | 문서 참조 URL 추가 |
| 11 | `skills/bkend-storage/SKILL.md` | ~5 | 문서 참조 URL 추가 |

### 8.2 수정 파일 (추가 1개)

| # | File | Lines Changed | Change Summary |
|---|------|:------------:|----------------|
| 12 | `skills/bkend-cookbook/SKILL.md` | ~6 | 문서 참조 URL 추가 |

### 8.3 신규 파일 (2개)

| # | File | Lines | Description |
|---|------|:-----:|-------------|
| 13 | `commands/output-style-setup.md` | ~45 | Output Style 수동 설치 커맨드 |
| 14 | `.claude/agent-memory/bkit-bkend-expert/MEMORY.md` | ~45 | bkend 에이전트 문서 참조 메모리 |

### 8.4 변경 없음 (확인만)

| File | Status | Note |
|------|--------|------|
| `output-styles/bkit-learning.md` | `keep-coding-instructions: true` 확인 | 변경 불필요 |
| `output-styles/bkit-pdca-guide.md` | `keep-coding-instructions: true` 확인 | 변경 불필요 |
| `output-styles/bkit-enterprise.md` | `keep-coding-instructions: true` 확인 | 변경 불필요 |
| `output-styles/bkit-pdca-enterprise.md` | `keep-coding-instructions: true` 확인 | 변경 불필요 |
| `lib/common.js` | v1.5.3 @version, 180 exports | 이미 최신 (GAP-01 수정 완료) |
| `CLAUDE.md` | 미생성 | 의도적 미제공 (Plan 3.1절 결정) |
| `.mcp.json` | 미생성 | 사용자 주도 생성 (Plan 3.2절 결정) |

---

## 9. Implementation Order

```
Phase 1 (독립 작업 - 병렬 가능)
├── Unit 1: plugin.json 수정
├── Unit 3: bkend 문서 참조 (agent memory + 5 skills + 1 agent)
├── Unit 4: bkend MCP 가이드 (bkend-quickstart 스킬)
└── Unit 6: CLAUDE.md 전략 (commands/bkit.md)

Phase 2 (Unit 1 완료 후 - 병렬 가능)
├── Unit 2: output-style-setup 커맨드 + session-start.js 수정
└── Unit 5: 버전/수치 동기화 (4개 config + session-start.js)
```

Note: Unit 4와 Unit 3의 bkend-quickstart 수정은 동일 파일을 대상으로 하므로 순서를 유의. Unit 4의 MCP 가이드 보강과 Unit 3의 문서 참조 URL은 서로 다른 섹션이므로 병합 가능.

---

## 10. Verification Matrix

| TC ID | Unit | Verification | Expected |
|-------|:----:|-------------|----------|
| ENH-U1-01 | 1 | `cat .claude-plugin/plugin.json \| grep outputStyles` | `"outputStyles": "./output-styles/"` |
| ENH-U1-02 | 1 | `cat .claude-plugin/plugin.json \| grep version` | `"version": "1.5.3"` |
| ENH-U1-03 | 1 | `ls output-styles/*.md \| wc -l` | 4 |
| ENH-U2-01 | 2 | `test -f commands/output-style-setup.md` | exists |
| ENH-U2-02 | 2 | `grep user-invocable commands/output-style-setup.md` | `true` |
| ENH-U2-03 | 2 | `grep keep-coding-instructions output-styles/*.md \| wc -l` | 4 |
| ENH-U2-04 | 2 | `grep "v1.5.3" hooks/session-start.js \| wc -l` | 3 |
| ENH-U2-05 | 2 | `grep "output-style-setup" hooks/session-start.js` | found |
| ENH-U3-01 | 3 | `test -f .claude/agent-memory/bkit-bkend-expert/MEMORY.md` | exists |
| ENH-U3-02 | 3 | `grep "SUMMARY.md" .claude/agent-memory/bkit-bkend-expert/MEMORY.md` | found |
| ENH-U3-03 | 3 | `grep "Official Documentation" agents/bkend-expert.md` | found |
| ENH-U3-04 | 3 | `grep "raw.githubusercontent" skills/bkend-quickstart/SKILL.md` | found |
| ENH-U3-05 | 3 | `grep "raw.githubusercontent" skills/bkend-auth/SKILL.md` | found |
| ENH-U3-06 | 3 | `grep "raw.githubusercontent" skills/bkend-data/SKILL.md` | found |
| ENH-U3-07 | 3 | `grep "raw.githubusercontent" skills/bkend-storage/SKILL.md` | found |
| ENH-U3-08 | 3 | `grep "raw.githubusercontent" skills/bkend-cookbook/SKILL.md` | found |
| ENH-U4-01 | 4 | `grep "Step-by-Step" skills/bkend-quickstart/SKILL.md` | found |
| ENH-U4-02 | 4 | `grep "Troubleshooting MCP" skills/bkend-quickstart/SKILL.md` | found |
| ENH-U5-01 | 5 | `grep '"1.5.3"' bkit.config.json` | found |
| ENH-U5-02 | 5 | `grep "v1.5.3" hooks/hooks.json` | found |
| ENH-U5-03 | 5 | `grep '"1.5.3"' .claude-plugin/marketplace.json \| wc -l` | 2 |
| ENH-U5-04 | 5 | `grep "26 skills" .claude-plugin/marketplace.json` | found |
| ENH-U5-05 | 5 | `grep "16 agents" .claude-plugin/marketplace.json` | found |
| ENH-U6-01 | 6 | `grep "CLAUDE.md and bkit" commands/bkit.md` | found |
| ENH-U6-02 | 6 | `grep "bkit-pdca-enterprise" commands/bkit.md` | found |
| ENH-U6-03 | 6 | `grep "v1.5.3 Features" commands/bkit.md` | found |
| REG-01 | - | `node -e "console.log(Object.keys(require('./lib/common')).length)"` | >= 180 |
| REG-02 | - | `ls skills/*/SKILL.md \| wc -l` | 26 |
| REG-03 | - | `ls agents/*.md \| wc -l` | 16 |
| REG-04 | - | `node -e "const h=require('./hooks/hooks.json');console.log(Object.keys(h.hooks).length)"` | 10 |
| REG-05 | - | `grep "keep-coding-instructions: true" output-styles/*.md \| wc -l` | 4 |

**Total TC: 31 (신규 26 + 회귀 5)**

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-10 | Initial design - 6 units, 14 files, 31 TC | CTO Lead (Claude Opus 4.6) |
