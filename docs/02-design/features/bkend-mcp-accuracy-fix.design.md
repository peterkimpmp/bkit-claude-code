# bkend MCP Accuracy Fix Design Document

> **Summary**: bkit v1.5.4 - Design for modifying 8 files to resolve 10 Gaps between bkend.ai MCP official documentation and bkit implementation. Following Context Engineering principles, bkend-patterns.md is strengthened as the Single Source of Truth, and MCP tool information in skills/agents is 100% synchronized with official documentation.
>
> **Project**: bkit-claude-code
> **Target Version**: v1.5.4
> **Author**: CTO Team (code-analyzer, gap-detector, integration-analyzer, design-validator, bkend-expert, enterprise-expert)
> **Date**: 2026-02-14
> **Status**: Draft
> **Planning Doc**: [bkend-mcp-accuracy-fix.plan.md](../../01-plan/features/bkend-mcp-accuracy-fix.plan.md)
> **Source of Truth**: https://github.com/popup-studio-ai/bkend-docs (en/mcp/, en/ai-tools/)

---

## 1. Overview

### 1.1 Design Goals

1. **100% MCP Tool Accuracy**: MCP tool names listed in bkit skills/agents match 100% with official bkend MCP documentation
2. **Complete Missing Tool Coverage**: Add Data CRUD 5 + Project 9 + search_docs 1 + schema/index version tools
3. **Live Reference Normalization**: All WebFetch URLs return 200 OK (0 404 errors)
4. **Context Engineering Optimization**: Strengthen bkend-patterns.md as Single Source of Truth, improve token efficiency
5. **Philosophy Self-Consistency**: Resolve all 10 violations of bkit's 4 core philosophies (Automation First, No Guessing, Docs=Code, Context Engineering)

### 1.2 Design Principles

- **Single Source of Truth**: MCP tool catalog is centralized in `bkend-patterns.md`, each skill focuses on domain-specific knowledge
- **Dynamic over Static**: REST API Base URL uses dynamic `get_context` reference pattern instead of hardcoding
- **Convention Over Configuration**: Strictly follow the existing bkit skill/agent file format (YAML frontmatter + Markdown body)
- **Backward Compatibility**: Existing `mcp__bkend__*` wildcard permissions are maintained, additional tools are automatically included

### 1.3 Non-Goals

- Modifying the bkend.ai MCP server itself (only bkit-side documentation is modified)
- Changing the bkend-expert agent's tool list (tools field) (indirect permission via skills_preload is sufficient)
- Exhaustively listing all 46 additional REST Auth API endpoints (addressed by correcting key endpoints + Live Reference dynamic lookups)
- Adding MCP configuration to plugin.json (users need to run `claude mcp add` per their environment)

---

## 2. Architecture

### 2.1 Before and After Comparison

```
Before (v1.5.3):
┌─────────────────────────────────────────────────────────────────────┐
│ bkend-expert agent                                                   │
│   skills_preload: [bkend-data, bkend-auth, bkend-storage]          │
│   MCP Tools (19): Guide 8 + Table API 11                            │
│                                                                      │
│ bkend-patterns.md (85 lines, 10/18 items)                            │
│   @import → 5 skills                                                 │
│                                                                      │
│ Missing: Data CRUD 5, Project 9, search_docs 1, Resources 4 URI    │
│ Wrong: Tool names 3, Live URLs all 404, Base URL mismatch           │
└─────────────────────────────────────────────────────────────────────┘

After (v1.5.4):
┌─────────────────────────────────────────────────────────────────────┐
│ bkend-expert agent                                                   │
│   skills_preload: [bkend-data, bkend-auth, bkend-storage]          │
│   MCP Tools (28+): Fixed 3 + Project 9 + Table 11 + Data 5         │
│   MCP Resources: 4 bkend:// URI                                     │
│                                                                      │
│ bkend-patterns.md (~150 lines, 18/18 items, Single Source of Truth)  │
│   @import → 5 skills (auto-propagated)                               │
│                                                                      │
│ Fixed: 10 GAPs resolved, Live URLs 200 OK, Base URL dynamic        │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Context Engineering Layer Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│              bkend Context Engineering Layers (v1.5.4)               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Layer 1: Shared Template (Single Source of Truth)                   │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ templates/shared/bkend-patterns.md                              │ │
│  │                                                                  │ │
│  │ - MCP Tool Complete Catalog (Fixed 3 + API 25 = 28)            │ │
│  │ - MCP Resources (4 bkend:// URI, TTL 60s)                     │ │
│  │ - REST API Patterns (dynamic base URL, headers, errors)        │ │
│  │ - Response Format ({ items, pagination })                      │ │
│  │ - Filter Operators (8: $eq,$ne,$gt,$gte,$lt,$lte,$in,$nin)    │ │
│  │ - ID Field Rule: "id" (NOT "_id")                              │ │
│  └────────────────────────────────────────────────────────────────┘ │
│           │ @import                                                  │
│           ▼                                                          │
│  Layer 2: Domain Skills (Specialized Knowledge)                      │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │
│  │bkend-data    │ │bkend-auth    │ │bkend-storage │                │
│  │              │ │              │ │              │                │
│  │Data CRUD     │ │search_docs   │ │search_docs   │                │
│  │Tool params   │ │→Auth workflow│ │→Storage work-│                │
│  │Filter/sort   │ │REST Auth API │ │REST File API │                │
│  │detail        │ │RBAC/RLS guide│ │Presigned URL │                │
│  │Index mgmt    │ │              │ │              │                │
│  └──────────────┘ └──────────────┘ └──────────────┘                │
│  ┌──────────────┐ ┌──────────────┐                                  │
│  │bkend-        │ │bkend-        │                                  │
│  │quickstart    │ │cookbook       │                                  │
│  │              │ │              │                                  │
│  │Project Tools │ │Tutorials     │                                  │
│  │MCP Resources │ │Troubleshoot  │                                  │
│  │Env mgmt     │ │FAQ           │                                  │
│  └──────────────┘ └──────────────┘                                  │
│           │                                                          │
│           ▼                                                          │
│  Layer 3: Orchestrating Agent                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ bkend-expert (model: sonnet)                                    │ │
│  │ skills_preload: [bkend-data, bkend-auth, bkend-storage]       │ │
│  │ skills: [dynamic, bkend-quickstart, ..., bkend-cookbook]       │ │
│  │ tools: [Read,Write,Edit,Glob,Grep,Bash,WebFetch]              │ │
│  │ allowed-tools from skills: mcp__bkend__* (wildcard inherited) │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Layer 4: Integration Points                                        │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │
│  │session-      │ │bkit.config   │ │lib/intent/   │                │
│  │start.js      │ │.json         │ │language.js   │                │
│  │MCP detection │ │Level detect  │ │Trigger       │                │
│  │(Dynamic+Ent) │ │(.mcp.json)   │ │patterns      │                │
│  │              │ │              │ │(8 languages) │                │
│  └──────────────┘ └──────────────┘ └──────────────┘                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Detailed Changes per File

### 3.1 templates/shared/bkend-patterns.md (Single Source of Truth Strengthening)

**Change Scale**: Major expansion (85 lines -> ~170 lines)
**Related GAPs**: GAP-04, GAP-05, GAP-06, GAP-08, GAP-09
**Philosophy Alignment**: CE-01 (Context Engineering Optimization), V-NG-04 (No Guessing)

#### 3.1.1 New Sections

**A. MCP Fixed Tools (New)**
```markdown
## MCP Fixed Tools (Always Available)

| Tool | Purpose | Parameters |
|------|---------|------------|
| `get_context` | Session context (org/project/env, API endpoint) | None |
| `search_docs` | Search bkend documentation (Auth/Storage guides) | query: string |
| `get_operation_schema` | Get tool input/output schema | operation: string, schemaType: "input" \| "output" |

**Important**: `get_context` MUST be called first. It returns the API endpoint URL dynamically.
```

**B. MCP Resources (New)**
```markdown
## MCP Resources (Read-Only, Cached)

| URI Pattern | Description | Cache TTL |
|-------------|-------------|-----------|
| `bkend://orgs` | Organization list | 60s |
| `bkend://orgs/{orgId}/projects` | Project list | 60s |
| `bkend://orgs/{orgId}/projects/{pId}/environments` | Environment list | 60s |
| `bkend://orgs/{orgId}/projects/{pId}/environments/{eId}/tables` | Table list with schema | 60s |

Access via `resources/list` and `resources/read` MCP methods.
Prefer Resources over Tools for read-only listing (lighter, cached).
```

**C. API Response Format (New)**
```markdown
## API Response Format

List responses use consistent pagination:
```json
{
  "items": [...],
  "pagination": { "page": 1, "limit": 20, "total": 100, "totalPages": 5 }
}
```

**ID Field**: Always use `id` (NOT `_id`).
```

**D. Filter & Pagination (New)**
```markdown
## Query Parameters

### Filtering
- AND filter: `?filter[field]=value` (multiple fields = AND)
- Operators: `$eq`, `$ne`, `$gt`, `$gte`, `$lt`, `$lte`, `$in`, `$nin`
- Text search: `?search=keyword`

### Pagination & Sorting
- Page: `?page=1` (default: 1)
- Limit: `?limit=20` (default: 20, max: 100)
- Sort: `?sort=field:asc` (or `desc`)
```

**E. Presigned URL (New)**
```markdown
## File Upload (Presigned URL)

- Presigned URL validity: 15 minutes
- Upload via PUT method with Content-Type header
- Complete upload by registering metadata: POST /v1/files
```

#### 3.1.2 Modifications

**Base URL Fix** (GAP-08):
```markdown
## REST Service API

Base URL is provided dynamically by `get_context` response.
Typical endpoints:
- MCP: https://api.bkend.ai/mcp
- Service API: Use the endpoint from `get_context` (e.g., https://api-client.bkend.ai/v1)

**Important**: Do NOT hardcode the Service API base URL. Always reference `get_context` output.
```

**ID Field Fix** (GAP-09):
- Since `_id` is not mentioned anywhere currently, only the `id (NOT _id)` rule is explicitly stated in bkend-patterns.md

---

### 3.2 skills/bkend-data/SKILL.md (Data CRUD Tool Addition)

**Change Scale**: Major expansion
**Related GAPs**: GAP-01 (CRITICAL), GAP-02 (CRITICAL), GAP-05, GAP-07, GAP-09

#### 3.2.1 MCP Data CRUD Tools Section Addition (GAP-01)

New section added under existing "MCP Database Tools":

```markdown
## MCP Data CRUD Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `backend_data_list` | List records (filter, sort, paginate) | tableId, page?, limit?, sortBy?, sortDirection?, andFilters?, orFilters? |
| `backend_data_get` | Get single record | tableId, recordId |
| `backend_data_create` | Create record | tableId, data: { field: value } |
| `backend_data_update` | Partial update record | tableId, recordId, data: { field: value } |
| `backend_data_delete` | Delete record | tableId, recordId |

All Data CRUD tools require: organizationId, projectId, environmentId (from `get_context`).

### Filter Operators
| Operator | Meaning | Example |
|----------|---------|---------|
| `$eq` | Equal | `{ "status": { "$eq": "active" } }` |
| `$ne` | Not equal | `{ "role": { "$ne": "admin" } }` |
| `$gt` / `$gte` | Greater than / >= | `{ "age": { "$gt": 18 } }` |
| `$lt` / `$lte` | Less than / <= | `{ "price": { "$lt": 100 } }` |
| `$in` / `$nin` | In / Not in array | `{ "tag": { "$in": ["a","b"] } }` |
```

#### 3.2.2 MCP Tool Name Corrections (GAP-02)

| Current | After Fix | Reason |
|---------|-----------|--------|
| `backend_table_update` | Removed | Not in official documentation |
| `backend_schema_rollback` | `backend_schema_version_apply` | Official name |
| `backend_index_rollback` | Removed (comment out if verification needed) | Not in official documentation |
| (none) | `backend_schema_version_get` added | Exists in official documentation |
| (none) | `backend_index_version_get` added | Exists in official documentation |

Updated MCP Database Tools table:
```markdown
## MCP Table Management Tools

| Tool | Purpose | Scope |
|------|---------|-------|
| `backend_table_create` | Create table | table:create |
| `backend_table_list` | List tables | table:read |
| `backend_table_get` | Get table detail + schema | table:read |
| `backend_table_delete` | Delete table | table:delete |
| `backend_field_manage` | Add/modify/delete fields | table:update |
| `backend_index_manage` | Manage indexes | table:update |
| `backend_schema_version_list` | Schema version history | table:read |
| `backend_schema_version_get` | Schema version detail | table:read |
| `backend_schema_version_apply` | Apply schema version (rollback) | table:update |
| `backend_index_version_list` | Index version history | table:read |
| `backend_index_version_get` | Index version detail | table:read |
```

#### 3.2.3 Guide Tools Reclassification (GAP-05)

```markdown
## MCP Guide Docs (via search_docs)

Use `search_docs` tool to access these guides:

| Doc ID | Content |
|--------|---------|
| `4_howto_implement_data_crud` | CRUD implementation patterns |
| `7_code_examples_data` | CRUD + file upload code examples |

Use `get_operation_schema` to get any tool's input/output schema.
```

#### 3.2.4 Auto System Fields Fix (GAP-09)

```markdown
## Auto System Fields

| Field | Type | Description |
|-------|------|-------------|
| id | String | Auto-generated unique ID |
| createdBy | String | Creator user ID |
| createdAt | Date | Creation timestamp |
| updatedAt | Date | Last update timestamp |

**Important**: bkend uses `id` (NOT `_id`) in all API responses.
```

#### 3.2.5 Live Reference URL Fix (GAP-07)

```markdown
## Official Documentation (Live Reference)

For the latest database documentation, use WebFetch:
- MCP Data Tools: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/05-data-tools.md
- MCP Table Tools: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/04-table-tools.md
- Database Guide: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/database/01-overview.md
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
```

---

### 3.3 skills/bkend-auth/SKILL.md (search_docs Workflow Addition)

**Change Scale**: Medium
**Related GAPs**: GAP-04 (HIGH), GAP-05, GAP-07

#### 3.3.1 MCP Auth Workflow Rewrite (GAP-04)

Before:
```markdown
## MCP Auth Tools
| 3_howto_implement_auth | Authentication implementation patterns |
| 6_code_examples_auth | Authentication code examples |
```

After:
```markdown
## MCP Auth Workflow

bkend MCP does NOT have dedicated auth tools. Use this workflow:

1. **Search docs**: `search_docs` with query "email signup" or "social login"
2. **Get examples**: `search_docs` with query "auth code examples"
3. **Generate code**: AI generates REST API code based on search results

### Searchable Auth Docs
| Doc ID | Content |
|--------|---------|
| `3_howto_implement_auth` | Signup, login, token management guide |
| `6_code_examples_auth` | Email, social, magic link code examples |

### Key Pattern
```
User: "Add social login"
  → search_docs(query: "social login implementation")
  → Returns auth guide with REST API patterns
  → AI generates Next.js social login code
```
```

#### 3.3.2 REST Auth API Corrections

Key discrepancy fixes:

| Current bkit | Fix | Reason |
|--------------|-----|--------|
| `GET /v1/auth/{provider}/authorize` | Remove or comment out | Not in official documentation |
| `POST /v1/auth/{provider}/callback` | `GET/POST /v1/auth/:provider/callback` | Method correction |
| `POST /v1/auth/email/verify/send` | Fix after path verification | Path mismatch with official documentation |
| `DELETE /v1/auth/account` | `DELETE /v1/auth/withdraw` | Path correction |
| `POST /v1/auth/social/link/unlink` | Remove or comment out | Not in official documentation |
| `GET /v1/auth/exists` | Remove or comment out | Not in official documentation |

**Note**: Endpoints not in the official documentation (authorize, social/link, etc.) may actually exist in the bkend API. In bkit, only endpoints confirmed by official documentation are listed, and unconfirmed endpoints are handled via Live Reference dynamic lookups.

```markdown
## REST Auth API (Core Endpoints)

For the complete endpoint list, use `search_docs` or check Live Reference.

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /v1/auth/email/signup | Sign up |
| POST | /v1/auth/email/signin | Sign in |
| GET | /v1/auth/me | Current user |
| POST | /v1/auth/refresh | Refresh token |
| POST | /v1/auth/signout | Sign out |
| GET/POST | /v1/auth/:provider/callback | Social login callback |
| POST | /v1/auth/password/reset/request | Password reset |
| POST | /v1/auth/password/reset/confirm | Confirm reset |
| POST | /v1/auth/password/change | Change password |
| GET | /v1/auth/sessions | List sessions |
| DELETE | /v1/auth/sessions/:sessionId | Remove session |
| DELETE | /v1/auth/withdraw | Delete account |

**Additional endpoints** (MFA, invitations, user management): use `search_docs` or Live Reference.
```

#### 3.3.3 Live Reference URL Fix (GAP-07)

```markdown
## Official Documentation (Live Reference)

For the latest authentication documentation, use WebFetch:
- Auth Overview: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/authentication/01-overview.md
- MCP Auth Guide: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/06-auth-tools.md
- Security: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/security/01-overview.md
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
```

---

### 3.4 skills/bkend-storage/SKILL.md (search_docs Workflow Addition)

**Change Scale**: Medium
**Related GAPs**: GAP-04 (HIGH), GAP-05, GAP-07

#### 3.4.1 MCP Storage Workflow Rewrite (GAP-04)

After:
```markdown
## MCP Storage Workflow

bkend MCP does NOT have dedicated storage tools. Use this workflow:

1. **Search docs**: `search_docs` with query "file upload presigned url"
2. **Get examples**: `search_docs` with query "file upload code examples"
3. **Generate code**: AI generates REST API code for file operations

### Searchable Storage Docs
| Doc ID | Content |
|--------|---------|
| `7_code_examples_data` | CRUD + file upload code examples |
```

#### 3.4.2 REST Storage API Corrections

| Current bkit | Fix | Reason |
|--------------|-----|--------|
| `GET /v1/files/{id}/download-url` | `POST /v1/files/:fileId/download-url` | Method change GET -> POST |
| (none) | Add 4 multipart upload endpoints | Exist in official documentation |

Addition:
```markdown
## Multipart Upload (Large Files)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /v1/files/multipart/init | Initialize multipart upload |
| POST | /v1/files/multipart/presigned-url | Get part upload URL |
| POST | /v1/files/multipart/complete | Complete multipart upload |
| POST | /v1/files/multipart/abort | Abort multipart upload |
```

#### 3.4.3 Live Reference URL Fix (GAP-07)

```markdown
## Official Documentation (Live Reference)

For the latest storage documentation, use WebFetch:
- Storage Overview: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/storage/01-overview.md
- MCP Storage Guide: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/07-storage-tools.md
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
```

---

### 3.5 skills/bkend-quickstart/SKILL.md (Project Tools + Resources Addition)

**Change Scale**: Medium
**Related GAPs**: GAP-03 (HIGH), GAP-05, GAP-06, GAP-07

#### 3.5.1 MCP Project Tools Addition (GAP-03)

```markdown
## MCP Project Management Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `backend_org_list` | List organizations | None |
| `backend_project_list` | List projects | organizationId |
| `backend_project_get` | Get project detail | organizationId, projectId |
| `backend_project_create` | Create project | organizationId, name, description? |
| `backend_project_update` | Update project | organizationId, projectId, name?, description? |
| `backend_project_delete` | Delete project (irreversible!) | organizationId, projectId |
| `backend_env_list` | List environments | organizationId, projectId |
| `backend_env_get` | Get environment detail | organizationId, projectId, environmentId |
| `backend_env_create` | Create environment | organizationId, projectId, name |
```

#### 3.5.2 MCP Resources Addition (GAP-06)

```markdown
## MCP Resources (Read-Only)

Lightweight, cached (60s TTL) read-only queries via bkend:// URI:

| URI | Description |
|-----|-------------|
| `bkend://orgs` | Organization list |
| `bkend://orgs/{orgId}/projects` | Project list |
| `bkend://orgs/{orgId}/projects/{pId}/environments` | Environment list |
| `bkend://orgs/{orgId}/projects/{pId}/environments/{eId}/tables` | Table list with schema |

**Tip**: Prefer Resources over Tools for listing operations (lighter, cached).
```

#### 3.5.3 Guide Tools Reclassification (GAP-05)

```markdown
## MCP Fixed Tools

| Tool | Purpose |
|------|---------|
| `get_context` | Session context (org/project/env, API endpoint) |
| `search_docs` | Search bkend documentation |
| `get_operation_schema` | Get tool input/output schema |

## Searchable Guides (via search_docs)

| Doc ID | Content |
|--------|---------|
| `1_concepts` | BSON schema, permissions, hierarchy |
| `2_tutorial` | Project~table creation tutorial |
```

#### 3.5.4 Live Reference URL Fix (GAP-07)

```markdown
## Official Documentation (Live Reference)

For the latest bkend documentation, use WebFetch:
- Quick Start: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/getting-started/02-quick-start.md
- Core Concepts: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/getting-started/03-core-concepts.md
- Claude Code Setup: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/ai-tools/04-claude-code-setup.md
- MCP Overview: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/01-overview.md
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
```

---

### 3.6 skills/bkend-cookbook/SKILL.md (Live Reference URL Fix)

**Change Scale**: Minor
**Related GAP**: GAP-07

```markdown
## Official Documentation (Live Reference)

For the latest cookbook and troubleshooting, use WebFetch:
- Cookbooks: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/cookbooks/blog/01-quick-start.md
- Troubleshooting: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/troubleshooting/01-common-errors.md
- Full TOC: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
```

---

### 3.7 agents/bkend-expert.md (MCP Tool Catalog Update)

**Change Scale**: Major
**Related GAPs**: GAP-01, GAP-02, GAP-03, GAP-04, GAP-05, GAP-06, GAP-07

#### 3.7.1 MCP Tools Section Full Rewrite

Before "MCP Tools (19)" -> After "MCP Tools (28+)":

```markdown
## MCP Tools

### Fixed Tools (Always Available)

| Tool | Purpose |
|------|---------|
| `get_context` | Session context (org/project/env, API endpoint) - MUST call first |
| `search_docs` | Search bkend docs (Auth/Storage guides, code examples) |
| `get_operation_schema` | Get tool input/output schema |

### Project Management Tools

| Tool | Purpose |
|------|---------|
| `backend_org_list` | List organizations |
| `backend_project_list` | List projects |
| `backend_project_get` | Get project detail |
| `backend_project_create` | Create project |
| `backend_project_update` | Update project |
| `backend_project_delete` | Delete project |
| `backend_env_list` | List environments |
| `backend_env_get` | Get environment detail |
| `backend_env_create` | Create environment |

### Table Management Tools

| Tool | Purpose | Scope |
|------|---------|-------|
| `backend_table_create` | Create table | table:create |
| `backend_table_list` | List tables | table:read |
| `backend_table_get` | Get detail + schema | table:read |
| `backend_table_delete` | Delete table | table:delete |
| `backend_field_manage` | Add/modify/delete fields | table:update |
| `backend_index_manage` | Index management | table:update |
| `backend_schema_version_list` | Schema version history | table:read |
| `backend_schema_version_get` | Schema version detail | table:read |
| `backend_schema_version_apply` | Apply schema version (rollback) | table:update |
| `backend_index_version_list` | Index version history | table:read |
| `backend_index_version_get` | Index version detail | table:read |

### Data CRUD Tools

| Tool | Purpose |
|------|---------|
| `backend_data_list` | List records (filter, sort, paginate) |
| `backend_data_get` | Get single record |
| `backend_data_create` | Create record |
| `backend_data_update` | Partial update record |
| `backend_data_delete` | Delete record |

### MCP Resources (Read-Only, Cached 60s)

| URI | Description |
|-----|-------------|
| `bkend://orgs` | Organization list |
| `bkend://orgs/{orgId}/projects` | Project list |
| `bkend://orgs/{orgId}/projects/{pId}/environments` | Environment list |
| `bkend://orgs/{orgId}/projects/{pId}/environments/{eId}/tables` | Table list + schema |

### Searchable Docs (via search_docs)

| Doc ID | Content |
|--------|---------|
| `1_concepts` | BSON schema, permissions, hierarchy |
| `2_tutorial` | Project~table creation guide |
| `3_howto_implement_auth` | Auth implementation patterns |
| `4_howto_implement_data_crud` | CRUD implementation patterns |
| `6_code_examples_auth` | Auth code examples |
| `7_code_examples_data` | CRUD + file upload examples |
```

#### 3.7.2 Service API Section Fix

```markdown
## Service API (REST)

### Base URL
Provided dynamically by `get_context`. Do NOT hardcode.
Typical: `https://api-client.bkend.ai/v1`

### Required Headers
```
x-project-id: {projectId}
x-environment: dev|staging|prod
Authorization: Bearer {accessToken}
```

### ID Field
Always use `id` (NOT `_id`) in API responses.
```

#### 3.7.3 Live Reference URL Fix (GAP-07)

```markdown
## Official Documentation (Live Reference)

When you need the latest bkend documentation, use WebFetch with these URLs:

- **Full TOC**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/SUMMARY.md
- **MCP Overview**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/01-overview.md
- **MCP Context**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/02-context.md
- **MCP Project Tools**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/03-project-tools.md
- **MCP Table Tools**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/04-table-tools.md
- **MCP Data Tools**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/05-data-tools.md
- **MCP Auth**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/06-auth-tools.md
- **MCP Storage**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/mcp/07-storage-tools.md
- **Claude Code Setup**: https://raw.githubusercontent.com/popup-studio-ai/bkend-docs/main/en/ai-tools/04-claude-code-setup.md

**Usage**: Fetch SUMMARY.md first to find the exact page, then fetch that specific page.
```

---

### 3.8 hooks/session-start.js (MCP Detection Level Expansion)

**Change Scale**: Minor (1 line change)
**Related GAP**: GAP-10 (LOW)

#### Change Details

File location: `hooks/session-start.js` line 567

```javascript
// Before (v1.5.3):
if (detectedLevel === 'Dynamic') {

// After (v1.5.4):
if (detectedLevel === 'Dynamic' || detectedLevel === 'Enterprise') {
```

**Reason**: Enterprise projects can also use bkend as a BaaS (utilizing bkend as part of microservices).

---

## 4. GAP Resolution Matrix

| GAP ID | Severity | Modified Files | Changes | Philosophy Violations Resolved |
|--------|----------|----------------|---------|-------------------------------|
| GAP-01 | CRITICAL | bkend-data, bkend-expert | Add 5 Data CRUD tools | V-AF-01, V-DC-02 |
| GAP-02 | CRITICAL | bkend-data, bkend-expert | Fix tool names (rollback -> version_apply, etc.) | V-NG-01 |
| GAP-03 | HIGH | bkend-quickstart, bkend-expert | Add 9 Project/Env management tools | V-AF-01 |
| GAP-04 | HIGH | bkend-auth, bkend-storage, bkend-patterns | Add search_docs workflow | V-AF-02, V-NG-02 |
| GAP-05 | HIGH | All bkend skills, bkend-expert | Reclassify Fixed Tool vs Searchable Docs | V-NG-03 |
| GAP-06 | MEDIUM | bkend-quickstart, bkend-patterns, bkend-expert | Add 4 MCP Resources URIs | V-AF-03, CE-01 |
| GAP-07 | MEDIUM | All bkend skills, bkend-expert | Fix Live Reference URLs src/ -> en/ | V-NG-02, V-DC-01 |
| GAP-08 | MEDIUM | bkend-patterns, bkend-expert | Switch to dynamic Base URL reference pattern | V-NG-04, CE-01 |
| GAP-09 | LOW | bkend-data | Fix _id -> id | V-DC-03 |
| GAP-10 | LOW | session-start.js | Expand Dynamic -> Dynamic\|Enterprise | V-AF-03 |

---

## 5. Implementation Order

### Phase 1: Foundation (bkend-patterns.md)
1. Expand bkend-patterns.md (MCP Fixed Tools, Resources, Response Format, Filters, ID Rule)
2. Switch Base URL to dynamic reference pattern

**Reason**: Highest priority since all 5 skills reference it via @import

### Phase 2: CRITICAL Fix (bkend-data, bkend-expert)
3. bkend-data/SKILL.md: Add 5 Data CRUD tools, fix tool names, fix ID field
4. bkend-expert.md: Full rewrite of MCP Tools section (19 -> 28+)

### Phase 3: HIGH Fix (bkend-auth, bkend-storage, bkend-quickstart)
5. bkend-auth/SKILL.md: search_docs workflow, REST endpoint corrections
6. bkend-storage/SKILL.md: search_docs workflow, multipart addition, download-url method fix
7. bkend-quickstart/SKILL.md: 9 Project Tools, Resources, Fixed Tools reclassification

### Phase 4: URL Fix + Integration
8. Batch fix Live Reference URLs across all 6 files (src/ -> en/, specific file paths)
9. bkend-cookbook/SKILL.md: Fix Live Reference URLs only
10. hooks/session-start.js: 1 line MCP detection condition change

---

## 6. Token Budget Impact Analysis

### Pre-Fix Token Consumption (v1.5.3 Estimate)

| Component | Lines | Est. Tokens | Effectiveness |
|-----------|-------|-------------|---------------|
| bkend-patterns.md | 85 | ~600 | 55.6% valid |
| bkend-data/SKILL.md | 122 | ~900 | MCP Data CRUD 0% |
| bkend-auth/SKILL.md | 118 | ~850 | search_docs 0% |
| bkend-storage/SKILL.md | 110 | ~800 | search_docs 0% |
| bkend-quickstart/SKILL.md | 118 | ~850 | Project Tools 0% |
| bkend-cookbook/SKILL.md | 101 | ~700 | Live URL 0% |
| bkend-expert.md | 231 | ~1,700 | 19/28+ tools |
| **Total** | **885** | **~6,400** | **Partially valid** |

### Post-Fix Token Consumption (v1.5.4 Estimate)

| Component | Lines | Est. Tokens | Effectiveness |
|-----------|-------|-------------|---------------|
| bkend-patterns.md | ~170 | ~1,200 | 100% valid (SSOT) |
| bkend-data/SKILL.md | ~170 | ~1,200 | Data CRUD 100% |
| bkend-auth/SKILL.md | ~125 | ~900 | search_docs workflow |
| bkend-storage/SKILL.md | ~130 | ~950 | search_docs + multipart |
| bkend-quickstart/SKILL.md | ~160 | ~1,150 | Project + Resources |
| bkend-cookbook/SKILL.md | ~105 | ~750 | Live URL normal |
| bkend-expert.md | ~270 | ~2,000 | 28+ tools complete |
| **Total** | **~1,130** | **~8,150** | **100% valid** |

**Token Increase**: ~1,750 tokens (+27%)
**Token Effectiveness Increase**: Partially valid -> 100% valid (0 incorrect information, 0 404 URLs)
**Net Effectiveness**: Investing 1,750 additional tokens restores 100% MCP automation paths -> **Very high ROI**

---

## 7. Verification Plan

### 7.1 Automated Verification (gap-detector)

| Verification Item | Expected Result | Tool |
|-------------------|-----------------|------|
| MCP Tool name match rate | 100% (0 mismatches) | gap-detector |
| Missing MCP Tool count | 0 (all 28+ listed) | gap-detector |
| Live Reference URL success rate | 100% (0 404 errors) | WebFetch test |
| Design-Implementation Match Rate | >= 95% | gap-detector |

### 7.2 Manual Verification (MCP Connection Test)

| Verification Item | Method |
|-------------------|--------|
| Guide Tool actual names | Run `claude mcp list` and check actual exposed names |
| backend_table_update existence | Call `get_operation_schema("backend_table_update","input")` |
| backend_schema_rollback existence | Call `get_operation_schema("backend_schema_rollback","input")` |
| backend_index_rollback existence | Call `get_operation_schema("backend_index_rollback","input")` |
| Service API Base URL | Call `get_context` and check endpoint field |

### 7.3 Success Criteria

- [ ] All 10 GAPs resolved
- [ ] 100% match between official documentation and MCP Tool names
- [ ] 0 Live Reference URL 404 errors
- [ ] gap-detector Match Rate >= 95%
- [ ] 0 YAML frontmatter syntax errors across 8 modified files
- [ ] Confirm `mcp__bkend__*` wildcard permission is maintained

---

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Guide Tool names may actually use number prefix format (0_, 1_) | Medium | Medium | Classify as "Searchable Docs" category during fix so correct guides are provided regardless of direct invocation |
| backend_table_update may actually exist | Medium | Low | Comment out with "verification needed" instead of deleting, verify via MCP connection test |
| bkend-docs may be updated with changed file paths | Low | Medium | Design Live Reference with pattern that references SUMMARY.md first |
| Token increase causing context window pressure | Low | Low | +1,750 tokens is negligible relative to total context, offset by 100% effectiveness improvement |
| SSOT expansion of bkend-patterns.md causing duplicate information | Low | Low | Each skill focuses only on domain-specific knowledge, common information is delegated to patterns |

---

## 9. Philosophy Alignment Summary

| Philosophy | v1.5.3 Violations | v1.5.4 Resolution |
|------------|-------------------|-------------------|
| **Automation First** | Data CRUD/Auth/Storage MCP automation impossible (3 cases) | Full automation restored with 28+ MCP tools + search_docs workflow |
| **No Guessing** | Incorrect tool names/URLs/categories inducing guesswork (4 cases) | 100% accurate tool names, working URLs, clear category classification |
| **Docs = Code** | bkit's own Design-Implementation Gap ~30% (3 cases) | 100% synchronization between bkit skills (Design) and bkend MCP (Implementation) |
| **Context Engineering** | Token inversion (consumed on incorrect info, missing critical info) | SSOT strengthened, 404 URLs removed, critical tool info added = optimal context |

**Conclusion**: The bkend MCP Accuracy Fix is a **self-consistency assurance effort** that applies bkit's 4 core philosophies to bkit itself, and is the key quality improvement of v1.5.4.
