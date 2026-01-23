# Trigger Matrix

> Core matrix showing which components trigger on each event (v1.4.0)
>
> **v1.4.0**: Dual Platform Support (Claude Code + Gemini CLI)

## Platform Hook Mapping (v1.4.0)

| Hook Event | Claude Code | Gemini CLI | Description |
|------------|-------------|------------|-------------|
| Session initialization | `SessionStart` | `SessionStart` | 세션 시작 |
| Before tool execution | `PreToolUse` | `BeforeTool` | 도구 실행 전 |
| After tool execution | `PostToolUse` | `AfterTool` | 도구 실행 후 |
| Agent completion | `Stop` | `AgentStop` | 에이전트 완료 |

---

## Hook Event Matrix

### hooks.json (Global Hooks)

These hooks are defined in `hooks/hooks.json` and apply to **all sessions regardless of skill/agent activation**:

| Event | Matcher | Script | Action |
|-------|---------|--------|--------|
| SessionStart | - | `session-start.js` | Initialize session, detect level, guide user via AskUserQuestion |
| PreToolUse | `Write\|Edit` | `pre-write.js` | PDCA doc check, task classification, convention hints, block major features without design |
| PostToolUse | `Write` | `pdca-post-write.js` | Suggest gap analysis after implementation |

> **Note**: Global hooks ensure PDCA guidance is available. Skill-specific hooks provide additional contextual features when skills are activated.

### Skill Frontmatter Hooks (PreToolUse/PostToolUse)

These hooks are defined in skill YAML frontmatter:

#### PreToolUse

| Tool | Skill/Agent | Script | Action |
|------|-------------|--------|--------|
| `Write` | [[../agents/design-validator|design-validator]] | `design-validator-pre.js` | Design document checklist |
| `Write\|Edit` | [[../agents/code-analyzer|code-analyzer]] | (block) | Code analyzer is read-only |
| `Bash` | [[../../skills/zero-script-qa/SKILL|zero-script-qa]] | `qa-pre-bash.js` | Block destructive commands |
| `Bash` | [[../../skills/phase-9-deployment/SKILL|phase-9-deployment]] | `phase9-deploy-pre.js` | Environment validation |

#### PostToolUse

| Tool | Skill/Agent | Script | Action |
|------|-------------|--------|--------|
| `Write` | [[../../skills/phase-5-design-system/SKILL|phase-5-design-system]] | `phase5-design-post.js` | Design token verification |
| `Write` | [[../../skills/phase-6-ui-integration/SKILL|phase-6-ui-integration]] | `phase6-ui-post.js` | UI layer separation check |
| `Write` | [[../agents/gap-detector|gap-detector]] | `gap-detector-post.js` | Post-analysis iteration guidance |
| `Write` | [[../agents/qa-monitor|qa-monitor]] | `qa-monitor-post.js` | Critical issue notification |

#### Stop

| Skill/Agent | Script | Action |
|-------------|--------|--------|
| [[../../skills/phase-1-schema/SKILL|phase-1-schema]] | `phase1-schema-stop.js` | Schema phase completion (v1.4.0) |
| [[../../skills/phase-2-convention/SKILL|phase-2-convention]] | `phase2-convention-stop.js` | Convention phase completion (v1.4.0) |
| [[../../skills/phase-3-mockup/SKILL|phase-3-mockup]] | `phase3-mockup-stop.js` | Mockup phase completion (v1.4.0) |
| [[../../skills/phase-4-api/SKILL|phase-4-api]] | `phase4-api-stop.js` | Zero Script QA guidance |
| [[../../skills/phase-7-seo-security/SKILL|phase-7-seo-security]] | `phase7-seo-stop.js` | SEO/Security phase completion (v1.4.0) |
| [[../../skills/phase-8-review/SKILL|phase-8-review]] | `phase8-review-stop.js` | Review summary + gap analysis |
| [[../../skills/zero-script-qa/SKILL|zero-script-qa]] | `qa-stop.js` | QA session cleanup |
| [[../../skills/development-pipeline/SKILL|development-pipeline]] | `echo` | Pipeline completion |
| [[../agents/gap-detector|gap-detector]] | `gap-detector-stop.js` | Check-Act iteration: Match Rate 기반 분기 (v1.3.0) |
| [[../agents/pdca-iterator|pdca-iterator]] | `iterator-stop.js` | Check-Act iteration: 완료/계속 안내 (v1.3.0) |

> **v1.4.0**: 4개 신규 Phase Stop 스크립트 추가 (phase1-schema, phase2-convention, phase3-mockup, phase7-seo)

---

## Write/Edit Flow (v1.4.0)

When user writes/edits source code files:

```
1. PreToolUse Stage (Skill Frontmatter)
   └── pre-write.js ← Unified hook
       ├── 1. Task classification (Quick Fix → Major Feature)
       ├── 2. PDCA document check (design doc exists?)
       └── 3. Convention hints (by file type)

2. Actual Write/Edit Execution

3. PostToolUse Stage (Skill Frontmatter)
   ├── pdca-post-write.js
   │   └── Suggest gap analysis (if design doc exists)
   ├── phase-5-design-system (phase5-design-post.js)
   │   └── Verify design tokens (if UI file: .tsx, .jsx, .vue, .svelte)
   └── phase-6-ui-integration (phase6-ui-post.js)
       └── Verify layer separation (if UI file or pages/components/features path)
```

**v1.2.0 Improvement**: 3 separate PreToolUse hooks merged into 1 unified hook for better performance.

**v1.2.1 Improvement**: Extension-based file detection replaces path-based detection for multi-language support.

**v1.2.3 Improvement**: SessionStart hook now guides users with AskUserQuestion (4 options).

**v1.3.0 Improvement**: Check-Act iteration loop with Stop hooks on gap-detector and pdca-iterator agents.

---

## Check-Act Iteration Loop (v1.3.0)

Automatic iteration cycle for quality improvement:

```
gap-detector Agent (Check)
    ↓ (Stop hook)
gap-detector-stop.js
    ├── >= 90% Match Rate → report-generator 제안
    ├── 70-89% Match Rate → 선택지 제공 (수동/자동)
    └── < 70% Match Rate  → pdca-iterator 강력 권장
                               ↓
                          pdca-iterator Agent (Act)
                               ↓ (Stop hook)
                          iterator-stop.js
                               ├── 완료 감지 → report-generator 제안
                               └── 진행 중 → gap-detector 재실행 안내
```

### Stop Hook Flow

| Agent | Condition | Action |
|-------|-----------|--------|
| gap-detector | Match Rate >= 90% | `/pdca-report` 제안 → `/archive` 가능 |
| gap-detector | Match Rate 70-89% | 수동 수정 or pdca-iterator 선택 |
| gap-detector | Match Rate < 70% | pdca-iterator 강력 권장 |
| pdca-iterator | 완료 메시지 감지 | gap-detector 재실행 또는 완료 안내 |
| pdca-iterator | 진행 중 | gap-detector로 Check 수행 안내 |

---

## Skill Description Triggers (Semantic Matching)

> **Note**: The "Triggers:" keyword in description is a **bkit convention**, not an official Claude Code feature. Claude uses **semantic matching** on the entire description field to decide when to auto-invoke skills/agents. The "Triggers:" section helps Claude understand activation contexts through natural language.

Skills and Agents are activated by semantic matching on their description field.

### Level Skills

| Skill | Trigger Keywords |
|-------|------------------|
| [[../../skills/starter/SKILL|starter]] | static website, portfolio, landing page, beginner, HTML CSS |
| [[../../skills/dynamic/SKILL|dynamic]] | fullstack, BaaS, bkend, authentication, login, signup, database |
| [[../../skills/enterprise/SKILL|enterprise]] | microservices, kubernetes, terraform, k8s, AWS, CTO, AI Native |

### Phase Skills

| Skill | Trigger Keywords |
|-------|------------------|
| [[../../skills/phase-1-schema/SKILL|phase-1-schema]] | schema, terminology, data model, entity |
| [[../../skills/phase-2-convention/SKILL|phase-2-convention]] | convention, coding style, naming rules |
| [[../../skills/phase-3-mockup/SKILL|phase-3-mockup]] | mockup, prototype, wireframe, UI design |
| [[../../skills/phase-4-api/SKILL|phase-4-api]] | API design, REST API, backend, endpoint |
| [[../../skills/phase-5-design-system/SKILL|phase-5-design-system]] | design system, component library, design tokens, shadcn |
| [[../../skills/phase-6-ui-integration/SKILL|phase-6-ui-integration]] | UI implementation, API integration, state management |
| [[../../skills/phase-7-seo-security/SKILL|phase-7-seo-security]] | SEO, security, meta tags, XSS, CSRF |
| [[../../skills/phase-8-review/SKILL|phase-8-review]] | code review, architecture review, quality check, refactoring |
| [[../../skills/phase-9-deployment/SKILL|phase-9-deployment]] | deployment, CI/CD, production, Vercel, Kubernetes, Docker |

### Core/Specialized Skills

| Skill | Trigger Keywords |
|-------|------------------|
| [[../../skills/bkit-rules/SKILL|bkit-rules]] | bkit, PDCA, develop, implement, feature, bug, code, design |
| [[../../skills/bkit-templates/SKILL|bkit-templates]] | template, plan document, design document, analysis document, report |
| [[../../skills/zero-script-qa/SKILL|zero-script-qa]] | zero script qa, log-based testing, docker logs, QA, testing |
| [[../../skills/development-pipeline/SKILL|development-pipeline]] | development pipeline, phase, where to start, new project |
| [[../../skills/mobile-app/SKILL|mobile-app]] | mobile app, React Native, Flutter, Expo, iOS, Android |
| [[../../skills/desktop-app/SKILL|desktop-app]] | desktop app, Electron, Tauri, mac app, windows app |

---

## Agent Auto-Trigger (Semantic Matching)

> Same semantic matching applies to agents. Claude decides to delegate based on the description's meaning.

| Agent | Trigger Keywords |
|-------|------------------|
| [[../agents/starter-guide|starter-guide]] | beginner, first project, learn to code, simple website, portfolio |
| [[../agents/bkend-expert|bkend-expert]] | bkend, BaaS, login, signup, database, fullstack, backend |
| [[../agents/enterprise-expert|enterprise-expert]] | CTO, AI Native, microservices, architecture decision |
| [[../agents/infra-architect|infra-architect]] | AWS, Kubernetes, Terraform, CI/CD, EKS, RDS, cloud |
| [[../agents/pipeline-guide|pipeline-guide]] | development pipeline, phase, where to start, how to begin |
| [[../agents/gap-detector|gap-detector]] | gap analysis, design-implementation check, compare design |
| [[../agents/design-validator|design-validator]] | design validation, document review, spec check |
| [[../agents/code-analyzer|code-analyzer]] | code analysis, quality check, security scan, code review |
| [[../agents/qa-monitor|qa-monitor]] | zero script qa, QA, testing, log analysis, docker logs |
| [[../agents/pdca-iterator|pdca-iterator]] | iterate, optimize, auto-fix, automatically fix |
| [[../agents/report-generator|report-generator]] | PDCA report, completion report, summary, progress report |

---

## Skill → Agent Connections (v1.3.0)

Each Skill is connected to specific Agents:

| Skill | Connected Agent | Note |
|-------|-----------------|------|
| `starter` | [[../agents/starter-guide|starter-guide]] | |
| `dynamic` | [[../agents/bkend-expert|bkend-expert]] | |
| `enterprise` | [[../agents/enterprise-expert|enterprise-expert]] | Includes AI Native, monorepo |
| `enterprise` | [[../agents/infra-architect|infra-architect]] | |
| `development-pipeline` | [[../agents/pipeline-guide|pipeline-guide]] | |
| `zero-script-qa` | [[../agents/qa-monitor|qa-monitor]] | |
| `phase-8-review` | [[../agents/code-analyzer|code-analyzer]] | Code quality analysis |
| `bkit-templates` | [[../agents/design-validator|design-validator]] | Document validation |
| `mobile-app` | [[../agents/pipeline-guide|pipeline-guide]] | |
| `desktop-app` | [[../agents/pipeline-guide|pipeline-guide]] | |

**Removed Connections (v1.2.0)**:
- `evaluator-optimizer` → Removed (merged into pdca-iterator agent description)
- `analysis-patterns` → Merged into phase-8-review
- `pdca-methodology` → Removed (merged into bkit-rules)
- `document-standards` → Merged into bkit-templates

---

## Related Documents

- [[priority-rules]] - Priority rules for conflicts
- [[../scenarios/scenario-write-code]] - Write/Edit scenario details
- [[../_GRAPH-INDEX]] - Full index
