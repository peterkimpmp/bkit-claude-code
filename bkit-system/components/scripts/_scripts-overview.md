# Scripts Overview

> bkit에서 사용하는 15개 Shell Scripts 목록과 역할

## Scripts란?

Scripts는 **Hooks에서 실행되는 실제 로직**입니다.
- Skill/Agent frontmatter의 hooks에서 참조
- stdin으로 JSON 입력, stdout으로 JSON 출력
- allow/block 결정 및 additionalContext 제공

## 전체 목록

### PDCA Scripts (3개)

| Script | Hook | Skill/Agent | 역할 |
|--------|------|-------------|------|
| [[pdca-pre-write]] | PreToolUse | bkit-rules | Write 전 design doc 체크, PDCA 안내 |
| [[pdca-post-write]] | PostToolUse | bkit-rules | Write 후 Gap Analysis 안내 |
| [[task-classify]] | PreToolUse | task-classification | 변경 크기 분류 (Quick Fix ~ Major) |

### Phase Scripts (7개)

| Script | Hook | Skill | 역할 |
|--------|------|-------|------|
| [[phase2-convention-pre]] | PreToolUse | phase-2-convention | 코딩 컨벤션 리마인드 |
| [[phase4-api-stop]] | Stop | phase-4-api | API 완료 후 Zero Script QA 안내 |
| [[phase5-design-post]] | PostToolUse | phase-5-design-system | 디자인 토큰 사용 검증 |
| [[phase6-ui-post]] | PostToolUse | phase-6-ui-integration | UI 레이어 분리 검증 |
| [[phase8-review-stop]] | Stop | phase-8-review | 리뷰 완료 요약 |
| [[phase9-deploy-pre]] | PreToolUse | phase-9-deployment | 배포 전 환경 검증 |

### QA Scripts (4개)

| Script | Hook | Skill/Agent | 역할 |
|--------|------|-------------|------|
| [[qa-pre-bash]] | PreToolUse | zero-script-qa | 파괴적 명령어 차단 |
| [[qa-monitor-post]] | PostToolUse | qa-monitor | Critical 이슈 발견 시 알림 |
| [[qa-stop]] | Stop | zero-script-qa | QA 세션 완료 안내 |

### Agent Scripts (2개)

| Script | Hook | Agent | 역할 |
|--------|------|-------|------|
| [[gap-detector-post]] | PostToolUse | gap-detector | 분석 완료 후 iterate 안내 |
| [[design-validator-pre]] | PreToolUse | design-validator | 설계 문서 체크리스트 |

### Other Scripts (2개)

| Script | 용도 | 호출 방식 |
|--------|------|----------|
| [[analysis-stop]] | 갭 분석 완료 안내 | analysis-patterns Stop hook |
| [[select-template]] | 레벨별 템플릿 선택 | Commands에서 직접 호출 |

---

## Script 입출력 규격

### 입력 (stdin)

PreToolUse/PostToolUse에서 받는 JSON:

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "..."
  }
}
```

### 출력 (stdout)

**Allow with context**:
```json
{
  "decision": "allow",
  "hookSpecificOutput": {
    "additionalContext": "Claude에게 전달할 메시지"
  }
}
```

**Block**:
```json
{
  "decision": "block",
  "reason": "차단 이유"
}
```

**No action**:
```json
{}
```

---

## 주요 Script 상세

### pdca-pre-write.sh

```
트리거: Write|Edit on source files (src/, lib/, app/, components/, pages/)

동작:
1. 파일 경로에서 feature 이름 추출
2. design doc 존재 여부 체크
3. 있으면 → "design doc 참조하세요" 안내
4. plan만 있으면 → "design 먼저 만드세요" 경고
5. 없으면 → 빈 출력 (Quick Fix로 판단)
```

### task-classify.sh

```
트리거: Write|Edit on source files

동작:
1. 변경 내용 크기 측정 (content length)
2. 분류:
   - < 50 chars → Quick Fix (PDCA 불필요)
   - < 200 chars → Minor Change (선택적 PDCA)
   - < 1000 chars → Feature (PDCA 권장)
   - >= 1000 chars → Major Feature (PDCA 필수)
```

### qa-pre-bash.sh

```
트리거: Bash commands during zero-script-qa

동작:
1. 명령어에서 파괴적 패턴 검색
   - rm -rf, DROP TABLE, DELETE FROM, etc.
2. 발견 시 → block
3. 안전 시 → allow with "QA 환경에서 안전"
```

### phase5-design-post.sh

```
트리거: Write on component files (components/, ui/)

동작:
1. 작성된 내용에서 하드코딩 색상 검색
   - #[0-9a-fA-F]{3,6}
   - rgb(, rgba(
2. 발견 시 → "디자인 토큰 사용하세요" 경고
3. 없으면 → "디자인 토큰 올바르게 사용" 확인
```

---

## Script 소스 위치

```
.claude/scripts/
├── pdca-pre-write.sh
├── pdca-post-write.sh
├── task-classify.sh
├── phase2-convention-pre.sh
├── phase4-api-stop.sh
├── phase5-design-post.sh
├── phase6-ui-post.sh
├── phase8-review-stop.sh
├── phase9-deploy-pre.sh
├── qa-pre-bash.sh
├── qa-monitor-post.sh
├── qa-stop.sh
├── gap-detector-post.sh
├── design-validator-pre.sh
├── analysis-stop.sh
└── select-template.sh
```

---

## Script 작성 가이드

### 필수 요소

```bash
#!/bin/bash
set -e  # 에러 시 중단

INPUT=$(cat)  # stdin에서 JSON 읽기
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# 로직...

# 반드시 JSON 출력
cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "..."}}
EOF
```

### 권장 사항

1. **Early exit**: 해당 없는 파일은 빨리 `{}` 반환
2. **jq 사용**: JSON 파싱에 jq 사용
3. **Block 최소화**: allow가 기본, block은 정말 위험할 때만
4. **메시지 간결**: additionalContext는 간결하게

---

## 관련 문서

- [[../hooks/_hooks-overview]] - Hook 이벤트 상세
- [[../skills/_skills-overview]] - Skill 상세
- [[../../triggers/trigger-matrix]] - 트리거 매트릭스
