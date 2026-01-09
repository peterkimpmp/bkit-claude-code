---
name: zero-script-qa
description: |
  Zero Script QA - Testing methodology without test scripts.
  Uses structured JSON logging and real-time Docker monitoring for verification.

  Triggers: zero script qa, log-based testing, docker logs, 제로 스크립트 QA, ゼロスクリプトQA, 零脚本QA
context: fork
agent: qa-monitor
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: prompt
          prompt: "Verify this bash command is safe for QA testing. No destructive operations allowed."
  Stop:
    - hooks:
        - type: prompt
          prompt: "Verify QA checks completed. Ensure all logs are analyzed and issues documented."
---

# Zero Script QA Expert Knowledge

## Overview

Zero Script QA verifies features through **structured logs** and **real-time monitoring** without writing test scripts.

```
Traditional: Write test code → Execute → Check results → Maintain
Zero Script: Build log infrastructure → Manual UX test → AI log analysis → Auto issue detection
```

## Core Principles

1. **Log Everything** - All API calls (including 200 OK), all errors, all business events
2. **Structured JSON Logs** - Parseable JSON format, consistent fields
3. **Real-time Monitoring** - Docker log streaming, Claude Code analyzes in real-time

## JSON Log Format Standard

```json
{
  "timestamp": "2026-01-08T10:30:00.000Z",
  "level": "INFO",
  "service": "api",
  "request_id": "req_abc123",
  "message": "API Request completed",
  "data": { "method": "POST", "path": "/api/users", "status": 200, "duration_ms": 45 }
}
```

### Required Log Fields

| Field | Type | Description |
|-------|------|-------------|
| timestamp | ISO 8601 | Time of occurrence |
| level | string | DEBUG, INFO, WARNING, ERROR |
| service | string | Service name |
| request_id | string | Request tracking ID |
| message | string | Log message |

### Log Level Policy

| Environment | Minimum Level |
|-------------|---------------|
| Local/Staging | DEBUG |
| Production | INFO |

## Request ID Propagation

```
Client → API Gateway → Backend → Database
   ↓         ↓           ↓          ↓
req_abc   req_abc     req_abc    req_abc
```

Track entire flow with same Request ID across all layers.

## Backend Logging (FastAPI Example)

```python
# middleware/logging.py
import json, logging, time, uuid
from fastapi import Request

class LoggingMiddleware:
    async def __call__(self, request: Request, call_next):
        request_id = request.headers.get('X-Request-ID', f'req_{uuid.uuid4().hex[:8]}')
        start_time = time.time()

        logger.info("Request started", extra={
            'request_id': request_id,
            'data': {'method': request.method, 'path': request.url.path}
        })

        response = await call_next(request)
        duration = (time.time() - start_time) * 1000

        logger.info("Request completed", extra={
            'request_id': request_id,
            'data': {'status': response.status_code, 'duration_ms': round(duration, 2)}
        })

        response.headers['X-Request-ID'] = request_id
        return response
```

## Frontend Logging (Next.js Example)

```typescript
// lib/logger.ts
type LogLevel = 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR';

function log(level: LogLevel, message: string, data?: object) {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level, service: 'web', message, data
  }));
}

export const logger = {
  debug: (msg: string, data?: object) => log('DEBUG', msg, data),
  info: (msg: string, data?: object) => log('INFO', msg, data),
  error: (msg: string, data?: object) => log('ERROR', msg, data),
};
```

## Docker-Based QA Workflow

### docker-compose.yml

```yaml
services:
  api:
    build: ./backend
    environment:
      - LOG_LEVEL=DEBUG
      - LOG_FORMAT=json
    logging:
      driver: json-file
      options:
        max-size: "10m"
```

### Real-time Log Monitoring

```bash
docker compose logs -f                    # Stream all logs
docker compose logs -f api                # Specific service
docker compose logs -f | grep '"level":"ERROR"'  # Filter errors
docker compose logs -f | grep 'req_abc123'       # Track Request ID
```

## QA Automation Workflow

1. **Start Environment**: `docker compose up -d && docker compose logs -f`
2. **Manual UX Testing**: User tests features in browser
3. **Claude Code Log Analysis**: Monitor stream, detect patterns, track Request ID
4. **Issue Documentation**: Auto-document findings

### Issue Documentation Template

```markdown
### ISSUE-001: Insufficient error handling
- **Request ID**: req_abc123
- **Severity**: Medium
- **Reproduction path**: Login → Wrong password
- **Log**: {"level":"ERROR","message":"Login failed"}
- **Recommended fix**: Add error code to message mapping
```

## Issue Detection Patterns

| Pattern | Detection | Action |
|---------|-----------|--------|
| `{"level":"ERROR"}` | Error logged | Report immediately |
| `{"data":{"duration_ms":3000}}` | Slow response | Warning when >1000ms |
| 3+ consecutive failures | System issue | Report potential problem |
| `{"data":{"status":500}}` | Server error | Report 5xx immediately |

## Iterative Test Cycle Pattern

| Cycle | Pass Rate | Bug Found | Fix Applied |
|-------|-----------|-----------|-------------|
| 1st | 30% | DB schema mismatch | Schema migration |
| 2nd | 45% | NULL handling | Add null checks |
| ... | ... | ... | ... |
| 8th | **89%** | Stable | Final polish |

### Cycle Workflow

```
Cycle N:
1. Run test (E2E or manual)
2. Claude monitors logs in real-time
3. Record pass/fail results
4. Claude identifies root cause
5. Fix code immediately
6. Document: Cycle N → Bug → Fix
Repeat until >85% pass rate
```

## Phase Integration

| Phase | Zero Script QA Integration |
|-------|---------------------------|
| Phase 4 (API) | API response logging verification |
| Phase 6 (UI) | Frontend logging verification |
| Phase 7 (Security) | Security event logging verification |
| Phase 8 (Review) | Log quality review |
| Phase 9 (Deployment) | Production log level configuration |

## Checklist

### Logging Infrastructure
- [ ] JSON log format applied
- [ ] Request ID generation and propagation
- [ ] Log level settings per environment
- [ ] Docker logging configuration

### Backend Logging
- [ ] Logging middleware implemented
- [ ] All API calls logged (including 200 OK)
- [ ] Business logic logging
- [ ] Detailed error logging

### Frontend Logging
- [ ] Logger module implemented
- [ ] API client integration

### QA Workflow
- [ ] Docker Compose configured
- [ ] Real-time monitoring ready
- [ ] Issue documentation template ready
