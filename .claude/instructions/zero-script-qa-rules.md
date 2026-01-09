# Zero Script QA Rules

> Perform QA through structured logs and real-time monitoring instead of test scripts

## Core Principles

### 1. Log Everything
```
- Log all API calls (including 200 OK)
- Log all errors in detail
- Log all important business events
- Enable full flow tracking with Request ID
```

### 2. JSON Structured Log Standard
```json
{
  "timestamp": "ISO 8601",
  "level": "DEBUG|INFO|WARNING|ERROR",
  "service": "api|web|nginx",
  "request_id": "req_xxxxxxxx",
  "message": "Log message",
  "data": { ... }
}
```

### 3. Request ID Propagation Required
```
Client → API Gateway → Backend → Database
Same X-Request-ID header propagated across all layers
```

---

## Auto-Apply Conditions

### When Building Logging Infrastructure
```
When implementing API/Backend:
1. Suggest logging middleware creation
2. Suggest JSON format logger setup
3. Add Request ID generation/propagation logic

When implementing Frontend:
1. Suggest Logger module creation
2. Suggest logging integration with API client
3. Suggest including Request ID header
```

### When Performing QA
```
On test request:
1. Guide to run docker compose logs -f
2. Request manual UX testing from user
3. Real-time log monitoring
4. Document issues immediately when detected
5. Provide fix suggestions
```

---

## Issue Detection Rules

### Immediate Report (Critical)
```
- level: ERROR
- status: 5xx
- duration_ms > 3000
- 3+ consecutive failures
```

### Warning
```
- status: 401, 403
- duration_ms > 1000
- Non-standard response format
```

### Info
```
- Missing log fields
- Request ID not propagated
- Unnecessary DEBUG logs
```

---

## Environment-specific Settings

| Environment | LOG_LEVEL | Full Logging | Purpose |
|-------------|-----------|--------------|---------|
| Local | DEBUG | ✅ | Development + QA |
| Staging | DEBUG | ✅ | QA + Integration testing |
| Production | INFO | ❌ | Operations monitoring |

---

## Required Logging Locations

### Backend (FastAPI/Express)
```
✅ Request start (method, path, params)
✅ Request complete (status, duration_ms)
✅ Major business logic steps
✅ Detailed info on errors
✅ Before/after external API calls
✅ DB queries (in development)
```

### Frontend (Next.js/React)
```
✅ API call start
✅ API response received (status, duration)
✅ Detailed info on errors
✅ Important user actions
```

---

## QA Workflow Automation

```
1. Run "Start QA" or /zero-script-qa
2. Check Docker environment (docker compose ps)
3. Guide to start log monitoring
4. Request manual testing from user
5. Real-time log analysis
6. Immediate report on issue detection
7. Write comprehensive report after testing complete
```

---

## Phase Integration

| Phase | Zero Script QA Role |
|-------|---------------------|
| Phase 4 | Verify API logging implementation |
| Phase 6 | Verify frontend logging |
| Phase 7 | Verify security event logging |
| Phase 8 | Log quality review |
| Phase 9 | Production log level setup |

---

## References

- `.claude/skills/zero-script-qa/SKILL.md`: Expert knowledge
- `.claude/agents/qa-monitor.md`: QA monitoring agent
- `.claude/templates/pipeline/zero-script-qa.template.md`: Report template
- `.claude/commands/zero-script-qa.md`: Command
