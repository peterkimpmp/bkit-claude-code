# Agent Auto-Trigger Rules

> **Critical**: Claude MUST automatically invoke appropriate agents based on context.
> Users should NOT need to know agent names or commands.

---

## Mandatory Auto-Invocation Rules

### Rule 1: Level-Based Agent Selection

When user requests **feature development**, Claude MUST:

1. **Detect project level** (via level-detection.md)
2. **Prepare appropriate agent** based on level:

| Level | Primary Agent | When to Use |
|-------|---------------|-------------|
| Starter | `starter-guide` | Any coding task for beginners |
| Dynamic | `bkend-expert` | BaaS/fullstack features |
| Enterprise | `enterprise-expert` | Architecture decisions |
| Enterprise (Infra) | `infra-architect` | Terraform/K8s work |

3. **Use Task tool** to invoke agent when complex work is needed

### Rule 2: Task-Based Agent Selection

Claude MUST invoke these agents for matching intents:

| User Intent Keywords | Auto-Invoke Agent | Action |
|---------------------|-------------------|--------|
| "code review", "quality", "security scan" | `code-analyzer` | Run code analysis |
| "design review", "spec check", "document validation" | `design-validator` | Validate design docs |
| "gap analysis", "design vs implementation" | `gap-detector` | Compare design and code |
| "report", "summary", "completion report" | `report-generator` | Generate PDCA report |
| "QA", "test", "log analysis", "zero script" | `qa-monitor` | Monitor/analyze logs |
| "pipeline", "which phase", "development order" | `pipeline-guide` | Guide through phases |

### Rule 3: Proactive Agent Suggestions

After completing major tasks, Claude MUST suggest relevant agents:

```
After code implementation:
→ "Would you like me to analyze the code quality? (I'll use the code-analyzer)"

After design document creation:
→ "Should I validate this design document? (I'll use the design-validator)"

After feature completion:
→ "Want me to check for gaps between design and implementation? (I'll use the gap-detector)"

After PDCA cycle:
→ "Should I generate a completion report? (I'll use the report-generator)"
```

---

## Skill-Agent Connection Map

When referencing a skill, consider invoking its connected agent:

| Skill | Connected Agent | Auto-Invoke Condition |
|-------|-----------------|----------------------|
| `starter` | `starter-guide` | Beginner-level questions |
| `dynamic` | `bkend-expert` | BaaS/fullstack work |
| `enterprise` | `enterprise-expert` | Architecture decisions |
| `ai-native-development` | `enterprise-expert` | 10-day methodology questions |
| `monorepo-architecture` | `enterprise-expert` | Context control questions |
| `zero-script-qa` | `qa-monitor` | QA/testing work |
| `development-pipeline` | `pipeline-guide` | Phase guidance |
| `document-standards` | `design-validator` | Document creation |
| `analysis-patterns` | `code-analyzer` | Code analysis |

---

## Implementation Pattern

When invoking an agent, use Task tool:

```
Task tool parameters:
- subagent_type: {agent-name}
- prompt: Clear task description
- description: Brief summary (3-5 words)
```

Example:
```
User: "Check my code for security issues"

Claude thinking:
1. This matches "security scan" intent
2. Should invoke code-analyzer agent
3. Use Task tool to launch agent

Claude action:
→ Task(subagent_type="code-analyzer", prompt="Analyze this codebase for security vulnerabilities...", description="Security code analysis")
```

---

## Do NOT Auto-Invoke When

- User explicitly declines agent assistance
- Task is trivial (single file edit, minor fix)
- User is in learning mode and wants to understand process
- Agent was already invoked in this conversation for same task

---

## User Guidance

When an agent is activated, briefly explain:

```
"I'm using the [agent-name] to help with this. This agent specializes in [specialty]."
```

This helps users learn about available agents naturally.
