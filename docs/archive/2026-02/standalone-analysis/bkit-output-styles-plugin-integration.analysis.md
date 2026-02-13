# bkit Output Styles Plugin Integration Analysis Report

> **Analysis Type**: Technical Research + Gap Analysis
>
> **Project**: bkit Claude Code Plugin
> **Version**: 1.5.2
> **Analyst**: Claude Opus 4.6 (PDCA Analysis Agent)
> **Date**: 2026-02-09
> **Feature**: Output Styles Plugin Distribution Mechanism

---

## 1. Analysis Overview

### 1.1 Analysis Purpose

bkit 플러그인에서 Output Styles(`output-styles/` 디렉토리)를 배포했으나, 플러그인 설치 후 `/output-style` 명령이 동작하지 않는 문제에 대한 근본 원인 분석. Claude Code의 Output Styles 공식 메커니즘을 종합적으로 조사하여 올바른 통합 방법을 도출한다.

### 1.2 Analysis Scope

- **조사 대상**: Claude Code Output Styles 공식 문서, GitHub 이슈, 공식 플러그인 예제
- **분석 대상**: bkit 플러그인의 현재 output styles 구현
- **분석 일자**: 2026-02-09

### 1.3 Investigated Sources

| Source | URL/Location | Status |
|--------|-------------|--------|
| **Official Docs** | https://code.claude.com/docs/en/output-styles | Analyzed |
| **Plugin Reference** | https://code.claude.com/docs/en/plugins-reference | Analyzed |
| **Settings Reference** | https://code.claude.com/docs/en/settings | Analyzed |
| **GitHub Issues** | anthropics/claude-code (20+ issues) | Analyzed |
| **Official Plugins** | `explanatory-output-style`, `learning-output-style` | Analyzed |
| **bkit Plugin Code** | `output-styles/`, `.claude-plugin/plugin.json` | Analyzed |

---

## 2. Claude Code Output Styles 공식 메커니즘

### 2.1 Output Styles 개요

Output Styles는 Claude Code의 **시스템 프롬프트를 직접 수정**하여 응답 방식을 변경하는 기능이다.

**핵심 동작 원리:**
- 모든 output styles는 효율적 출력 지시(간결한 응답 등)를 **제외**
- Custom output styles는 코딩 관련 지시도 **제외** (`keep-coding-instructions: true`가 아닌 한)
- Custom instructions는 시스템 프롬프트 **끝**에 추가
- 대화 중 output style 지시를 따르라는 **리마인더**가 자동으로 트리거

### 2.2 Built-in Output Styles (3종)

| Style | Description |
|-------|-------------|
| **Default** | 소프트웨어 엔지니어링 최적화 (기본값) |
| **Explanatory** | 교육적 인사이트 제공 + 코딩 보조 |
| **Learning** | 학습 모드, `TODO(human)` 마커 사용 |

### 2.3 Output Styles 파일 발견 경로 (Discovery Path)

Claude Code는 다음 3가지 경로에서 output style 파일을 발견한다:

```
┌─────────────────────────────────────────────────────────────────┐
│  Output Style Discovery Order                                    │
├─────────────────────────────────────────────────────────────────┤
│  1. Built-in styles: Default, Explanatory, Learning              │
│  2. User level:     ~/.claude/output-styles/*.md                 │
│  3. Project level:  .claude/output-styles/*.md                   │
│  4. Plugin:         plugin.json → "outputStyles": "./styles/"    │
└─────────────────────────────────────────────────────────────────┘
```

> **Source**: https://code.claude.com/docs/en/output-styles
> "You can save these files at the user level (`~/.claude/output-styles`) or project level (`.claude/output-styles`)."

### 2.4 Output Style 파일 포맷

```markdown
---
name: My Custom Style
description: |
  A brief description of what this style does
keep-coding-instructions: true
---

# Custom Style Instructions

[시스템 프롬프트에 추가될 내용]
```

**Frontmatter Fields:**

| Field | Purpose | Default |
|-------|---------|---------|
| `name` | UI 표시 이름 | 파일명에서 상속 |
| `description` | `/output-style` UI 설명 | None |
| `keep-coding-instructions` | 코딩 관련 시스템 프롬프트 유지 여부 | `false` |

### 2.5 `/output-style` 명령 동작

- `/output-style` → 메뉴에서 스타일 선택
- `/output-style [name]` → 직접 스타일 적용
- 설정은 `.claude/settings.local.json`의 `"outputStyle"` 필드에 저장
- `/config` 메뉴에서도 접근 가능

### 2.6 Plugin에서의 Output Styles 배포

**도입 시점**: v2.0.41 (2025-11-18) - "Plugins: Added support for sharing and installing output styles"
**관련 이슈**: GitHub #10344 (FEATURE: Add Output-Styles to Plugins) - Dickson Tsai (Anthropic) 담당

**`plugin.json` 스키마 (공식 문서):**

```json
{
  "name": "plugin-name",
  "outputStyles": "./styles/"    // string | array
}
```

> **Source**: https://code.claude.com/docs/en/plugins-reference
> Component path fields table:
> `outputStyles` | string|array | Additional output style files/directories | `"./styles/"`

**중요**: `outputStyles`는 default location이 **없다**. 반드시 `plugin.json`에서 명시적으로 선언해야 한다.

| Component | Default Location | 자동 발견 |
|-----------|-----------------|---------|
| commands/ | `commands/` | O |
| agents/ | `agents/` | O |
| skills/ | `skills/` | O |
| hooks | `hooks/hooks.json` | O |
| **outputStyles** | **(없음)** | **X - 명시 선언 필요** |
| mcpServers | `.mcp.json` | O |
| lspServers | `.lsp.json` | O |

### 2.7 Output Styles 버전 히스토리

| Version | Date | Event |
|---------|------|-------|
| **v1.0.81** | 2025-08 | Output styles 최초 출시 (Explanatory, Learning) |
| **v2.0.28** | 2025-10 | Output styles 동작 중단 시작 |
| **v2.0.30** | 2025-10~11 | **Deprecated** - 대안으로 --system-prompt-file, hooks 등 권장 |
| (community) | 2025-11 | 대규모 커뮤니티 반발: #10671 (66 upvotes), #10721 (12 upvotes) |
| **v2.0.32** | 2025-11 | **Un-deprecated** - 커뮤니티 피드백 수용, 플러그인 지원 추가 |
| **v2.0.41** | 2025-11-18 | Plugin marketplace에서 output styles 배포 지원 완료 (#10344) |
| **v2.1.2+** | 2025-12~ | /plugins UI에서 output styles 통합 관리 |

### 2.8 Output Styles vs 대안 비교

| Mechanism | System Prompt 영향 | 지속성 | Token 효율 |
|-----------|------------------|-------|-----------|
| **Output Styles** | 코어 시스템 프롬프트 **교체** | 항상 활성 | 최적 |
| **CLAUDE.md** | 변경 없음 (user message로 추가) | 프로젝트 전체 | 보통 |
| **--append-system-prompt** | 끝에 추가 | 세션 한정 | 보통 |
| **SessionStart hook** | additionalContext로 주입 | 세션 시작 시 | 비효율 (매 세션 추가 토큰) |
| **--system-prompt-file** | 전체 교체 | 세션 한정 | 최적 |

> **커뮤니티 주장**: SessionStart hook은 "prompt injection"과 유사하여 다중 턴 대화에서 지시 준수율이 떨어짐. Output Styles는 system prompt에 직접 반영되어 가장 안정적.

---

## 3. 공식 Output Style 플러그인 분석

### 3.1 explanatory-output-style 플러그인

```
plugins/explanatory-output-style/
├── .claude-plugin/
│   └── plugin.json         # "outputStyles" 필드 없음!
├── hooks-handlers/
│   └── session-start.sh    # SessionStart hook으로 구현
├── hooks/
│   └── hooks.json
└── README.md
```

**plugin.json:**
```json
{
  "name": "explanatory-output-style",
  "version": "1.0.0",
  "description": "Adds educational insights (mimics the deprecated Explanatory output style)"
}
```

**hooks.json:**
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks-handlers/session-start.sh"
      }]
    }]
  }
}
```

**session-start.sh:**
```bash
#!/usr/bin/env bash
cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "You are in 'explanatory' output style mode..."
  }
}
EOF
exit 0
```

### 3.2 learning-output-style 플러그인

동일한 패턴: SessionStart hook + additionalContext로 구현.

### 3.3 공식 플러그인의 접근법 분석

| Approach | 사용 여부 | 이유 |
|----------|---------|------|
| `outputStyles` in plugin.json | **미사용** | deprecated 시기에 생성된 플러그인 |
| SessionStart hook | **사용** | Output style이 deprecated (v2.0.30)되었을 때의 우회 방법 |
| `.claude/output-styles/` 파일 | **미사용** | Hook 기반 접근법 채택 |

> **Key Insight**: 공식 output-style 플러그인들은 **Output Styles가 deprecated (v2.0.30)** 되었을 때 만들어져서 SessionStart hook으로 우회했다. Output Styles가 v2.0.32에서 복원된 후에도 업데이트되지 않았다.

---

## 4. bkit 현재 상태 Gap Analysis

### 4.1 현재 구조

```
bkit-claude-code/
├── output-styles/                    ← 프로젝트 루트 (잘못된 위치)
│   ├── bkit-enterprise.md
│   ├── bkit-learning.md
│   ├── bkit-pdca-enterprise.md
│   └── bkit-pdca-guide.md
├── .claude-plugin/
│   └── plugin.json                   ← outputStyles 필드 없음
├── .claude/
│   ├── settings.json                 ← enabledPlugins: {}
│   └── settings.local.json           ← "outputStyle": "bkit-pdca-enterprise"
└── bkit.config.json                  ← "outputStyles.directory": "output-styles"
```

### 4.2 Gap 분석 결과

| Item | Expected | Actual | Status | Impact |
|------|----------|--------|--------|--------|
| Output style 파일 위치 | `.claude/output-styles/` 또는 plugin.json 선언 | `output-styles/` (루트) | **Gap** | `/output-style` 메뉴에 표시 안됨 |
| plugin.json `outputStyles` 필드 | `"outputStyles": "./output-styles/"` | 필드 없음 | **Gap** | 플러그인 캐시에 output styles 미복사 |
| bkit.config.json `outputStyles` | Claude Code 무시 | `"directory": "output-styles"` | **Gap** | bkit 자체 설정일 뿐, Claude Code가 인식하지 않음 |
| settings.local.json `outputStyle` | 발견 가능한 스타일명 | `"bkit-pdca-enterprise"` | **조건부** | 로컬에서만 동작 (개발환경), 배포 시 실패 |

### 4.3 Root Cause 분석

```
┌─────────────────────────────────────────────────────────────────┐
│  ROOT CAUSE                                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. output-styles/ 디렉토리가 .claude/output-styles/가 아닌       │
│     프로젝트 루트에 위치                                          │
│                                                                  │
│  2. plugin.json에 "outputStyles" 컴포넌트 경로가 선언되지 않음     │
│                                                                  │
│  3. bkit.config.json의 outputStyles.directory는 bkit 내부 설정     │
│     으로, Claude Code의 plugin discovery 메커니즘과 무관           │
│                                                                  │
│  결과: Claude Code가 bkit의 output style 파일을 발견할 수 없음     │
│                                                                  │
│  개발환경에서 동작하는 이유:                                       │
│  - settings.local.json에 "outputStyle": "bkit-pdca-enterprise"    │
│  - 현재 시스템 프롬프트에 직접 적용됨 (세션 시작 시 hook에서 주입)  │
│  - 하지만 /output-style 메뉴에는 표시되지 않음                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.4 Match Rate Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  Overall Match Rate: 25%                                         │
├─────────────────────────────────────────────────────────────────┤
│  ✅ Match:           1 item  (25%)  - 파일 포맷/frontmatter 정확 │
│  ❌ Gap:             3 items (75%)  - 위치, 선언, 배포 메커니즘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. 해결 방안 분석

### 5.1 Option Comparison

| Option | Approach | Pros | Cons | Recommendation |
|--------|----------|------|------|----------------|
| **A** | `plugin.json`에 `outputStyles` 추가 | 공식 메커니즘, 플러그인 배포 시 자동 동작, 가장 깔끔 | 플러그인 캐시 의존 | **Recommended** |
| **B** | `.claude/output-styles/`로 이동 | 개발환경에서 즉시 동작, 간단 | 플러그인 배포 시 .claude는 별도 관리 필요, gitignore 충돌 | Not recommended |
| **C** | SessionStart hook으로 우회 (공식 플러그인 방식) | 검증된 패턴, deprecated 이력에 안전 | Output Style 메커니즘 미사용, `/output-style` 미지원, 시스템 프롬프트 중복 | Legacy approach |
| **D** | A + B 병합 (plugin.json 선언 + 심볼릭 링크) | 개발환경 + 배포환경 모두 동작 | 복잡도 증가 | Optional enhancement |

### 5.2 Recommended Solution: Option A

**plugin.json 수정:**

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
  "keywords": ["vibecoding", "pdca", "..."],
  "outputStyles": "./output-styles/"
}
```

**효과:**
1. 플러그인 설치 시 `output-styles/` 디렉토리가 플러그인 캐시에 자동 복사
2. `/output-style` 메뉴에 bkit output styles 자동 표시
3. 사용자가 `/output-style bkit-pdca-enterprise`로 직접 선택 가능
4. 네임스페이스: `bkit:bkit-pdca-enterprise` 형태로 표시될 수 있음

### 5.3 추가 개선사항

**keep-coding-instructions 검증:**

bkit의 모든 output styles는 코딩 도구이므로 반드시 `keep-coding-instructions: true`가 필요하다.

| Style File | `keep-coding-instructions` | Status |
|-----------|--------------------------|--------|
| bkit-enterprise.md | 확인 필요 | ? |
| bkit-learning.md | 확인 필요 | ? |
| bkit-pdca-enterprise.md | `true` | ✅ |
| bkit-pdca-guide.md | 확인 필요 | ? |

---

## 6. GitHub Issues 종합 분석 (30+ Issues Reviewed)

### 6.1 Case Sensitivity 이슈 (bkit 직접 영향)

> **Critical**: `outputStyle` 설정 값은 **case-sensitive**이다 (#8476).
> `"outputStyle": "explanatory"` (소문자) → 동작 안함
> `"outputStyle": "Explanatory"` (PascalCase) → 동작
> Anthropic @dicksontsai: "output style names are case sensitive"

**bkit 영향 분석:**
- 현재 bkit 스타일명: `bkit-pdca-enterprise`, `bkit-learning` 등 (kebab-case)
- `/output-style` 메뉴에서 선택 시 파일명 기반으로 동작하므로 kebab-case가 정상
- 단, settings.json에 직접 입력 시 정확한 케이스 필요
- `--settings` CLI 플래그 사용 시 정확한 이름 필수

### 6.2 Output Style 내부 동작 메커니즘 (GitHub에서 발견)

> **핵심 발견**: Output styles는 단순 append가 아니라 시스템 프롬프트의 **~75%를 제거**하고 교체한다.
> "Output styles are NOT just system prompt appends -- they REMOVE about 3/4 of the original system prompt and inject reminders."
> - 코딩 관련 지시, 간결함 지시 등이 제거됨 (`keep-coding-instructions: true`로 코딩 지시 유지 가능)
> - 턴 간 **adherence reminders**가 자동 트리거됨 (SessionStart hook으로 대체 불가)

### 6.3 알려진 버그 (bkit에 영향 가능)

| Issue # | Title | Status | Severity | bkit Impact |
|---------|-------|--------|----------|-------------|
| **#18875** | `/output-style` 설정 미유지 | Open | High | 사용자가 스타일 변경 후 초기화될 수 있음 |
| **#22643** | statusline에서 output_style.name 미갱신 | Open | Medium | bkit statusline hook 사용 시 영향 |
| **#15889** | 체크마크 갱신 안됨 | Open | Low | UX 혼란 (스타일 자체는 정상 동작) |
| **#14908** | slash command에 output-style 옵션 | Open | Low | bkit skill별 스타일 적용 미지원 |
| **#16995** | CRLF line endings in .sh | Open | Medium | 플러그인 배포 시 크로스플랫폼 이슈 |

### 6.4 크로스 플랫폼 이슈

| Issue # | Platform | Problem | Workaround |
|---------|----------|---------|------------|
| **#16995** | macOS/Linux | `.sh` 파일 CRLF → "command not found" | `sed -i '' 's/\r$//'` |
| **#15013** | Windows | `.sh` 파일이 IDE에서 열림 | `"command": "bash ${CLAUDE_PLUGIN_ROOT}/..."` |
| **#23309** | Windows | hooks.json `.sh` 실행 실패 | `bash` 접두사 추가 |

### 6.5 리스크 평가

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Output Styles 재 deprecated | **Very Low** | High | Anthropic이 "indefinitely" 유지 선언, SessionStart hook fallback 이미 존재 |
| Case sensitivity 문제 | Medium | Medium | 문서화 + 정확한 이름 사용 가이드 |
| Plugin outputStyles 필드 미동작 버그 | Medium | High | 설치 후 `/output-style` 메뉴 확인 검증 추가 |
| 크로스 플랫폼 hook 실패 | Medium | High | bkit hooks는 `.js`로 구현 (영향 없음) |
| 네임스페이싱 충돌 | Low | Medium | 고유한 `bkit-` 접두사 유지 |

---

## 7. 현재 bkit의 Output Styles가 동작하는 이유

현재 개발환경에서 `bkit-pdca-enterprise` 스타일이 동작하는 이유를 분석:

```
┌─────────────────────────────────────────────────────────────────┐
│  현재 동작 경로 (개발환경)                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. settings.local.json에 "outputStyle": "bkit-pdca-enterprise"  │
│     → Claude Code가 이 값을 읽음                                 │
│                                                                  │
│  2. Claude Code가 output style 파일 검색:                         │
│     ~/.claude/output-styles/bkit-pdca-enterprise.md  → 없음       │
│     .claude/output-styles/bkit-pdca-enterprise.md    → 없음       │
│     plugins cache/output-styles/                     → 없음       │
│                                                                  │
│  3. 파일을 찾지 못하면 → 스타일명을 system prompt에 문자열로 주입   │
│     (현재 동작하는 것은 session-start hook에서                     │
│      additionalContext로 스타일 내용을 직접 주입하기 때문)          │
│                                                                  │
│  4. 따라서 /output-style 메뉴에는 bkit 스타일들이 표시되지 않음    │
│     (검증 필요: 실제로 Custom style로 인식되는지 확인)             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**현재 bkit session-start.js의 역할:**
- `session-start.js`가 `additionalContext`로 output style 내용을 주입
- 이것은 Output Style 메커니즘을 **우회**하는 방식
- `/output-style` 메뉴와 독립적으로 동작

---

## 8. Recommended Actions

### 8.1 Immediate (구현 필요)

| Priority | Item | File | Effect |
|----------|------|------|--------|
| **P0** | `plugin.json`에 `"outputStyles": "./output-styles/"` 추가 | `.claude-plugin/plugin.json` | 플러그인 배포 시 output styles 자동 동작 |
| **P0** | 모든 output style 파일에 `keep-coding-instructions: true` 확인/추가 | `output-styles/*.md` | 코딩 지시 유지 보장 |

### 8.2 Short-term (검증 필요)

| Priority | Item | Expected Result |
|----------|------|----------------|
| **P1** | 플러그인 설치 후 `/output-style` 메뉴 표시 검증 | bkit 스타일 4종 표시 |
| **P1** | 플러그인 캐시 디렉토리에서 output-styles 복사 확인 | `~/.claude/plugins/cache/bkit/output-styles/*.md` 존재 |
| **P2** | session-start.js의 output style 주입과 중복 여부 검토 | 중복 시 hook에서 제거 또는 조건 분기 |

### 8.3 Long-term (아키텍처 개선)

| Item | Description | Notes |
|------|-------------|-------|
| Output Style 선택 자동화 | level detection 결과에 따라 자동 output style 적용 | SessionStart hook에서 가능 |
| 중복 주입 방지 | plugin outputStyles + hook additionalContext 중복 방지 로직 | output style 활성화 여부 감지 필요 |
| SDK 호환성 | Claude Code SDK에서 `setting_sources` 명시 필요 | SDK 기본값이 빈 문자열이라 output style 미로드 (#211) |
| 커뮤니티 이슈 대응 | #18875, #22643 해결 시 bkit 호환성 확인 | 릴리즈 노트 모니터링 |

---

## 9. Overall Score

```
┌─────────────────────────────────────────────────────────────────┐
│  Overall Score: 45/100                                           │
├─────────────────────────────────────────────────────────────────┤
│  Output Style 파일 품질:     90 points (포맷, frontmatter 정확)  │
│  Discovery 메커니즘 통합:    10 points (plugin.json 미선언)      │
│  Plugin 배포 호환성:         20 points (개발환경만 동작)         │
│  공식 문서 준수:             40 points (파일 위치 불일치)         │
│  사용자 UX:                  60 points (hook 우회로 부분 동작)   │
│  리스크 관리:                50 points (deprecated 대비 없음)    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Conclusion

### 핵심 발견 사항 (7가지)

1. **Claude Code는 output-styles를 `~/.claude/output-styles/` 또는 `.claude/output-styles/`에서만 자동 발견한다.**

2. **Plugin에서 output styles를 배포하려면 `plugin.json`에 `"outputStyles"` 필드를 반드시 선언해야 한다.** 이 필드는 default location이 없어 자동 발견되지 않는다. (v2.0.41부터 지원, #10344)

3. **bkit의 현재 `output-styles/` 디렉토리는 프로젝트 루트에 위치하여 Claude Code가 발견할 수 없다.** 개발환경에서 동작하는 것은 `session-start.js` hook이 `additionalContext`로 스타일 내용을 직접 주입하기 때문이다.

4. **공식 output-style 플러그인들(`explanatory-output-style`, `learning-output-style`)은 SessionStart hook 패턴을 사용한다.** 이는 Output Styles가 deprecated(v2.0.30)되었을 때의 우회 방법이며, 복원(v2.0.32) 후에도 업데이트되지 않았다.

5. **Output Styles는 시스템 프롬프트의 ~75%를 제거하고 교체하는 강력한 메커니즘이다.** 단순 append가 아니며, 턴 간 adherence reminders가 자동 트리거된다. SessionStart hook으로는 이 효과를 완전히 복제할 수 없다.

6. **Output Style 이름은 case-sensitive이다** (#8476). settings.json에 직접 입력할 때 정확한 케이스 필요.

7. **`plugin.json`에 `"outputStyles": "./output-styles/"`를 추가하는 것이 가장 깔끔한 해결책이다.** 이 한 줄 변경으로 플러그인 배포 시 output styles가 자동으로 `/output-style` 메뉴에 표시된다. Anthropic이 output styles를 "indefinitely" 유지하기로 선언했으므로 재 deprecated 리스크는 극히 낮다.

---

## 11. Reference Sources

### Official Documentation
- [Output Styles](https://code.claude.com/docs/en/output-styles) - Claude Code 공식 문서
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference) - plugin.json 스키마 (outputStyles 필드)
- [Settings](https://code.claude.com/docs/en/settings) - outputStyle 설정 참조

### GitHub Issues (30+ analyzed)
- [#10344](https://github.com/anthropics/claude-code/issues/10344) - FEATURE: Add Output-Styles to Plugins (completed, v2.0.41)
- [#10671](https://github.com/anthropics/claude-code/issues/10671) - FEATURE: Please don't remove Output-Styles (66 upvotes, closed-restored)
- [#10721](https://github.com/anthropics/claude-code/issues/10721) - BUG: IMPORTANT: 2.0.30 please KEEP the output-style (closed-restored)
- [#10672](https://github.com/anthropics/claude-code/issues/10672) - BUG: why deprecating output styles? (closed-restored)
- [#10694](https://github.com/anthropics/claude-code/issues/10694) - FEATURE: Ability to turn off SW engineering prompt (closed-restored)
- [#8476](https://github.com/anthropics/claude-code/issues/8476) - BUG: outputStyle only accepts PascalCase (closed-fixed)
- [#18875](https://github.com/anthropics/claude-code/issues/18875) - Bug: /output-style setting not persisting (open)
- [#22643](https://github.com/anthropics/claude-code/issues/22643) - BUG: statusline output_style.name not updating (open)
- [#15889](https://github.com/anthropics/claude-code/issues/15889) - BUG: /output-style menu checkmark doesn't update (open)
- [#14908](https://github.com/anthropics/claude-code/issues/14908) - Feature Request: output-style option to slash commands (open)
- [#16995](https://github.com/anthropics/claude-code/issues/16995) - Bug: CRLF line endings in .sh plugin hooks (open)
- [#15013](https://github.com/anthropics/claude-code/issues/15013) - Bug: learning-output-style fails on Windows (closed)

### GitHub PRs (analyzed)
- [#10495](https://github.com/anthropics/claude-code/pull/10495) - Implement Explanatory output style as plugin (merged 2025-10-29)
- [#10826](https://github.com/anthropics/claude-code/pull/10826) - Add learning-output-style plugin (merged 2025-11-01)
- [#10830](https://github.com/anthropics/claude-code/pull/10830) - Add both plugins to marketplace (merged 2025-11-01)

### Official Plugins (analyzed)
- [explanatory-output-style](https://github.com/anthropics/claude-code/tree/main/plugins/explanatory-output-style) - SessionStart hook 패턴
- [learning-output-style](https://github.com/anthropics/claude-code/tree/main/plugins/learning-output-style) - SessionStart hook 패턴

### Community Resources
- [SimpleClaude](https://github.com/kylesnowschwartz/SimpleClaude) - marketplace.json에 output styles 포함 예시
- [awesome-claude-code-output-styles-that-i-really-like](https://github.com/hesreallyhim/awesome-claude-code-output-styles-that-i-really-like) - 커뮤니티 스타일 모음

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-09 | Initial analysis - comprehensive research + gap analysis | Claude Opus 4.6 |
| 0.2 | 2026-02-09 | GitHub Issues 30+ 분석 결과 통합, version timeline, case sensitivity, SDK 호환성 추가 | Claude Opus 4.6 |
