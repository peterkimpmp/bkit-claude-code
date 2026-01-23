# v1.4.0 Documentation Sync Design Document

> **Summary**: bkit v1.4.0 코드베이스-문서 동기화 상세 설계
>
> **Project**: bkit-claude-code
> **Version**: 1.4.0
> **Author**: Claude (AI Assistant)
> **Date**: 2026-01-24
> **Status**: Complete
> **Planning Doc**: [documentation-sync-v1.4.0.plan.md](../01-plan/features/documentation-sync-v1.4.0.plan.md)

---

## 1. Overview

### 1.1 Design Goals

1. 코드베이스와 문서 간 100% 수치 일치
2. Gemini CLI 지원 정보 완전 문서화
3. 모든 신규 기능(함수, 스크립트) 문서화
4. 플랫폼 간 차이점 명확한 비교 테이블 제공

### 1.2 Design Principles

- **Single Source of Truth**: 코드베이스가 진실의 원천
- **Consistency**: 모든 문서에서 동일한 수치 사용
- **Completeness**: 누락 없이 모든 변경사항 반영

---

## 2. Gap Analysis Results

### 2.1 코드베이스 현황 (Ground Truth)

```
실측 데이터 (2026-01-24):
─────────────────────────────────
Scripts:          26개 (glob: scripts/*.js)
Agents:           11개 (glob: agents/*.md)
Skills:           18개 (glob: skills/*/SKILL.md)
Commands (Claude): 20개 (glob: commands/*.md)
Commands (Gemini): 20개 (glob: commands/gemini/*.toml)
Templates:        20개 (glob: templates/*.md + templates/pipeline/*.md)
lib/common.js:    80+ 함수 (코드 분석)
─────────────────────────────────
```

### 2.2 문서 현황 비교

| 문서 | 항목 | 문서 값 | 실제 값 | Gap |
|------|------|--------|--------|-----|
| bkit-system/README.md | Scripts | 26 | 26 | ✅ |
| bkit-system/README.md | lib/common.js | 80+ | 80+ | ✅ |
| bkit-system/_GRAPH-INDEX.md | Scripts | 26 | 26 | ✅ |
| bkit-system/_GRAPH-INDEX.md | lib/common.js | 80+ | 80+ | ✅ |
| CUSTOMIZATION-GUIDE.md | Scripts | 26 | 26 | ✅ |
| CUSTOMIZATION-GUIDE.md | Templates | 20 | 20 | ✅ |

### 2.3 확인 필요 문서 상세 분석

#### README.md 확인 필요 항목

| 항목 | 현재 상태 | 필요 조치 |
|------|----------|----------|
| 버전 배지 | 1.4.0 | ✅ 완료 |
| Gemini CLI 설치 방법 | 존재 | ✅ 완료 |
| 컴포넌트 수 (Scripts) | 21 → 26 | ✅ 수정 완료 |

#### bkit-system/triggers/trigger-matrix.md

| 항목 | 현재 상태 | 필요 조치 |
|------|----------|----------|
| 버전 헤더 | v1.3.1 → v1.4.0 | ✅ 수정 완료 |
| Gemini CLI 훅 매핑 | 미존재 → 추가됨 | ✅ 추가 완료 |
| v1.4.0 Phase Stop 스크립트 | 미존재 → 추가됨 | ✅ 추가 완료 |

#### bkit-system/scenarios/*.md

| 항목 | 현재 상태 | 필요 조치 |
|------|----------|----------|
| Gemini CLI 시나리오 | 불필요 | ✅ 확인 완료 (기존 시나리오 플랫폼 독립적) |

---

## 3. Implementation Plan

### 3.1 Phase 1: 확인 작업 (Check)

```
Step 1.1: README.md 확인
├── 버전 배지 확인 (1.4.0)
├── Gemini CLI 설치 방법 확인
├── 컴포넌트 수 확인
└── Features 섹션 확인

Step 1.2: bkit-system/triggers/trigger-matrix.md 확인
├── 현재 내용 분석
├── Gemini CLI 훅 매핑 필요 여부 확인
└── 필요시 업데이트 계획 수립

Step 1.3: bkit-system/scenarios/*.md 확인
├── 현재 시나리오 목록 확인
├── Gemini CLI 관련 내용 필요 여부 확인
└── 필요시 업데이트 계획 수립

Step 1.4: bkit-system/philosophy/*.md 확인
├── v1.4.0 관련 업데이트 필요 여부 확인
└── 필요시 업데이트 계획 수립
```

### 3.2 Phase 2: 업데이트 작업 (Do)

각 파일별 구체적 수정 내용:

#### 3.2.1 README.md 업데이트 (필요시)

```markdown
# 확인 항목:
- [ ] 버전 배지가 1.4.0인지 확인
- [ ] Features 섹션에 "21 Scripts" → "26 Scripts" 업데이트 필요 여부
- [ ] Gemini CLI 설치 방법이 최신인지 확인
```

#### 3.2.2 bkit-system/triggers/trigger-matrix.md 업데이트 (필요시)

```markdown
# 추가할 내용 (Gemini CLI 훅 매핑):

## Platform Hook Mapping

| Claude Code | Gemini CLI | 설명 |
|-------------|------------|------|
| SessionStart | SessionStart | 세션 시작 |
| PreToolUse | BeforeTool | 도구 실행 전 |
| PostToolUse | AfterTool | 도구 실행 후 |
| Stop | AgentStop | 에이전트 완료 |
```

#### 3.2.3 신규 lib/common.js 함수 문서화 체크리스트

**Platform Detection (v1.4.0):**
- [x] `detectPlatform()` - 문서화됨
- [x] `isClaudeCode()` - 문서화됨
- [x] `isGeminiCli()` - 문서화됨
- [x] `getPluginPath()` - 문서화됨

**PDCA Status v2.0 (v1.4.0):**
- [x] `createInitialStatusV2()` - 문서화됨
- [x] `migrateStatusToV2()` - 문서화됨
- [x] `getDefaultFeatureStatus()` - 문서화됨

**Multi-Feature Management (v1.4.0):**
- [x] `setActiveFeature()` - 문서화됨
- [x] `addActiveFeature()` - 문서화됨
- [x] `getActiveFeatures()` - 문서화됨
- [x] `switchFeatureContext()` - 문서화됨
- [x] `getFeatureContext()` - 문서화됨

**Intent Detection (v1.4.0):**
- [x] `detectNewFeatureIntent()` - 문서화됨
- [x] `matchImplicitAgentTrigger()` - 문서화됨
- [x] `matchImplicitSkillTrigger()` - 문서화됨

**Ambiguity Detection (v1.4.0):**
- [x] `calculateAmbiguityScore()` - 문서화됨
- [x] `generateClarifyingQuestions()` - 문서화됨
- [x] `detectAmbiguousTerms()` - 문서화됨

**Requirement Tracking (v1.4.0):**
- [x] `extractRequirementsFromPlan()` - 문서화됨
- [x] `calculateRequirementFulfillment()` - 문서화됨
- [x] `getUnfulfilledRequirements()` - 문서화됨

**Phase Validation (v1.4.0):**
- [x] `checkPhaseDeliverables()` - 문서화됨
- [x] `validatePdcaTransition()` - 문서화됨
- [x] `getPhaseRequirements()` - 문서화됨

#### 3.2.4 신규 스크립트 문서화 체크리스트

| 스크립트 | _scripts-overview.md | _GRAPH-INDEX.md |
|---------|:-------------------:|:---------------:|
| `phase-transition.js` | ✅ | ✅ |
| `phase1-schema-stop.js` | ✅ | ✅ |
| `phase2-convention-stop.js` | ✅ | ✅ |
| `phase3-mockup-stop.js` | ✅ | ✅ |
| `phase7-seo-stop.js` | ✅ | ✅ |

---

## 4. Verification Checklist

### 4.1 수치 일관성 검증

| 항목 | bkit-system/README.md | _GRAPH-INDEX.md | CUSTOMIZATION-GUIDE.md | 코드베이스 |
|------|:--------------------:|:---------------:|:---------------------:|:----------:|
| Scripts | 26 | 26 | 26 | 26 |
| Agents | 11 | 11 | 11 | 11 |
| Skills | 18 | 18 | 18 | 18 |
| Commands | 20 (×2) | 20 | 20 (×2) | 20+20 |
| Templates | 20 | 20 | 20 | 20 |
| lib/common.js | 80+ | 80+ | 80+ | 80+ |

### 4.2 Gemini CLI 문서화 검증

| 항목 | README.md | CUSTOMIZATION-GUIDE.md | _GRAPH-INDEX.md | _hooks-overview.md |
|------|:---------:|:---------------------:|:---------------:|:-----------------:|
| 설치 방법 | ✅ | - | - | - |
| 훅 매핑 | - | ✅ | ✅ | ✅ |
| 명령어 위치 | ✅ | ✅ | ✅ | - |
| 환경변수 | ✅ | ✅ | ✅ | - |

### 4.3 CHANGELOG v1.4.0 검증

| 항목 | 포함 여부 |
|------|:--------:|
| Dual Platform Support | ✅ |
| lib/common.js 80+ 함수 | ✅ |
| 5개 신규 스크립트 | ✅ |
| 8언어 지원 | ✅ |
| PDCA Status v2.0 | ✅ |
| Compatibility 정보 | ✅ |

---

## 5. Implementation Order

```
┌─────────────────────────────────────────────────────────────┐
│                    Implementation Flow                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: 확인 필요 문서 읽기                                  │
│     ├─ README.md                                            │
│     ├─ bkit-system/triggers/trigger-matrix.md               │
│     ├─ bkit-system/scenarios/*.md                           │
│     └─ bkit-system/philosophy/*.md                          │
│                    ↓                                        │
│  Step 2: Gap 분석                                           │
│     ├─ 누락된 정보 식별                                      │
│     └─ 업데이트 필요 항목 목록화                              │
│                    ↓                                        │
│  Step 3: 업데이트 실행                                       │
│     ├─ 누락된 정보 추가                                      │
│     └─ 수치 불일치 수정                                      │
│                    ↓                                        │
│  Step 4: 검증 (Check)                                       │
│     ├─ 수치 일관성 확인                                      │
│     └─ Gemini CLI 정보 완전성 확인                           │
│                    ↓                                        │
│  Step 5: 반복 (Act)                                         │
│     └─ Match Rate < 90% 시 Step 2로 돌아감                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Success Criteria

| 기준 | 목표 | 측정 방법 |
|------|------|----------|
| 수치 일관성 | 100% | 모든 문서 간 수치 비교 |
| 기능 문서화 | 100% | 체크리스트 완료율 |
| Gemini CLI 정보 | 100% | 비교 테이블 완성도 |
| Match Rate | ≥ 90% | gap-detector 실행 결과 |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-01-24 | Initial draft | Claude |
