# PDCA Methodology Overview

## What is PDCA?

PDCA (Plan-Do-Check-Act) is a management methodology for continuous improvement.
In software development, it's utilized for **documentation-based development** and **quality management**.

```
┌────────────────────────────────────────────────────────────┐
│                       PDCA Cycle                            │
│                                                             │
│     ┌─────────┐                      ┌─────────┐           │
│     │  Plan   │──────────────────────▶│   Do    │           │
│     │         │                       │         │           │
│     └────┬────┘                       └────┬────┘           │
│          │                                 │                │
│          │      Improvement Cycle          │                │
│          │                                 │                │
│     ┌────┴────┐                       ┌────┴────┐           │
│     │   Act   │◀──────────────────────│  Check  │           │
│     │         │                       │         │           │
│     └─────────┘                       └─────────┘           │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

## PDCA in Software Development

### Plan
- Requirements analysis
- Feature specification writing
- Success criteria definition

### Design - Between Plan and Do
- Architecture design
- Data model definition
- API specification writing

### Do (Execute)
- Design-based implementation
- Test writing
- Code review

### Check (Analyze)
- Design vs implementation comparison (Gap analysis)
- Code quality analysis
- Performance measurement

### Act (Improve)
- Learning summary
- Process improvement
- Next cycle preparation

## Why PDCA?

### 1. Documentation-Based Development
```
❌ Traditional: Code first → Document later (or skip)
✅ PDCA: Document first → Code based on docs → Maintain sync
```

### 2. Prevent Guessing
```
❌ Traditional: "This will probably work"
✅ PDCA: "According to the design document..."
```

### 3. Knowledge Accumulation
```
❌ Traditional: Exists only in developer's head
✅ PDCA: Document → Team sharing → Easy onboarding
```

### 4. Quality Assurance
```
❌ Traditional: Find bug → Fix → Find another
✅ PDCA: Design review → Implement → Analyze → Improve
```

## PDCA Vibecoding

"Vibecoding" is an approach that applies PDCA while respecting developer intuition.

```
1. Idea → Plan document (can be simple)
2. Design by feel → Design document (doesn't have to be perfect)
3. Code right away → Do (reference design)
4. Check when done → Check (Gap analysis)
5. Summarize learnings → Act (do better next time)
```

Key: **Not perfect documentation, but the habit of recording**

## SoR (Single Source of Truth) Principle

```
1st priority: Codebase (what actually works)
2nd priority: CLAUDE.md / Convention documents
3rd priority: Design documents (for understanding intent)
```

If design document and code differ? → **Code is the answer** (design needs update)

## Getting Started

1. Apply `.claude/` template to your project
2. PDCA is automatically applied on first feature request
3. Or initialize with `/init-starter` (or dynamic/enterprise)

## Related Documents

- [Plan Stage Guide](./plan-guide.md)
- [Design Stage Guide](./design-guide.md)
- [Check/Act Stage Guide](./check-act-guide.md)
