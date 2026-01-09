# Refactoring Prompt Examples

## Overview

Prompts for code quality improvement and refactoring.
Refactoring also follows the PDCA cycle.

---

## Refactoring Process

```
1. Analyze current state (Check)
2. Create improvement plan (Plan)
3. Update design document (Design)
4. Execute refactoring (Do)
5. Analyze results and report (Check, Act)
```

---

## Code Structure Improvement

### Function Separation

```
"This function is too long. Split it"
"Split [function] into smaller functions"
```

**Examples:**
```
"processOrder function is 100 lines. Split it"
"Split handleSubmit function into smaller functions"
```

### Component Separation

```
"This component is too big. Split it"
"Extract [part] from [component]"
```

**Examples:**
```
"Dashboard component is 500 lines. Split it"
"Extract ProductDetails, ProductReviews from ProductPage"
```

### Module Organization

```
"Organize file structure"
"Group related code into modules"
```

**Examples:**
```
"Organize auth related code into features/auth/"
"Organize utility functions by category"
```

---

## Duplicate Removal

### Remove Duplicate Code

```
"Remove duplicate code"
"Extract repeated logic"
```

**Examples:**
```
"Extract repeated API call logic from these three files"
"Merge similar button components into one"
```

### Extract Common Logic

```
"Extract [logic] into common function"
"Make [pattern] into custom hook"
```

**Examples:**
```
"Extract error handling logic into common function"
"Make data fetching pattern into custom hook"
```

---

## Readability Improvement

### Naming Improvement

```
"Improve variable/function names"
"Change to clearer names"
```

**Examples:**
```
"Improve variable names like data, temp, x"
"Improve ambiguous function names like process, handle"
```

### Comments/Documentation

```
"Add comments"
"Add JSDoc"
```

**Examples:**
```
"Add comments to complex logic"
"Add JSDoc to public APIs"
```

### Code Formatting

```
"Clean up code"
"Make consistent style"
```

---

## Pattern Application

### Design Patterns

```
"Apply [pattern] pattern"
```

**Examples:**
```
"Apply Repository pattern"
"Refactor with Strategy pattern"
"Apply Factory pattern"
```

### Architecture Patterns

```
"Refactor to Clean Architecture"
"Separate layers"
```

**Examples:**
```
"Separate business logic to service layer"
"Separate data access code to Repository"
```

---

## Performance Improvement

### Optimization

```
"Improve performance"
"Optimize [part]"
```

**Examples:**
```
"Optimize this component rendering"
"Optimize API calls"
"Reduce bundle size"
```

### Memoization

```
"Apply memoization where appropriate"
```

**Examples:**
```
"Apply useMemo, useCallback"
"Apply caching to expensive computation functions"
```

---

## Type Improvement

### TypeScript Types

```
"Improve types"
"Remove any types"
```

**Examples:**
```
"Change all any to specific types"
"Remove duplicate types using type inference"
```

### Type Separation

```
"Separate type definitions"
```

**Examples:**
```
"Separate inline types to separate file"
"Move common types to types/ folder"
```

---

## Test Improvement

### Test Refactoring

```
"Refactor test code"
"Improve test readability"
```

**Examples:**
```
"Extract repeated test setup"
"Organize test cases clearly"
```

### Add Tests

```
"Add tests before refactoring"
```

**Examples:**
```
"Add tests before refactoring this function"
"Write tests to guarantee existing behavior"
```

---

## PDCA Integration

### Refactor After Analysis

```
"Refactor based on analysis results"
"Fix issues from Gap analysis"
```

### Design Update

```
"Reflect refactoring content to design document"
```

### Report Writing

```
"Write refactoring result report"
```

---

## Cautions

### 1. Tests First

```
Check if tests exist before refactoring
Add tests first if none exist
```

### 2. Small Units

```
❌ Refactor everything at once
✅ Refactor one small unit at a time
```

### 3. Preserve Behavior

```
Refactoring = Improve structure without changing behavior
Adding new features ≠ Refactoring
```

### 4. Separate Commits

```
Separate refactoring commits from feature commits
```

---

## Tips

### 1. Clear Purpose

```
❌ "Clean up the code"
✅ "Function is too long and hard to test. Split it"
```

### 2. Limit Scope

```
❌ "Refactor entire code"
✅ "Refactor only auth module"
```

### 3. Request Priority

```
"Tell me most urgent refactoring points"
"Organize by complexity level"
```

---

## Related Documents

- [Feature Development Prompts](./feature-prompts.md)
- [Analysis Prompts](./analysis-prompts.md)
- [Debugging Prompts](./debug-prompts.md)
