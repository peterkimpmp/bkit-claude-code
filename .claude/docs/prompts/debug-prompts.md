# Debugging Prompt Examples

## Overview

Prompts for bug fixing and troubleshooting.

---

## Error Resolution

### Sharing Error Messages

```
"Fix this error: [error message]"
```

**Examples:**
```
"Fix this error: TypeError: Cannot read property 'map' of undefined"
"Fix this error: CORS policy blocked"
"Fix this error: Module not found: Can't resolve '@/lib/utils'"
```

### Sharing Stack Traces

```
"Analyze this error stack trace:
[paste stack trace]"
```

### Sharing Console Logs

```
"Analyze this console log:
[paste console output]"
```

---

## Unexpected Behavior

### Different from Expected

```
"[feature] should [expected behavior] but it [actual behavior]"
```

**Examples:**
```
"Login button click should go to home but it doesn't navigate"
"Form submit should show success message but nothing happens"
"Page refresh should keep login but it logs out"
```

### Intermittent Bugs

```
"[feature] sometimes has [problem]"
```

**Examples:**
```
"Login sometimes fails"
"Images sometimes don't show"
"API responses are sometimes slow"
```

---

## Root Cause Analysis

### Analyze Why

```
"Analyze why [problem] is happening"
```

**Examples:**
```
"Analyze why infinite loop is happening"
"Analyze why data isn't updating"
"Analyze why styles aren't applying"
```

### Logic Tracing

```
"Trace the logic flow of [feature]"
"Track where [variable] is being changed"
```

**Examples:**
```
"Trace the login logic flow"
"Track where user state becomes null"
```

---

## Specific Situations

### Specific Environment

```
"[problem] only happens in [environment]"
```

**Examples:**
```
"Images don't show only in production"
"Layout breaks only on mobile"
"Doesn't work only in Safari"
```

### Specific Conditions

```
"[problem] only happens when [condition]"
```

**Examples:**
```
"Error only on first login"
"Slow only with lots of data"
"Only specific users can't access"
```

---

## Debugging Help

### Debugging Method Questions

```
"How should I debug [problem]?"
```

**Examples:**
```
"How should I track state changes?"
"How should I debug network requests?"
"How should I find memory leaks?"
```

### Request Log Addition

```
"Add debugging logs"
```

**Examples:**
```
"Add debugging logs to login process"
"Add API request/response logging"
```

---

## Fix Requests

### Direct Fix

```
"Fix [problem]"
```

**Examples:**
```
"Fix null error"
"Fix infinite loop"
"Fix type error"
```

### Fix with Explanation

```
"Explain why and fix it"
```

**Examples:**
```
"Explain why this error occurs and fix it"
"Analyze root cause and fix"
```

---

## PDCA Integration

### Document Issue

```
"Document this bug analysis result"
```

**Result:** docs/03-analysis/issues/{issue}.md created

### Verify After Fix

```
"Check if fix matches design after fixing"
```

---

## Level-specific Examples

### Starter

```
"Why isn't CSS working?"
"Why don't images show?"
"Why don't links work?"
```

### Dynamic

```
"Why doesn't login work?"
"Why doesn't data load?"
"Why doesn't real-time update work?"
```

### Enterprise

```
"Why doesn't inter-service communication work?"
"Why is Kubernetes Pod dying?"
"Why does deployment fail?"
```

---

## Tips

### 1. Provide Enough Information

```
❌ "It doesn't work"
✅ "Login button click shows 'TypeError: x is undefined' error"
```

### 2. Explain Reproduction Steps

```
"1. Go to login page
2. Enter email
3. Enter password
4. Click login button
5. Error occurs"
```

### 3. Include Environment Info

```
"Chrome 120 / macOS / Production environment"
```

### 4. Mention Recent Changes

```
"It worked until yesterday but doesn't work today"
"It doesn't work after this commit"
```

---

## Related Documents

- [Feature Development Prompts](./feature-prompts.md)
- [Analysis Prompts](./analysis-prompts.md)
- [Refactoring Prompts](./refactor-prompts.md)
