---
name: pdca-methodology
description: |
  PDCA (Plan-Do-Check-Act) methodology knowledge.
  Covers documentation-first development, design-implementation sync, continuous improvement.

  Use proactively when user starts feature development or needs quality assurance guidance.

  Triggers: PDCA, plan, design, check, act, 계획, 설계, 検証, 改善

  Do NOT use for: quick fixes, trivial changes, or non-development tasks.
agent: design-validator
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
user-invocable: true
---

# PDCA Methodology Skill

## PDCA Cycle Overview

```
┌─────────────────────────────────────────────────────────┐
│                      PDCA Cycle                          │
├──────────────┬──────────────────────────────────────────┤
│ Plan         │ Planning and documentation                │
│              │ → Record in docs/01-plan/                 │
├──────────────┼──────────────────────────────────────────┤
│ Do           │ Design-based implementation               │
│              │ → Code while referencing design docs      │
├──────────────┼──────────────────────────────────────────┤
│ Check        │ Design vs implementation analysis         │
│              │ → Record results in docs/03-analysis/     │
├──────────────┼──────────────────────────────────────────┤
│ Act          │ Learning and improvement                  │
│              │ → Write report in docs/04-report/         │
└──────────────┴──────────────────────────────────────────┘
```

## Each Phase in Detail

### Plan (Planning)

**Purpose**: Document what, why, and how

```markdown
# {Feature} Plan

## Objectives
- What will be achieved?

## Background
- Why is it needed?

## Scope
- What's included
- What's excluded

## Success Criteria
- How to determine completion?

## Timeline (optional)
- Expected duration
```

### Design

**Purpose**: Document detailed design before implementation

```markdown
# {Feature} Design Document

## Architecture
- Component structure
- Data flow

## Data Model
- Entity definitions
- Relationships

## API Specification
- Endpoints
- Request/Response

## UI/UX (if applicable)
- Screen layouts
- User flows
```

### Do (Execute)

**Purpose**: Implement based on design

```
Rules:
1. Read design document first
2. Track work with TodoWrite
3. If implementation must differ from design, update design first
4. Move to Check phase after completion
```

### Check (Analysis)

**Purpose**: Analyze differences between design and implementation

```markdown
# {Feature} Analysis Results

## Design Match Rate
- N%

## Differences
- In design but not in implementation
- In implementation but not in design
- Implemented differently than designed

## Issues
- Problems discovered
- Root cause analysis

## Recommended Actions
- Fix implementation / Update design
```

### Act (Improve)

**Purpose**: Organize learnings and prepare for next cycle

```markdown
# {Feature} Completion Report

## Result Summary
- Completed items
- Incomplete items

## Learnings
- What went well
- What to improve

## Next Steps
- Follow-up work
- Next cycle plan
```

## Document Folder Structure

```
docs/
├── 01-plan/                    # [P] Planning
│   ├── _INDEX.md              # List and status
│   ├── requirements.md        # Overall requirements
│   └── features/
│       └── {feature}.plan.md  # Feature-specific plans
│
├── 02-design/                  # [D] Design
│   ├── _INDEX.md
│   ├── architecture.md        # Overall architecture
│   ├── data-model.md          # Data model
│   ├── api-spec.md            # API specification
│   └── features/
│       └── {feature}.design.md
│
├── 03-analysis/                # [C] Analysis
│   ├── _INDEX.md
│   ├── gap-analysis/          # Design-implementation gaps
│   └── issues/                # Issue analysis
│
└── 04-report/                  # [A] Reports
    ├── _INDEX.md
    ├── changelog.md           # Change history
    └── features/
        └── {feature}.report.md
```

## PDCA Application Rules

### For New Feature Requests

```
1. Check docs/02-design/
2. If no design → Write design document first
3. If design exists → Implement based on design
4. After implementation → Suggest Check
```

### For Bug Fix Requests

```
1. Check docs/03-analysis/issues/
2. Document root cause analysis
3. Implement fix
4. Update analysis document
```

### For Refactoring

```
1. Analyze current state (Check)
2. Create improvement plan (Plan)
3. Update design documents (Design)
4. Implement refactoring (Do)
5. Analyze results and report (Check, Act)
```

## PDCA Maturity Levels

| Level | Description | Documentation Level |
|-------|-------------|---------------------|
| Level 1 | Basic | Only README |
| Level 2 | Planning | Requirements documented |
| Level 3 | Design | Design documented |
| Level 4 | Analysis | Design-implementation sync |
| Level 5 | Continuous Improvement | Full PDCA cycle operation |

## Core Principles

```
1. Documentation First
   - Design before code
   - Reference design during implementation
   - Update documents on changes

2. No Guessing
   - Check documents if uncertain
   - Ask if not in documents
   - Record, don't assume

3. Continuous Sync
   - Design and implementation always match
   - Take immediate action on gaps
   - Periodic verification

4. Learn & Improve
   - Learn from each cycle
   - Improve processes
   - Accumulate team knowledge
```

## Relationship with Development Pipeline

### Pipeline and PDCA are Not Separate

```
❌ Wrong understanding:
Mapping entire Pipeline to PDCA
(Plan=Phase1-3, Do=Phase4-6, Check=Phase7-8, Act=Phase9)

✅ Correct understanding:
Run PDCA cycle within each Phase

Phase N
├── Plan: Plan what to do in this Phase
├── Design: Detailed design
├── Do: Execute/implement
├── Check: Verify/review
└── Act: Confirm and move to next Phase
```

### Visual Representation

```
┌─────────────────────────────────────────────────────────────────┐
│                    Development Pipeline                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ ... ──→ Phase 9           │
│    │           │           │                    │                │
│  [PDCA]      [PDCA]      [PDCA]              [PDCA]             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Application Scope

| Situation | PDCA | Pipeline |
|-----------|------|----------|
| New project (non-developer) | ✅ | ✅ |
| New project (experienced) | ✅ | Optional |
| Feature addition/modification | ✅ | ❌ |
| Bug fix | ✅ | ❌ |
| Non-development AI work | ✅ | ❌ |

**Key Point**:
- PDCA applies to **all work**
- Pipeline applies **only to new project development**, **optionally**

### Related Skills

- `development-pipeline/`: Complete Pipeline knowledge
- `phase-1-schema/` ~ `phase-9-deployment/`: Phase-by-phase guides
