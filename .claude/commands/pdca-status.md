---
description: Check current PDCA progress status
allowed-tools: ["Read", "Glob", "Grep"]
---

# PDCA Status Check

## Tasks Performed

1. **Scan Document Folders**
   - docs/01-plan/ (or 00-requirement/)
   - docs/02-design/ (or 01-development/)
   - docs/03-analysis/ (or 03-refactoring/)
   - docs/04-report/ (or 04-operation/)

2. **Check Status per Folder**
   - Count documents
   - Status of each document (Approved/In Progress/On Hold)
   - Last modified date

3. **Output PDCA Status Summary**

## Output Format

```
┌─────────────────────────────────────────────────────────┐
│                    PDCA Status Overview                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Current Level: Dynamic                                 │
│  Project: {project_name}                                │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  Phase          │ Docs  │ Approved │ In Progress │ Last Modified │
├────────────────┼───────┼──────────┼─────────────┼──────────────┤
│  📋 Plan       │   3   │    2     │      1      │ 2024-12-10   │
│  📐 Design     │   5   │    3     │      2      │ 2024-12-12   │
│  🔍 Analysis   │   2   │    1     │      1      │ 2024-12-11   │
│  📊 Report     │   1   │    1     │      0      │ 2024-12-08   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Current Active Cycles:                                 │
│  - login feature: Design phase (In Progress)           │
│  - signup feature: Check phase (Analysis needed)       │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  Recommended Next Actions:                              │
│  1. Complete login.design.md                           │
│  2. Run Gap analysis for signup (/pdca-analyze signup) │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Status Determination Criteria

- **Approved**: frontmatter has `status: Approved` or status emoji ✅
- **In Progress**: `status: Draft` or 🔄
- **On Hold**: `status: On Hold` or ⏸️

## Next Step Suggestions

Suggest appropriate next actions based on document status:
- Only Plan exists → Recommend writing Design
- Only Design exists → Recommend implementation or Check
- Implementation complete → Recommend Check (Gap analysis)
- Check complete → Recommend Act (report)
