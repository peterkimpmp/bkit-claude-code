# Verification Checklist Guide

> **Purpose**: Build the capability to self-verify AI-generated results
> **Key Point**: Answering "How do I know if this is correct?"

---

## 3 Essential Capabilities for AI-Native Development

```
⚠️ Without these three: "AI becomes a tool that quickly creates wrong things."

1. Verification Ability - Must be able to judge if results are correct
2. Direction Setting - Must clearly know what to build
3. Quality Standards - Must be able to define what "good code" is
```

This document guides you on systematically building **verification ability**.

---

## Phase-by-Phase Verification Checklists

### Phase 1: Schema Design Verification

#### Required Check Items
```
□ Are all core entities (data types) defined?
□ Are relationships between entities clear? (1:1, 1:N, N:M)
□ Are required and optional fields distinguished?
□ Are unique values specified?
□ Is handling of related data on deletion defined?
```

#### Verification Method
```markdown
## Scenario Verification Method

Verify schema with "When XXX user does YYY" scenarios:

Example: "When a user adds a product to cart"
- User table exists? ✓
- Product table exists? ✓
- Cart table exists? ✓
- User-Cart relationship defined? ✓
- Cart-Product relationship defined? ✓

If anything is missing, schema modification needed!
```

#### Requesting Verification from Claude
```
"Verify if these scenarios are possible with this schema:
1. User registration
2. Product search
3. Add to cart
4. Place order
5. Payment

If any scenarios are impossible, suggest schema modifications."
```

---

### Phase 2: Convention Verification

#### Required Check Items
```
□ Are file naming rules consistent?
  - Components: PascalCase (Button.tsx)
  - Utilities: camelCase (formatDate.ts)
  - Constants: SCREAMING_CASE (API_ENDPOINTS.ts)

□ Does folder structure follow the defined pattern?
  - Consistency in feature-based or layer-based approach

□ Is code style unified?
  - Indentation, quotes, semicolons, etc.
```

#### Verification Method
```bash
# File naming rule verification
ls -la src/components/  # Check PascalCase
ls -la src/utils/       # Check camelCase

# Code style verification
npm run lint           # Run ESLint
npm run format:check   # Prettier verification
```

#### Requesting Verification from Claude
```
"Analyze the current project's conventions and find consistency violations.
Report in order: file names, folder structure, code style."
```

---

### Phase 3: Mockup Verification

#### Required Check Items
```
□ Are all core screens defined?
□ Is user flow uninterrupted? (A → B → C connected)
□ Are error state screens present? (loading, error, empty state)
□ Is responsive design considered? (mobile, tablet, desktop)
□ Is accessibility considered? (color contrast, font size)
```

#### Verification Method
```markdown
## 5-Step Flow Verification

1. Happy Path
   - Check user journey when everything works normally

2. Error Path
   - Check screens for network disconnection, server errors

3. Edge Cases
   - When there's no data, when there's too much data

4. Responsive Check
   - Check layout while resizing browser

5. User Simulation
   - Click/input as an actual user would
```

#### Requesting Verification from Claude
```
"Verify user flow based on this mockup.
- Whether all screens from signup to first purchase are connected
- Whether there are missing screens or connections
- Whether error state screens are defined"
```

---

### Phase 4: API Verification

#### Required Check Items
```
□ Are all necessary endpoints implemented?
□ Are request/response formats consistent?
□ Are error response formats standardized?
□ Is authentication/authorization applied to endpoints that need it?
□ Is input validation implemented?
```

#### Verification Method
```bash
# API call test (terminal)
curl -X GET http://localhost:3000/api/users
curl -X POST http://localhost:3000/api/users -H "Content-Type: application/json" -d '{"name":"test"}'

# Response format check
- status: 200, 201, 400, 401, 404, 500
- body: { data: ..., error: null } or { data: null, error: {...} }
```

#### Verification Check Template
```markdown
## API Verification Checksheet

| Endpoint | Method | Auth | Validation | Test |
|----------|--------|:----:|:----------:|:----:|
| /api/users | GET | ✓ | ✓ | ✓ |
| /api/users | POST | ✓ | ✓ | ✓ |
| /api/users/:id | GET | ✓ | ✓ | ⬜ |
| /api/users/:id | PUT | ✓ | ⬜ | ⬜ |
| /api/users/:id | DELETE | ✓ | ⬜ | ⬜ |
```

#### Requesting Verification from Claude
```
"Verify the current API implementation:
1. Whether all endpoints in design document are implemented
2. Whether response formats are consistent
3. Whether error handling is standardized
4. Whether there's missing validation"
```

---

### Phase 5: Design System Verification

#### Required Check Items
```
□ Is color palette defined? (primary, secondary, error, etc.)
□ Is there a typography scale? (h1~h6, body, caption)
□ Is there a spacing system? (4px multiples, etc.)
□ Are common components reusable?
□ Is dark mode considered? (if needed)
```

#### Verification Method
```markdown
## Visual Consistency Verification

1. Screenshot Comparison
   - Do all buttons of the same type look identical?
   - Are same-level headings the same size?

2. Code Verification
   - Are there hardcoded color values? (❌ #007bff → ✅ var(--primary))
   - Are there hardcoded font sizes?

3. Responsive Verification
   - Does it not break at all resolutions?
```

#### Requesting Verification from Claude
```
"Verify design system consistency:
1. Find hardcoded color/font/spacing values
2. Find non-reused style patterns
3. Suggest parts that can be unified with design tokens"
```

---

### Phase 6: UI Integration Verification

#### Required Check Items
```
□ Do all screens integrate normally with API?
□ Is loading state displayed?
□ Is user notified when errors occur?
□ Is empty state handled?
□ Is real-time data reflected? (if needed)
```

#### Verification Method
```markdown
## Manual Test Scenarios

### Happy Path Test
1. Sign up → Confirm success message
2. Log in → Confirm dashboard navigation
3. Query data → Confirm list display
4. Create data → Confirm added to list
5. Edit data → Confirm change reflected
6. Delete data → Confirm removed from list

### Error Path Test
1. Wrong input → Confirm error message
2. Network disconnection → Confirm retry prompt
3. Server error → Confirm error screen
4. No permission → Confirm access restriction message
```

#### Requesting Verification from Claude
```
"Verify UI integration status:
1. Find screens not connected to API
2. Find places missing loading/error/empty state handling
3. Check console errors"
```

---

### Phase 7: Security Verification

#### Required Check Items
```
□ Is sensitive information not exposed? (API keys, passwords, etc.)
□ Is authentication applied to APIs that need it?
□ Is HTTPS applied? (production)
□ Is XSS attack defended? (input value escaping)
□ Is CSRF token applied? (if needed)
□ Is SQL Injection defended? (ORM usage or parameter binding)
```

#### Verification Method
```bash
# Check environment variable exposure
grep -r "sk-" .           # Search for hardcoded API keys
grep -r "password" .      # Search for hardcoded passwords

# Check if .env is in gitignore
cat .gitignore | grep ".env"

# Check if sensitive info is in frontend bundle
# (search bundle files after build)
```

#### Requesting Verification from Claude
```
"Check for security vulnerabilities:
1. Hardcoded sensitive information (API keys, passwords)
2. Protected resources accessible without authentication
3. Input handling with XSS vulnerabilities
4. Environment variable configuration status"
```

---

### Phase 8: Code Review Verification

#### Required Check Items
```
□ Is there no duplicate code? (DRY principle)
□ Do functions/components do only one thing? (SRP)
□ Are there comments on hard-to-understand logic?
□ Is error handling appropriate?
□ Are there no performance issues? (N+1 queries, unnecessary re-renders, etc.)
```

#### Verification Method
```markdown
## Code Quality Checkpoints

### Readability
- Can you tell what a function does just from its name?
- Are magic numbers (meaningless numbers) defined as constants?
- Are complex conditions extracted to meaningful variables?

### Maintainability
- When changes are needed, is there only one place to modify?
- Are there test codes? (if applicable)
- Are dependencies clear?

### Performance
- Are there unnecessary API calls?
- Are large lists virtualized/paginated?
- Are images optimized?
```

#### Requesting Verification from Claude
```
"Do a code quality review:
1. DRY principle violations (duplicate code)
2. SRP violations (functions/components with multiple responsibilities)
3. Performance issues (N+1, unnecessary re-renders)
4. Refactoring suggestions with improvement priorities"
```

---

### Phase 9: Pre-Deployment Final Verification

#### Required Check Items
```
□ Does build complete without errors?
□ Are production environment variables set?
□ Is database migration complete?
□ Is HTTPS applied?
□ Is error monitoring set up?
□ Is logging properly configured?
□ Is there a backup plan?
```

#### Verification Method
```bash
# Build test
npm run build          # Completes without errors

# Local test in production mode
npm run start          # Test built version

# Environment variable check
printenv | grep -E "(DATABASE|API|SECRET)"  # Check necessary variables are set
```

#### Pre-Deployment Checklist
```markdown
## Final Deployment Checklist

### Feature Verification
- [ ] All core user flows tested
- [ ] Payment feature tested (if applicable)
- [ ] Email/notification features tested (if applicable)

### Infrastructure Verification
- [ ] Domain setup complete
- [ ] SSL certificate applied
- [ ] CDN setup (if needed)
- [ ] Auto-scaling setup (if needed)

### Monitoring Verification
- [ ] Error tracking (Sentry, etc.) set up
- [ ] Performance monitoring set up
- [ ] Log collection set up
- [ ] Alerts set up (downtime, etc.)

### Documentation Verification
- [ ] README updated
- [ ] API documentation updated
- [ ] Deployment guide written
```

---

## Building Self-Verification Capability

### Step 1: Follow the Checklists
```
At first, follow this document's checklists exactly as written.
Open the relevant checklist for each Phase and verify.
```

### Step 2: Habit of Questioning
```
Instead of asking Claude "Is this correct?",
ask "How can I verify if this is correct?"

By learning verification methods, you can check yourself.
```

### Step 3: Learning from Failures
```
When bugs occur:
1. Analyze what verification was missed
2. Add that item to the checklist
3. Prevent the same mistake next time
```

### Step 4: Automation
```
Automate repetitive verifications:
- ESLint/Prettier → Automatic code style verification
- TypeScript → Automatic type error verification
- CI/CD → Automatic build/test verification
- Zero Script QA → Automatic log-based verification
```

---

## Verification Request Prompt Collection

### Comprehensive Verification
```
"Do a comprehensive verification of the current project status:
1. Implementation completion rate against design documents
2. List of missing features
3. Quality issues (security, performance, code quality)
4. List of work needed before deployment"
```

### Specific Feature Verification
```
"Verify the [feature name] feature:
1. Whether requirements defined in design document are met
2. Error case handling status
3. Test scenarios and results"
```

### Change Impact Verification
```
"Analyze the impact scope when changing [filename]:
1. Other files that use this file
2. Features that might break due to the change
3. Additional modifications needed"
```

---

## Conclusion

```
Verification Ability = Core capability for AI-Native development

Checklist → Questions → Learn from failures → Automation

Build verification capability in this order.
When you can verify yourself, AI becomes a true partner.
```
