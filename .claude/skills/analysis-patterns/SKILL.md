---
name: analysis-patterns
description: |
  Design-implementation gap analysis, code quality analysis, and report writing patterns.
  Used in PDCA Check phase for verification and quality assurance.

  Use proactively when user needs to verify implementation against design documents.

  Triggers: gap analysis, code review, quality check, 설계-구현 분석, ギャップ分析, 差距分析

  Do NOT use for: initial development, design phase, or deployment tasks.
hooks:
  Stop:
    - hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/analysis-stop.sh"
context: fork
agent: code-analyzer
allowed-tools:
  - Read
  - Grep
  - Glob
  - LSP
---

# Analysis Patterns Skill

## Analysis Types

### 1. Gap Analysis (Design-Implementation Differences)

Analysis that identifies differences between design documents and actual implementation

```markdown
# Gap Analysis Report

## Analysis Target
- Design document: docs/02-design/login.design.md
- Implementation path: src/features/auth/

## Results by Analysis Item

### API Endpoints
| Design | Implementation | Status |
|--------|----------------|--------|
| POST /auth/login | POST /auth/login | ✅ Match |
| POST /auth/register | - | ❌ Not implemented |
| - | POST /auth/social | ⚠️ Missing from design |

### Data Model
| Field | Design | Implementation | Status |
|-------|--------|----------------|--------|
| email | string | string | ✅ |
| password | string | string | ✅ |
| createdAt | - | Date | ⚠️ Missing from design |

## Match Rate: 75%

## Recommended Actions
1. Implement POST /auth/register
2. Add social login to design document
3. Reflect createdAt field in design
```

### 2. Code Quality Analysis

Analysis of code quality, security, and performance issues

```markdown
# Code Quality Analysis Report

## Analysis Scope
- Path: src/
- File count: 45
- Total lines: 3,500

## Quality Metrics

### Complexity
| File | Function | Complexity | Status |
|------|----------|------------|--------|
| UserService.ts | processUser | 15 | ⚠️ High |
| utils.ts | formatDate | 3 | ✅ Acceptable |

### Code Smells
| Type | File | Line | Description |
|------|------|------|-------------|
| Long function | api.ts | 45-120 | 75 lines (recommended: ≤50) |
| Duplicate code | helpers.ts | 10, 45 | Same logic repeated |

### Security Issues
| Severity | File | Issue |
|----------|------|-------|
| 🔴 High | auth.ts | Hardcoded secret |
| 🟡 Medium | api.ts | Missing input validation |

## Score: 72/100

## Improvement Recommendations
1. [High] Move auth.ts secret to environment variable
2. Split processUser function (SRP violation)
3. Extract duplicate code to utility
```

### 3. Performance Analysis

Analysis of performance bottlenecks and optimization opportunities

```markdown
# Performance Analysis Report

## Analysis Target
- Feature: Product list query
- Endpoint: GET /api/products

## Measurement Results

### Response Time
| Case | Response Time | Target | Status |
|------|---------------|--------|--------|
| 10 items | 50ms | 100ms | ✅ |
| 100 items | 450ms | 200ms | ❌ |
| 1000 items | 4.5s | 500ms | ❌ |

### Bottleneck Analysis
1. N+1 query problem
   - Location: ProductRepository.findAll()
   - Impact: 1 additional query per product

2. Missing index
   - Table: products
   - Column: category_id

## Optimization Recommendations
1. Solve N+1 with Eager Loading
2. Add index on category_id
3. Apply pagination as required
```

## Analysis Checklists

### Design Verification Checklist

```
□ Required sections exist
  □ Overview
  □ Architecture
  □ Data model
  □ API specification
  □ Error handling

□ Consistency
  □ Unified terminology
  □ Naming convention compliance
  □ Data type consistency

□ Completeness
  □ All endpoints defined
  □ All entities defined
  □ Error cases defined
```

### Code Analysis Checklist

```
□ Structure
  □ Architecture pattern compliance
  □ Correct dependency direction
  □ Appropriate module separation

□ Quality
  □ Appropriate function length (< 50 lines)
  □ No duplicate code
  □ Naming convention compliance

□ Security
  □ Input validation
  □ No hardcoded secrets
  □ SQL injection prevention
  □ XSS prevention

□ Performance
  □ No N+1 queries
  □ Appropriate indexes
  □ No unnecessary re-renders
```

## Report Writing Patterns

### Issue Classification Criteria

```
🔴 Critical (Fix immediately)
- Security vulnerabilities
- Potential data loss
- Potential service disruption

🟡 Warning (Improvement recommended)
- Performance degradation
- Maintenance difficulty
- Code smells

🟢 Info (Reference)
- Style improvements
- Insufficient documentation
- Insufficient tests
```

### Recommended Action Format

```markdown
## Recommended Actions

### Immediate (Within 24 hours)
1. **[Critical] Fix security vulnerability**
   - File: src/auth.ts:42
   - Content: Move API key to environment variable
   - Owner: @developer

### Short-term (Within 1 week)
1. **[Warning] Performance optimization**
   - File: src/api/products.ts
   - Content: Solve N+1 query
   - Expected effect: 80% response time reduction

### Long-term (Backlog)
1. **[Info] Refactoring**
   - File: src/utils/
   - Content: Organize utility functions
```

## Analysis Tool Usage

### Claude Code Tools

```
Read      → Read file contents
Glob      → Search file patterns
Grep      → Search patterns in code
LSP       → Track definitions/references
Task      → Execute parallel analysis
```

### Analysis Query Examples

```
# Find design documents
Glob: docs/**/*.design.md

# Find specific patterns
Grep: "TODO|FIXME|HACK"

# Find hardcoded secrets
Grep: "api[_-]?key|secret|password"

# Find long functions
Grep: "function.*\{" -A 100
```
