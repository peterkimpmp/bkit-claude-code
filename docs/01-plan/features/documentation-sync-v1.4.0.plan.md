# v1.4.0 Documentation Sync Planning Document

> **Summary**: bkit v1.4.0 코드베이스와 문서(bkit-system/, README.md, CHANGELOG.md, CUSTOMIZATION-GUIDE.md) 완벽 동기화
>
> **Project**: bkit-claude-code
> **Version**: 1.4.0
> **Author**: Claude (AI Assistant)
> **Date**: 2026-01-24
> **Status**: Complete

---

## 1. Overview

### 1.1 Purpose

bkit v1.4.0 릴리스에 따른 코드베이스와 문서 간 완벽한 동기화를 통해:
- 사용자가 정확한 정보를 얻을 수 있도록 함
- 새로운 기능(Gemini CLI 지원, 80+ 함수)이 문서에 반영됨
- bkit-system/ 문서가 실제 코드베이스와 100% 일치함

### 1.2 Background

v1.4.0에서 다음과 같은 주요 변경이 발생:
- **Dual Platform Support**: Claude Code + Gemini CLI 동시 지원
- **lib/common.js 확장**: 38개 → 80+ 함수
- **Scripts 증가**: 21개 → 26개
- **8언어 Intent Detection**: EN, KO, JA, ZH, ES, FR, DE, IT
- **PDCA Status v2.0**: 멀티 피처 컨텍스트 관리

### 1.3 Related Documents

- `gemini-extension.json` - Gemini CLI 매니페스트
- `GEMINI.md` - Gemini CLI 컨텍스트 파일
- `lib/common.js` - 공유 유틸리티 라이브러리

---

## 2. Scope

### 2.1 In Scope

- [x] `bkit-system/_GRAPH-INDEX.md` - v1.4.0 변경사항 반영
- [x] `bkit-system/README.md` - 컴포넌트 수, 플랫폼 지원 정보 업데이트
- [x] `bkit-system/components/scripts/_scripts-overview.md` - 26개 스크립트, lib/common.js 80+ 함수
- [x] `bkit-system/components/hooks/_hooks-overview.md` - Gemini CLI 훅 매핑
- [ ] `bkit-system/philosophy/*.md` - 필요시 업데이트
- [ ] `bkit-system/triggers/trigger-matrix.md` - Gemini CLI 트리거 추가
- [ ] `bkit-system/scenarios/*.md` - Gemini CLI 시나리오 추가
- [x] `CHANGELOG.md` - v1.4.0 릴리스 노트
- [x] `README.md` - Gemini CLI 설치 방법 확인
- [x] `CUSTOMIZATION-GUIDE.md` - 플랫폼별 경로, 구조 업데이트

### 2.2 Out of Scope

- 실제 코드 변경 (이미 v1.4.0 코드는 완성됨)
- 새 기능 추가
- 기존 기능 삭제

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01 | 모든 문서에서 스크립트 수가 26개로 표시되어야 함 | High | Partial |
| FR-02 | lib/common.js 함수 수가 80+로 표시되어야 함 | High | Partial |
| FR-03 | Gemini CLI 지원 정보가 모든 관련 문서에 포함되어야 함 | High | Partial |
| FR-04 | 플랫폼 비교 테이블이 포함되어야 함 | Medium | Partial |
| FR-05 | v1.4.0 CHANGELOG 엔트리가 완전해야 함 | High | Done |
| FR-06 | 모든 신규 함수가 문서화되어야 함 | High | Partial |
| FR-07 | 5개 신규 스크립트가 문서화되어야 함 | High | Partial |

### 3.2 Non-Functional Requirements

| Category | Criteria | Measurement Method |
|----------|----------|-------------------|
| Consistency | 모든 문서 간 수치 일치 | Gap Analysis |
| Completeness | 누락된 정보 0건 | Checklist 검증 |
| Accuracy | 코드베이스와 100% 일치 | Code-Doc 비교 |

---

## 4. Success Criteria

### 4.1 Definition of Done

- [ ] 모든 문서에서 동일한 수치 표시 (Scripts: 26, Functions: 80+)
- [ ] Gemini CLI 지원 정보 완전 문서화
- [ ] gap-detector 실행 시 Match Rate 90% 이상
- [ ] 모든 신규 함수 및 스크립트 문서화

### 4.2 Quality Criteria

- [ ] 문서 내 링크 모두 유효
- [ ] 코드 예제 정확성 확인
- [ ] 플랫폼별 경로 정확성 확인

---

## 5. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 일부 문서 누락 | High | Medium | 체계적 체크리스트 사용 |
| 수치 불일치 | Medium | Low | Gap Analysis 자동화 |
| 플랫폼별 차이 누락 | Medium | Medium | 비교 테이블 필수 포함 |

---

## 6. Gap Analysis - 현재 상태

### 6.1 코드베이스 현황 (Ground Truth)

| 항목 | 실제 값 | 소스 |
|------|---------|------|
| Scripts | 26 | `scripts/*.js` glob 결과 |
| Agents | 11 | `agents/*.md` glob 결과 |
| Skills | 18 | `skills/*/SKILL.md` glob 결과 |
| Commands (Claude) | 20 | `commands/*.md` glob 결과 |
| Commands (Gemini) | 20 | `commands/gemini/*.toml` glob 결과 |
| Templates | 20 | `templates/*.md` glob 결과 |
| lib/common.js 함수 | 80+ | 코드 분석 결과 |

### 6.2 신규 스크립트 (v1.4.0)

| 스크립트 | 설명 |
|---------|------|
| `phase-transition.js` | PDCA 페이즈 전환 검증 |
| `phase1-schema-stop.js` | Schema 페이즈 완료 핸들러 |
| `phase2-convention-stop.js` | Convention 페이즈 완료 핸들러 |
| `phase3-mockup-stop.js` | Mockup 페이즈 완료 핸들러 |
| `phase7-seo-stop.js` | SEO/Security 페이즈 완료 핸들러 |

### 6.3 lib/common.js 신규 함수 카테고리 (v1.4.0)

| 카테고리 | 함수 수 | 주요 함수 |
|---------|--------|----------|
| Platform Detection | 4 | `detectPlatform()`, `isClaudeCode()`, `isGeminiCli()`, `getPluginPath()` |
| Caching System | 2 | `_cache` 객체, TTL 기반 무효화 |
| Debug Logging | 1 | `debugLog()` |
| PDCA Status v2.0 | 3 | `createInitialStatusV2()`, `migrateStatusToV2()`, `getDefaultFeatureStatus()` |
| Multi-Feature Management | 5 | `setActiveFeature()`, `addActiveFeature()`, `getActiveFeatures()`, `switchFeatureContext()`, `getFeatureContext()` |
| Intent Detection | 3 | `detectNewFeatureIntent()`, `matchImplicitAgentTrigger()`, `matchImplicitSkillTrigger()` |
| Ambiguity Detection | 3 | `calculateAmbiguityScore()`, `generateClarifyingQuestions()`, `detectAmbiguousTerms()` |
| Requirement Tracking | 3 | `extractRequirementsFromPlan()`, `calculateRequirementFulfillment()`, `getUnfulfilledRequirements()` |
| Phase Validation | 3 | `checkPhaseDeliverables()`, `validatePdcaTransition()`, `getPhaseRequirements()` |

---

## 7. Sync Target Documents

### 7.1 완료된 문서

| 문서 | 상태 | 변경 내용 |
|------|------|----------|
| `CHANGELOG.md` | ✅ Done | v1.4.0 릴리스 노트 추가 |
| `bkit-system/_GRAPH-INDEX.md` | ✅ Done | v1.4.0 헤더, 스크립트 26개, lib/common.js 80+ 함수, Gemini CLI 섹션 |
| `bkit-system/README.md` | ✅ Done | 스크립트 26개, Gemini CLI 지원, 소스 경로 테이블 |
| `bkit-system/components/scripts/_scripts-overview.md` | ✅ Done | 26개 스크립트, lib/common.js 상세 문서화 |
| `bkit-system/components/hooks/_hooks-overview.md` | ✅ Done | 플랫폼 훅 매핑, 신규 Phase 스크립트 11개 |
| `CUSTOMIZATION-GUIDE.md` | ✅ Done | v1.4.0 컴포넌트 수, Gemini CLI 경로, 구조도 |

### 7.2 확인 필요 문서

| 문서 | 상태 | 확인 필요 항목 |
|------|------|--------------|
| `README.md` | ⚠️ Check | Gemini CLI 설치 방법, 버전 배지 |
| `bkit-system/philosophy/*.md` | ⚠️ Check | v1.4.0 관련 업데이트 필요 여부 |
| `bkit-system/triggers/trigger-matrix.md` | ⚠️ Check | Gemini CLI 트리거 추가 여부 |
| `bkit-system/scenarios/*.md` | ⚠️ Check | Gemini CLI 시나리오 추가 여부 |

---

## 8. Next Steps

1. [x] Plan 문서 작성 (본 문서)
2. [x] Design 문서 작성 (상세 구현 계획)
3. [x] 확인 필요 문서 Gap Analysis
4. [x] Do: 누락된 문서 업데이트
   - [x] README.md Scripts 수 수정 (21 → 26)
   - [x] trigger-matrix.md v1.4.0 업데이트 + Gemini CLI 훅 매핑 추가
   - [x] core-mission.md v1.4.0 업데이트 + 컴포넌트 수 수정
5. [x] Check: 수동 검증 실행
6. [x] Act: 최종 보고서 생성 - 완료

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-01-24 | Initial draft | Claude |
