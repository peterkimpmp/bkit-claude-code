# bkit Clean Architecture Refactoring Plan

> **Document Type**: Refactoring Plan
> **Project**: bkit-claude-code
> **Version**: 1.3.0
> **Date**: 2026-01-20
> **Reference**: [[../03-analysis/05-clean-architecture-refactoring-analysis]]

---

## 1. Overview

### 1.1 목적

`.claude/` 폴더를 클린 아키텍처 원칙에 맞게 리팩토링하여:
- 범용성 확보 (다양한 프로젝트 구조 지원)
- 확장성 향상 (설정 기반 커스터마이징)
- 유지보수성 개선 (중복 제거, 일관성 확보)

### 1.2 현재 상태

| Metric | Current | Target |
|--------|---------|--------|
| Skills | 26개 | 12~15개 |
| 하드코딩 | 14개소 | 0개 |
| 중복 코드 | 8개소 | 0개 |
| 불필요 파일 | 5개 | 0개 |

### 1.3 리팩토링 원칙

1. **설정 외부화**: 하드코딩 → config.json
2. **공통 라이브러리**: 중복 코드 → common.sh
3. **단일 책임**: 하나의 모듈 = 하나의 역할
4. **일관성**: Naming, 출력 포맷, 에러 처리 통일

---

## 2. Phase 1: Cleanup (정리)

### 2.1 불필요 파일 삭제

| File | Reason | Action |
|------|--------|--------|
| `.claude/instructions/_DEPRECATED.md` | 명시적 deprecated | DELETE |
| `.claude/hooks/test-hook.md` | 테스트용 | DELETE |
| `.claude/instructions/` 폴더 전체 | deprecated 후 빈 폴더 | DELETE |

### 2.2 하드코딩 제거 (긴급)

**File**: `scripts/select-template.sh` (Line 36)

```bash
# Before (개인 경로 포함)
PLUGIN_TEMPLATE_DIR="${CLAUDE_PROJECT_DIR:-/Users/popup-kay/Documents/GitHub/popup/bkit-claude-code}/templates"

# After
PLUGIN_TEMPLATE_DIR="${CLAUDE_PROJECT_DIR:-.}/templates"
```

### 2.3 동기화

```bash
./scripts/sync-folders.sh
```

---

## 3. Phase 2: Config Externalization (설정 외부화)

### 3.1 Config 파일 생성

**File**: `.claude/config/bkit.config.json`

```json
{
  "$schema": "./bkit.config.schema.json",
  "version": "1.3.0",

  "paths": {
    "docs": "docs",
    "plan": "01-plan",
    "design": "02-design",
    "analysis": "03-analysis",
    "features": "features"
  },

  "sourcePatterns": [
    "src/**",
    "lib/**",
    "app/**",
    "components/**",
    "pages/**",
    "features/**"
  ],

  "excludePatterns": [
    "node_modules/**",
    "dist/**",
    ".next/**",
    "coverage/**"
  ],

  "classification": {
    "quickFixMaxChars": 50,
    "minorChangeMaxChars": 200,
    "featureMaxChars": 1000
  },

  "levelDetection": {
    "enterprise": {
      "directories": ["kubernetes", "terraform", "k8s", "helm", "infra"],
      "files": ["docker-compose.prod.yml"]
    },
    "dynamic": {
      "directories": ["prisma", "api", "backend", "services"],
      "files": ["docker-compose.yml", ".env"],
      "packageKeywords": ["bkend", "@supabase", "firebase", "prisma"]
    },
    "starter": {
      "description": "Default when no dynamic/enterprise indicators"
    }
  }
}
```

### 3.2 Config 읽기 유틸리티

**File**: `.claude/scripts/lib/config.sh`

```bash
#!/bin/bash
# scripts/lib/config.sh
# Purpose: Load and access bkit configuration

CONFIG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/config/bkit.config.json"
LOCAL_CONFIG="./bkit.config.json"

# Use local config if exists, otherwise plugin config
if [ -f "$LOCAL_CONFIG" ]; then
    BKIT_CONFIG="$LOCAL_CONFIG"
elif [ -f "$CONFIG_FILE" ]; then
    BKIT_CONFIG="$CONFIG_FILE"
else
    BKIT_CONFIG=""
fi

get_config() {
    local key=$1
    local default=$2

    if [ -z "$BKIT_CONFIG" ] || [ ! -f "$BKIT_CONFIG" ]; then
        echo "$default"
        return
    fi

    local value=$(jq -r "$key // empty" "$BKIT_CONFIG" 2>/dev/null)
    echo "${value:-$default}"
}

get_config_array() {
    local key=$1

    if [ -z "$BKIT_CONFIG" ] || [ ! -f "$BKIT_CONFIG" ]; then
        return
    fi

    jq -r "$key[]? // empty" "$BKIT_CONFIG" 2>/dev/null
}
```

### 3.3 스크립트 수정 계획

| Script | 수정 내용 |
|--------|----------|
| `pdca-pre-write.sh` | 경로를 config에서 읽도록 |
| `task-classify.sh` | 임계값을 config에서 읽도록 |
| `select-template.sh` | 레벨 감지 조건을 config에서 읽도록 |

---

## 4. Phase 3: Common Library (공통 라이브러리)

### 4.1 공통 함수 추출

**File**: `.claude/scripts/lib/common.sh`

```bash
#!/bin/bash
# scripts/lib/common.sh
# Purpose: Common functions for bkit scripts

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# ============================================
# Input Validation
# ============================================

validate_input() {
    local input=$1
    if [ -z "$input" ] || [ "$input" = "null" ]; then
        echo '{}'
        exit 0
    fi
}

parse_tool_input() {
    local input=$1
    FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')
    CONTENT=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // ""')
    TOOL_NAME=$(echo "$input" | jq -r '.tool_name // ""')
}

# ============================================
# Source File Detection
# ============================================

is_source_file() {
    local file_path=$1
    local patterns=$(get_config_array '.sourcePatterns')

    if [ -z "$patterns" ]; then
        # Default patterns
        patterns="src/* lib/* app/* components/* pages/* features/*"
    fi

    for pattern in $patterns; do
        if [[ "$file_path" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# ============================================
# Feature Extraction
# ============================================

get_feature_name() {
    local file_path=$1

    # Try to extract from path like src/features/auth/login.ts -> auth
    local feature=$(echo "$file_path" | sed -n 's/.*features\/\([^\/]*\)\/.*/\1/p')

    if [ -z "$feature" ]; then
        # Fallback: get parent directory
        feature=$(basename "$(dirname "$file_path")")
    fi

    # Skip common directories
    case "$feature" in
        src|lib|app|components|pages|features|.)
            echo ""
            ;;
        *)
            echo "$feature"
            ;;
    esac
}

# ============================================
# Level Detection
# ============================================

detect_project_level() {
    # Check CLAUDE.md first
    if [ -f "CLAUDE.md" ]; then
        local level=$(grep -i "^level:" CLAUDE.md | head -1 | awk '{print $2}')
        if [ -n "$level" ]; then
            echo "$level"
            return
        fi
    fi

    # Check Enterprise indicators
    local enterprise_dirs=$(get_config_array '.levelDetection.enterprise.directories')
    for dir in ${enterprise_dirs:-kubernetes terraform k8s helm}; do
        if [ -d "$dir" ]; then
            echo "Enterprise"
            return
        fi
    done

    # Check Dynamic indicators
    local dynamic_dirs=$(get_config_array '.levelDetection.dynamic.directories')
    for dir in ${dynamic_dirs:-prisma api backend}; do
        if [ -d "$dir" ]; then
            echo "Dynamic"
            return
        fi
    done

    local dynamic_files=$(get_config_array '.levelDetection.dynamic.files')
    for file in ${dynamic_files:-docker-compose.yml .env}; do
        if [ -f "$file" ]; then
            echo "Dynamic"
            return
        fi
    done

    # Default
    echo "Starter"
}

# ============================================
# Hook Output
# ============================================

output_allow() {
    local message=$1
    if [ -z "$message" ]; then
        echo '{}'
    else
        cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "$message"}}
EOF
    fi
}

output_block() {
    local reason=$1
    cat << EOF
{"decision": "block", "reason": "$reason"}
EOF
}

output_empty() {
    echo '{}'
}
```

### 4.2 스크립트 리팩토링 예시

**Before** (`pdca-pre-write.sh`):
```bash
#!/bin/bash
set -e
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
# ... 50+ lines of duplicated logic
```

**After** (`pdca-pre-write.sh`):
```bash
#!/bin/bash
set -e
source "$(dirname "$0")/lib/common.sh"

INPUT=$(cat)
parse_tool_input "$INPUT"

# Skip non-source files
if ! is_source_file "$FILE_PATH"; then
    output_empty
    exit 0
fi

FEATURE=$(get_feature_name "$FILE_PATH")
if [ -z "$FEATURE" ]; then
    output_empty
    exit 0
fi

# Check for design document
DOCS_PATH=$(get_config '.paths.docs' 'docs')
DESIGN_PATH=$(get_config '.paths.design' '02-design')
DESIGN_DOC="${DOCS_PATH}/${DESIGN_PATH}/features/${FEATURE}.design.md"

if [ -f "$DESIGN_DOC" ]; then
    output_allow "PDCA Notice: Design doc found at ${DESIGN_DOC}"
else
    output_empty
fi
```

---

## 5. Phase 4: Skill Consolidation (스킬 통합)

### 5.1 통합 계획

| Category | Current Skills | Target | Action |
|----------|---------------|--------|--------|
| **Core** | bkit-rules, pdca-methodology, task-classification | bkit-core | MERGE |
| **Levels** | starter, dynamic, enterprise | 유지 (3) | KEEP |
| **Phases** | phase-1 ~ phase-9 (9개) | 유지 (9) | KEEP |
| **Analysis** | analysis-patterns, evaluator-optimizer | analysis | MERGE |
| **Templates** | bkit-templates, document-standards | templates | MERGE |
| **Others** | ai-native-development, monorepo-architecture, mobile-app, desktop-app, level-detection, zero-script-qa | 검토 필요 | REVIEW |

### 5.2 Target Skills (15개)

```
skills/
├── core/
│   └── bkit-core/           # bkit-rules + pdca-methodology + task-classification
├── levels/
│   ├── starter/
│   ├── dynamic/
│   └── enterprise/
├── phases/
│   ├── phase-1-schema/
│   ├── phase-2-convention/
│   ├── phase-3-mockup/
│   ├── phase-4-api/
│   ├── phase-5-design-system/
│   ├── phase-6-ui-integration/
│   ├── phase-7-seo-security/
│   ├── phase-8-review/
│   └── phase-9-deployment/
├── analysis/                # analysis-patterns + evaluator-optimizer
├── templates/               # bkit-templates + document-standards
└── qa/                      # zero-script-qa
```

### 5.3 트리거 키워드 정리

| Keyword | Assigned Skill | Removed From |
|---------|---------------|--------------|
| "PDCA", "계획", "설계" | bkit-core | pdca-methodology, task-classification |
| "로그인", "인증" | dynamic | phase-4-api |
| "배포", "deploy" | phase-9-deployment | enterprise |
| "QA", "테스트" | qa | analysis |

---

## 6. Phase 5: Consistency (일관성)

### 6.1 Naming Convention

**Scripts**:
```
{domain}-{hook-type}.sh

Examples:
- pdca-pre.sh (was: pdca-pre-write.sh)
- pdca-post.sh
- task-pre.sh (was: task-classify.sh)
- qa-pre.sh
- qa-post.sh
```

**Skills**:
```
{category}-{name} or {phase}-{domain}

Examples:
- bkit-core (was: bkit-rules)
- phase-4-api
- level-starter (was: starter)
```

### 6.2 Hook Output Format

**Standard Format**:
```json
{
  "decision": "allow|block",
  "hookSpecificOutput": {
    "additionalContext": "Message to Claude"
  }
}
```

**Empty Response**:
```json
{}
```

### 6.3 Error Handling Standard

```bash
#!/bin/bash
set -euo pipefail

# Validate dependencies
command -v jq >/dev/null 2>&1 || { echo '{}'; exit 0; }

# Validate input
INPUT=$(cat)
[ -z "$INPUT" ] && { echo '{}'; exit 0; }

# Main logic with error handling
{
    # ... script logic
} || {
    echo '{}'
    exit 0
}
```

---

## 7. Implementation Schedule

### Week 1: Phase 1-2

| Day | Task | Deliverable |
|-----|------|-------------|
| 1 | Phase 1: Cleanup | 불필요 파일 삭제 완료 |
| 2-3 | Phase 2: Config | bkit.config.json, config.sh 완료 |
| 4-5 | Testing | Config 기반 스크립트 테스트 |

### Week 2: Phase 3-4

| Day | Task | Deliverable |
|-----|------|-------------|
| 1-2 | Phase 3: Common Library | common.sh 완료 |
| 3-4 | Scripts Refactoring | 16개 스크립트 수정 |
| 5 | Phase 4: Skill Planning | 통합 계획 확정 |

### Week 3: Phase 4-5

| Day | Task | Deliverable |
|-----|------|-------------|
| 1-3 | Skill Consolidation | 26개 → 15개 통합 |
| 4-5 | Phase 5: Consistency | Naming, Format 통일 |

### Week 4: Testing & Documentation

| Day | Task | Deliverable |
|-----|------|-------------|
| 1-3 | Integration Testing | 전체 테스트 |
| 4-5 | Documentation | README, CHANGELOG 업데이트 |

---

## 8. Risk & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| 기존 사용자 호환성 | HIGH | 마이그레이션 가이드 제공 |
| Config 파일 누락 | MEDIUM | 합리적인 기본값 제공 |
| Skill 통합 시 기능 손실 | HIGH | 통합 전 기능 매핑 검증 |
| 테스트 부족 | MEDIUM | test/ 폴더 활용한 검증 |

---

## 9. Success Criteria

| Metric | Current | Target | Measure |
|--------|---------|--------|---------|
| 하드코딩 | 14개 | 0개 | grep으로 검증 |
| 중복 코드 | 8개소 | 0개 | 코드 리뷰 |
| Skills 수 | 26개 | 15개 | 폴더 카운트 |
| 테스트 통과율 | N/A | 100% | test-checklist 기준 |
| Config 커버리지 | 0% | 100% | 설정 가능 항목 비율 |

---

## 10. Checklist

### Phase 1: Cleanup
- [ ] `.claude/instructions/_DEPRECATED.md` 삭제
- [ ] `.claude/hooks/test-hook.md` 삭제
- [ ] `select-template.sh` 개인 경로 제거
- [ ] `sync-folders.sh` 실행

### Phase 2: Config
- [ ] `.claude/config/` 디렉토리 생성
- [ ] `bkit.config.json` 작성
- [ ] `scripts/lib/config.sh` 작성
- [ ] 스크립트에서 config 사용하도록 수정

### Phase 3: Common Library
- [ ] `scripts/lib/common.sh` 작성
- [ ] `pdca-pre-write.sh` 리팩토링
- [ ] `task-classify.sh` 리팩토링
- [ ] `select-template.sh` 리팩토링
- [ ] 나머지 13개 스크립트 리팩토링

### Phase 4: Skill Consolidation
- [ ] bkit-core 통합 (3→1)
- [ ] analysis 통합 (2→1)
- [ ] templates 통합 (2→1)
- [ ] 트리거 키워드 정리
- [ ] 불필요 skill 삭제

### Phase 5: Consistency
- [ ] 스크립트 naming 통일
- [ ] Hook output format 통일
- [ ] Error handling 통일
- [ ] 문서 업데이트

---

## References

- [[../03-analysis/05-clean-architecture-refactoring-analysis]] - 분석 문서
- [[../03-analysis/04-codebase-comprehensive-gap-analysis]] - Gap 분석
- [[../../bkit-system/testing/test-checklist]] - 테스트 체크리스트
