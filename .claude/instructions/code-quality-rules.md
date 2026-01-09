# Code Quality Core Principles

> Core principles automatically applied to all code writing

## Pre-coding Required Checks

### 1. Check Existing Code
```
Before creating new functions/components:
1. Does similar functionality already exist? → Search first
2. Check utils/, hooks/, components/ui/
3. If exists, reuse; if not, create
```

### 2. Reusability Assessment
```
Can this code be used elsewhere?
- YES → Extract to generic function/component
- NO → Write in place (but extract on 2nd use)
```

## Core Principles (Always Apply)

### DRY (Don't Repeat Yourself)
```
❌ Forbidden: Copy-paste same code to 2+ locations
✅ Required: Extract to common function/component

Exception: Really simple 1-2 line code
```

### Single Responsibility Principle (SRP)
```
❌ Forbidden: One function doing multiple things
✅ Required: One function, one responsibility

Judgment: If function name contains "and" or "or", split needed
```

### Extensibility First
```
❌ Forbidden: Hardcoding for specific cases only
✅ Required: Write in generalized patterns

Example:
// ❌ Specific case
if (status === 'active') return 'Active'
if (status === 'inactive') return 'Inactive'

// ✅ Generalized
const STATUS_LABELS = { active: 'Active', inactive: 'Inactive' }
return STATUS_LABELS[status] ?? status
```

### No Hardcoding
```
❌ Forbidden: Magic numbers, magic strings
✅ Required: Define as constants with meaningful names

Example:
// ❌ Hardcoded
if (items.length > 10) { ... }

// ✅ Constant
const MAX_DISPLAY_ITEMS = 10
if (items.length > MAX_DISPLAY_ITEMS) { ... }
```

## Post-coding Self-Check

```
□ Does same logic exist elsewhere?
□ Can this function be reused elsewhere?
□ Are there hardcoded values?
□ Does function do only one thing?
□ Can new code replace existing code?
```

## When to Refactor

```
Refactor immediately when:
1. Same code appears for 2nd time
2. Function exceeds 20 lines
3. if-else nests 3+ levels deep
4. Same parameters passed to multiple functions
```
