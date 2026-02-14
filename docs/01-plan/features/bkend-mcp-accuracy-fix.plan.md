# bkend MCP Accuracy Fix Plan

> **Feature**: bkend-mcp-accuracy-fix
> **Target Version**: bkit v1.5.4
> **Level**: Dynamic
> **Date**: 2026-02-14
> **Scope**: bkit plugin (skills, agents, templates, hooks) -- bkend.ai MCP integration accuracy
> **Source of Truth**: https://github.com/popup-studio-ai/bkend-docs (en/mcp/, en/ai-tools/)

---

## 1. Problem Statement

In bkit v1.5.2, 5 skills + 1 agent were added for bkend.ai integration, but **10 Gaps exist between the official bkend.ai MCP documentation and the bkit implementation**. This causes bkit users to encounter **incorrect tool name references, missing tools, and wrong URLs** when using bkend MCP.

### Analysis Method

- **Source of Truth**: `popup-studio-ai/bkend-docs` GitHub repository (en/mcp/ directory)
- **Comparison Target**: bkit skills/bkend-*, agents/bkend-expert.md, templates/shared/bkend-patterns.md
- **Verification Scope**: MCP Tool names, parameters, categories, REST API URLs, Live Reference URLs, MCP Resources

---

## 2. Gap Analysis Summary

### Severity Classification

| Severity | Count | Description |
|----------|-------|-------------|
| CRITICAL | 2 | Directly impacts user functionality |
| HIGH | 3 | Major feature omissions |
| MEDIUM | 3 | Inaccurate information/URLs |
| LOW | 2 | Recommended improvements |

### Complete Gap List

| ID | Severity | Gap Description | Affected Files |
|----|----------|-----------------|----------------|
| GAP-01 | CRITICAL | 5 Data CRUD MCP tools completely missing | bkend-data/SKILL.md, bkend-expert.md |
| GAP-02 | CRITICAL | MCP Tool name mismatch (rollback vs version_apply) | bkend-data/SKILL.md, bkend-expert.md |
| GAP-03 | HIGH | Project/Env management MCP tools missing (9 tools) | bkend-quickstart/SKILL.md, bkend-expert.md |
| GAP-04 | HIGH | `search_docs` Fixed Tool undocumented | All bkend skills |
| GAP-05 | HIGH | Guide Tool name mismatch (numeric prefix vs actual name) | bkend-expert.md, all bkend skills |
| GAP-06 | MEDIUM | MCP Resources (bkend:// URI) undocumented | All bkend skills |
| GAP-07 | MEDIUM | Live Reference URL path error (src/ vs en/) | All bkend skills, bkend-expert.md |
| GAP-08 | MEDIUM | REST API Base URL mismatch | bkend-patterns.md |
| GAP-09 | LOW | Auto System Field ID mismatch (_id vs id) | bkend-data/SKILL.md |
| GAP-10 | LOW | MCP detection limited to Dynamic level only | hooks/session-start.js |

---

## 3. Detailed Gap Analysis

### GAP-01: 5 Data CRUD MCP Tools Completely Missing (CRITICAL)

**Symptom**: The official bkend MCP documentation has 5 dedicated Data CRUD MCP tools, but they are **not listed at all** in bkit's bkend-data skill and bkend-expert agent.

**Official Documentation (en/mcp/05-data-tools.md)**:
| MCP Tool | Function |
|----------|----------|
| `backend_data_list` | List query with filtering/sorting/pagination |
| `backend_data_get` | Single record query |
| `backend_data_create` | Create record |
| `backend_data_update` | Partial update record |
| `backend_data_delete` | Delete record |

**bkit Current State**: bkend-data/SKILL.md only lists 11 Table management tools (backend_table_*), with 0 Data CRUD MCP tools.

**Impact**: When users try to perform data CRUD via MCP, bkit only suggests REST API and is unaware of the MCP tools' existence. **The most frequently used core tools are missing.**

**Fix Plan**:
- `skills/bkend-data/SKILL.md`: Add MCP Data CRUD Tools section (5 tools + parameters)
- `agents/bkend-expert.md`: Add Data CRUD 5 tools to API Tools list (19 -> 24+)

---

### GAP-02: MCP Tool Name Mismatch (CRITICAL)

**Symptom**: Tool names used by bkit differ from the official MCP documentation.

| bkit Current Name | Official Doc Name | Note |
|-------------------|-------------------|------|
| `backend_schema_rollback` | `backend_schema_version_apply` | Completely different name |
| `backend_index_rollback` | Needs verification (no explicit name in docs) | Possibly different name |
| `backend_table_update` | Not in official docs | Existence needs verification |

**Impact**: When bkit agent calls MCP tools with incorrect names, the call will fail.

**Fix Plan**:
- Verify actual tool names from the official MCP endpoint (using `get_operation_schema`)
- Batch update tool names in bkend-data/SKILL.md, bkend-expert.md
- Schema version related: `backend_schema_version_list`, `backend_schema_version_get`, `backend_schema_version_apply`
- Index version related: `backend_index_version_list`, `backend_index_version_get`

---

### GAP-03: Project/Environment Management MCP Tools Missing (HIGH)

**Symptom**: The official bkend documentation (en/mcp/03-project-tools.md) has 9 project/environment management tools, but they are not listed in bkit.

**Official Project Tools**:
| MCP Tool | Function |
|----------|----------|
| `backend_org_list` | List organizations |
| `backend_project_list` | List projects |
| `backend_project_get` | Project details |
| `backend_project_create` | Create project |
| `backend_project_update` | Update project |
| `backend_project_delete` | Delete project |
| `backend_env_list` | List environments |
| `backend_env_get` | Environment details |
| `backend_env_create` | Create environment |

**bkit Current State**: Only guides using `0_get_context` to obtain org/project information. Dedicated management tools not listed.

**Fix Plan**:
- `skills/bkend-quickstart/SKILL.md`: Add MCP Project Tools section (9 tools)
- `agents/bkend-expert.md`: Add Project Management MCP Tools category

---

### GAP-04: `search_docs` Fixed Tool Undocumented (HIGH)

**Symptom**: Among the 3 Fixed Tools of bkend MCP, `search_docs` is completely absent from bkit skills/agents.

**Official Fixed Tools**:
| Tool | Listed in bkit |
|------|----------------|
| `get_context` | Yes (listed as 0_get_context) |
| `search_docs` | No (completely missing) |
| `get_operation_schema` | Yes (listed as 5_get_operation_schema) |

**Impact**: Auth and Storage have no dedicated MCP tools, so searching docs via `search_docs` and then generating REST API code is the **only MCP-based workflow**. Without this tool, MCP utilization for Auth/Storage is impossible.

**Fix Plan**:
- Add `search_docs` tool description to all bkend skills
- Add "`search_docs`-based MCP workflow" pattern to bkend-auth/SKILL.md, bkend-storage/SKILL.md
- Add `search_docs` to Fixed Tools in bkend-expert.md

---

### GAP-05: Guide Tool Name Mismatch (HIGH)

**Symptom**: bkit represents Guide Tools with numeric prefixes (`0_get_context`, `1_concepts`, etc.), but official documentation may use different names.

**bkit Listed (8 tools)**:
```
0_get_context, 1_concepts, 2_tutorial, 3_howto_implement_auth,
4_howto_implement_data_crud, 5_get_operation_schema,
6_code_examples_auth, 7_code_examples_data
```

**Official Fixed Tools (3 tools)**:
```
get_context, search_docs, get_operation_schema
```

**Difference**: In the official documentation, `1_concepts`, `2_tutorial`, etc. are NOT Fixed Tools. They are likely **document IDs** returned by `search_docs` results (e.g., `3_howto_implement_auth` is a document name found by search_docs).

**Fix Plan**:
- Fixed Tools (always available): Reclassify as `get_context`, `search_docs`, `get_operation_schema`
- Guide Docs (accessed via search_docs): Reclassify `1_concepts` ~ `7_code_examples_data` as "searchable documents"
- Clearly distinguish categories to prevent user confusion

---

### GAP-06: MCP Resources Undocumented (MEDIUM)

**Symptom**: bkend MCP provides a resource system with `bkend://` URI schema, but there is no mention of it in bkit.

**Official MCP Resources**:
| URI Pattern | Description |
|-------------|-------------|
| `bkend://orgs` | Organization list (read-only) |
| `bkend://orgs/{orgId}/projects` | Project list |
| `bkend://orgs/{orgId}/projects/{pId}/environments` | Environment list |
| `bkend://orgs/{orgId}/projects/{pId}/environments/{eId}/tables` | Table list (including schema) |

**Usage**: Resources are read-only queries with caching (TTL 60s), lighter than Tools.

**Fix Plan**:
- `templates/shared/bkend-patterns.md`: Add MCP Resources section
- `skills/bkend-quickstart/SKILL.md`: Add Resources usage guide
- `agents/bkend-expert.md`: Add Resources utilization guide

---

### GAP-07: Live Reference URL Path Error (MEDIUM)

**Symptom**: Live Reference URLs in bkit skills use incorrect paths.

| bkit Current Path | Actual Repository Path |
|-------------------|------------------------|
| `src/getting-started/` | `en/getting-started/` |
| `src/authentication/` | `en/authentication/` |
| `src/database/` | `en/database/` |
| `src/storage/` | `en/storage/` |
| `src/security/` | `en/security/` |
| `src/ai-tools/` | `en/ai-tools/` |
| `src/cookbooks/` | `en/cookbooks/` |
| `src/troubleshooting/` | `en/troubleshooting/` |

**Impact**: WebFetch returns 404 errors when fetching Live References.

**Fix Plan**:
- Batch update URLs from `src/` to `en/` across all 5 bkend skills + bkend-expert agent
- Verify exact filenames and replace with direct file URLs (directory URLs return 404 on GitHub)

---

### GAP-08: REST API Base URL Mismatch (MEDIUM)

**Symptom**: bkit's bkend-patterns.md uses `https://api.bkend.ai/v1` as Base URL, but the official MCP Context tool documentation references `https://api-client.bkend.ai`.

| Source | Base URL |
|--------|----------|
| bkit bkend-patterns.md | `https://api.bkend.ai/v1` |
| Official MCP Context docs | `https://api-client.bkend.ai` |

**Fix Plan**:
- Verify the exact Service API Base URL from the latest official bkend documentation
- Update `templates/shared/bkend-patterns.md`
- Specify that "API endpoint is included in the `get_context` response", recommending dynamic reference over hardcoding

---

### GAP-09: Auto System Field ID Mismatch (LOW)

**Symptom**: bkit bkend-data skill documents `_id` (MongoDB ObjectId style), but the official MCP Data Tools documentation uses `id` and explicitly states the "id (NOT _id)" rule.

**Fix Plan**:
- `skills/bkend-data/SKILL.md`: Change `_id` to `id`
- Specify `id` usage rule ("bkend API response uses `id`, not `_id`")

---

### GAP-10: MCP Detection Limited to Dynamic Level (LOW)

**Symptom**: The bkend MCP status check in `hooks/session-start.js` only runs under the `detectedLevel === 'Dynamic'` condition.

**Impact**: MCP status is not displayed for Enterprise-level projects using bkend.

**Fix Plan**:
- Expand condition to `detectedLevel === 'Dynamic' || detectedLevel === 'Enterprise'`

---

## 4. Target Files for Modification

| File | Modification Type | Related GAPs |
|------|-------------------|--------------|
| `skills/bkend-data/SKILL.md` | Major modification | GAP-01, 02, 05, 07, 09 |
| `agents/bkend-expert.md` | Major modification | GAP-01, 02, 03, 04, 05, 06, 07 |
| `skills/bkend-quickstart/SKILL.md` | Medium modification | GAP-03, 05, 06, 07 |
| `skills/bkend-auth/SKILL.md` | Medium modification | GAP-04, 05, 07 |
| `skills/bkend-storage/SKILL.md` | Medium modification | GAP-04, 05, 07 |
| `skills/bkend-cookbook/SKILL.md` | Minor modification | GAP-07 |
| `templates/shared/bkend-patterns.md` | Medium modification | GAP-06, 08 |
| `hooks/session-start.js` | Minor modification | GAP-10 |

**Total: 8 files, 10 GAPs to fix**

---

## 5. Implementation Priority

### Phase 1: CRITICAL Fixes (GAP-01, GAP-02)
- Add 5 Data CRUD MCP tools
- Verify and fix MCP Tool name accuracy
- **Expected affected files**: bkend-data/SKILL.md, bkend-expert.md

### Phase 2: HIGH Fixes (GAP-03, GAP-04, GAP-05)
- Add 9 Project/Env management tools
- Document search_docs Fixed Tool
- Reclassify Guide Tool vs Fixed Tool categories
- **Expected affected files**: All 5 bkend skills + bkend-expert.md

### Phase 3: MEDIUM Fixes (GAP-06, GAP-07, GAP-08)
- Document MCP Resources
- Fix Live Reference URL paths (src/ -> en/)
- Verify/fix REST API Base URL
- **Expected affected files**: All skills + templates + bkend-expert.md

### Phase 4: LOW Fixes (GAP-09, GAP-10)
- Fix ID field name (_id -> id)
- Expand MCP detection level
- **Expected affected files**: bkend-data/SKILL.md, session-start.js

---

## 6. MCP Tool Complete Reference (Target State After Fix)

### Fixed Tools (3) - Always Available

| Tool | Function | Parameters |
|------|----------|------------|
| `get_context` | Session context query (org/project/env) | None |
| `search_docs` | Search bkend documentation (Auth/Storage guide access) | query: string |
| `get_operation_schema` | Query specific tool's input/output schema | operation, schemaType |

### Project Management Tools (9) - Organization/Project/Environment Management

| Tool | Function | Key Parameters |
|------|----------|----------------|
| `backend_org_list` | List organizations | None |
| `backend_project_list` | List projects | organizationId |
| `backend_project_get` | Project details | organizationId, projectId |
| `backend_project_create` | Create project | organizationId, name |
| `backend_project_update` | Update project | organizationId, projectId |
| `backend_project_delete` | Delete project | organizationId, projectId |
| `backend_env_list` | List environments | organizationId, projectId |
| `backend_env_get` | Environment details | organizationId, projectId, environmentId |
| `backend_env_create` | Create environment | organizationId, projectId, name |

### Table Management Tools (Existing, Verification/Fix Required)

| Tool | Function | Note |
|------|----------|------|
| `backend_table_create` | Create table | Retain |
| `backend_table_list` | List tables | Retain |
| `backend_table_get` | Table details (including schema) | Retain |
| `backend_table_delete` | Delete table | Retain |
| `backend_field_manage` | Add/modify/delete fields | Retain |
| `backend_index_manage` | Add/delete indexes | Retain |
| `backend_schema_version_list` | Schema version list | Name verification needed |
| `backend_schema_version_get` | Schema version details | Newly added |
| `backend_schema_version_apply` | Apply schema version (rollback) | ~~backend_schema_rollback~~ name fix |
| `backend_index_version_list` | Index version list | Retain |
| `backend_index_version_get` | Index version details | Newly added |

### Data CRUD Tools (5) - Newly Added

| Tool | Function | Key Parameters |
|------|----------|----------------|
| `backend_data_list` | List query (filter/sort/pagination) | tableId, page, limit, sortBy, andFilters, orFilters |
| `backend_data_get` | Single record query | tableId, recordId |
| `backend_data_create` | Create record | tableId, data |
| `backend_data_update` | Update record (Partial Update) | tableId, recordId, data |
| `backend_data_delete` | Delete record | tableId, recordId |

### MCP Resources (4 URIs) - Newly Documented

| URI | Description | Cache TTL |
|-----|-------------|-----------|
| `bkend://orgs` | Organization list | 60s |
| `bkend://orgs/{orgId}/projects` | Project list | 60s |
| `bkend://orgs/{orgId}/projects/{pId}/environments` | Environment list | 60s |
| `bkend://orgs/{orgId}/projects/{pId}/environments/{eId}/tables` | Table list + schema | 60s |

### Searchable Docs (Accessed via search_docs) - Category Reclassification

| Doc ID | Content |
|--------|---------|
| `1_concepts` | BSON schema, permissions, resource hierarchy |
| `2_tutorial` | Project-to-table creation tutorial |
| `3_howto_implement_auth` | Authentication implementation guide |
| `4_howto_implement_data_crud` | CRUD implementation patterns |
| `6_code_examples_auth` | Authentication code examples |
| `7_code_examples_data` | CRUD + file upload code examples |

---

## 7. Verification Plan

### Verification Items

| Item | Verification Method | Pass Criteria |
|------|---------------------|---------------|
| MCP Tool name accuracy | Cross-reference with official docs | 100% match |
| MCP Tool count completeness | Official docs checklist | 0 omissions |
| Live Reference URLs | WebFetch test on each URL | 0 404 errors |
| REST API Base URL | Official docs verification | Correct URL reflected |
| MCP Resources documentation | Cross-reference with official docs | All 4 URIs listed |
| Gap Analysis | Run gap-detector | Match Rate >= 95% |

### Verification Procedure

1. Complete Phase 1-4 implementation
2. Cross-reference MCP tool names in each skill/agent file 1:1 with official docs
3. Verify accessibility of all Live Reference URLs via WebFetch
4. Run gap-detector agent for Design vs Implementation analysis
5. Generate Report when Match Rate reaches 95% or above

---

## 8. Risk Factors

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| bkend MCP API differs from documentation | Medium | High | Verify with get_operation_schema after actual MCP connection |
| Guide Tool names may actually use numeric prefix format | Medium | Medium | Verify with actual MCP tool list |
| bkend-docs may be updated and changed | Low | Medium | Use Live Reference URLs for dynamic latest doc reference |
| backend_table_update tool may actually exist | Medium | Low | Verify with get_operation_schema |

---

## 9. Success Criteria

- [ ] All 10 GAPs resolved
- [ ] 100% match between official docs and bkit implementation MCP Tool names
- [ ] 0 Live Reference URL 404 errors
- [ ] gap-detector Match Rate >= 95%
- [ ] All 8 modified files free of syntax/structural errors
