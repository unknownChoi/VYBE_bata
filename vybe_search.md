# vybe 검색 기능 진행 계획 (Algolia 연동)

> 이 문서는 검색 기능을 나중에 구현할 때 Claude/개발자가 참고하는 작업 계획서다.
> 현재는 **테스트용 임시 구현** 상태이며, 최종 목표는 **Algolia 검색엔진 연동**이다.

---

## 1. 현재 상태 (2026-06-21 기준)

### 임시 구현 (테스트용 — 실데이터 아님)
- 검색은 **가상 더미 데이터** 기반으로만 동작 중. Firestore 실데이터와 미연동.
- 관련 파일:
  - `lib/presentation/search/data/dummy_clubs.dart` — `DummyClub` 모델 + 더미 10개 (지역·장르 다양화: 홍대/강남/이태원/건대, 힙합/테크노/EDM/R&B 등)
  - `lib/presentation/search/data/club_search.dart` — `searchDummyClubs()` 순수 함수 (동적 사전 기반 랭킹 알고리즘)
  - `lib/presentation/search/search_result_screen.dart` — query를 `searchDummyClubs`에 통과시켜 결과 표시 + 빈상태
  - `lib/presentation/search/search_screen.dart` — 검색 입력/자동완성(더미)/최근검색어 칩 탭→검색
- **주의**: 현재 "강남 검색 시 2개"는 더미 데이터 한계. 실 Firestore에는 강남 클럽 39개 존재.

### 기존 Firestore 검색 (미사용 상태)
- `lib/data/datasources/remote/firebase_club_datasource.dart`의 `searchClubs(keyword)`:
  - clubs 전체(isActive=true) `.get()` → 클라에서 name/tags `contains` 필터
  - 한계: 매 검색마다 전체 fetch(read 비용), 한글 약함, 관련도 정렬 없음, area/genre 누락
- `lib/presentation/search/viewmodels/search_viewmodel.dart`의 `SearchViewModel.search()`가 이 메서드 호출 (단, 결과화면은 현재 더미 사용 중이라 실질 연결 안 됨)

### 임시 랭킹 알고리즘 (club_search.dart) — Algolia 도입 전까지 참고용
점수 기반 정렬. **사전을 하드코딩하지 않고 데이터에서 동적 추출**(area set 등):
```
name == query           +100
name startsWith(공백무관) +80
name contains            +60
지역어 매칭(area==추출지역) +50
토큰별: genre contains    +40 / name contains +35 / area==token +30 / address contains +10
노이즈어("클럽" 등) 제외
점수>0만, 정렬: 점수 → isVybeRecommended → rating
```
- "홍대클럽" → area=홍대 분리 후 홍대 클럽들 상위
- "강남 테크노" → 강남+테크노 둘 다 맞는 클럽 최상위
- 검증 완료(임시 더미 기준 정상 동작)

---

## 2. 최종 목표 & 결정사항

### 방향: Algolia 검색엔진 연동
- **동기화 방식: 직접 Cloud Functions** (Extension 아님)
  - 이유: 대용량 전제 시 배치/partial update/큐/재시도 제어 가능 → 안정성·효율·비용 우위
  - Extension은 소규모·빠른 PoC용. 확장(배치/큐)이 막힘.
- **단계적 구현**:
  1. 1단계: Functions 직접, 트리거 → `saveObject` 단건 (단순, 확장 여지 큼)
  2. 2단계(write 트래픽 증가 시): Pub/Sub or Cloud Tasks 큐 + 배치 워커(`saveObjects` 1K씩) + 재시도/DLQ

### 아키텍처
```
[Firestore clubs]  --(Cloud Functions 동기화)-->  [Algolia 인덱스 'clubs']
      원본 DB                                          검색용 복제본
                                                           ↑
[Flutter 앱] --검색요청(Search-only key)-------------------┘
   결과(클럽 목록/clubId) 받아 리스트 표시
   상세페이지는 clubId로 Firestore 재조회 (단일 진실 원천 = Firestore)
```

### 검색 흐름
- 앱은 **Firestore 직접 검색 안 함** → Algolia가 전담 (전체 fetch 제거, read 비용↓)
- Algolia 인덱스엔 검색 필요 필드만: `clubId(objectID)`, `name`, `area`, `genre`, `tags`, `rating`, `reviewCount`, `isVybeRecommended`, `thumbnailUrl`
- 민감정보 인덱싱 금지

---

## 3. 작업 체크리스트 (구현 시 순서대로)

### 사전 준비 (사용자가 직접 — 키 발급)
- [ ] Algolia 계정 생성(algolia.com) → Application 생성
- [ ] **App ID** 확보
- [ ] **Admin API key** 확보 (서버 전용, 앱에 절대 X)
- [ ] **Search-only key** 확보 (앱에 안전)
- [ ] 인덱스 이름 결정 (기본: `clubs`)

### A. 서버 동기화 (Cloud Functions) — `functions/src/`
- [ ] `functions/.env`에 `ALGOLIA_APP_ID`, `ALGOLIA_ADMIN_KEY`, `ALGOLIA_INDEX=clubs` 추가 (git 제외)
- [ ] `algoliasearch` npm 패키지 추가 (functions)
- [ ] `functions/src/search/sync-clubs.ts`:
  - `onDocumentWritten('clubs/{clubId}')` 트리거
  - 삭제 → `deleteObject(clubId)`
  - 생성/수정 → 검색 필드만 골라 `saveObject({ objectID: clubId, ...fields })` (objectID=clubId 고정 → idempotent)
  - `isActive==false`면 인덱스에서 제거(노출 차단)
- [ ] 백필 스크립트 `scripts/algolia_backfill.js`: 기존 clubs 전체를 청크 배치(`saveObjects` 1K씩)로 1회 인덱싱
- [ ] `functions/src/index.ts`에 export 추가
- [ ] Algolia 대시보드/코드로 인덱스 설정:
  - `searchableAttributes`: `['name', 'area', 'genre', 'tags']`
  - `customRanking`: `['desc(isVybeRecommended)', 'desc(rating)', 'desc(reviewCount)']`
  - 한글 CJK 토크나이징 기본 지원 / typo tolerance 확인

### B. 앱 검색 (Flutter)
- [ ] `.env`에 `ALGOLIA_APP_ID`, `ALGOLIA_SEARCH_KEY` 추가 (Search-only만)
- [ ] 검색 패키지 추가: `algoliasearch` (Dart) 또는 `algolia_helper_flutter`
- [ ] MVVM 레이어 준수:
  - datasource: `lib/data/datasources/remote/algolia_search_datasource.dart` (Algolia 호출 전담)
  - repository: 기존 `club_repository`에 `searchClubs` 구현을 Algolia 경유로 교체 (또는 별도 search_repository)
  - **주의**: Algolia는 Firebase가 아니므로 `data/datasources/`에 두되, CLAUDE.md의 "Firebase는 remote/에만" 규칙과 별개. Algolia용 datasource로 분리.
- [ ] `SearchViewModel.search()` → Algolia datasource 호출로 전환
- [ ] `search_result_screen.dart` → 더미(`searchDummyClubs`) 제거하고 실 검색 결과(ClubModel) 표시
- [ ] 결과 항목 탭 → `ClubDetailScreen(clubId)` (상세는 Firestore 조회 유지)

### C. 자동완성 (선택, 비용 주의)
- [ ] as-you-type 검색 시 **디바운스(300ms)** + **최소 글자수(2자)** 제한 필수
  - 이유: 키 입력마다 search request → Algolia 검색 횟수(=비용) 폭증
- [ ] 현재 `search_screen.dart`의 더미 자동완성(`_suggestionKeywords`)을 Algolia query suggestions 또는 결과 prefix로 교체

### D. 정리
- [ ] 임시 파일 제거 결정: `dummy_clubs.dart`, `club_search.dart` (테스트 종료 후)
- [ ] `firebase_club_datasource.searchClubs` (구 클라필터) 제거 또는 폴백용 유지 결정

---

## 4. 키 / 보안 규칙

| 키 | 용도 | 위치 |
|----|------|------|
| Admin API key | 쓰기/인덱싱 | `functions/.env` (서버만). 앱·git 절대 X |
| Search-only key | 검색 읽기만 | `.env` → 앱. 노출돼도 검색만 가능 |
| App ID | 앱 식별 | 공개 가능 |

- `.gitignore`에 `.env`, `functions/.env` 이미 포함됨 (CLAUDE.md 참조)
- `.env.example`에 키 이름만 추가 (값 없이)

---

## 5. 비용 요약 (도입 시점 재확인 필요 — 단가 자주 변동)

Algolia 과금 = **records** + **search requests** 2축.

| 플랜 | records | 검색요청 |
|------|---------|----------|
| Build(무료) | 100만 포함 | 월 1만건 |
| Grow | 10만 무료→ $0.40/1K | 월 1만 무료→ **$0.50/1K** |
| Grow Plus(AI) | 동일 | 월 1만 무료→ $1.75/1K |
| Elevate | 연약정 맞춤가 | — |

- vybe 규모: 클럽 수천~수만이어도 **records는 무료 한참 아래** → 비용 핵심은 **검색 횟수**
- 예) 월 5만 검색 → (5만-1만)/1000 × $0.50 = **$20/월**
- **자동완성 디바운스 안 하면 검색 수 폭증 → 비용 급증** (최대 주의점)
- 베타·초기엔 무료 티어 내 가능성 높음

---

## 6. 미결정 / 확인 필요

- [ ] Algolia 계정·키 발급 여부 (사용자)
- [ ] 예상 클럽 총 규모 (수백 / 수천 / 만+) — 2단계(큐·배치) 도입 시점 판단용
- [ ] 자동완성 기능 포함 여부 (비용·UX 트레이드오프)
- [ ] 인덱스 분리 필요성 (예: area별, 또는 단일 `clubs` 인덱스)

---

## 7. 대안 (Algolia 안 갈 경우 — 참고)

- **B안 (Firestore 내)**: clubs에 `searchTokens: array` 필드(name분해+area+genre+tags) Cloud Function 생성 → `array-contains` 서버 쿼리. 추가 인프라 0, 무료. 단 부분일치·오타교정 약함. ~수천개까지 적정.
- **C안 (셀프호스트)**: Typesense/Meilisearch (Cloud Run). 저비용·한글 OK. 서버 운영 부담.
- Algolia는 연동 쉬움 + 오타교정/자동완성/한글 품질 강함이 장점. 비용은 검색량 의존.
