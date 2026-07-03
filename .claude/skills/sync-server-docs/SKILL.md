---
name: sync-server-docs
description: >-
  vybe 프로젝트에서 서버/백엔드 관련 변경이 생겼을 때 CLAUDE.md와 firebase_structure.html
  두 문서를 동기화한다. 트리거 — Cloud Functions 추가·삭제·수정, Firestore 컬렉션/필드
  스키마 변경, Security Rules 변경, Storage 경로 구조 변경, Firestore 인덱스 변경,
  seed/migration 스크립트로 인한 데이터 구조 변경. "서버 문서 업데이트", "sync docs",
  "CLAUDE.md 갱신", functions 배포 직후 등에 사용.
---

# sync-server-docs

vybe 프로젝트의 서버 변경사항을 **두 문서**에 동시 반영한다.

- `CLAUDE.md` (프로젝트 루트) — Claude 작업 지침 겸 스키마 소스
- `firebase_structure.html` (프로젝트 루트) — 사람이 보는 시각화 문서

두 문서는 **같은 정보를 서로 다른 형식**으로 담는다. 한쪽만 고치면 어긋난다 → 항상 둘 다 갱신.

## 언제 실행하나

서버/백엔드 변경이 완료된 직후. 대표 트리거:

1. **Cloud Functions** 추가·삭제·역할 변경 (`functions/src/**`, `index.ts` export)
2. **Firestore 컬렉션/필드** 추가·삭제·의미 변경 (스키마)
3. **Security Rules** 변경 (`firestore.rules`, `storage.rules`)
4. **Firestore 인덱스** 추가·삭제
5. **Storage 경로 구조** 변경
6. **seed/migration 스크립트**로 데이터 구조가 바뀐 경우

> 순수 앱(Flutter presentation/UI) 변경은 대상 아님. 서버 계약/스키마가 바뀔 때만.

## 절차

1. **무엇이 바뀌었는지 확정.**
   - 방금 대화에서 한 변경이면 그대로 사용.
   - 불명확하면 `git diff`로 `functions/`, `firestore.rules`, `storage.rules`, `firestore.indexes.json`, `scripts/` 확인.

2. **CLAUDE.md 갱신.** 관련 섹션만 정확히 수정. 아래 "갱신 지점 맵" 참고.

3. **firebase_structure.html 갱신.** CLAUDE.md와 동일 정보를 HTML 표/카드 형식으로. 아래 맵 참고.

4. **카운트·요약 동기화.** 함수 개수, 폴더별 개수, 배지, 사이드바 nav 숫자 등 파생 수치 전부 맞추기.

5. **일관성 검증.** 두 문서에서 방금 바꾼 항목의 이름·숫자가 일치하는지 grep로 교차 확인.

## 갱신 지점 맵

### Cloud Functions 변경 시

**CLAUDE.md** (`### Cloud Functions 목록` 섹션):
- 상단 "총 **N개** 함수" 숫자
- 구조 라인 `functions/src/auth/ (7) · ...` 폴더별 개수
- 해당 카테고리 테이블 행: HTTP onCall / 자동 트리거 / 스케줄 함수
- 필요 시 `#### 구현 시 주의사항` 리스트

**firebase_structure.html** (`<h2>Cloud Functions` 섹션, 대략 line 684+):
- `<h2>` 옆 "총 N개" 텍스트
- 구조 `<p>` 폴더별 개수
- 상단 `<span class="badge">Cloud Functions ×N</span>`
- 사이드바 nav `<a class="sub">` 카테고리별 개수 (line ~308)
- 해당 카테고리 `<table>` 행
- 필요 시 `#functions-notes` 주의사항 `<ul><li>`

### Firestore 컬렉션/필드 변경 시

**CLAUDE.md** (`### Firestore 컬렉션 구조`): 해당 컬렉션 코드블록에 필드 추가/수정. 필드 의미·제약·자동갱신 여부 주석 포함.

**firebase_structure.html**: 해당 컬렉션 `<table>` 또는 카드에 `<tr>` 필드 행 추가. 자동 필드는 `<span class="pill auto">자동</span>` 배지.

### Security Rules 변경 시

**CLAUDE.md** (`### Security Rules`): Firestore/Storage Rules 요약 표.
**firebase_structure.html**: Rules 섹션 표.

### 인덱스 변경 시

두 문서 모두 해당 컬렉션 설명의 "인덱스:" 항목 수정. (performances 등)

## 규칙

- **두 문서 항상 함께.** 한쪽만 고치면 실패로 간주.
- 기존 문서의 **말투·형식·주석 밀도**를 그대로 따라감. 새 스타일 도입 금지.
- 핵심 설계 의도(왜 이렇게 했는지)를 한 줄 note로 남길 것 — 특히 함정·예외 로직.
- 파생 수치(카운트·배지·nav) 빠뜨리지 말 것. 문서 신뢰도 깨짐.
- 확실치 않은 스키마는 추측 말고 실제 코드(`functions/src`, `firestore.rules`)에서 확인.
- 변경 완료 후 무엇을 어디에 반영했는지 짧게 요약 보고.
