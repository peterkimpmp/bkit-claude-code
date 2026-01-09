# Feature Development Prompt Examples

## Overview

Prompt examples for developing features based on PDCA.
Even without knowing commands, Claude automatically applies PDCA when you make natural language requests.

---

## New Feature Requests

### Basic Pattern

```
"Create [feature]"
```

**Examples:**
```
"Create login feature"
"Create contact form"
"Create user profile page"
```

**Claude Behavior:**
1. Check docs/02-design/ → Create design first if none exists
2. Implement based on design
3. Suggest Gap analysis after completion

### Detailed Requests

```
"Create [feature] with [condition]"
```

**Examples:**
```
"Create login feature with email and password"
"Create contact form with file upload capability"
"Create settings page with profile photo change"
```

### Reference Requests

```
"Create [feature] like [reference]"
```

**Examples:**
```
"Create login page like GitHub"
"Create ProductCard like existing UserCard"
"Implement according to docs/02-design/login.design.md"
```

---

## Plan Stage Requests

### Plan Document Request

```
"Write plan for [feature]"
```

**Examples:**
```
"Write plan for payment feature"
"Write plan for notification system"
```

**Result:** docs/01-plan/features/{feature}.plan.md created

### Requirements Organization

```
"Organize requirements for [feature]"
```

**Examples:**
```
"Organize requirements for chat feature"
"Organize requirements for admin page"
```

---

## Design Stage Requests

### Design Document Request

```
"Design [feature]"
"Write design document for [feature]"
```

**Examples:**
```
"Design login feature"
"Design shopping cart feature"
```

**Result:** docs/02-design/features/{feature}.design.md created

### Data Model Design

```
"Design data model for [feature]"
```

**Examples:**
```
"Design data model for bulletin board"
"Design data model for order system"
```

### API Design

```
"Design API for [feature]"
```

**Examples:**
```
"Design user management API"
"Design product search API"
```

---

## Implementation Stage Requests

### Full Implementation

```
"Implement [feature]"
```

**Examples:**
```
"Implement login according to design document"
"Implement shopping cart feature"
```

### Partial Implementation

```
"Implement [part] of [feature]"
```

**Examples:**
```
"Implement only validation part of login"
"Implement only quantity change feature of shopping cart"
```

### Component Implementation

```
"Create [component] component"
```

**Examples:**
```
"Create LoginForm component"
"Create ProductCard component"
"Create Pagination component"
```

---

## Level-specific Examples

### Starter Level

```
"Create a portfolio site"
"Add About page"
"Make it responsive"
"Create contact form"
```

### Dynamic Level

```
"Create login/signup feature"
"Create post CRUD"
"Add comment feature"
"Create real-time notifications"
```

### Enterprise Level

```
"Design auth microservice"
"Implement order service"
"Create payment integration API"
"Implement inter-service communication"
```

---

## Tips

### 1. Be Specific

```
❌ "Create feature"
✅ "Create signup feature with email verification"
```

### 2. Use References

```
❌ "Create a nice button"
✅ "Create SecondaryButton like existing PrimaryButton"
```

### 3. Specify Stage (Optional)

```
"Write only Plan for login feature"
"Design is done so just implement"
```

---

## Related Documents

- [Analysis Prompts](./analysis-prompts.md)
- [Debugging Prompts](./debug-prompts.md)
- [Refactoring Prompts](./refactor-prompts.md)
