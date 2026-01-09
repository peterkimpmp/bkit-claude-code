# AI-Native Development Anti-Patterns

> **Purpose**: Document patterns to avoid when collaborating with AI
> **Key Point**: Knowing failures in advance allows prevention

---

## Why Know Anti-Patterns?

```
⚠️ AI works fast.
⚠️ But if the direction is wrong, it quickly builds the wrong thing.

Knowing anti-patterns allows you to:
✅ Avoid repeating the same mistakes
✅ Detect problems before they grow
✅ Understand AI limitations and leverage them properly
```

---

## Critical Anti-Patterns (Must Avoid)

### 1. 🔴 Accepting AI Output Without Verification

**Pattern**
```
AI generates code → Commit immediately → Discover problems later
```

**Problems**
- AI can generate "plausibly wrong" code
- Code that compiles but has incorrect logic
- Code containing security vulnerabilities

**Correct Approach**
```markdown
AI output → I understand it → Verify → Commit

Verification questions:
1. Can I explain what this code does?
2. Do I understand why it was implemented this way?
3. Are edge cases handled?
4. Are there security issues?
```

**Request to Claude**
```
"Find potential bugs or security vulnerabilities in this code.
Also explain why it was implemented this way."
```

---

### 2. 🔴 Requesting Implementation Without Design

**Pattern**
```
"Create login feature" → AI generates code immediately → Structure mismatch later
```

**Problems**
- Implementation inconsistent with existing code
- Large modifications needed during integration
- Missing requirements

**Correct Approach**
```markdown
Follow PDCA order:
1. Plan: Organize requirements
2. Design: Write design document
3. Do: Implement based on design
4. Check: Compare design vs implementation
```

**Request to Claude**
```
"Before implementing the login feature, write a design document first.
Analyze the existing project structure and create a plan for which files
to create and modify."
```

---

### 3. 🔴 Asking Questions Without Context

**Pattern**
```
"Why doesn't this work?"
"There's an error, fix it"
```

**Problems**
- AI answers based on guesses
- Corrections go in wrong direction
- Wasted time

**Correct Approach**
```markdown
Components of a good question:
1. Current situation: What were you trying to do?
2. Expected result: What should happen?
3. Actual result: What actually happened?
4. Error message: Full error message (copy-paste)
5. Already tried: What solutions did you try?
```

**Good Question Example**
```
"In the signup feature, when calling the email duplicate check API:
Expected: { exists: true/false } response
Actual: 500 error occurs

Error message:
TypeError: Cannot read property 'email' of undefined
at validateEmail (/api/users.ts:45:12)

Already tried:
- Logging request.body → shows undefined

I think it's a body-parser configuration issue, please check."
```

---

### 4. 🔴 Requesting Too Large Changes at Once

**Pattern**
```
"Refactor the entire app"
"Change all APIs from REST to GraphQL"
```

**Problems**
- Too many changes make verification impossible
- Difficult to rollback if problems occur midway
- Context limits cause only partial processing

**Correct Approach**
```markdown
Break into small units:
1. Change one feature/file at a time
2. Test after each change
3. If no problems, proceed to next step

Example: REST → GraphQL migration
Day 1: User API only to GraphQL
Day 2: Product API
Day 3: Order API
...
```

**Request to Claude**
```
"Break down the full refactoring into steps.
Each step should be independently testable and
rollback-able if problems occur.
Start with the lowest risk items."
```

---

### 5. 🔴 Blind Trust in AI Decisions

**Pattern**
```
"Which framework should I use?" → AI recommends → Adopt as-is
"How should I architect this?" → AI designs → Adopt as-is
```

**Problems**
- AI doesn't fully understand your situation
- Information might not be current
- Doesn't know your team/company/customer context

**Correct Approach**
```markdown
AI is an option suggester, I am the decision maker

1. Ask AI for multiple options
2. Request analysis of pros/cons for each
3. Gather additional info (official docs, community)
4. Make final decision based on my situation
```

**Request to Claude**
```
"Suggest 3 possible options for this situation.
Compare the pros/cons, suitable situations, and risks for each.
I'll make the final decision."
```

---

## Caution Anti-Patterns (Should Avoid)

### 6. 🟡 Copy-Paste Development

**Pattern**
```
AI generated code → Copy without understanding → Paste → Done if it works
```

**Problems**
- Can't debug code you don't understand
- Depend on AI again for similar problems
- Lost learning opportunities

**Correct Approach**
```markdown
Understand before copying:
1. What does this code do?
2. Why was it implemented this way?
3. Are there other approaches?
4. How does it apply to my project?
```

---

### 7. 🟡 Overly Detailed Instructions

**Pattern**
```
"Create a Button component with variant prop,
if variant is 'primary' apply bg-blue-500,
if 'secondary' apply bg-gray-500..."
```

**Problems**
- Not leveraging AI's expertise
- Constraints reduce quality
- Wasted time

**Correct Approach**
```markdown
Convey only intent and constraints:

"Create a Button component for the design system.
- Support variants: primary, secondary, danger
- Support sizes: sm, md, lg
- Follow the existing tailwind config in the project"
```

---

### 8. 🟡 Ignoring Error Messages

**Pattern**
```
Error occurs → "There's an error" → AI guesses a fix → Different error → Repeat
```

**Problems**
- Can't find actual cause
- Wasted time
- Wrong fixes create new bugs

**Correct Approach**
```markdown
Error messages are the answer key!

1. Copy entire error message
2. Check stack trace (which file, which line)
3. Check error type (TypeError, SyntaxError, etc.)
4. Provide all information to AI
```

---

### 9. 🟡 Declaring Feature Complete Without Testing

**Pattern**
```
Write code → Run once → Success → "Done!"
```

**Problems**
- Only happy path tested
- Bugs in edge cases
- Problems in production

**Correct Approach**
```markdown
Minimum test scenarios:

1. Happy path: Normal input → Normal result
2. Error path: Wrong input → Appropriate error
3. Edge cases: Empty values, very long values, special characters
4. Authorization: Not logged in, no permission
```

---

### 10. 🟡 Postponing Document Updates

**Pattern**
```
Code change → Verify it works → Commit → Documentation later...
```

**Problems**
- Forget changes over time
- Documentation-code mismatch
- Confuses team (or future self)

**Correct Approach**
```markdown
Update docs immediately after changes:

Code change → Verify it works → Update related docs → Commit

To Claude:
"Update the related documentation to reflect these changes."
```

---

## Anti-Patterns by Development Phase

### Design Phase

| Anti-Pattern | Correct Approach |
|-------------|------------------|
| Coding without design | Write design doc first |
| Accepting AI design as-is | Review and modify/approve |
| Unclear requirements | Clarify requirements first |

### Implementation Phase

| Anti-Pattern | Correct Approach |
|-------------|------------------|
| Implementing everything at once | Break into small units |
| Copy-paste | Understand then apply |
| Postponing tests | Test immediately after implementation |

### Debugging Phase

| Anti-Pattern | Correct Approach |
|-------------|------------------|
| "Why doesn't it work?" questions | Provide detailed context |
| Ignoring error messages | Start with error message analysis |
| Fixing by guessing | Identify cause then fix |

### Deployment Phase

| Anti-Pattern | Correct Approach |
|-------------|------------------|
| Deploy without sufficient testing | Deploy after checklist complete |
| No rollback plan | Confirm rollback method first |
| Deploy without monitoring | Set up monitoring before deploy |

---

## Recovery Patterns After Failure

### When Code is Broken

```bash
# 1. Check recent commits
git log --oneline -10

# 2. Restore to state before change
git checkout <commit-hash> -- <file-path>

# 3. Or full rollback
git reset --hard <commit-hash>
```

### When AI Keeps Repeating Same Mistake

```markdown
1. Start new conversation (context reset)
2. Explain problem situation clearly from beginning
3. Specify "methods tried before that didn't work"
4. Proceed step by step
```

### When Project Structure is Messed Up

```markdown
1. Git commit current state (preserve current state)
2. Find last working version
3. Create branch from that version
4. Selectively apply only necessary changes
```

---

## Anti-Pattern Self-Diagnosis Checklist

Check once a week:

### This week, did I...

```
□ Accept AI output without verification?
□ Request implementation without design?
□ Ask questions without context?
□ Request too large changes at once?
□ Follow AI recommendations as-is?
□ Use code without understanding it?
□ Ignore error messages?
□ Declare complete without testing?
□ Postpone document updates?
```

**If any items are checked**: Review the "Correct Approach" for that pattern.

---

## Conclusion

```
Avoiding anti-patterns = Properly leveraging AI

AI is a tool.
Even good tools cause harm when used incorrectly.

Use AI as "a partner that quickly builds the right thing"
not as "a tool that quickly builds the wrong thing".
```
