# Analysis Prompt Examples

## Overview

Prompts for analysis requests that can be used in the PDCA Check stage.

---

## Gap Analysis (Design-Implementation Differences)

### Basic Requests

```
"Analyze [feature]"
"Compare design and implementation of [feature]"
```

**Examples:**
```
"Analyze the login feature"
"Compare design and implementation of shopping cart"
```

### Detailed Requests

```
"Do Gap analysis for [feature]"
"Check if design document matches actual implementation"
```

**Examples:**
```
"Do Gap analysis for payment feature"
"Check if docs/02-design/auth.design.md matches actual implementation"
```

### Result Example

```
🔍 Gap Analysis Results: login

Design-Implementation Match Rate: 85%

✅ Match (17 items)
⚠️ Missing from design (2 items) - exists only in implementation
❌ Not implemented (1 item) - exists only in design

Recommendation: Update design document or implement missing items
```

---

## Code Quality Analysis

### Full Analysis

```
"Analyze code quality"
"Review the code"
```

**Examples:**
```
"Analyze code quality of src/features/auth/"
"Review this file"
```

### Specific Perspective

```
"Analyze from [perspective]"
```

**Examples:**
```
"Analyze from complexity perspective"
"Check for duplicate code"
"Analyze SOLID principle compliance"
```

### Security Analysis

```
"Analyze security vulnerabilities"
"Check for security issues"
```

**Examples:**
```
"Check auth code for security vulnerabilities"
"Check for XSS, SQL Injection vulnerabilities"
```

---

## Performance Analysis

### Code Level

```
"Analyze performance issues"
"Find optimization points"
```

**Examples:**
```
"Analyze re-rendering issues in this component"
"Find API call optimization points"
"Check for N+1 queries"
```

### Bundle Analysis

```
"Analyze bundle size"
"Check for unnecessary dependencies"
```

---

## Test Analysis

### Coverage

```
"Analyze test coverage"
"Find areas lacking tests"
```

**Examples:**
```
"Analyze test coverage for auth module"
"Find edge cases lacking tests"
```

### Test Quality

```
"Analyze test code quality"
"Check if tests are properly written"
```

---

## Architecture Analysis

### Dependency Analysis

```
"Analyze dependencies"
"Check for circular dependencies"
```

**Examples:**
```
"Analyze inter-module dependencies"
"Check if Clean Architecture dependency direction is correct"
```

### Structure Analysis

```
"Analyze project structure"
"Check architecture pattern compliance"
```

---

## Documentation Analysis

### Document Completeness

```
"Analyze document completeness"
"Check for missing documents"
```

**Examples:**
```
"Analyze design document completeness"
"Check if API docs have missing endpoints"
```

### Document-Code Sync

```
"Check if docs and code are in sync"
"Check if README is up to date"
```

---

## Full Analysis

### Comprehensive Analysis

```
"Do full analysis of [feature]"
"/pdca-analyze [feature] --full"
```

**Result:**
- Gap analysis
- Code quality
- Security
- Test coverage
- Performance

### Entire Project

```
"Analyze entire project"
"Analyze full codebase"
```

---

## Using Analysis Results

### Request Issue Fixes

```
"Fix Critical issues from analysis results"
"Fix discovered security vulnerabilities"
```

### Request Design Updates

```
"Update design document based on analysis results"
"Add missing items from design to document"
```

### Generate Report

```
"Write report from analysis results"
"/pdca-report [feature]"
```

---

## Tips

### 1. Be Clear About Scope

```
❌ "Analyze"
✅ "Analyze code quality of src/features/auth/"
```

### 2. Specify Perspective

```
❌ "Look at this code"
✅ "Analyze this code from performance perspective"
```

### 3. Design Document Required

Gap analysis is only meaningful with a design document.
```
Analysis request without design → Claude will suggest writing design first
```

---

## Related Documents

- [Feature Development Prompts](./feature-prompts.md)
- [Debugging Prompts](./debug-prompts.md)
- [Analysis Patterns Skill](../../skills/analysis-patterns/SKILL.md)
