# Plan Stage Guide

## Purpose

The Plan stage is where you define **"what and why"** you will do.

## When is a Plan Document Needed?

### Required
- New feature development
- Large-scale refactoring
- Architecture changes

### Optional
- Simple bug fixes (can be replaced with issue documents)
- Minor UI adjustments
- Documentation updates

## Plan Document Structure

```markdown
# {Feature Name} Plan

## 1. Overview
### 1.1 Purpose
{The problem this feature solves}

### 1.2 Background
{Why it's needed now}

## 2. Scope
### 2.1 In Scope
- Things to implement

### 2.2 Out of Scope
- Things not to do this time

## 3. Requirements
### 3.1 Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | ... | High |

### 3.2 Non-Functional Requirements
- Performance, security, accessibility, etc.

## 4. Success Criteria
- Criteria for judging completion

## 5. Risks
- Expected problems and countermeasures
```

## Writing Tips

### 1. Keep it Concise
```
❌ Too detailed: 3-page requirement spec
✅ Just right: Core content within 1 page
```

### 2. Focus on "Why"
```
❌ How: "Create a form using React"
✅ Why: "Users need to easily input information"
```

### 3. Clarify Scope
```
❌ Vague: "Login feature"
✅ Clear: "Email/password login, social login excluded"
```

## Practical Examples

### Simple Plan (Starter Level)

```markdown
# Contact Form Plan

## Purpose
A form for users to send inquiries

## Scope
- Name, email, message input
- Submit button
- Submission success message

## Excluded
- Backend integration (later)
- File attachments

## Success Criteria
- Form input works
- Validation works
- Mobile responsive
```

### Detailed Plan (Enterprise Level)

```markdown
# Payment System Plan

## 1. Overview
### 1.1 Purpose
Provide safe and fast payment experience

### 1.2 Background
- Current redirect to external payment page → UX degradation
- Expected $50,000 monthly payment volume

## 2. Scope
### 2.1 Included
- Card payments (domestic/international)
- Payment history lookup
- Refund processing

### 2.2 Excluded
- Recurring payments (Phase 2)
- Cryptocurrency payments

## 3. Requirements
### 3.1 Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Card information input form | High |
| FR-02 | Payment processing API | High |
| FR-03 | Payment history lookup | Medium |
| FR-04 | Refund request | Medium |

### 3.2 Non-Functional Requirements
- Performance: Payment completion < 3 seconds
- Security: PCI-DSS compliance
- Availability: 99.9% uptime

## 4. Success Criteria
- [ ] Test payment successful
- [ ] Security audit passed
- [ ] Load test passed

## 5. Risks
| Risk | Impact | Countermeasure |
|------|--------|----------------|
| PG provider outage | High | Backup PG integration |
| Card company response delay | Medium | Timeout handling |
```

## Next Steps

After writing Plan:
1. **Team Review** (optional): Review recommended for complex features
2. **Design Stage**: `/pdca-design [feature name]`
3. **Or request implementation**: "Create login feature"

## Related Documents

- [Design Stage Guide](./design-guide.md)
- [Plan Template](../../templates/plan.template.md)
