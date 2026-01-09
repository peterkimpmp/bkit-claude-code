# AI-Native Capability Guide

> **Purpose**: Training on core capabilities for effective collaboration with AI
> **Key Point**: For AI to be a tool, you must set the direction

---

## What is AI-Native Development?

```
Traditional Development:
Developer writes code directly → Test → Fix → Deploy

AI-Native Development:
Developer sets direction → AI generates code → Developer verifies → Deploy

Key Difference:
"Person who writes code directly" → "Person who directs AI"
```

---

## 3 Essential Capabilities

### ⚠️ Important Warning

```
Without these three capabilities:
"AI becomes a tool that quickly creates wrong things."

Real Cases:
- App completed in 2 weeks → Security vulnerability found → Complete rewrite
- Launched with AI-generated code → Bug explosion → Customer churn
- Quick development → Unmaintainable → Project abandoned
```

### Capability 1: Verification Ability

**Definition**
```
The ability to judge whether results are right or wrong

"Is this code correct?" → You must be able to answer yourself
"Is this design appropriate?" → You must be able to judge yourself
```

**Why is it important?**
```
AI can create "plausibly wrong" results:
- Syntactically correct but logically wrong
- Works but has security vulnerabilities
- Passes tests but misses edge cases
```

**How to develop verification ability**

| Step | Method | Example |
|------|--------|---------|
| 1. Use checklists | Follow document checklists | verification-checklist.md |
| 2. Habit of questioning | "Why did this turn out this way?" | Question every AI result |
| 3. Testing habit | Happy path + Edge cases | Minimum 3 scenarios |
| 4. Comparison habit | Design vs Implementation | PDCA Check stage |

**Verification Question Template**
```markdown
□ Can I explain what this code does?
□ Do I understand why it was implemented this way?
□ Are there other approaches? If so, why this one?
□ What are the edge cases and how are they handled?
□ Are there security/performance issues?
□ Does it match the design document?
```

---

### Capability 2: Direction Setting Ability

**Definition**
```
The ability to clearly define what needs to be built

"Build this feature" → Exactly what feature?
"Fix the bug" → Exactly what bug? What's the cause?
```

**Why is it important?**
```
AI guesses your intent:
- Vague request → Guess-based result → Different from what you wanted
- Clear request → Accurate result → Time saved
```

**How to develop direction setting ability**

| Step | Method | Example |
|------|--------|---------|
| 1. Document requirements | Write down what to build | "Users should be able to ~" |
| 2. Specify constraints | List what not to do | "Maintain existing API format" |
| 3. Decide priorities | Start with what's important | P0, P1, P2 classification |
| 4. Define success criteria | Definition of done | "Success if ~" |

**Good Request vs Bad Request**

```markdown
❌ Bad request:
"Build a login feature"

✅ Good request:
"Build a login feature.
- Email/password method
- Use JWT tokens
- Add to existing /api/auth/ path
- Show error message on failure
- Lock for 10 minutes after 5 failures
- Success criteria: Navigate to dashboard after successful login"
```

**Request Writing Template**
```markdown
## Feature Request

### Purpose
[Why is this feature needed?]

### Detailed Requirements
- [Specific requirement 1]
- [Specific requirement 2]

### Constraints
- [Things to follow]
- [Technologies/patterns to use]

### Success Criteria
- [Done when this is achieved]

### Reference
- [Related files/documents]
```

---

### Capability 3: Quality Standards

**Definition**
```
The ability to define what "good code" is

"Is this code okay?" → Judge what's okay and what's not
"Can it be made better?" → Must have criteria for "better"
```

**Why is it important?**
```
Without giving AI quality standards:
- Only creates "working code"
- Inconsistent codebase
- Hard to maintain structure
```

**Quality Standards Example**

```markdown
## Code Quality Standards

### Readability
- Can understand role from function/variable name alone
- One function does one thing
- Comments on complex logic

### Consistency
- Follow naming conventions
- Follow file structure patterns
- Unified error handling patterns

### Maintainability
- No duplicate code (DRY)
- Clear dependencies
- Testable structure

### Performance
- No unnecessary computations
- Appropriate caching
- No N+1 queries

### Security
- Input validation
- No sensitive information exposure
- Proper authentication/authorization
```

**Communicating Quality Standards**
```markdown
Communicating quality standards to Claude:

"Here are the code quality standards for this project:
1. Naming: camelCase functions, PascalCase components
2. Structure: feature-based folder structure
3. Errors: Wrap all API calls with try-catch
4. Logging: Log all errors with console.error

Please write code following these standards."
```

---

## Self-Assessment by Capability Level

### Verification Ability Level

| Level | Description | Assessment |
|-------|-------------|------------|
| Lv.1 | Use AI results as-is | "If it works, it's OK" |
| Lv.2 | Read results once | "Seems roughly right" |
| Lv.3 | Verify with checklist | "Checked each item" |
| Lv.4 | Verify with test scenarios | "Tested edge cases too" |
| Lv.5 | Verify against design | "Matches design and quality verified" |

**Current Level**: ___

---

### Direction Setting Ability Level

| Level | Description | Assessment |
|-------|-------------|------------|
| Lv.1 | "Do ~" level request | "Build login" |
| Lv.2 | Rough requirements | "Build email login" |
| Lv.3 | Detailed requirements | "Do ~, and ~, and ~" |
| Lv.4 | Include constraints | "Do ~ but don't do ~" |
| Lv.5 | Include success criteria | "Done when ~" |

**Current Level**: ___

---

### Quality Standards Ability Level

| Level | Description | Assessment |
|-------|-------------|------------|
| Lv.1 | No standards | "If it works, it's OK" |
| Lv.2 | Intuitive standards | "If it looks clean, it's OK" |
| Lv.3 | Some standards | "Naming is important" |
| Lv.4 | Documented standards | "We have a conventions document" |
| Lv.5 | Automated verification | "Lint/tests enforce standards" |

**Current Level**: ___

---

## Capability Improvement Roadmap

### Weekly Learning Plan

#### Week 1: Verification Ability Basics
```
Day 1-2: Study verification-checklist.md
Day 3-4: Practice applying checklist to AI results
Day 5-7: Make 3 scenario testing a habit
```

#### Week 2: Direction Setting Ability Basics
```
Day 1-2: Study request writing template
Day 3-4: Practice rewriting existing requests with template
Day 5-7: Write new feature requests using template
```

#### Week 3: Quality Standards Basics
```
Day 1-2: Read/create project conventions document
Day 3-4: Practice communicating quality standards to AI
Day 5-7: Practice applying standards during code review
```

#### Week 4: Integration Practice
```
Day 1-7: Small feature from start to finish
- Direction setting (write request)
- AI utilization (code generation)
- Verification (checklist + test)
- Quality check (apply standards)
```

---

## Practical Exercise Scenarios

### Scenario 1: Simple Feature Addition

**Mission**: "Add a dark mode toggle button"

```markdown
1. Direction Setting Practice
   - Write requirements clearly
   - Organize constraints
   - Define success criteria

2. AI Utilization
   - Request from Claude with written requirements

3. Verification Practice
   - Verify results with checklist
   - Execute 3+ test scenarios

4. Quality Check
   - Check convention compliance
   - Check consistency with existing code
```

### Scenario 2: Bug Fix

**Mission**: "Fix bug where login sometimes fails"

```markdown
1. Direction Setting Practice
   - Describe bug phenomenon precisely
   - Organize reproduction conditions
   - Establish hypotheses for expected cause

2. AI Utilization
   - Request analysis → Request cause identification → Request fix

3. Verification Practice
   - Reproduce original bug → Confirm fix resolves it
   - Confirm no impact on other features

4. Quality Check
   - Does fix code match existing patterns?
   - Are there preventive measures for similar bugs?
```

### Scenario 3: Refactoring

**Mission**: "Consolidate duplicate API call logic"

```markdown
1. Direction Setting Practice
   - Organize current problems (where is the duplication?)
   - Define target state (how should it be?)
   - Constraints (maintain existing behavior)

2. AI Utilization
   - Request analysis → Request design → Request implementation

3. Verification Practice
   - Confirm all existing features work normally
   - Confirm duplication was actually removed

4. Quality Check
   - Is new code better? (readability, maintainability)
   - No performance impact?
```

---

## Growth Checkpoints

### 1 Month Self-Check

```markdown
□ I don't accept AI results without verification
□ I write detailed requests instead of vague ones
□ I know and apply the project's quality standards
□ I habitually use checklists
□ I test with at least 3 scenarios
```

### 3 Month Self-Check

```markdown
□ I write design documents before implementation
□ I explicitly communicate quality standards to AI
□ I regularly perform design vs implementation gap analysis
□ I give feedback based on quality standards during code review
□ I recognize and avoid anti-patterns
```

### 6 Month Self-Check

```markdown
□ Effectively directing AI improves productivity 2x or more
□ I systematically develop complex features using PDCA cycle
□ I can teach AI-Native development methods to team members
□ I can define and automate project quality standards
□ I understand AI limitations and utilize appropriately
```

---

## Conclusion

```
AI-Native Development Core:
For AI to be a tool, you must be the conductor.

3 Essential Capabilities:
1. Verification Ability: Judge if results are correct
2. Direction Setting: Define what to build
3. Quality Standards: Present criteria for good code

Without these capabilities:
"A tool that quickly creates wrong things"

With these capabilities:
"A partner that quickly creates right things"

Claude is not perfect.
Always verify important decisions.
```

---

## Next Steps

After completing capability training:

```bash
# 1. Start a practical project
/init-starter              # First project

# 2. Start PDCA-based development
/pdca-plan {feature}       # Create plan

# 3. Use verification checklist
/zero-script-qa            # Log-based QA
```
