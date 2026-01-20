# Template Improvement Plan: Clean Architecture & Coding Convention Support

> **Summary**: Improve PDCA templates to better support document-driven development with clean architecture and coding conventions
>
> **Author**: Claude (with Kay)
> **Date**: 2026-01-20
> **Status**: ✅ All Phases Completed (Phase 1-4)
> **Related Docs**: 00-ARCHITECTURE.md, 02-BKIT-PLUGIN-DESIGN.md, 03-BKIT-FEATURES.md

---

## 1. Overview

### 1.1 Purpose

Analyze whether current templates (`templates/`) provide sufficient information for developing with **clean architecture** and **coding conventions** as intended in the design documents (docs/00-03), and propose improvements.

### 1.2 Background

The design documents describe:
- **Document-driven development**: Design first, implement later
- **PDCA methodology**: Plan → Design → Do → Check → Act cycle
- **9-phase pipeline**: Schema → Convention → Mockup → ... → Deployment
- **Level-based support**: Starter / Dynamic / Enterprise

For this to work effectively, **templates must capture sufficient information** to guide AI-assisted development with architectural consistency.

### 1.3 Analysis Scope

| Template Category | Files Analyzed |
|-------------------|----------------|
| **PDCA Templates** | plan, design, design-starter, design-enterprise, analysis, report |
| **Pipeline Templates** | phase-1-schema, phase-2-convention, phase-8-review |
| **Other Templates** | CLAUDE, iteration-report |

---

## 2. Current State Analysis

### 2.1 Template Inventory

```
templates/
├── PDCA Templates (Core)
│   ├── plan.template.md           # Plan phase
│   ├── design.template.md         # Design phase (Dynamic level default)
│   ├── design-starter.template.md # Simplified for Starter
│   ├── design-enterprise.template.md # Detailed for Enterprise
│   ├── analysis.template.md       # Check phase (Gap analysis)
│   └── report.template.md         # Act phase (Completion report)
│
├── Pipeline Templates
│   ├── pipeline/phase-1-schema.template.md    # Terminology & data model
│   ├── pipeline/phase-2-convention.template.md # Coding rules
│   ├── pipeline/phase-3-mockup.template.md    # UI prototypes
│   ├── pipeline/phase-4-api.template.md       # API specification
│   ├── pipeline/phase-5-design-system.template.md
│   ├── pipeline/phase-6-ui.template.md
│   ├── pipeline/phase-7-seo-security.template.md
│   ├── pipeline/phase-8-review.template.md    # Architecture/Convention review
│   ├── pipeline/phase-9-deployment.template.md
│   └── pipeline/zero-script-qa.template.md
│
└── Other
    ├── CLAUDE.template.md
    ├── iteration-report.template.md
    └── _INDEX.template.md
```

### 2.2 Clean Architecture Support Analysis

| Template | Clean Architecture Coverage | Notes |
|----------|:---------------------------:|-------|
| **design.template.md** | ⚠️ Partial | Has "Design Principles" placeholder but no layer definitions |
| **design-enterprise.template.md** | ✅ Good | Has explicit Clean Architecture Layers section |
| **design-starter.template.md** | ➖ N/A | Appropriately simplified |
| **analysis.template.md** | ⚠️ Missing | No architecture compliance verification |
| **phase-2-convention.template.md** | ✅ Excellent | Full layer definitions, dependency rules |
| **phase-8-review.template.md** | ✅ Excellent | Architecture verification matrix |

**Key Finding**: Pipeline templates have excellent clean architecture support, but core PDCA templates (design.template.md, analysis.template.md) lack integration with these concepts.

### 2.3 Coding Convention Support Analysis

| Template | Convention Coverage | Notes |
|----------|:-------------------:|-------|
| **plan.template.md** | ❌ Missing | No convention consideration section |
| **design.template.md** | ❌ Missing | No convention reference section |
| **analysis.template.md** | ⚠️ Partial | Has "Code Quality" but no convention compliance check |
| **phase-2-convention.template.md** | ✅ Excellent | Comprehensive naming, style, env vars, architecture |
| **phase-8-review.template.md** | ✅ Excellent | Convention compliance verification |
| **CLAUDE.template.md** | ⚠️ Partial | Has placeholder but no detailed structure |

**Key Finding**: Convention definitions exist in phase-2-convention but are not referenced or verified in PDCA flow.

### 2.4 Pipeline Integration Analysis

| PDCA Template | Phase 1 (Schema) Reference | Phase 2 (Convention) Reference |
|---------------|:--------------------------:|:------------------------------:|
| plan.template.md | ❌ None | ❌ None |
| design.template.md | ❌ None | ❌ None |
| analysis.template.md | ❌ None | ❌ None |

**Key Finding**: PDCA templates operate independently from Pipeline templates, missing the opportunity to leverage already-defined schema and conventions.

---

## 3. Gap Analysis Summary

### 3.1 Critical Gaps

| ID | Gap | Impact | Priority | Status |
|----|-----|--------|:--------:|:------:|
| G-1 | **design.template.md lacks Clean Architecture section** | Dynamic level projects get no architecture guidance | 🔴 High | ✅ Resolved |
| G-2 | **analysis.template.md lacks Convention compliance check** | Phase 2 definitions not verified in Check phase | 🔴 High | ✅ Resolved |
| G-3 | **PDCA templates don't reference Pipeline artifacts** | Information silos, repeated work | 🟡 Medium | ✅ Resolved |
| G-4 | **plan.template.md lacks architecture considerations** | Architecture decisions deferred to implementation | 🟡 Medium | ✅ Resolved |

> **✅ All Critical Gaps Resolved** - See Section 6 for implementation details

### 3.2 Coverage Matrix

**Before Implementation:**
```
                    Schema  Convention  Clean Arch  Dependency  Env Vars
                    ------  ----------  ----------  ----------  --------
plan.template         ❌        ❌          ❌          ❌         ❌
design.template       ⚠️        ❌          ⚠️          ❌         ❌
design-enterprise     ✅        ❌          ✅          ✅         ⚠️
analysis.template     ⚠️        ❌          ❌          ❌         ❌
phase-2-convention    ➖        ✅          ✅          ✅         ✅
phase-8-review        ✅        ✅          ✅          ✅         ✅
```

**After Implementation (v1.2):**
```
                    Schema  Convention  Clean Arch  Dependency  Env Vars
                    ------  ----------  ----------  ----------  --------
plan.template         ✅        ✅          ✅          ✅         ✅
design.template       ✅        ✅          ✅          ✅         ✅
design-enterprise     ✅        ✅          ✅          ✅         ✅
analysis.template     ✅        ✅          ✅          ✅         ✅
phase-2-convention    ➖        ✅          ✅          ✅         ✅
phase-8-review        ✅        ✅          ✅          ✅         ✅

Legend: ✅ Good  ⚠️ Partial  ❌ Missing  ➖ N/A
```

---

## 4. Proposed Improvements

### 4.1 Option A: Enhance PDCA Templates (Recommended)

**Approach**: Add clean architecture and convention sections directly to PDCA templates.

**Pros**:
- Works for both Pipeline and non-Pipeline workflows
- Self-contained templates
- Immediate benefit

**Cons**:
- Some duplication with Pipeline templates
- Larger template files

### 4.2 Option B: Cross-Reference System

**Approach**: Add reference sections in PDCA templates pointing to Pipeline artifacts.

**Pros**:
- No duplication
- Encourages Pipeline usage

**Cons**:
- Requires Pipeline to be completed first
- More complex workflow

### 4.3 Option C: Conditional Sections (Hybrid)

**Approach**: Add conditional sections that are used when Pipeline artifacts exist.

**Pros**:
- Best of both worlds
- Flexible

**Cons**:
- More complex templates
- May confuse users

**Recommendation**: **Option A** for immediate improvement, with Option B references as enhancement.

---

## 5. Detailed Improvement Plan

### 5.1 design.template.md Improvements

**Current State**: Basic architecture diagram placeholder

**Proposed Additions**:

```markdown
## X. Clean Architecture (New Section)

### X.1 Layer Structure

| Layer | Responsibility | Location |
|-------|---------------|----------|
| Presentation | UI components, hooks | src/components/, src/hooks/ |
| Application | Use cases, services | src/services/, src/features/*/hooks/ |
| Domain | Entities, types | src/types/, src/domain/ |
| Infrastructure | API clients, DB | src/lib/, src/api/ |

### X.2 Dependency Rules

```
Presentation → Application → Domain ← Infrastructure
                    ↓
              Infrastructure
```

### X.3 File Import Rules

| From | Can Import | Cannot Import |
|------|-----------|---------------|
| Presentation | Application, Domain | Infrastructure directly |
| Application | Domain, Infrastructure | Presentation |
| Domain | Nothing external | All layers |
| Infrastructure | Domain only | Application, Presentation |

---

## Y. Coding Convention Reference (New Section)

### Y.1 Naming Conventions

> Reference: `docs/01-plan/conventions.md` or Phase 2 output

| Target | Rule | Example |
|--------|------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Functions | camelCase | `getUserById()` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Files | kebab-case | `user-profile.ts` |

### Y.2 Environment Variables

| Variable | Purpose | Scope |
|----------|---------|-------|
| NEXT_PUBLIC_* | Client-side | Browser |
| DB_* | Database | Server |
| API_* | External APIs | Server |
| AUTH_* | Authentication | Server |
```

**Estimated Effort**: Medium (add ~50 lines)

---

### 5.2 analysis.template.md Improvements

**Current State**: Code quality analysis without architecture/convention checks

**Proposed Additions**:

```markdown
## X. Clean Architecture Compliance (New Section)

### X.1 Layer Dependency Verification

| Layer | Expected Dependencies | Actual | Status |
|-------|----------------------|--------|--------|
| Presentation | Application, Domain | {actual} | ✅/❌ |
| Application | Domain, Infrastructure | {actual} | ✅/❌ |
| Domain | None | {actual} | ✅/❌ |
| Infrastructure | Domain | {actual} | ✅/❌ |

### X.2 Dependency Violations

| File | Violation | Recommendation |
|------|-----------|----------------|
| `components/UserList.tsx` | Imports `@/lib/api` directly | Use service hook |

---

## Y. Convention Compliance (New Section)

### Y.1 Naming Check

| Category | Convention | Compliance | Violations |
|----------|-----------|:----------:|------------|
| Files | kebab-case | 95% | `UserProfile.ts` should be `user-profile.ts` |
| Functions | camelCase | 100% | - |
| Components | PascalCase | 100% | - |

### Y.2 Folder Structure Check

| Expected Path | Status | Notes |
|---------------|--------|-------|
| src/components/ | ✅ | |
| src/features/ | ✅ | |
| src/services/ | ⚠️ | Some services in wrong location |
| src/types/ | ✅ | |

### Y.3 Import Order Check

- [ ] External libraries first
- [ ] Internal modules second (absolute paths)
- [ ] Relative imports third
- [ ] Type imports fourth
- [ ] Styles last
```

**Estimated Effort**: Medium (add ~60 lines)

---

### 5.3 plan.template.md Improvements

**Current State**: No architecture/convention considerations

**Proposed Additions**:

```markdown
## X. Architecture Considerations (New Section)

### X.1 Level Selection

| Level | Characteristics | Selected |
|-------|-----------------|:--------:|
| Starter | Simple structure (components, lib, types) | ☐ |
| Dynamic | Feature-based modules, services layer | ☐ |
| Enterprise | Strict layer separation, DI | ☐ |

### X.2 Key Architectural Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| State management | Context / Zustand / Redux | {selected} | {reason} |
| API client | fetch / axios / react-query | {selected} | {reason} |
| Form handling | react-hook-form / formik | {selected} | {reason} |

---

## Y. Convention Prerequisites (New Section)

### Y.1 Existing Conventions

- [ ] Convention document exists (`docs/01-plan/conventions.md` or Phase 2 output)
- [ ] CLAUDE.md has coding conventions section
- [ ] ESLint/Prettier configured

### Y.2 New Conventions to Define

| Category | To Define | Priority |
|----------|-----------|:--------:|
| Naming | {specific rules needed} | High |
| Folder structure | {structure decisions} | High |
| Environment variables | {env var list} | Medium |
```

**Estimated Effort**: Low (add ~30 lines)

---

### 5.4 CLAUDE.template.md Improvements

**Current State**: Placeholder for conventions

**Proposed Additions**:

```markdown
## Coding Conventions (Enhanced)

### Naming Rules

| Target | Convention | Example |
|--------|-----------|---------|
| Components | PascalCase | `UserProfile` |
| Functions | camelCase | `getUserById` |
| Constants | UPPER_SNAKE_CASE | `MAX_COUNT` |
| Types | PascalCase | `UserProfile` |
| Files (component) | PascalCase.tsx | `UserProfile.tsx` |
| Files (utility) | camelCase.ts | `formatDate.ts` |
| Folders | kebab-case | `user-profile/` |

### Import Order

1. External libraries (`react`, `next`)
2. Internal absolute imports (`@/components`)
3. Relative imports (`./hooks`)
4. Type imports (`type { User }`)
5. Styles (`./styles.css`)

### Clean Architecture

| Layer | Location | Depends On |
|-------|----------|-----------|
| Presentation | `components/`, `hooks/` | Application |
| Application | `services/`, `features/*/hooks/` | Domain, Infrastructure |
| Domain | `types/`, `domain/` | None |
| Infrastructure | `lib/`, `api/` | Domain |

### Environment Variables

| Prefix | Scope | Example |
|--------|-------|---------|
| NEXT_PUBLIC_ | Client | `NEXT_PUBLIC_API_URL` |
| DB_ | Server | `DB_HOST` |
| API_ | Server | `API_KEY` |
| AUTH_ | Server | `AUTH_SECRET` |
```

**Estimated Effort**: Low (add ~40 lines)

---

## 6. Implementation Checklist

### Phase 1: Core Template Enhancement (Priority: High) ✅ COMPLETED

- [x] **design.template.md** (v1.1 → v1.2)
  - [x] Add Clean Architecture section (Section 9)
  - [x] Add Coding Convention Reference section (Section 10)
  - [x] Add Environment Variables section

- [x] **analysis.template.md** (v1.1 → v1.2)
  - [x] Add Clean Architecture Compliance section (Section 6)
  - [x] Add Convention Compliance section (Section 7)
  - [x] Add Dependency Violation detection format

### Phase 2: Supporting Template Enhancement (Priority: Medium) ✅ COMPLETED

- [x] **plan.template.md** (v1.1 → v1.2)
  - [x] Add Architecture Considerations section (Section 6)
  - [x] Add Convention Prerequisites section (Section 7)

- [x] **CLAUDE.template.md** (v1.0.0 → v1.1.0)
  - [x] Enhance Coding Conventions section with specific rules
  - [x] Add Import Order rules
  - [x] Add Clean Architecture summary
  - [x] Add Environment Variables section

### Phase 3: Pipeline Integration (Priority: Low) ✅ COMPLETED

- [x] Add cross-references from PDCA templates to Pipeline artifacts
  - [x] design.template.md: Added Pipeline References section
  - [x] analysis.template.md: Added Pipeline References for verification
  - [x] plan.template.md: Enhanced Pipeline Integration section with commands
- [x] Create template selection guide based on workflow
  - [x] Created `TEMPLATE-GUIDE.md` with flowchart and comparison tables

### Phase 4: Validation ✅ COMPLETED

- [x] Update gap-detector to analyze new sections
  - [x] Added Section 7: Convention Compliance comparison
  - [x] Enhanced Clean Architecture comparison with import rules
  - [x] Added Overall Scores table to report format
  - [x] Added bkit-templates and phase-2-convention skills
- [x] Sync all changes to .claude/ folder

---

## 7. Success Criteria

| Criteria | Measurement | Status |
|----------|-------------|:------:|
| design.template covers architecture | Has layer definitions, dependency rules | ✅ Section 9 added |
| analysis.template checks compliance | Has architecture and convention verification | ✅ Sections 6, 7 added |
| Templates are self-sufficient | Can be used without Pipeline | ✅ All sections self-contained |
| Templates integrate with Pipeline | Can reference Phase 1/2 outputs | ✅ Pipeline References added |
| Claude can verify implementations | gap-detector uses new sections | ✅ Section 7 added to agent |

---

## 8. Risks and Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Template bloat | Overwhelming for beginners | Keep level-specific templates (starter stays simple) |
| Duplication with Pipeline templates | Maintenance burden | Add "Reference Pipeline" option |
| Breaking existing workflows | User confusion | Version templates, provide migration guide |

---

## 9. Next Steps

1. [x] Review and approve this plan
2. [x] Implement Phase 1 changes (design.template, analysis.template)
3. [x] Test with sample feature development
4. [x] Implement Phase 2 changes
5. [x] Update documentation

> **✅ All Next Steps Completed** - Plan fully implemented on 2026-01-20

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-01-20 | Initial draft | Claude |
| 1.0 | 2026-01-20 | Phase 1 & 2 implemented | Claude |
| 1.1 | 2026-01-20 | Phase 3 & 4 implemented, all phases complete | Claude |

---

> **Note**: Claude is not perfect. Always verify important decisions.
