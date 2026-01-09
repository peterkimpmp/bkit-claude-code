# Check/Act Stage Guide

## Check Stage (Analysis)

### Purpose

The Check stage is for **analyzing differences between design and implementation**.

```
Design Document ───┐
                   ├──▶ Gap Analysis ──▶ Analysis Report
Implementation ────┘
```

### Analysis Types

#### 1. Gap Analysis (Design-Implementation Differences)

```markdown
## Gap Analysis Results

### API Endpoints
| Design | Implementation | Status |
|--------|----------------|--------|
| POST /auth/login | POST /auth/login | ✅ Match |
| POST /auth/logout | - | ❌ Not implemented |
| - | POST /auth/refresh | ⚠️ Missing from design |

### Match Rate: 80%
```

#### 2. Code Quality Analysis

```markdown
## Code Quality

### Complexity
| File | Function | Complexity | Status |
|------|----------|------------|--------|
| auth.ts | login | 5 | ✅ Appropriate |
| auth.ts | processUser | 15 | ⚠️ High |

### Security Issues
- 🔴 Critical: Hardcoded secret (auth.ts:42)
- 🟡 Warning: Missing input validation
```

#### 3. Performance Analysis

```markdown
## Performance

| Endpoint | Response Time | Target | Status |
|----------|---------------|--------|--------|
| POST /login | 150ms | 200ms | ✅ |
| GET /users | 450ms | 200ms | ❌ |

### Bottleneck: N+1 query (UserRepository.findAll)
```

### How to Run Check

```bash
# Analyze specific feature
/pdca-analyze login

# Full analysis (quality + security included)
/pdca-analyze login --full

# Or in natural language
"Analyze the login feature"
```

### Analysis Report Structure

```markdown
# {Feature Name} Analysis Report

## 1. Analysis Overview
- Analysis date, scope

## 2. Gap Analysis
- Design vs implementation comparison table
- Match rate

## 3. Code Quality
- Complexity, code smells, security issues

## 4. Overall Score
- Based on 100 points

## 5. Recommended Actions
- Critical → Warning → Info order
```

---

## Act Stage (Improvement)

### Purpose

The Act stage is for **summarizing learnings and making improvements**.

```
Analysis Results ──▶ Fix Issues ──▶ Learning Summary ──▶ Completion Report
                                                              │
                                                              ▼
                                                       Next PDCA Cycle
```

### What to Do in Act

1. **Fix Issues**
   - Critical issues first
   - Update design documents (items missing from design)

2. **Learning Summary (KPT)**
   - Keep: What went well
   - Problem: What to improve
   - Try: What to try next

3. **Write Completion Report**
   - Results summary
   - Process improvement suggestions

### Completion Report Structure

```markdown
# {Feature Name} Completion Report

## 1. Results Summary
- Completion rate: 95% (19/20 items)
- Incomplete: 1 item (carried over to next cycle)

## 2. Quality Metrics
| Metric | Target | Final | Change |
|--------|--------|-------|--------|
| Match rate | 90% | 95% | +20% |
| Test coverage | 80% | 82% | +12% |

## 3. Learning (KPT)
### Keep (Continue doing)
- Design documentation improved implementation efficiency

### Problem (Issues)
- Initial scope estimation was inaccurate

### Try (Try next)
- Introduce TDD approach

## 4. Next Steps
- New feature: {next feature}
- Improvement: {improvement item}
```

### How to Run Act

```bash
# Generate completion report
/pdca-report login

# Or in natural language
"Write completion report for login feature"
```

---

## Check → Act Flow

### General Flow

```
1. Implementation complete
      ↓
2. Run /pdca-analyze {feature}
      ↓
3. Review analysis results
      ↓
4. If Critical issues exist → Fix → Analyze again
      ↓
5. Once all issues resolved → /pdca-report {feature}
      ↓
6. PDCA cycle complete!
```

### Issue Resolution Priority

```
🔴 Critical (Immediately)
   - Security vulnerabilities
   - Data loss potential
   - Service outage

🟡 Warning (Short-term)
   - Performance degradation
   - Code quality issues
   - Design-implementation mismatch

🟢 Info (Backlog)
   - Style improvements
   - Insufficient documentation
   - Insufficient testing
```

---

## Continuous Improvement

### PDCA Cycle Iteration

```
1st cycle: Basic feature implementation
    ↓
2nd cycle: Performance optimization
    ↓
3rd cycle: Feature expansion
    ↓
...
```

### Process Improvement

Improve the process itself after each cycle:

```markdown
## Process Improvement Suggestions

| Stage | Current | Improvement Suggestion |
|-------|---------|------------------------|
| Plan | Insufficient requirements | Add user interviews |
| Design | Manual review | Introduce checklist |
| Check | Manual analysis | Automation tools |
```

---

## Tips

### 1. Don't Fear Analysis
```
It's okay if analysis results aren't good.
Finding problems itself is valuable.
```

### 2. Start with Small Improvements
```
Don't try to fix everything at once.
Critical first, the rest gradually.
```

### 3. Record Your Learning
```
To avoid repeating the same mistakes,
always write KPT.
```

## Related Documents

- [Analysis Template](../../templates/analysis.template.md)
- [Report Template](../../templates/report.template.md)
- [Analysis Patterns Skill](../../skills/analysis-patterns/SKILL.md)
