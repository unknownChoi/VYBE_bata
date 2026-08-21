# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**vybe** is a Flutter mobile application for discovering nightclubs based on map.

- **Platform:** Android, iOS
- **Language:** Dart (SDK ^3.9.2)
- **Framework:** Flutter (v3.18.0+)
- **Core Features:**
  - Map-based club discovery
  - Club detail pages (info, hours, price, menu)
  - User reviews
  - Search & filtering

---

## Architecture

This project follows **MVVM (Model-View-ViewModel)** pattern with **Riverpod** for state management.

```
View (Widget) → ViewModel (Notifier) → Repository → DataSource (Firebase)
```

- **View:** UI only, no business logic
- **ViewModel:** `AsyncNotifier` / `Notifier` via Riverpod, handles state & logic
- **Repository:** Abstracts data source, returns domain models
- **DataSource:** Firebase (Firestore, Auth, Storage) calls

---

## Folder Structure

```
├── lib/
│   ├── design_system/   # 색상, 타이포그래피, 간격
│   ├── core/
│   │   ├── constants/   # app_geo.dart (폴백 좌표 · 상권 좌표 · 지역 판정)
│   │   │                #   korea_regions.dart (전국 시군구 252개 중심 좌표표 — 구 있는 시는 구 단위)
│   │   ├── providers/   # 전역 Riverpod providers (auth_providers, location_providers 등)
│   │   ├── theme/       # 앱 테마
│   │   └── utils/       # 유틸리티 (firebase_logger.dart 등)
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/   # 기기 SDK 전담 datasource
│   │   │   │   ├── device_location_datasource.dart  # geolocator (GPS 코드는 여기에만)
│   │   │   │   └── device_network_datasource.dart   # connectivity_plus · app_settings
│   │   │   │                                        #   (연결 확인·설정 열기는 여기에만)
│   │   │   └── remote/  # Firebase 전담 datasource (Firebase 코드는 여기에만)
│   │   │       ├── firebase_auth_datasource.dart
│   │   │       ├── firebase_user_datasource.dart
│   │   │       ├── firebase_storage_datasource.dart
│   │   │       ├── firebase_club_datasource.dart
│   │   │       ├── firebase_search_history_datasource.dart
│   │   │       ├── firebase_review_datasource.dart
│   │   │       ├── firebase_favorite_datasource.dart
│   │   │       ├── firebase_banner_datasource.dart
│   │   │       ├── firebase_notice_datasource.dart
│   │   │       ├── firebase_promotion_datasource.dart
│   │   │       └── firebase_app_config_datasource.dart
│   │   ├── models/      # Freezed 모델 (user, club, club_info, menu, photo, review,
│   │   │                #   favorite, banner, notice, search_history, operating_hours,
│   │   │                #   app_version_config)
│   │   └── repositories/# domain 인터페이스 구현체 (*_repository_impl.dart, Riverpod provider 포함)
│   ├── domain/
│   │   └── repositories/    # repository 인터페이스 (Firebase 의존 금지)
│   ├── presentation/
│   │   ├── common/          # 화면 공용 — widgets/(Vybe prefix) + location_flip_mixin.dart
│   │   │                    #   + network_gate/ (네트워크 게이트 — VersionGate보다 위)
│   │                    #   + version_gate/ (버전 게이트 — AuthGate보다 위)
│   │   │                    #   + renew/ (리뉴얼 디자인 토큰·글래스 프리미티브 — Renew prefix)
│   │   ├── main_scaffold/   # 루트 IndexedStack + 하단 탭바
│   │   ├── home/            # 홈 (widgets/, viewmodels/)
│   │   ├── promotion/       # 배너 상세 (promotions 콘텐츠 렌더)
│   │   ├── nearby/          # 내 주변 (지도 기반, widgets/)
│   │   ├── saved/           # 찜 (favorites, saved_common.dart, widgets/, viewmodels/)
│   │   ├── pass_wallet/     # 패스/지갑 (플레이스홀더, 현재 탭에서 미연결)
│   │   ├── search/          # 검색 (widgets/, viewmodels/)
│   │   ├── clubs/           # 클럽 상세 (tabs/, widgets/, viewmodels/)
│   │   ├── hip_hop/         # 장르 페이지 + 오늘의 라인업 (widgets/, *_models.dart)
│   │   ├── hot_places/      # 핫플레이스 (더미 데이터, widgets/)
│   │   ├── recommend/       # VYBE 추천 (widgets/, recommend_models.dart)
│   │   ├── free_entry/      # 입장비 무료
│   │   ├── service_drinks/  # 서비스 음료
│   │   ├── my_page/         # 마이페이지
│   │   ├── profile/         # 프로필
│   │   └── auth/            # 인증 플로우
│   └── main.dart
│
├── functions/           # Cloud Functions (TypeScript, src/auth · account · favorites · reviews)
├── scripts/             # Firestore/Storage seed·migration 스크립트 (Node.js)
│
└── assets/
    ├── images/          # 로고 등 이미지
    ├── icons/
    │   ├── common/      # 범용 아이콘
    │   └── social/      # 소셜 로그인 아이콘
    └── fonts/
```

### 화면 파일 구성 규칙

| 두는 곳 | 무엇을 |
|---------|--------|
| `<feature>/<name>_screen.dart` | 화면 조립 + 상태(State/ViewModel 연결)만 |
| `<feature>/widgets/` | 그 화면 전용 하위 위젯 |
| `<feature>/<feature>_models.dart` | 표시 전용 모델 + `ClubModel` → 카드 모델 매퍼 |
| `<feature>/<feature>_style.dart` | 화면 전용 색·상수 |
| `presentation/common/widgets/` | **두 화면 이상**이 쓰는 위젯 (`Vybe` prefix) |

- 화면 파일이 **300줄을 넘으면 분리 신호**. 위젯을 `widgets/`로 빼고 화면엔 조립만 남긴다.
- 같은 위젯을 두 번째 화면에서 복붙하게 되면 그때 `common/widgets/`로 승격한다
  (색·크기가 화면마다 다르면 파라미터로 받되, 기본값은 원래 화면 값 유지).
- 긴 목록은 `ListView(children: [...])`가 아니라 `SliverList.builder` — 전부 즉시 빌드하지 않는다.
- `MediaQuery.of(context).padding` 대신 `MediaQuery.paddingOf(context)` (구독 범위 축소).

---

## Tech Stack

| 역할 | 패키지 |
|------|--------|
| 상태관리 | `flutter_riverpod` ^3.0 |
| 백엔드 | Firebase (Firestore, Auth, Storage, Functions) |
| 지도 | `flutter_naver_map` + `geoflutterfire_plus` (geohash GeoQuery) |
| 라우팅 | **별도 라우터 패키지 없음** — `MainScaffold`(IndexedStack 5탭) + 탭 내부 `Navigator` |
| 코드 생성 | `riverpod_generator` ^4.0, `freezed` ^3.0 |
| 아이콘/벡터 | `cupertino_icons`, `flutter_svg` |
| 미디어 | `video_player`, `image_picker`(리뷰 사진 첨부) |
| UI 보조 | `flutter_spinkit`(로딩), `flutter_staggered_grid_view`(갤러리) |
| 반응형 | `flutter_screenutil` |
| 네이버 로그인 | `flutter_naver_login` |
| 카카오 로그인 | `kakao_flutter_sdk_user` |
| 검색엔진 | `algoliasearch` (Algolia — Firebase Extension으로 clubs 자동 동기화) |
| 환경변수 관리 | `flutter_dotenv` (Flutter) / `dotenv` (Cloud Functions) |
| 앱 버전 조회 | `package_info_plus` (버전 게이트 · 설정 화면 버전 표기) |
| 기기 위치 | `geolocator` (앱 첫 로딩 GPS 조회 + 위치 권한 요청) |
| 네트워크 확인 | `connectivity_plus` (앱 첫 로딩 연결 확인 + 연결 변화 구독) |
| 설정 앱 열기 | `app_settings` **^5.x 고정** (8.x는 SPM 전용 — 이 프로젝트는 CocoaPods) |

> ⚠️ `go_router` / `google_maps_flutter` / `json_serializable` 미사용. 화면 전환은
> 하단 탭(`MainScaffold`) + 탭별 `Navigator.push`. 지도는 네이버 지도.

---

## Commands

```bash
# 앱 실행
flutter run

# 테스트
flutter test

# 코드 분석 (경고 0 유지 — analysis_options.yaml에 const·정렬 린트 추가돼 있음)
flutter analyze

# 린트 자동 수정 (const 누락, import 정렬, 미사용 import 등)
dart fix --apply lib

# 코드 생성 (Freezed, Riverpod, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# 코드 생성 (watch 모드)
flutter pub run build_runner watch --delete-conflicting-outputs

# 빌드
flutter build apk      # Android
flutter build ios      # iOS

# Cloud Functions 배포
firebase deploy --only functions
firebase deploy --only functions:naverLogin  # 특정 함수만
```

---

## 환경변수 / 키 관리 (dotenv)

API 키는 `.env` 파일로 관리하며 절대 git에 커밋하지 않는다.

### Flutter (`flutter_dotenv`)
파일 위치: 프로젝트 루트 `.env`

```
# .env (git 제외)
KAKAO_NATIVE_APP_KEY=your_key_here     # main.dart: KakaoSdk.init
NAVER_MAP_CLIENT_ID=your_id_here       # main.dart: 네이버 지도 초기화 (FlutterNaverMap)
ALGOLIA_APP_ID=your_id_here            # algolia_club_search_datasource: 클럽 검색
ALGOLIA_SEARCH_API_KEY=your_key_here   # 반드시 Search-Only 키 (Admin/Write 키 금지)
```

> main.dart 초기화 순서: `dotenv.load` → `Firebase.initializeApp` → `KakaoSdk.init` → 네이버 지도(`NAVER_MAP_CLIENT_ID`).
> ⚠ 네이버 **로그인** clientId/clientSecret 은 dotenv 가 아니라 **네이티브 설정**에 있다 —
> `android/app/src/main/AndroidManifest.xml` 의 `com.naver.sdk.*` 메타데이터와 `ios/Runner/Info.plist`.
> 서버(Cloud Functions)는 클라가 넘긴 accessToken 만 검증하므로 이 값들이 필요 없다.

사용법:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// main.dart에서 초기화
await dotenv.load(fileName: '.env');

// 어디서나 접근
final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY']!;
```

### Cloud Functions (`dotenv`)
파일 위치: `functions/.env` (템플릿 `functions/.env.example` 은 커밋)

```
# functions/.env (git 제외) — 서버가 실제로 읽는 키는 이 둘뿐이다
PORTONE_IMP_KEY=your_key_here        # verifyIdentity — 포트원 토큰 발급
PORTONE_IMP_SECRET=your_secret_here  # verifyIdentity — 포트원 토큰 발급
```

> ⚠ **현재 배포본에 이 키가 안 실려 있다 (2026.08.20 확인)** — `verifyIdentity` 의 런타임
> 환경변수에 `PORTONE_*` 가 없어 호출하면 `internal`("포트원 API 키가 설정되지 않았습니다")로
> 실패한다. 앱이 아직 이 함수를 부르지 않아 드러나지 않았을 뿐(문자 인증이 `'123456'` 하드코딩).
> 값을 채운 뒤 `firebase deploy --only functions:verifyIdentity` 로 반영할 것.
>
> `firebase deploy` 는 `functions/.env` 를 읽어 **런타임 환경변수로 올린다** — 파일이 없으면
> 조용히 없는 채로 배포된다(경고 없음). 로그인 3종은 서버 시크릿을 안 써서 영향 없다.

## 클럽 검색 (Algolia)

검색은 **Algolia 단일 경로**. (구 Firestore searchTokens 검색은 폐기 —
onClubWritten 트리거·searchTokens 필드·전용 인덱스 전부 삭제됨. 2026.07.19)

```
clubs 쓰기 → Firebase Extension(firestore-algolia-search) → Algolia `clubs` 인덱스 자동 동기화
앱 검색   → algolia_club_search_datasource (Search-Only 키) → 관련도순 hit 페이지
          → hit를 ClubModel.fromSearchHit로 직접 매핑 (Firestore read 0)
상세 진입 → clubId로 getClub 1건만 조회
```

- Extension 설정: Collection Path `clubs`, Index `clubs`, objectID = doc.id(= clubId),
  Indexable Fields (**19개 — 이 목록이 정본**):
  ```
  name,area,genre,genreStyles,tags,address,rating,reviewCount,thumbnailUrl,entryFeeMin,entryFeeMax,operatingHours,isActive,isVybeRecommended,isNonSmoking,favoriteCount,location,freeEntry,isFreeEntry
  ```
  ⚠ **배포된 설정이 문서와 달라져 있던 적이 있다 (2026.08.21 발견)** — 배포본 `FIELDS`에
  `reviewCount`·`entryFeeMax`·`operatingHours`·`isVybeRecommended`·`isNonSmoking`·`location`
  6개가 빠져 있었고(= 2026.07.31 '조인 제거' 설정이 실제로는 반영된 적이 없음), 그동안 검색은
  내내 `complete=false` → `getClub` 조인 폴백으로 돌고 있었다. **화면이 멀쩡해서 티가 안 난다**
  — 조용히 read 비용만 낸다. 설정을 만졌으면 반드시 실물로 확인할 것:
  ```bash
  TOKEN=$(gcloud auth print-access-token)
  curl -s -H "Authorization: Bearer $TOKEN" \
    "https://firebaseextensions.googleapis.com/v1beta/projects/vybe-bata-c07aa/instances/firestore-algolia-search" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['state']); print(d['config']['params']['FIELDS'])"
  # 그 다음 hit에 실제로 실려 오는지 (앱과 같은 Search-Only 키)
  curl -s -X POST "https://$ALGOLIA_APP_ID-dsn.algolia.net/1/indexes/clubs/query" \
    -H "X-Algolia-API-Key: $ALGOLIA_SEARCH_API_KEY" -H "X-Algolia-Application-Id: $ALGOLIA_APP_ID" \
    -d '{"query":"","hitsPerPage":1}' | python3 -c "import json,sys; print(sorted(json.load(sys.stdin)['hits'][0].keys()))"
  ```
- **Firestore 조인 제거 (2026.07.31 설계 · 2026.08.21 현재 미가동)** — 목록 카드·필터·정렬·지도 핀에 필요한 필드를
  전부 인덱싱해 검색 시 Firestore 문서 read가 0이 됨. 필요 필드 목록은
  `AlgoliaClubSearchDataSource._requiredFields` (단일 소스).
  hit에 하나라도 빠지면 `complete=false` → 예전 `getClub` 조인으로 자동 폴백(화면 안 깨짐).
  ⚠ Indexable Fields를 바꾸면 기존 문서는 자동 반영 안 됨 → `node scripts/reindex_clubs.js`로
  전체 touch 필요. `_requiredFields`에 필드를 추가할 때도 Extension 설정 + 재색인 동반 필수.
- **Searchable Attributes (Algolia 인덱스 설정 — Extension 설정과 별개)**:
  ```
  unordered(name), unordered(tags), unordered(genre), unordered(freeEntry.condition)
  ```
  순서 = 우선순위. `freeEntry.condition`은 **맨 뒤**라 이름 매치를 밀어내지 않는다.
  ⚠ **인덱싱된 필드 ≠ 검색되는 필드다** — Extension의 Indexable Fields는 "인덱스에 실어 보낼
  필드", searchableAttributes는 "그중 검색어로 찾을 필드". 여기 없으면 값이 실려 있어도 0건이다.
  - `freeEntry.condition` 추가 (2026.08.21) — 검색창에 **`무료`를 치면 무료입장 클럽 119곳**이
    뜨게 하려고. 조건 문구 80종이 전부 '무료'를 포함한다(always 71 + timed 48, `none` 45곳만 빈 값).
    ⚠ **`입장료`로는 안 걸린다** — 문구가 전부 '입장 무료'·'무료입장'이라 '입장료'라는 단어가
    데이터에 없다(필터 칩 라벨은 '입장료 무료'라 헷갈릴 수 있음).
    부수 효과로 `여성`(8곳)·`오픈런`(6곳) 같은 조건 단어로도 찾아진다 — 의도한 것.
  - 한국어는 **부분 일치**가 된다(실측: `테이션` → `클럽 스테이션`). 접두사만이 아니라 중간·끝
    조각도 잡히므로 `무료`가 `무료입장`·`무료`를 모두 건진다.
  - ⚠ **이 설정은 리포에 없다** — Algolia 대시보드(또는 Settings API)에만 산다. Extension을
    재구성한 뒤에는 살아남았는지 확인할 것:
    `GET https://{APP_ID}-dsn.algolia.net/1/indexes/clubs/settings`
- ⚠ **Extension 업데이트는 전체 재색인을 동반한다** (`DO_FULL_INDEXING=true`) — 2026.08.21
  설정 변경 후 ACTIVE로 바뀌자 164개가 자동으로 다시 색인됐다. 즉 Indexable Fields만 고치면
  `scripts/reindex_clubs.js`를 따로 돌릴 필요가 없다(수동 touch는 설정을 안 건드리고 다시 밀
  때만 쓴다). 반영은 상태가 DEPLOYING → ACTIVE로 바뀐 뒤 1~2분.
- 진입점은 `ClubRepositoryImpl.searchClubsPage` 하나 — viewmodel/화면은 엔진 무관.
  cursor = Algolia 페이지 번호(int, 0부터).
- 결과 개수는 `ClubSearchPage.totalCount`(= Algolia `nbHits`, 검색어 전체 매칭 수).
  응답에 이미 실려와 추가 비용 0. 검색 결과 화면 메타 행은 필터 없을 때 이 값을 쓰고,
  필터가 걸리면 서버가 필터를 모르므로 로드된 것 중 통과 개수로 대체한다.
- 비활성 클럽 제외는 hit의 `isActive` 값으로 처리(폴백 경로에선 조인 후 확인).
  (Algolia `filters`는 attributesForFaceting 미선언 속성이면 조용히 0건 — 사용 금지)
- ⚠ .env에 ALGOLIA 키 없으면 검색 결과 빈 값 (fallback 없음 — 키 필수).
- ⚠ 키 규칙: 앱에는 **Search-Only 키만**. Admin/Write 키는 Extension(서버)에서만 사용.

### .gitignore 규칙
- `.env` — Flutter 키
- `functions/.env` — Cloud Functions 키
- `.env.example` · `functions/.env.example` 은 커밋 (실제 값 없이 키 이름만 포함)

---

## State Management

Riverpod 2.x 기반, `AsyncNotifier` / `Notifier` 패턴 사용.

- 단순 상태: `@riverpod` 함수형 provider
- 비동기 상태: `AsyncNotifier`
- UI는 `ConsumerWidget` 또는 `ConsumerStatefulWidget` 사용

---

## Design System Rules

모든 색상, 타이포그래피, 공통 컴포넌트는 먼저 정의된 것이 있는지 확인 후 사용한다.
**정의된 것이 있으면 반드시 가져다 쓰고, 없으면 하드코딩 허용.**

### 색상
```dart
// ✅ VybeColors에 있으면
color: VybeColors.mainPurple500

// ✅ 없으면 하드코딩 허용
color: Color(0xFF1A1A2E)
```

### 타이포그래피
```dart
// ✅ VybeTypography에 있으면
style: VybeTypography.heading1

// ✅ 없으면 하드코딩 허용
style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)
```

### 공통 컴포넌트
```dart
// ✅ common/widgets/에 있으면
VybeButton(label: '로그인', onTap: () {})

// ✅ 없으면 기본 위젯 사용 허용
ElevatedButton(onPressed: () {}, child: Text('로그인'))
```

> 새 UI 작업 전 반드시 `VybeColors`, `VybeTypography`, `common/widgets/` 먼저 확인할 것

### ⚠ 라운드 카드에 테두리를 그릴 때 (2026.08.20)

클립되는 카드의 **테두리는 `decoration`이 아니라 `foregroundDecoration`에 둔다.**

```dart
Container(
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(gradient: ..., borderRadius: r),      // 채움만
  foregroundDecoration: BoxDecoration(border: ..., borderRadius: r), // 테두리는 자식 위
  child: ...,
)
```

`decoration`에 `border`를 넣으면 **직선부만 남고 코너 호에서 선이 사라진다** —
카드 모서리가 잘려 나간 것처럼 보인다. Flutter가 `Container`를
`DecoratedBox(decoration) > ClipPath(바깥 라운드렉트) > Padding(테두리 두께) > child`
로 짜기 때문 —
① decoration(채움 + 테두리)을 먼저 그리고 ② 자식을 **바깥** 라운드렉트로 클립해 그 위에 얹는다.
직선부는 `decoration.padding`(= 테두리 두께)이 자식을 1px 들여보내 선이 살아남지만,
그 균일한 1px 인셋은 **코너 곡선을 따라가지 않아** 호 구간에서 자식이 선을 덮는다.
바깥 `ClipRRect`로 감싸도 결과는 같다(둘 다 실측 확인 — 직선부 밝기 83 대 호 14~25,
`foregroundDecoration`은 호 76~83).

카드 하단이 배경색과 비슷한 화면(홈 주변 클럽 카드 등)에서 특히 티가 난다 —
호에 선이 없으면 대비가 0이라 아래 모서리가 통째로 안 보인다.
**바깥 `ClipRRect`로 감싸는 것도 같은 결과**라 `ClipRRect > Container(border)` 형태는
`Container(clipBehavior: Clip.antiAlias)` + `foregroundDecoration` 으로 바꿔야 한다
(`ClipRRect`를 남긴 채 `foregroundDecoration`만 쓰면 바깥 클립이 다시 호를 깎는다).

적용된 곳 — 사진/불투명 카드 14곳:
`home_nearby_clubs` · `home_free_time_clubs` · `home_banner` · `search/club_list_item` ·
`free_entry_screen` · `service_drinks_screen` · `hip_hop_poster_card` · `saved_thumb` ·
`recommend_featured` · `my_review_card` · `hot_places_podium` · `hot_places_list_row` ·
`table_floor_map` · `renew_free_entry`(입장비 도형 칸).
`RenewGlassCard`(`common/renew/renew_glass.dart`)는 처음부터 이 방식이다.

⚠ **아직 안 고친 곳** — 글래스 pill·시트·바 계열(`vybe_toast` · `vybe_glass_surface` ·
`vybe_confirm_dialog` · `nearby_gnb` · `nearby_glass` · `club_pin_card` ·
`club_nearby_list_item`의 pill · `notification_header` · `search_bar` · `renew_chrome` ·
`home_category_grid` · `home_gnb`). 같은 버그지만 `BackdropFilter`가 끼어 있어
테두리를 자식 위로 올리면 글래스 질감이 달라질 수 있다 — 화면별로 눈으로 보고 옮길 것.
찾는 법은 아래 스캔:

```bash
# 클립 안 decoration 에 테두리가 있는 곳 (괄호 매칭)
grep -rn "border: Border.all" lib/presentation/   # 후보 추린 뒤 ClipRRect/clipBehavior 포함 여부 확인
```

---

## Coding Conventions

- 파일명: `snake_case.dart`
- 클래스명: `PascalCase`
- Provider명: `camelCase` + `Provider` suffix (e.g. `clubListViewModelProvider`)
- 위젯은 `StatelessWidget` / `ConsumerWidget` 우선, `StatefulWidget` 최소화
- 비즈니스 로직은 절대 Widget 안에 작성하지 않음
- `freezed` 모델은 `data/models/` 또는 `domain/entities/`에 위치

---

## Responsive UI

이 프로젝트는 **`flutter_screenutil`** 을 사용하여 모든 UI 단위를 반응형으로 처리한다.
기준 디자인 사이즈는 `main.dart`에 설정되어 있다 **(393 x 852, iPhone 15 기준)**.

- 모든 width, height, fontSize, borderRadius는 반드시 screenutil 단위 사용
- `.w` (가로), `.h` (세로), `.r` (border radius), `.sp` (폰트 크기)
- 절대 `px` 고정값(예: `width: 100`) 사용 금지

---

## Design (Figma)

이 프로젝트는 **Figma MCP**를 통해 디자인을 직접 참조하여 UI를 구현한다.

- **MCP 연동:** Figma MCP (`https://mcp.figma.com/mcp`) 사용
- UI 구현 시 Figma 디자인을 기준으로 색상, 타이포그래피, 간격, 컴포넌트를 최대한 정확하게 반영할 것
- Figma에 정의된 컴포넌트는 `presentation/common/` 폴더에 재사용 가능한 위젯으로 분리할 것
- 디자인 토큰(색상, 폰트 크기 등)은 `core/constants/` 또는 `core/theme/`에 상수로 정의할 것

### Figma 활용 규칙

- 새 화면 구현 전 반드시 Figma에서 해당 화면 디자인을 먼저 확인할 것
- Figma의 레이어 이름을 위젯 변수명/파일명 참고용으로 활용할 것
- 디자인과 다르게 구현이 필요한 경우 반드시 사유를 주석으로 남길 것
- **UI가 이미 구현된 화면 작업 시 Figma MCP 확인 불필요, 로직 레이어만 작성할 것**

---

## 현재 구현 상태 (2026.06.25 기준)

### 완료 ✅
- 디자인 시스템 (colors, typography, spacing) + 앱 테마
- Firebase 초기화 (firebase_options.dart), dotenv/카카오/네이버지도 초기화
- 인증 UI 화면 전체 (welcome, OTP, 본인인증, 약관, 가입완료)
- 공통 위젯 (VybeButton, VybeTextField 등)
- **Cloud Functions 13개 전부 구현** (auth 7 + favorites 2 + reviews 3 + performances 1)
- **Flutter 데이터 레이어 전부 구현** — Freezed 모델 11종, datasource 9종,
  repository 인터페이스 8종 + impl 8종 (각 Riverpod provider 포함)
- 인증 플로우 연결 (SDK → Functions → Firebase)
- `MainScaffold` 5탭 (홈 / 주변 / 찜 / 검색 / 내 정보)
- 홈 (배너·추천), 내 주변 (네이버 지도 + geohash), 검색 화면
- **클럽 상세 — club_detail_glass.html(리퀴드 글래스) 리뉴얼 완료**
  (오로라 배경 + 히어로 320 + 히어로를 -34 덮는 아이덴티티 글래스 카드 +
  퀵 액션 4칸(전화·길찾기·공유·저장) + sticky 글래스 세그먼트 탭 5개)
  - 홈: 시간대별 무료입장(정책 있는 클럽만) / 매장정보(주소·영업시간 확장) / 오늘의 라인업 /
    테이블 요약 / 메뉴3 / 사진6 / 주변 클럽
  - 메뉴: 메뉴판 이미지 + sticky 카테고리 칩(섹션 스크롤) + 카테고리별 섹션
  - 사진: sticky 필터 칩(개수) + 2열 매스너리 + 12장씩 더 보기
  - 리뷰: 평점 요약(분포 바) + 작성 버튼 + 정렬 칩 + 5개씩 더 보기
  - 매장 정보: 위치(네이버 지도·주소 복사·길찾기) / 상세 정보 / 편의시설 / 이용 안내
  - 공통 글래스 위젯은 `clubs/widgets/club_glass.dart`
  - ⚠ **`NestedScrollView.headerSliverBuilder`에 pinned `SliverPersistentHeader` 금지**
    — Flutter 3.41 세만틱스 검증(`debugCheckForParentData`)이 매 프레임
    `'!semantics.parentDataDirty'` assert를 던져 화면이 통째로 안 그려진다(빈 화면).
    sticky 바는 스크롤 밖 고정 행(탭바는 `NestedScrollView.body` 최상단)으로 구현할 것
  - **편의시설 (2026.08.15)** — `info.facilities`(영문 키 배열) → 3열 그리드 카드.
    키↔라벨·아이콘 대응은 `clubs/renew/widgets/renew_facilities.dart`의 `ClubFacility` enum 하나.
    등록된 시설이 없으면 섹션 자체를 뺀다. 데이터 없으면 `node scripts/seed_facilities.js`
- **찜 탭 (`saved/`) — favorites 실연동** (정렬, 리스트↔그리드 뷰, 찜 해제)
- **마이페이지 (`my_page/`) — my_renew.html 리뉴얼 완료 (2026.08.15)**
  (오로라 배경 + 가로 프로필 행(아바타 76 · 프로필 수정 pill) + 통계 카드 2칸(리뷰·찜) +
  '내 활동'·'계정' 메뉴 목록 + 버전 표기. 메뉴는 카드로 감싸지 않고 **헤어라인으로만** 구분 —
  글래스 카드를 겹겹이 쌓으면 배경이 탁해져 본문이 안 읽힌다)
  - 하위 화면: 내 리뷰 관리(collectionGroup 조회·수정·삭제) / 내 정보 수정(닉네임) /
    설정(로컬 토글 + 캐시 삭제 실동작) — 공통 상단바는 `MyPushHeader`
  - 화면 전용 조각은 `my_page/widgets/my_page_common.dart` 하나에 모음
    (푸시 헤더 · 메뉴 행 · 토글 · 입력 · 아바타 · 등장 애니메이션)
  - 디자인의 @핸들·한 줄 소개·성별·활동지역은 users 스키마에 없어 제외
    (핸들 자리는 가입 방식 표기로 대체), 리뷰 '좋아요 수'도 reviews 스키마에 없어 제외
  - 리뷰 수정은 실동작(작성 화면 재사용), **프로필 사진 변경·알림 화면은 준비 중 토스트**
  - ⚠ 리뉴얼 디자인 토큰·글래스 프리미티브(`RenewGlass` · `RenewGlassCard` · `RenewBar` ·
    `RenewSectionHead` · `RenewButton` · `RenewIcons`)는 클럽 상세와 함께 쓰므로
    `presentation/common/renew/`에 있다 (예전 `clubs/renew/widgets/`에서 승격)
- **리뷰 작성 페이지 (`clubs/review_write_screen.dart`) — review_write.jsx 글래스 디자인 기반**
  (별점 0.5 단위 반쪽 별, 추천 태그 칩 → `tags`, 사진 최대 4장 `image_picker` → Storage 업로드,
  후기 500자, 주의사항, 등록 완료 화면). 구 `write_review_sheet.dart` 바텀시트는 대체·삭제됨
- **검색 화면 인기 해시태그 · 실시간 인기 검색어 실연동 (2026.07.31)** — 더미 상수 제거 완료.
  `searchLogs`(수집) → `aggregateSearchTrends`(집계) → `searchTrends/current`·`searchHashtags`(노출).
  순수 로직은 `functions/src/search/compute_trends.ts`에 분리(Firestore 의존 없음) —
  되먹임 필터·고유유저 집계·증감·fallback·갱신주기 판단 전부 여기 있음
- **홈 배너 → 프로모션 상세 (2026.08.06)** — `promotions` 컬렉션 + 범용 상세 화면
  (`presentation/promotion/promotion_detail_screen.dart`). 배너 탭 → `banner_link_handler`가
  `linkType`으로 분기 → `promotion`이면 promotionId로 문서 1건 조회해 히어로·제목·기간·본문·
  사진 n장·하단 CTA(클럽 상세 / 외부 URL)를 렌더. **배너마다 다른 광고 페이지를 앱 배포 없이
  DB만으로 추가** 가능. 배너 카드에 없던 `onTap` 신설(기존엔 링크 필드가 죽어 있었음)
- **공지사항 (2026.08.03)** — `notices` 컬렉션 + 앱 읽기 전용 화면
  (마이페이지 계정 메뉴 → `my_page/notices_screen.dart` 목록 → `notice_detail_screen.dart` 상세).
  카테고리 배지·고정 공지·NEW(7일) 배지·사진 n장. **작성/수정은 어드민 페이지(별도 구축 예정) 전용**
  - **게시 기간·게시 상태 (2026.08.07)** — 예약 게시(`publishedAt` 미래) / 게시 종료(`endAt`) /
    게시중단(`isActive=false`, 기간보다 우선) 3조건으로 노출 제어.
    판정은 `NoticeModel.isVisibleAt(now)` 단일 소스, 목록·단건 조회 양쪽에 적용
- **앱 버전 체크 / 강제 업데이트 (2026.08.13)** — `appConfig/{platform}` 정책 문서 +
  `presentation/common/version_gate/`. 루트가 `VersionGate` → `AuthGate` 순서라
  **로그인 전에** 판정한다. 점검 > 강제 > 권유 > 통과 4단계, 강제·점검은 전체화면
  차단(`PopScope canPop:false`), 권유는 앱 실행당 1회 바텀시트.
  앱 복귀(`AppLifecycleState.resumed`)마다 재검사 — 앱을 며칠 켜둔 기기가 강제
  업데이트를 영영 피하는 구멍 차단. 조회 실패·타임아웃은 전부 통과(fail-open).
  버전 비교·판정은 `core/utils/version_utils.dart` 순수 함수 + `test/version_utils_test.dart`.
  설정 화면 하단 버전 표기도 하드코딩 대신 이 결과를 재사용(`package_info_plus`)
- **네트워크 연결 게이트 (2026.08.16)** — `presentation/common/network_gate/`.
  루트가 `SplashGate` → `NetworkGate` → `VersionGate` → `AuthGate` 순서라
  **버전 조회·세션 복원보다 먼저** 걸린다(연결이 없으면 그것들은 타임아웃만 먹고
  빈 화면이 된다). 확인은 스플래시가 도는 동안 시작 —
  `splashDestinationProvider`가 `networkStatusProvider`를 보기 때문.
  - 판정 2단계 — ① `connectivity_plus` 연결 종류(비행기 모드·데이터 꺼짐)
    ② `InternetAddress.lookup('firestore.googleapis.com')` 실제 도달(공용 와이파이
    로그인 페이지). **fail-open** — 플러그인 오류·조회 타임아웃·DNS 타임아웃은 전부
    통과시킨다(확인 실패로 앱을 막으면 잘못된 차단). 판정은
    `data/datasources/local/device_network_datasource.dart` 한 곳
  - 차단 화면 `widgets/network_error_screen.dart` (디자인 `network_error.jsx` 이식) —
    오로라 배경 + 신호없음 아이콘(`no_signal_icon.dart`, CustomPaint) + 다시 시도 +
    '네트워크 설정 열기'. 재시도 실패는 `VybeToast`(횟수 표기)
  - 자동 복구 3경로 — 재시도 버튼 · 앱 복귀(`resumed`) · 기기 연결 변화 스트림.
    설정에서 와이파이를 켜고 돌아오면 버튼을 안 눌러도 넘어간다
  - ⚠ iOS는 와이파이 설정 직접 진입이 막혀 있어 '설정 열기'가 **앱 설정 화면**으로
    열린다(app_settings 폴백). Android는 와이파이 설정으로 직행
  - **화면 확인용 강제 오프라인** — `DeviceNetworkDataSource.debugForceOffline = true`
    로 바꾸고 **핫리로드**하면 바로 안내 화면이 뜬다(`NetworkGate.reassemble` 이
    매 핫리로드마다 재검사). iOS 시뮬레이터는 Mac 네트워크를 그대로 써서 실제로
    끊으려면 Mac 와이파이를 꺼야 하므로 이 스위치가 빠르다.
    `kDebugMode` 안에서만 읽으므로 켠 채 커밋해도 **릴리즈 빌드는 영향 없음**
- **내 위치 기반 지역 판정 (2026.08.16)** — 지역 '홍대' 고정을 해제.
  `SplashGate` 진입 시 `geolocator`로 GPS 1회 조회(권한 팝업도 여기) →
  `userLocationProvider`(keepAlive) 갱신 → 홈 위치 칩 라벨 · 홈 '주변 클럽' 섹션 ·
  주변 탭 최초 조회 중심 · 힙합 카드 거리가 전부 이 좌표 하나를 본다.
  - GPS 코드는 `data/datasources/local/device_location_datasource.dart` **한 곳만**.
    서비스 꺼짐·권한 거부·타임아웃(5초)은 전부 예외 대신 null → 폴백 좌표(홍대)로 진행
  - 좌표 → 지역 이름은 `AppGeo.areaOf()` **2단계** — ① 클럽 상권
    (`AppGeo.hotspotCenters`, 반경 2km) ② 전국 시군'구'(`korea_regions.dart`, 252개,
    상한 60km). 둘 다 최근접이 우선(홍대·신촌은 1.2km라 반경으론 못 가린다).
    판정 테스트는 `test/app_geo_test.dart` · `test/user_location_test.dart`
    - **국내 밖(60km 밖)이면 좌표를 상권으로 대체한다 (2026.08.16)** —
      `AppGeo.overseasFallbackAreas`(홍대·건대·이태원·강남) 중 **앱 실행마다 랜덤 1곳**의
      좌표를 쓰고, 라벨만 `AppGeo.outsideKoreaLabel`(**'위치 확인 불가'**)로 바꾼다.
      해외 좌표를 그대로 두면 반경 3~30km에 클럽이 0곳이라 홈 '주변 클럽'·주변 탭이
      빈 화면이 되기 때문. 좌표를 빌린 걸 숨기고 '강남'이라 쓰면 거짓 정보라 라벨은 분리.
      대체 여부는 `UserLocation.outsideKorea`, 화면 문구는 **`areaLabel`로만** 읽을 것
      (`area`엔 대체한 상권명이 들어간다). 판정·대체는 `UserLocationNotifier.setLocation`
      한 곳. 뽑은 상권은 앱 실행 내내 고정 — 칩을 누를 때마다 주변 클럽이 갈아엎히면 안 됨
    - 상권명('홍대'·'강남')은 `clubs.area` 값과 **정확히 같아야** 한다 —
      지역 필터·거리표가 같은 문자열을 쓴다. DB에 상권을 추가하면
      `AppGeo.hotspotCenters`에도 추가할 것
    - **구가 있는 시는 시가 아니라 구를 넣는다 (2026.08.16)** — 일반구를 둔 12개 시
      (수원·성남·안양·안산·고양·용인·부천·청주·천안·전주·포항·창원)는 시 항목을 빼고
      구 35개로 대체. 시 하나로 두면 분당·일산·수지가 전부 '성남시'·'고양시'로 뭉개진다.
      화성시는 일반구 미설치라 아직 시 단위 — 설치되면 같이 쪼갤 것
    - 시군구 라벨은 `clubs.area`와 **무관한 표시 전용** 문자열. 이름이 겹치는
      중구·동구·남구·서구·북구·강서구·고성군·포항 남북구만 '서울 중구'처럼 시도를 앞에
      붙였다(경기 광주시도 광주광역시와 구분하려 '경기 광주시'). 라벨 유일성은 테스트가
      지킨다. 상권 2km가 시군구보다 먼저라 홍대에 있으면 '마포구'가 아니라 '홍대'로 뜬다
  - 홈 '주변 클럽'은 3 → 10 → 30km로 반경을 넓혀 가까운 순 5곳. 다 비면 홍대로 폴백
    (섹션을 비우느니 보여준다)
  - ⚠ **홍대 고정으로 되돌리려면 `AppGeo.useFixedLocation = true`** 하나만 바꾼다
    (GPS를 아예 안 읽어 권한 팝업도 안 뜬다). 홍대 좌표·라벨 상수는 그대로 살아 있다
  - 위치 권한 문구는 이미 설정돼 있음 — Android `ACCESS_FINE/COARSE_LOCATION`,
    iOS `NSLocationWhenInUseUsageDescription`
- **회원 탈퇴 — 30일 보관 soft delete (2026.08.17, 서버 배포 완료 · 앱 배포만 남음)**
  요구가 둘이라 축을 나눴다 — ① 데이터는 **30일 보관** 후 파기 ② 보관과 별개로
  리뷰·사진은 **탈퇴 즉시 비노출**. 그래서 "삭제"가 아니라 **숨김 + 예약 파기**다.
  - 즉시(`requestAccountDeletion` onCall) — `users.status='pendingDeletion'` + `deletedAt`·`purgeAt`,
    리뷰·사진·찜 `isHidden=true`, 클럽 `rating`·`reviewCount`·`favoriteCount` 감산,
    Auth 계정 `disabled=true`. **멱등** — 중간 실패 후 재호출해도 안 숨겨진 것만 이어서 처리
  - 30일 후(`purgeDeletedUsers` 스케줄, 매일 KST 04:30) — Firestore 문서 · Storage 파일 ·
    Auth 유저 완전 삭제. 회차당 50명, 한 명 실패해도 다음 회차에 다시 잡힌다
  - ⚠ **Auth 유저를 즉시 지우지 않고 `disabled`로 두는 이유** — 소셜 uid는 `kakao:{id}`로
    **고정**이라 Auth에서 지우면 재로그인 시 **같은 uid가 다시 만들어져 보관 중 데이터에 붙는다**.
    `disabled`면 로그인이 거부되고, 앱의 `isSessionRevokedCode`가 `user-disabled`를 이미
    처리해 **다른 기기 세션도 다음 실행 때 자동 정리**된다(앱 추가 작업 0)
  - ⚠ **집계 감산 주체는 `requestAccountDeletion` 하나** — 트리거 3종
    (`onReviewUpdated`·`onReviewDeleted`·`onFavoriteDeleted`)에 `isHidden` 가드를 넣었다.
    없으면 파기 때 두 번 깎여 음수가 된다
  - ⚠ **쓰기 경로도 `isHidden: false`를 같이 써야 한다** — `ReviewModel.toFirestore()`와
    `firebase_favorite_datasource.addFavorite`에 들어 있다. 빠뜨리면 목록 쿼리
    (`where isHidden == false`)가 못 잡아 새 리뷰가 조용히 사라진다
  - 앱: 설정 하단 '탈퇴하기' → `my_page/account_delete_screen.dart` —
    **account_delete.html(만류 화면) 디자인 적용 (2026.08.20)**.
    내 찜/리뷰/사진 개수 카드 + 놓치게 되는 것 6줄 + 탈퇴→보관→파기 3단계 타임라인 +
    사유 칩(고르면 대안 카드) + 동의 체크 + 주 버튼은 '계속 이용하기'(탈퇴는 밑줄 링크)
    + 확인 다이얼로그. 조각은 `my_page/widgets/account_delete_parts.dart`
    - ⚠ **디자인 시안의 '30일 안에는 재가입할 수 있어요'는 서버와 반대라 안 쓴다** —
      보관 기간엔 로그인·재가입 둘 다 막히고(`checkPhoneDuplicate` → pendingDeletion)
      파기일이 지나야 다시 가입할 수 있다. 화면 문구는 이 기준으로 통일
    - ⚠ **완료 안내는 라우트가 아니라 오버레이**(`LeaveDoneOverlay`) — 탈퇴 직후
      `AuthGate`가 루트 위 라우트를 전부 걷어내 화면으로 push하면 뜨자마자 사라진다.
      `OverlayState`는 `await` 전에 잡아 둘 것. 재가입 가능일은 서버가 준 `purgeAt` 사용
    - 확인 다이얼로그는 공용 `VybeConfirmDialog`에 `icon`·`cancelTone`·
      `VybeConfirmTone.dangerQuiet`(붉은 아웃라인)를 더해 만들었다 — 취소('더 써볼게요')가
      채운 버튼이어야 탈퇴 쪽이 주 동작으로 보이지 않는다
    - 사유 칩 라벨 = 서버 `deletionReason` 값. **문구를 바꾸면 저장값도 바뀐다**
    - 대안 카드 CTA는 실제로 갈 곳이 있는 것만 단다(알림 설정·개인정보 처리방침).
      클럽 제보·의견 보내기는 창구가 없어 버튼 없이 문구만
    탈퇴 성공 시 repository가 이어서 `signOut()` → `AuthGate`가 루트를 Welcome으로 교체
  - **보관 기간 내 재로그인 = 자동 복구 (2026.08.20)** — 별도 '철회' 버튼이 아니라
    **로그인이 곧 복구**다. 서버 `restorePendingDeletionOnLogin()`
    (`functions/src/account/restore_account.ts`)이 로그인 3종에서 Custom Token 발급 **전에**
    돌아 역연산을 한다 — 리뷰·사진·찜 `isHidden=false` + 집계 **가산** + Auth `disabled=false` +
    `status='active'`·`deletedAt`·`purgeAt`·`deletionReason` 삭제
    - ⚠ **`purgeAt`이 지났으면 되살리지 않는다** — 살려 놔도 그날 새벽 `purgeDeletedUsers`가
      데이터를 지운다. 이때는 예전처럼 `failed-precondition`으로 막되 `purgeAt`은 **null로**
      보낸다(이미 지난 날짜를 '그날부터 가입 가능'이라 안내하면 거짓말)
    - ⚠ 상태 필드(`status` 등)는 **맨 마지막에** 지운다. 중간에 실패하면 `pendingDeletion`이
      남아 다음 로그인이 처음부터 다시 시도한다. 각 단계가 `isHidden==true`인 문서만 손대므로
      재실행해도 **이중 가산 없음**(숨김 쪽과 대칭)
    - ⚠ 집계 가산 주체도 이 함수 하나 — `isHidden` false 전이는 `onReviewUpdated`가
      가드로 건너뛴다(이미 양방향 전이를 모두 무시하게 돼 있다)
    - `checkPhoneDuplicate`도 같이 바뀜 — 본인 + 파기 전이면 `sameAccount=true`·
      `pendingDeletion=false`·`restorable=true`로 통과시킨다. 안 그러면 본인인증 경로가
      로그인 화면 앞에서 먼저 막혀 복구까지 도달을 못 한다
    - 앱: 복구되면 토스트 `kAccountRestoredMessage`(소셜은 Welcome, 본인인증은 인증번호 화면),
      본인인증 경로는 넘어가기 전에 `kAccountRestoreNotice`로 예고. 문구 상수는 `signup_flow.dart`
    - 탈퇴 화면 타임라인·완료 오버레이 문구도 '보관 기간엔 로그인도 막힌다' → '다시 로그인하면
      복구된다'로 수정 (**새 가입은 여전히 파기일 이후**)
  - 배포 순서·주의는 아래 '미구현' 항목 참고. 상세 설계는 `firebase_structure.html#account-deletion`

### 미구현 / 진행 중 ✗
- **시간대별 무료입장 — 앱 전 화면 완료, Algolia 색인만 남음 (2026.08.21)**
  Firestore `clubs`에 `freeEntry`·`isFreeEntry` 배정 완료(164개, timed 47).
  **완료** — `data/models/free_entry_policy.dart`(순수 함수 `statusAt()` +
  `test/free_entry_policy_test.dart` 25건), `ClubModel.freeEntry`·`isFreeEntry`,
  `getTimedFreeEntryClubs()`, 홈 '이 시간에만 무료입장' 섹션(`home/widgets/home_free_time_clubs.dart`),
  **클럽 상세 '시간대별 무료입장' 섹션 (2026.08.20 — club_detail_renew.html 디자인 이식)**,
  **입장비 무료 페이지 · 검색 필터 · 검색 카드 (2026.08.21)**:
  - `getFreeEntryClubs()` 기준을 `entryFeeMin==0` → `isFreeEntry==true`로 교체
    (**상시 72 → 상시+시간대 119곳**). `entryFeeMin==0`은 timed 클럽을 영영 못 잡는다 —
    timed는 무료가 끝났을 때 보여 줄 요금이 필요해 `entryFeeMin > 0`으로 두기 때문
  - `free_entry_screen.dart` — 리본 3상태(지금 무료 · 시간대 무료 · 입장비 무료), 화면 전용
    정렬 `'지금 무료순'`(기본값), 인트로 pill이 **지금 무료인 곳 수**를 센다.
    ⚠ **무료가 지금 유효할 때만 요금에 취소선**을 긋는다 — 아닐 때 그으면 지금 공짜로
    들어갈 수 있다는 거짓말이 된다(그때는 `22:00부터 무료`로 바꿔 쓴다)
  - `ClubFilter.freeEntry` → `c.isFreeEntry`, 검색 카드 입장료 칩은 timed 진행 중이면 '지금 무료입장'
  - 시각 표기 문구(`38분 남음`·`금 22:00부터`)는 홈과 공유 — `presentation/common/free_entry_labels.dart`.
    두 화면이 같은 클럽을 다르게 말하면 안 되므로 한 곳에 둔다
  - 판정 시각은 **화면당 한 번** 읽어 목록 전체에 넘긴다. 카드마다 `DateTime.now()`를 다시 읽으면
    같은 목록 안에서 기준이 어긋나 정렬과 표기가 따로 논다
  - 테스트 `test/free_entry_screen_test.dart` 4건 — 시각을 주입할 수 없어 창을 **지금 기준 상대
    시각**으로 만들어 실행 시각과 무관하게 같은 결과가 나오게 짰다
  남은 것:
  ① **Algolia Extension Indexable Fields를 정본 19개로 맞추기** → `node scripts/reindex_clubs.js`
  (2026.08.21 현재 `freeEntry`·`isFreeEntry`는 들어갔지만 그 전부터 6개가 빠져 있다 —
  위 '클럽 검색(Algolia)' 항목의 ⚠ 참고). 그때까지 검색 hit은 `complete=false` → `getClub` 조인 폴백이라
  **값은 맞고 read만 든다**(앱 코드는 이미 두 필드를 `_requiredFields`에 넣어 뒀다)
  ② 어드민 편집 UI (요일·시간 입력 + `isFreeEntry` 동시 쓰기)
  - **클럽 상세 (2026.08.20)** — 홈 탭 **첫 섹션** `clubs/renew/widgets/renew_free_entry.dart`.
    남은 시간 카운트다운(실시각 1초) + 시간대별 입장비 도형 + 조건 한 줄 + 요일별 무료입장 시간(접힘).
    매장 정보·상세 정보 탭의 **입장료 행**도 `RenewFeeRow`로 바뀌어 '지금 무료' pill + 무료 시간대가 붙는다
    - ⚠ **`freeEntry.type == 'timed'` 클럽에서, 무료 시작 1시간 전부터만 그려진다** —
      판정은 `RenewFreeEntrySection.maybeBuild()` 한 곳, null이면 호출부가 목록에서 뺀다.
      미표시 조건 넷 — `none`(무료 없음) · `always`(**상시 무료 — 나눌 시간대가 없어 도형이
      한 칸, 카운트다운도 없다. '무료'는 입장료 행이 이미 알린다**) · timed인데 쓸 수 있는 창이
      하나도 없을 때 · **다음 무료 시작이 `RenewFreeEntrySection.leadTime`(1시간)보다 멀 때**
      (무료가 여섯 시간 뒤인데 카운트다운이 홈 탭 첫 자리를 종일 차지하면 안 된다).
      무료가 **진행 중**이면 남은 시간이 곧 알맹이라 무조건 표시
    - ⚠ **표시 판정은 화면을 만드는 시점 한 번**이다 — 이미 떠 있는 섹션은 무료 시간이 끝나도
      그대로 두고 헤드만 '다음 무료입장'으로 바뀐다. 보고 있는 화면에서 섹션이 통째로 사라지면
      스크롤이 튀고 방금 본 정보를 다시 찾게 된다. 다시 숨기는 건 다음 진입 때
    - ⚠ **Firestore에 시간대별 요금표는 없다** — 도형은 `operatingHours`(회차) × `freeEntry.windows`
      × `entryFeeMin`을 겹쳐 만든다(`data/models/free_entry_timeline.dart` ·
      `test/free_entry_timeline_test.dart` 17건). 없는 요금 구간을 지어내지 않는다
    - 도형이 그리는 **회차(오픈~마감)**는 앵커로 고른다 — 무료 중이면 지금 회차,
      아니면 다음 무료 창의 시작 시각이 든 회차. 앵커 회차에 무료 구간이 없으면 도형을 뺀다
      (다른 날로 몰래 건너뛰면 헤드 문구와 다른 날을 그리게 된다)
    - 칸 너비는 길이 비례지만 **최소 폭 52**를 보장하고 모자란 만큼 넓은 칸에서 뗀다.
      현재 시각 마커도 **같은 너비 배열**로 계산해야 칸 경계와 안 어긋난다
    - 디자인의 **'무료 시간 시작 전 알림 받기' 버튼은 뺐다** — 푸시 알림 경로가 없어 눌러도 아무 일이 없다.
      '만석 시 조기 마감'·'신분증 지참' 두 줄도 대응 필드가 없어 뺐다(조건은 `freeEntry.condition` 하나)
    - ⚠ **영업 여부는 판정과 같은 시각으로 물어야 한다** — `OperatingHours.dayAt(now).isOpenAt(now)`.
      `today.isCurrentlyOpen`은 **벽시계**를 읽어, 시각을 주입하는 판정과 섞으면
      "무료 창 안인데 영업 종료" 같은 어긋난 답이 나온다(홈 카드 `toHomeFreeTimeClub`도 같이 고침)
  - Rules·인덱스·Cloud Functions 변경 **없음** (집계 아님 · clubs 쓰기는 어드민 전용 · 등호 2개라 복합 인덱스 불필요)
  - 구버전 앱은 `entryFeeMin==0`만 보므로 timed 클럽이 무료 목록에서 **안 보일 뿐**(누락) 오표기는 아니다
    → 강제 업데이트 사안 아님. 상세 설계는 `firebase_structure.html#feature-free-entry`
- 회원 탈퇴 잔여 작업 — **서버는 2026.08.17 전부 배포 완료**
  (백필 4865건 · 인덱스 · Rules · Functions 15개 · 스케줄 잡 ENABLED).
  ⚠ **단, 보관 기간 내 재로그인 복구(2026.08.20)는 아직 미배포** —
  `firebase deploy --only functions:kakaoLogin,functions:naverLogin,functions:phoneLogin,functions:checkPhoneDuplicate`.
  앱을 먼저 내보내도 안전하다(구서버는 `restored`·`restorable`을 안 주고 앱은 false로 폴백 →
  예전처럼 차단될 뿐). 반대로 **서버만 먼저 내보내도** 안전하다(구앱은 필드를 무시하고
  복구된 계정으로 그냥 로그인된다 — 안내 토스트만 없다)
  남은 것 ① **앱 빌드·배포** (`isHidden` 쿼리 필터와 탈퇴 화면이 여기 들어 있다)
  ② 개인정보처리방침에 '30일 보관' 문구 추가(법무 확인)
  ③ 어드민 페이지에 `pendingDeletion` 조회·즉시 파기 기능
  - 배포 후 확인함 — 인덱스 목록 쿼리·컬렉션그룹 `userId` 조회 200,
    **비인증**으로 숨긴 문서 단건 조회 **403**(목록에도 0건), `requestAccountDeletion`
    비인증 호출 401, `purgeDeletedUsers` 수동 실행 `파기 대상 없음`·ok, 앱 빌드 성공.
    **실계정 종단 테스트는 못 했다** — 커스텀 토큰 발급에 필요한
    `iam.serviceAccounts.signJwt` 권한이 없음. 앱 배포 후 실기기에서 볼 것
    (`firebase_structure.html#account-deletion` 검증 표)
  - 배포 중 **구 `deleteUser` 함수 제거** — 소스에선 `bb2fb34`에서 이미 빠졌는데
    배포본만 살아 있었다. users 문서·Storage·Auth를 **즉시 하드 삭제**하고 리뷰·사진·찜은
    남겨 고아 데이터를 만드는, 30일 보관 요구와 어긋나는 경로. 호출부·호출 로그 0이라 삭제
  - ⚠ 순서 주의(이미 지켜짐) — 백필·인덱스가 앱보다 먼저여야 한다. 앱을 먼저 내보내면
    `where isHidden == false`가 필드 없는 문서를 못 잡아 **리뷰 탭·사진 탭이 빈 화면**,
    인덱스가 없으면 `failed-precondition`. 지금은 서버가 다 돼 있어 앱은 아무 때나 내보내도 된다
- 패스·지갑 탭 (`pass_wallet_screen.dart` 플레이스홀더 — 현재 탭 슬롯엔 미연결)
- 주변 페이지 ↔ 상세 페이지 연동 마무리 (최근 커밋 진행 중)
- 마이페이지 세부 — 프로필 사진 변경(image_picker 설치됨 — 연결만 남음), 알림 화면
  (리뷰 수정은 작성 화면 재사용으로 연결 완료)
- reviews collectionGroup 인덱스·Rules 배포 (`firebase deploy --only firestore` — 미배포 시 내 리뷰 관리 동작 안 함)
- 편의시설 잔여 작업 — ① `node scripts/seed_facilities.js` (안 돌리면 `info.facilities`가 비어
  매장정보 탭에 편의시설 섹션이 안 뜸. Rules·인덱스 변경은 불필요 — info 서브컬렉션 기존 규칙 그대로)
  ② 실제 시설 데이터 입력 + 어드민 편집 UI (현재 seed 값은 clubId 해시로 만든 샘플)
- 검색 트렌드 배포 잔여 작업 — ① `firebase deploy --only firestore:rules,functions:aggregateSearchTrends`
  ② `node scripts/seed_search_hashtags.js` (안 돌리면 두 섹션 다 빈 화면)
  ③ 콘솔에서 `searchLogs.expireAt` TTL 정책 추가
- 홈 배너 링크 잔여 작업 — ① `firebase deploy --only firestore:rules,storage`
  (promotions 규칙 + Storage `promotions/**`) ② 샘플 데이터 `node scripts/seed_promotions.js`
  (안 돌리면 기존 배너 4개가 `linkType:'screen'` 플레이스홀더라 탭해도 아무 일 없음)
  ③ 배너 `linkType`의 club·page·url 분기 연결 (`banner_link_handler.dart`) ④ 어드민 작성 UI
- 공지사항 배포 잔여 작업 — ① `firebase deploy --only firestore:rules,firestore:indexes,storage`
  (notices 규칙 + `notices(isActive, publishedAt DESC)` 인덱스) ② 샘플 데이터 `node scripts/seed_notices.js`
  ③ 어드민 페이지(작성 UI) 별도 구축
- 버전 체크 잔여 작업 — **Rules 배포·초기값 seed는 2026.08.13 완료**
  (`appConfig/android`·`appConfig/ios` 생성됨, 값은 전부 비어 있어 **차단 없음** 상태).
  남은 것 — ① **iOS `storeUrl`** (App Store Connect 등록 후 `.../app/id{앱ID}`.
  iOS는 폴백이 없어 비어 있으면 업데이트 버튼이 토스트만 띄운다)
  ② Android `applicationId`가 아직 `com.example.vybe`(Flutter 기본값) — **Play 스토어 게시 불가**.
  실제 패키지명 확정 필요 (`storeUrl`은 비워 두면 설치된 패키지명으로 폴백하므로 그때도 수정 불필요)
  ③ 어드민 페이지에 버전 정책 편집 UI
- 위치 연동 잔여 작업 — 입장비 무료(`free_entry`) · 서비스 음료(`service_drinks`)
  위치 칩이 아직 `AppGeo.hongdaeLabel` 고정. 두 화면은 좌표가 아니라
  `ClubAreaDistance` 지역 간 거리표(홍대·강남·이태원·압구정·건대)로 거리를 추정해서,
  라벨만 실제 지역으로 바꾸면 표에 없는 지역('신촌'·'내 주변')일 때 거리가 전부 0이 된다.
  → 카드 뷰모델에 클럽 좌표를 실어 실제 haversine 거리로 바꾸는 작업이 선행돼야 함
- Storage Security Rules 배포 검증 (Firestore Rules는 배포됨)
- Apple 로그인 (이후 구현)

---

## 작업 순서 (로드맵)

핵심 백엔드·데이터 레이어·주요 화면은 완료. 남은 작업:

```
1. 주변 ↔ 상세 페이지 연동 마무리 (진행 중)
        ↓
2. 마이페이지 잔여 작업 (프로필 사진 변경, 알림 화면)
        ↓
3. 패스·지갑 탭 실제 구현 (탭 슬롯 재배치 포함)
        ↓
4. Security Rules·인덱스 배포 검증(reviews collectionGroup 포함) + 본인인증(verifyIdentity) 실연동 점검
   (⚠ 선행: `functions/.env` 에 `PORTONE_IMP_KEY`·`PORTONE_IMP_SECRET` 채우고 재배포)
        ↓
5. Apple 로그인 (이후)
```

---

## Firebase 설계

### 베타 버전 범위

**포함 기능:**
- 회원가입 / 로그인 (네이버, Apple + 본인인증)
- 홈 / 검색 / 내 주변 (지도 기반 탐색)
- 업체 상세 (정보, 메뉴, 갤러리, 인앱 리뷰)
- 찜 목록
- 마이페이지 (프로필, 리뷰 내역)

**제외 기능:**
- 웨이팅 / 테이블 예약
- 분실물 찾기
- 결제 내역
- 블로그 리뷰
- Apple 로그인 (이후 구현)

---

### 인증 플로우

#### 로그인 방식
| 방식 | 처리 방법 | Firebase UID 형식 | 구현 시점 |
|------|-----------|-------------------|-----------|
| 카카오 | Cloud Functions (kakaoLogin) → Custom Token | `kakao:{kakaoId}` | 베타 |
| 네이버 | Cloud Functions (naverLogin) → Custom Token | `naver:{naverId}` | 베타 |
| 본인인증 | verifyIdentity → 신규 유저 등록 | Firebase 자동 생성 | 베타 |
| Apple | Firebase Auth 직접 처리 | Firebase 자동 생성 | 이후 구현 |

#### 전체 흐름
```
1. 소셜 로그인 SDK → accessToken / identityToken 발급
2. 네이버: Cloud Functions(naverLogin) → Custom Token 발급
   Apple: Firebase Auth 직접 처리
3. FirebaseAuth.signInWithCustomToken() → Firebase UID 발급
4. Firestore users/{uid} 존재 여부 확인
   - 신규 유저 → 본인인증(verifyIdentity) → 프로필 입력 → users/{uid} 문서 생성 → 홈
   - 기존 유저 → 홈 화면 이동
```

#### 핵심 규칙
- accessToken은 매번 달라지지만 네이버ID는 불변 → 항상 같은 Firebase UID 생성
- 본인인증은 로그인 방식이 아닌 신원 확인 수단
- `phone` 필드로 **다른 방식의** 중복 가입 방지 — 같은 번호라도 **가입할 때와 같은 방식이면 로그인은 허용**한다
  (막으면 로그아웃한 사용자가 영영 못 들어온다). 판정은 `checkPhoneDuplicate` 참고
- `isVerified: false` 로 초기 생성 → 본인인증 완료 시 `true` 로 업데이트

#### 전화번호 주인 판정 (재로그인 vs 차단) — 2026.08.18

같은 번호가 이미 쓰이고 있을 때 **막을지 통과시킬지**는 "누가 주인이냐"로 정한다.
번호가 있다는 이유만으로 막으면 본인인증으로 가입한 사용자가 로그아웃한 뒤
영영 못 들어온다(실제로 그랬다).

| 상황 | 결과 |
|------|------|
| 처음 보는 번호 | 약관 동의 → 문자 인증 → **가입** |
| 가입할 때와 **같은 방식**의 내 계정 | 약관 생략 → 문자 인증 → **로그인** (홈 직행. 가입완료 화면·프로필 저장 없음 = Firestore 쓰기 0) |
| **다른 방식**으로 가입된 번호 | 차단 — `이미 존재하는 계정입니다.` + 계정 생성 안 함 |
| 탈퇴 대기(30일) 계정 — **본인** | 통과 → 로그인하는 순간 **계정 복구** (`restorePendingDeletionOnLogin`) |
| 탈퇴 대기(30일) 계정 — 남 / 파기일 지남 | 차단 (재가입 가능일 안내) |

- 판정은 서버(`checkPhoneDuplicate`) 한 곳. **시도 중인 uid를 클라가 정하지 않는다** —
  세션이 있으면 `context.auth.uid`, 없고 본인인증 경로면 `phone:{phone}`,
  소셜 신규면 없음(= 무조건 다른 계정). 앱은 `method`(= `users.provider` 값)만 넘긴다
- ⚠ **주인의 uid·provider는 응답에 싣지 않는다** — 번호만 넣어 보면 남의 카카오/네이버
  식별자나 가입 방식을 캐낼 수 있다. 비교는 서버에서 끝내고 `sameAccount` 불리언만 준다
- 앱 쪽 흐름: `SignupMethod`(진입 방식)를 Welcome → 본인인증 화면 → 인증번호 화면까지
  들고 다닌다. 공용 조각은 `presentation/auth/signup_flow.dart`
  (`SignupMethod` · `PhoneAccountStatus` · `phoneBlockedMessage` · `enterHomeAfterAuth`)
- 차단 시 `AuthViewModel.abortSignup()` 으로 만들다 만 세션을 정리한다 — 소셜 로그인은
  본인인증 화면에 오기 **전에** 세션이 붙어서, 그냥 두면 이름·전화번호가 빈 계정으로 앱에 들어간다
- **로그인은 `saveUserProfile`을 부르지 않는다** — 값이 같아도 `updatedAt`이 갱신돼
  수정한 적 없는 계정이 로그인할 때마다 수정된 것으로 남는다. `isLogin`이 켜졌다는 건
  이미 프로필이 완성돼 있다는 뜻이라(`users.phone`을 쓰는 경로가 `isVerified=true`를 같이 쓴다)
  쓸 것도 없다. 소셜 '가입 이어하기'는 `isLogin: false`로 들어와 그대로 저장된다
- 인증번호 화면에서 **한 번 더** 판정한다. 앞 화면 통과와 계정 생성 사이에 다른 기기에서
  같은 번호가 가입될 수 있고, 실제로 계정이 생기는 건 그 시점이다
- ⚠ **문자 인증이 아직 가짜다** — 코드가 `'123456'` 하드코딩이고(`certification_number_handler.dart`),
  `phoneLogin`은 번호만 받으면 Custom Token을 내준다. 지금까지는 "이미 있는 번호 차단"이
  우연히 계정 탈취를 막고 있었는데, 재로그인을 허용하면서 그 방벽이 사라졌다.
  **출시 전 Firebase Phone Auth(실제 SMS) 연동 필수**

#### Flutter 네이버 로그인 코드 패턴
```dart
// 1. 네이버 로그인 → accessToken
final NaverLoginResult result = await FlutterNaverLogin.logIn();
final String accessToken = result.accessToken.token;

// 2. Cloud Functions 호출 → Custom Token
final callable = FirebaseFunctions.instance.httpsCallable('naverLogin');
final response = await callable.call({'accessToken': accessToken});
final String customToken = response.data['customToken'];
final bool isNewUser = response.data['isNewUser'];

// 3. Firebase 로그인
await FirebaseAuth.instance.signInWithCustomToken(customToken);

// 4. 신규/기존 분기
if (isNewUser) { /* 본인인증 화면 */ } else { /* 홈 화면 */ }
```

---

### Firebase 아키텍처 규칙

#### 레이어별 Firebase 허용 범위

| 레이어 | Firebase import | 설명 |
|--------|----------------|------|
| `presentation/` | ❌ 절대 금지 | Firebase SDK 직접 접근 불가 |
| `domain/` | ❌ 절대 금지 | 순수 Dart 인터페이스만 |
| `data/repositories/` | ❌ 금지 | datasource 타입 참조만 허용 |
| `data/datasources/remote/` | ✅ 허용 | Firebase 코드는 오직 여기에만 |

> 같은 규칙을 기기 SDK에도 적용한다 — `geolocator`(GPS) import는
> `data/datasources/local/device_location_datasource.dart` 안에만 둔다.
> presentation은 `userLocationProvider`만 본다.
> `connectivity_plus`·`app_settings`도 마찬가지로 `device_network_datasource.dart`
> 한 곳만 — presentation은 `networkStatusProvider`(+ 설정 열기 호출)만 본다.

#### 파일 구조 규칙
- 모든 Firebase datasource 파일은 `data/datasources/remote/` 안에 위치
- 파일명 패턴: `firebase_{domain}_datasource.dart`
- 클래스명 패턴: `Firebase{Domain}DataSource`

#### 새 Firebase 기능 추가 시 작업 순서
```
1. data/datasources/remote/firebase_{domain}_datasource.dart 에 메서드 추가
2. domain/repositories/{domain}_repository.dart 에 인터페이스 추가
3. data/repositories/{domain}_repository_impl.dart 에 구현체 추가
4. presentation에서는 repositoryProvider 또는 viewModelProvider만 참조
```

#### 현재 로그인 uid 접근 방법
presentation 레이어에서 현재 사용자 uid가 필요할 때는 반드시 `currentUidProvider` 사용:
```dart
// ✅ 올바른 방법
import 'package:vybe/core/providers/auth_providers.dart';
final uid = ref.watch(currentUidProvider); // String? (null = 비로그인)

// ❌ 절대 금지
import 'package:firebase_auth/firebase_auth.dart';
FirebaseAuth.instance.currentUser?.uid
```

#### Firebase 접근 로깅 규칙
모든 datasource 메서드에서 Firebase 호출 전 반드시 `logFirebaseAccess()` 호출:
```dart
import 'package:vybe/core/utils/firebase_logger.dart';

logFirebaseAccess(
  file: 'firebase_{domain}_datasource.dart',
  service: 'Firestore(컬렉션/경로)',
  purpose: '데이터 사용 목적 설명',
);
```

---

### Firestore 컬렉션 구조

Firebase 관련 코드는 반드시 `data/datasources/remote/` 에만 작성할 것.

#### users/{uid}
```
uid             : string    // Firebase Auth UID (PK)
name            : string    // 사용자 실명
phone           : string    // 본인인증 완료된 전화번호 (중복 가입 방지 기준)
birthDate       : string    // 생년월일 YYYYMMDD
gender          : string    // "male" | "female" — 주민번호 뒷자리 첫 숫자에서 도출(홀수 남/짝수 여)
                            //   ⚠ 영문 키만 저장. 한글 라벨은 화면에서 붙인다(provider·facilities와 같은 규칙)
                            //   알 수 없으면 필드 자체를 안 쓴다 — 빈 값은 '미입력'과 구분이 안 됨
                            //   도출은 genderFromCode()(presentation/auth/signup_flow.dart) 한 곳
profileImageUrl : string    // Storage 프로필 이미지 URL
provider        : string    // "naver" | "apple"
isVerified      : boolean   // 본인인증 완료 여부 (초기값: false)
status          : string    // "active" | "pendingDeletion" — 탈퇴 대기 여부.
                            //   필드가 없으면 active로 간주(기존 문서)
                            //   보관 기간 안에 다시 로그인하면 서버가 active로 되돌리고
                            //   deletedAt·purgeAt·deletionReason 을 지운다(복구)
deletedAt       : timestamp?// 탈퇴 요청 시각
purgeAt         : timestamp?// deletedAt + 30일 = 완전 파기 예정 시각(재가입 가능 시점)
deletionReason  : string?   // 탈퇴 사유(선택 설문). 안 고르면 빈 문자열
createdAt       : timestamp // 가입 시각. **문서를 처음 만들 때만** 쓴다(Rules가 이후 변경을 막음)
updatedAt       : timestamp // 수정 시각. 로그인만으로는 갱신 안 됨(재로그인 경로는 users 쓰기 0)
```
> ⚠ **`createdAt`은 앱이 쓴다 — `onUserCreated` 트리거에 맡기지 않는다 (2026.08.18)**
> 원래는 Auth 신규 유저 트리거가 채우는 설계였는데 **그 트리거가 실행되지 않고 있다**
> (`phoneLogin`이 새 uid를 만든 시각에 `onUserCreated` 호출 로그가 0건, 그렇게 만들어진
> `phone:` 문서엔 전부 `createdAt`이 비어 있음. 2026-04에 만들어진 `kakao:` 문서엔 있다).
> 이제 `setUserProfile`이 **문서가 없을 때만** `createdAt`을 같이 쓴다 —
> Rules의 update 규칙이 `createdAt` 변경을 막아 **이미 비어 있는 문서는 앱에서 못 메운다**
> (서버 스크립트 백필 필요).
> `status`·`deletedAt`·`purgeAt`는 **서버 전용** — Rules의 update 금지 키에 들어 있다.
> 클라가 고칠 수 있으면 탈퇴를 스스로 취소하거나 파기 시점을 뒤로 밀 수 있다.

#### clubs/{clubId}
```
clubId              : string    // = 문서 ID (PK). 문서 필드로는 저장 안 됨 (doc.id 사용)
name                : string    // 클럽 이름
description         : string    // 클럽 소개글
address             : string    // 주소
area                : string    // 지역 (예: "홍대", "강남", "이태원")
phone               : string    // 연락처
instagramUrl        : string    // 인스타그램 URL
location            : object    // { lat: double, lng: double, geohash: string }
                                //   geohash는 GeoQuery용 — location 맵 안에 포함됨 (최상위 아님)
                                //   쿼리 시 'location.geohash' 필드 경로 사용
genre               : string    // 주요 장르 (예: "힙합", "테크노", "팝")
genreStyles         : array     // 세부 장르 스타일 태그 (예: ["트랩","붐뱁","드릴","올드스쿨","R&B"])
                                //   장르 페이지(힙합 등) 포스터 카드 #태그 표시 + 추후 세부 필터용
                                //   검색(Algolia 인덱스 필드)과는 별개 — 혼용 금지
rating              : double    // 평점 (ratingSum / reviewCount, Cloud Functions 자동 업데이트, 직접 수정 금지)
ratingSum           : number    // 별점 합계 (Cloud Functions 자동 업데이트, 직접 수정 금지)
reviewCount         : number    // 리뷰 수 (Cloud Functions 자동 업데이트, 직접 수정 금지)
operatingHours      : object    // 요일별 영업시간
                                //   { mon, tue, wed, thu, fri, sat, sun }
                                //   각 요일: { isOpen: boolean, open: string?, close: string? }
                                //   예: { isOpen: true, open: "22:00", close: "06:00" }
                                //   휴무일: { isOpen: false }
closeTime           : string    // (레거시) 일부 클럽에 존재하는 단일 마감시각 필드.
                                //   영업시간 표시는 operatingHours 기준 — closeTime 신규 사용 금지
entryFeeMin         : number    // 평상시 입장료 최소 (원, 0이면 상시 무료)
                                //   ⚠ freeEntry.type='timed' 클럽은 0으로 두지 말 것 — 무료 시간이 끝났을 때
                                //     보여 줄 요금이 사라지고, 구버전 앱이 상시 무료로 오인한다
entryFeeMax         : number    // 평상시 입장료 최대 (원)
heroImageUrls       : array     // 상단 슬라이더 이미지 URL 목록 (상세 페이지 히어로)
imageUrls           : array     // 갤러리(사진탭) 이미지 URL 목록
menuBoardUrls       : array     // 메뉴판 이미지 URL 목록
thumbnailUrl        : string    // 리스트 대표 이미지 URL
tags                : array     // 태그 목록
favoriteCount       : number    // 찜 수 (Cloud Functions 자동 업데이트, 직접 수정 금지)
isActive            : boolean   // false면 앱에 노출 안 됨
isVybeRecommended   : boolean   // vybe 추천 여부
serviceDrink        : object    // 무료 서비스 음료 정보 (서비스 음료 페이지 데이터 소스)
                                //   { isOffered: boolean, comment: string, drinks: string[] }
                                //   isOffered : 제공 여부 (필터/노출 기준). 미제공이면 필드 생략 or false
                                //   comment   : 제공 코멘트 (예: "1인 음료 무제한", "테이블당 맥주 6병")
                                //   drinks    : 음료 종류 ["양주","샴페인","칵테일","맥주","와인"]
                                //   서비스 음료 페이지: isOffered=true 필터 + drinks로 종류 필터
freeEntryCondition  : string    // (레거시) 입장비 무료 조건 코멘트. freeEntry.condition으로 이관됨
                                //   예: "여성 무료입장", "새벽 2시까지 무료", "게스트리스트 등록 시 무료"
                                //   seed_free_entry.js로 배정 (entryFeeMin=0 클럽 대상)
                                //   앱은 freeEntry.condition이 비었을 때만 폴백으로 읽는다 — 다음 배포에서 제거
freeEntry           : object    // 무료입장 정책 (필드 없으면 type='none'으로 간주)
                                //   { type: string, condition: string, windows: array }
                                //   type      : "none" | "always" | "timed"
                                //     always : 상시 무료(entryFeeMin=0) / timed : 특정 시간대만 무료
                                //   condition : 조건 코멘트 (예: "자정 이전 입장 무료")
                                //   windows   : type='timed'일 때만. [{ days, start, end, label }]
                                //     days  : ["thu","fri","sat"] — operatingHours와 같은 키. 빈 배열이면 매일
                                //     start : "22:00" 포함 / end : "01:00" 미포함
                                //     end <= start 면 자정을 넘긴 창 — 창은 **시작 요일**에 속한다
                                //       (금 23:00~02:00 은 토 01:00 도 무료 → 판정은 어제 창도 같이 봐야 한다)
                                //   ⚠ 지금 무료인지 판정은 앱 순수 함수 FreeEntryPolicy.statusAt() 단일 소스.
                                //     Firestore는 "요일 × 시:분 × 자정 넘김"을 쿼리할 수 없다
                                //   ⚠ 무료 뱃지는 영업 중일 때만 표시 — 문 닫은 클럽의 '지금 무료'는 거짓 정보
                                //   홈 '이 시간에만 무료입장'은 getTimedFreeEntryClubs()
                                //     (isActive=true + freeEntry.type='timed') — 상시 무료는 뺀다
isFreeEntry         : boolean   // = (freeEntry.type != "none") 파생값
                                //   입장비 무료 페이지 쿼리(isActive=true + isFreeEntry=true) · 검색 '무료입장'
                                //   필터 · Algolia 인덱스 전용. 등호 2개라 복합 인덱스 불필요
                                //   ⚠ 트리거로 만들지 않는다 — clubs write가 Algolia Extension 동기화를 다시
                                //     태워 쓰기·색인이 2배가 된다(구 onClubWritten을 지운 이유와 같다).
                                //     freeEntry를 쓰는 쪽(seed·어드민)이 반드시 같이 쓴다
createdAt           : timestamp
updatedAt           : timestamp
```
> **시간대별 무료입장 (2026.08.18 데이터 배정 완료 · 앱 미구현)** — `node scripts/seed_free_entry_windows.js`로
> 전 클럽 164개에 `freeEntry`·`isFreeEntry`를 채웠다. 배정은 **지역별로 유료 클럽(`entryFeeMin>0`)의 절반**
> (홍대 16 · 강남 13 · 이태원 10 · 건대 6 · 신촌 2 = **timed 47** / always 72 / none 45).
> 상시 무료 클럽을 timed 후보에서 뺀 이유는 무료 시간이 끝났을 때 보여 줄 평상시 요금이 0원이라 없기 때문.
> 선정·시간대 모두 clubId 해시 기반이라 재실행해도 같은 결과(`--force` 재배정, `--dry` 확인만).
> ⚠ **창(window)은 전부 영업시간 안에 둔다** — DB의 164개 클럽은 전부 **목·금·토만 영업**
> (목·금 22:00~06:00, 토 22:00~05:00, 월·화·수·일 휴무). 밖에 창을 두면(오픈런 20:00~22:00, 주중 무료 등)
> '지금 무료'가 영영 안 뜬다. 영업일이 늘면 패턴 풀도 같이 늘릴 것.
> 실제 조사 데이터가 아니라 화면 확인용 샘플 — 운영 데이터는 어드민 편집 UI로 덮어쓴다.
> 설계 상세는 `firebase_structure.html#feature-free-entry`.

#### clubs/{clubId}/info/{clubId}
```
nearbySubways   : array     // 주변 지하철역 목록 [{ stationName: string, distanceM: number, lines: string[] }]
                            //   lines: 호선 목록 (예: ["9호선"]) — SubwayLineBadge 표시용
openChatUrl     : string    // 카카오 오픈채팅방 URL
cautions        : array     // 유의사항 목록 (string[])
facilities      : array     // 편의시설 키 목록 (string[]) — 클럽 상세 '매장정보' 탭 편의시설 섹션
                            //   parking(주차 가능) · restroom(화장실 분리) · smoking(흡연실)
                            //   locker(물품보관함) · card(카드 결제) · groupSeat(단체석)
                            //   ⚠ 한글 라벨이 아닌 **영문 키만** 저장. 라벨·아이콘 대응은 앱의
                            //     `ClubFacility` enum(renew_facilities.dart) 단일 소스 —
                            //     문구를 바꿀 때 전 클럽 문서를 손대지 않기 위함
                            //   ⚠ enum에 없는 키는 앱이 **조용히 버린다**(영문 키 노출 방지).
                            //     시설을 늘리려면 enum에 먼저 추가할 것
                            //   빈 배열이면 섹션 자체가 안 그려짐 (빈 카드 = '시설 없음'으로 읽히므로)
updatedAt       : timestamp
```
> 편의시설 seed(샘플): `scripts/seed_facilities.js` — card·restroom은 전 클럽 공통,
> 나머지는 clubId 해시로 결정(같은 클럽은 항상 같은 조합). 실제 시설 조사 데이터가 아니라
> 화면 확인용. **쓰기는 어드민 페이지(별도 구축 예정) 전용 — 앱은 읽기만.**

#### clubs/{clubId}/menus/{menuId}
```
menuId          : string    // PK
clubId          : string    // FK → clubs
name            : string    // 메뉴명
description     : string    // 설명
price           : number    // 가격 (원)
imageUrl        : string    // 메뉴 이미지 URL
category        : string    // 카테고리 (주류, 음식 등)
isAvailable     : boolean   // 판매 여부
isFeatured      : boolean   // 대표 메뉴 여부
createdAt       : timestamp
```

#### clubs/{clubId}/photos/{photoId}
```
photoId         : string    // PK (Firestore 자동 생성)
clubId          : string    // FK → clubs
userId          : string    // 올린 사람 uid (seed 데이터는 "seed")
url             : string    // Storage 다운로드 URL
category        : string    // "venue"(업체) | "food"(음식) | "inside"(내부)
                            //   PhotoCategory enum — Firestore엔 영문키, UI는 한글 라벨 매핑
isHidden        : boolean   // 올린 사람이 탈퇴하면 true — 사진탭 조회·Rules 양쪽에서 빠진다.
                            //   ⚠ 새 문서에도 false를 반드시 쓸 것 (리뷰와 같은 이유).
                            //     현재 앱엔 사진 생성 경로가 없고 seed로만 들어온다
createdAt       : timestamp // 사진탭은 createdAt desc 정렬 → index 0이 최신
```
> 사진탭(detail_gallery_tab) 카테고리 필터의 데이터 소스. 칩별 count는 메모리 집계.
> 기존 `clubs.imageUrls` 배열을 마이그레이션(`scripts/seed_photos.js`)해 생성 — 카테고리는 round-robin 임의 배정(실제 분류 아님).

#### clubs/{clubId}/reviews/{reviewId}
```
reviewId        : string    // PK
clubId          : string    // FK → clubs
userId          : string    // FK → users
userName        : string    // 표시 이름 (임시 — 추후 users/{uid} 조회로 대체)
rating          : number    // 별점 0.5~5.0 (0.5 단위 — 리뷰 작성 페이지에서 반쪽 별 입력)
content         : string    // 리뷰 텍스트
imageUrls       : array     // 첨부 이미지 URL 목록 (최대 4장)
                            //   Storage 경로 reviews/{clubId}/{reviewId}/{index}.{ext}
tags            : array     // 선택한 추천 태그 (예: ["음악이 좋아요","사운드 최고"])
                            //   리뷰 작성 페이지 고정 8종 칩에서 선택. 없으면 빈 배열
isHidden        : boolean   // 작성자가 탈퇴하면 true — 클럽 리뷰 목록·평점 집계에서 빠진다.
                            //   집계 감산은 requestAccountDeletion이 직접 한다
                            //   ⚠ 새 리뷰에도 false를 반드시 써야 한다 (ReviewModel.toFirestore).
                            //     목록 쿼리가 where isHidden==false라 필드가 없으면 Firestore가
                            //     문서를 못 잡아 **방금 쓴 리뷰가 조용히 안 보인다**
                            //   ⚠ 클라 수정 금지(Rules) — 유저가 직접 켜면 목록에선 사라지는데
                            //     reviewCount는 남아 평점이 영구히 어긋난다
createdAt       : timestamp
updatedAt       : timestamp
```
> 마이페이지 '내 리뷰 관리'는 `collectionGroup('reviews') where userId== orderBy(createdAt desc)`
> 크로스-클럽 조회 사용 (`firebase_review_datasource.watchUserReviews`).
> 인덱스: `reviews COLLECTION_GROUP (userId ASC, createdAt DESC)`.
> Rules: collectionGroup 쿼리는 중첩 match가 안 먹혀 `match /{path=**}/reviews`로
> 본인 리뷰 읽기만 별도 허용 (쓰기는 기존 clubs/.../reviews 규칙 그대로).

#### favorites/{favoriteId}
```
favoriteId      : string    // PK
userId          : string    // FK → users
clubId          : string    // FK → clubs (favoriteCount 자동 연동)
isHidden        : boolean   // 찜한 사람이 탈퇴하면 true. 찜은 본인만 읽어 '노출' 이슈는 없고,
                            //   favoriteCount에서 이미 뺐다는 표시 = 파기 때 이중 감산 방지
createdAt       : timestamp
```

#### users/{uid}/searchHistory/{historyId}
```
historyId       : string    // PK
userId          : string    // FK → users
keyword         : string    // 검색어
createdAt       : timestamp
```

#### banners/{bannerId}
```
bannerId        : string    // PK (= doc.id fallback)
imageUrl        : string    // 배너 이미지 URL
linkType        : string    // "promotion" | "club" | "page" | "url" — 탭 시 이동 방식
                            //   BannerLinkType enum. 알 수 없는 값은 none(이동 없음)으로 폴백
linkValue       : string    // 링크 대상 값
                            //   promotion: promotionId / club: clubId / page: 화면 키 / url: URL
order           : number    // 정렬 순서 (오름차순)
isActive        : boolean   // 노출 여부
startAt         : timestamp // 노출 시작
endAt           : timestamp // 노출 종료
createdAt       : timestamp
```
> 홈 배너 데이터 소스. `firebase_banner_datasource.getActiveBanners()`는
> `isActive=true` 쿼리 후 클라이언트에서 `startAt < now < endAt` 필터 + `order` 정렬.
> 탭 라우팅은 `core/navigation/banner_link_handler.dart` 한 곳에서 `linkType`으로 분기.
> 광고 페이지는 전체화면이라 `pushHidingNavBar`로 열어 하단 nav 바를 내린다(돌아오면 복원).
> **현재 연결된 건 `promotion` 뿐** — club·page·url은 미연결이라 조용히 무시된다
> (잘못된 곳으로 보내는 것보다 낫다).

#### promotions/{promotionId}
```
promotionId  : string     // PK (= doc.id fallback)
title        : string     // 상세 제목
subtitle     : string     // 제목 아래 한 줄 요약. 비면 미표시
heroImageUrl : string     // 상세 상단 히어로 이미지. 비면 히어로 없이 제목부터 시작
                          //   (배너 imageUrl은 목록용 비율이라 상세에서 재사용 안 함)
content      : string     // 본문 plain text. \n 줄바꿈 그대로 렌더 (마크다운/HTML 파싱 안 함)
imageUrls    : array      // 본문 아래 첨부 사진 0~n장 — Storage promotions/{promotionId}/{index}.{ext}
ctaType      : string     // "none" | "club" | "url" — 하단 고정 버튼 동작
ctaValue     : string     // club: clubId / url: URL
ctaLabel     : string     // 버튼 문구. 비면 타입별 기본값('클럽 보러가기' / '자세히 보기')
isActive     : boolean    // 노출 여부. false면 상세에서 '종료된 이벤트' 표시
startAt      : timestamp  // 표시용 진행 기간 시작 (선택)
endAt        : timestamp  // 표시용 진행 기간 종료 (선택) — 둘 다 없으면 기간 pill 미표시
createdAt    : timestamp
updatedAt    : timestamp
```
> 홈 배너(`linkType: "promotion"`) 탭 시 열리는 상세 콘텐츠. **top-level**(banners와 동급).
> 화면은 `presentation/promotion/promotion_detail_screen.dart` **하나뿐**이고 내용만 이 문서에서
> 갈아 끼운다 → 배너별로 사진·본문이 다른 광고 페이지를 **앱 배포 없이** 늘릴 수 있다.
> **쓰기는 어드민 페이지(별도 구축 예정) 전용 — 앱은 읽기만.**
> ⚠ **배너 doc에 본문을 넣지 않는 이유** — 홈 진입마다 배너 N개를 읽는데 안 여는 사용자까지
> 본문·사진 배열을 내려받게 된다. 탭했을 때만 doc 1건 조회(`getPromotion`).
> 쿼리는 단건 get뿐 → **인덱스 불필요**. 집계 필드 없음 → Cloud Functions 트리거 불필요.
> ⚠ **Rules에서 `isActive`를 read 조건에 넣지 않는다**(notices와 다른 점) — 단건 get이라
> 규칙으로 막으면 permission-denied가 되어 앱이 '없음'과 '오류'를 구분할 수 없다.
> 노출 여부는 datasource에서 필터해 null로 돌린다. seed(샘플): `scripts/seed_promotions.js`
> (프로모션 4건 생성 + 기존 배너 4개의 linkType/linkValue를 그 문서로 연결).

#### appConfig/{platform}  — 문서 2개 고정 (android · ios)
```
platform           : string    // "android" | "ios" (= doc.id)
minVersion         : string    // 이 버전 미만이면 강제 업데이트(앱 사용 차단). 비면 강제 없음
latestVersion      : string    // 이 버전 미만이면 업데이트 권유(닫을 수 있는 시트). 비면 권유 없음
storeUrl           : string    // 스토어 링크 — 앱 배포 없이 바꿀 수 있게 서버에 둔다
                               //   비면 Android만 market://details?id={packageName}로 폴백
updateTitle        : string    // 업데이트 안내 제목. 비면 화면 기본 문구
updateMessage      : string    // 업데이트 안내 본문. 비면 화면 기본 문구
isMaintenance      : boolean   // 점검 모드 — 버전과 무관하게 진입 차단 (버전보다 우선)
maintenanceMessage : string    // 점검 안내 문구. 비면 기본 문구
updatedAt          : timestamp
```
> 앱 버전 게이트 데이터 소스. **top-level** — 유저·클럽에 종속 안 되는 전역 설정.
> **쓰기는 어드민 페이지(별도 구축 예정) 전용 — 앱은 읽기만.**
> 앱 실행 시 `appConfig/{platform}` **문서 1건만** get → 인덱스 불필요, 집계 없음 →
> Cloud Functions 트리거 불필요. seed(초기값): `scripts/seed_app_config.js`.
> **판정 3단계** — ① `isMaintenance`(점검) ② `minVersion` 미만(강제) ③ `latestVersion` 미만(권유).
> 판정은 `decideVersionAction()`(`core/utils/version_utils.dart`) 한 곳에만 두고,
> 비교는 파트 단위 숫자 비교라 `1.10.0 > 1.9.0`이 올바르게 나온다(문자열 비교 금지).
> 빌드번호(`+7`)·프리릴리스(`-beta1`)는 무시 — 스토어에 노출되는 건 버전명이므로
> **핫픽스도 patch를 올려야** 게이트가 인식한다.
> ⚠ **Android/iOS 문서를 나눈 이유** — 스토어 심사·배포 시점이 달라 한쪽만
> `minVersion`을 올릴 수 있어야 한다.
> ⚠ **fail-open** — 네트워크 실패·3초 타임아웃·문서 없음·버전 미상은 전부 통과시킨다.
> 서버 사고로 전 유저 앱이 잠기는 쪽이 업데이트를 한 번 놓치는 것보다 훨씬 큰 사고다.
> 예외를 삼키는 곳은 `VersionCheck` 뷰모델 **한 곳뿐** — datasource는 그대로 던진다.
> ⚠ **Rules에서 read에 auth 조건을 걸지 않는다** — 게이트는 **로그인 전**에 읽는다.
> auth를 요구하면 비로그인 유저가 강제 업데이트·점검 안내를 영영 못 받는다.

##### appConfig 운영 주의사항
값 하나로 전 유저를 막을 수 있는 문서다. 어드민 편집 UI를 만들 때도 이 규칙을 따를 것.

| 상황 | 해야 할 것 / 하면 안 되는 것 |
|------|------|
| 강제 업데이트 켜기 | **새 빌드가 스토어에 실제 게시된 것을 확인한 뒤** `minVersion`을 올린다. **심사 중에 미리 올리면 심사자 기기가 차단 화면에 막혀 리젝**된다. Android 단계적 출시(%) 중이면 100% 도달 후 |
| 잘못 올렸을 때 | `minVersion`을 빈 문자열로 되돌리면 **즉시 해제** — 앱 재배포 불필요. 유저 기기 반영은 다음 실행 또는 백그라운드 복귀 시점 |
| 반영 시점 | 앱 **실행 시** + **복귀(resumed) 시**에만 조회. 앱을 켜 둔 채 화면만 옮기는 동안엔 반영 안 됨 (사용 중 갑자기 차단되지 않게 한 의도된 동작) |
| 점검 모드 | `isMaintenance=true`는 **최신 버전 유저까지 전원 차단**. 끄면 '다시 시도' 버튼으로 즉시 복귀 |
| 버전 값 형식 | `"1.2.0"` 숫자·점만. 빌드번호(`+7`)·프리릴리스(`-beta1`)는 **무시**되므로 **핫픽스도 patch를 올려야** 구분된다. `pubspec.yaml`의 `version:`과 스토어 버전명이 일치해야 판정이 맞는다 |
| 문서 삭제 금지 | 문서가 없으면 게이트가 **항상 통과**(fail-open) = 사실상 꺼짐. 끄고 싶으면 **문서를 지우지 말고 필드를 비운다** |
| storeUrl | 비면 **Android만** `market://details?id={설치된 packageName}` 폴백. **iOS는 폴백 없음** — App Store 등록 후 `https://apps.apple.com/kr/app/id{앱ID}` 필수 |
| 오프라인 유저 | Firestore `get()`이 캐시본을 주거나 3초 타임아웃 → **둘 다 통과**. 오프라인에선 강제 업데이트가 걸리지 않는다 (의도된 fail-open) |
| 쓰기 권한 | Custom Claim `admin: true`만. 어드민 페이지 전까진 `scripts/seed_app_config.js` 또는 콘솔에서 직접 수정 |

#### vybeRecommendations/{recId}
```
recId           : string    // PK (= doc.id fallback)
clubId          : string    // FK → clubs. 클럽 기본 정보(이름·평점·영업시간 등)는
                            //   clubId로 clubs에서 조인해 사용 (여기엔 에디토리얼 필드만)
rank            : number    // 추천 순위. 1 = featured(NO.1 PICK 히어로), 나머지는 순위 리스트
match           : number    // VYBE 매치 % (큐레이션 적합도)
reason          : string    // 큐레이터 노트 (추천 사유)
tags            : array     // 큐레이션 태그 override (비면 club.tags 사용)
weekOf          : timestamp // 주간 식별 (매주 화요일 업데이트)
isActive        : boolean   // 노출 여부
createdAt       : timestamp
```
> VYBE 추천 페이지 데이터 소스.
> `firebase_vybe_recommendation_datasource.getActiveRecommendations()`는
> `isActive=true` + `orderBy(rank)` 쿼리. clubs 컬렉션을 참조하고 페이지 전용
> 에디토리얼 필드(rank·match·reason·tags)만 보관 — 클럽 기본 정보는 clubId로 조인.
> 첫 항목(rank 1) = featured 히어로, 나머지 = 순위 리스트.

#### performances/{performanceId}
```
performanceId   : string    // PK (= doc.id)
clubId          : string    // FK → clubs. 클럽 기본정보(평점·영업·썸네일)는 clubId로 조인
clubName        : string    // 비정규화 — rail/hero에서 조인 없이 표시
clubArea        : string    // 비정규화 — 지역 표시/필터
genre           : string    // "힙합" 등 — 장르 페이지 공통 (EDM·K-POP 동일 구조 재사용)
artistName      : string    // 헤드라이너/라인업 (예: "YANO"). 아티스트는 별도 컬렉션 없이 임베드
artistType      : string    // "rapper" | "dj"  (rail 아이콘 Mic/Disc 분기)
startAt         : timestamp // 공연 시작 시각 — 시간순 정렬 + "오늘 22:00 공연" 표시
date            : string    // "YYYYMMDD" — 날짜 버킷 쿼리용 (멀티-날짜 저장 핵심)
isFeatured      : boolean   // true = Hero 캐러셀 노출 / false = rail만
isActive        : boolean   // 노출 여부
createdAt       : timestamp
```
> 장르 페이지(힙합 등) 공연 일정 데이터 소스. **top-level** 컬렉션 — DJ rail·hero가
> "오늘 모든 힙합 클럽 공연을 시간순"으로 가져오는 크로스-클럽 쿼리이기 때문(서브컬렉션이면 collectionGroup 필요).
> 문서 1개 = (클럽 × 날짜 × 공연). 같은 클럽이 여러 날 공연하면 doc 여러 개(clubId 동일, date·startAt 상이) → 멀티-날짜 저장.
> 쿼리: `genre== + date==<today YYYYMMDD> + isActive==true orderBy(startAt asc)` → hero=isFeatured만 / rail=전체.
> 포스터 그리드의 live·lineup은 오늘 공연 목록을 clubId로 머지해 도출(클럽에 저장 안 함 — 날짜 지나면 자동 무효).
> 인덱스: `performances(genre, date, startAt)`. seed: `scripts/seed_performances.js`.
> ⚠ favoriteCount·rating 같은 집계 없음 → Cloud Functions 트리거 불필요(live/lineup은 클라 머지 계산).

#### notices/{noticeId}
```
noticeId    : string     // PK (= doc.id fallback)
title       : string     // 공지 제목
content     : string     // 본문 plain text. \n 줄바꿈 그대로 렌더 (마크다운/HTML 파싱 안 함)
imageUrls   : array      // 첨부 사진 URL 0~n장 — Storage notices/{noticeId}/{index}.{ext}
category    : string     // "notice" | "update" | "event" | "maint" | "ad" — 목록 배지
                         //   배지 색: 공지=흰색 / 업데이트=보라 / 이벤트=라임 / 점검=옐로 / 광고=스카이블루
                         //   알 수 없는 값이면 '공지'로 폴백
promotionId : string     // 연결된 promotions 문서 id. 비어 있지 않으면 목록/이전·다음에서
                         //   탭했을 때 공지 상세가 아니라 PromotionDetailScreen으로 직행
                         //   (광고 공지 = 홈 배너와 같은 목적지 → 같은 내용 두 번 안 보게)
                         //   category와 분리 — 프로모션 없는 광고 공지도, 광고 아닌 공지의
                         //   이벤트 페이지 링크도 가능해야 하므로
isPinned    : boolean    // 상단 고정 (정렬은 클라 메모리에서 처리)
isActive    : boolean    // 게시 상태 — true: 게시 / false: 게시중단.
                         //   게시중단이면 게시 기간 안이어도 노출 안 됨 (기간보다 우선)
publishedAt : timestamp  // 게시 시작 시각 = 목록 정렬 키 (createdAt과 분리 → 예약/소급 게시)
                         //   미래 시각이면 그 시각이 될 때까지 노출 안 됨
endAt       : timestamp? // 게시 종료 시각. 없으면(null) 무기한 게시
                         //   지나면 문서를 지우지 않고 목록에서만 사라짐
authorName  : string     // 표시 작성자 (기본 "VYBE 운영팀")
createdAt   : timestamp
updatedAt   : timestamp
```
> 마이페이지 '계정 → 공지사항' 데이터 소스. **top-level** — 클럽·유저에 종속 안 되는
> 전역 콘텐츠(banners와 동급). **쓰기는 어드민 페이지(별도 구축 예정) 전용 — 앱은 읽기만.**
> 쿼리: `where isActive==true + where publishedAt <= now orderBy publishedAt desc limit 50`.
> 인덱스: `notices(isActive ASC, publishedAt DESC)` — `publishedAt <= now`는 정렬 키와
> 같은 필드라 **기존 인덱스로 그대로 처리**된다(추가 인덱스 불필요).
> **노출 조건 3가지** — ① `isActive==true`(게시상태) ② `publishedAt <= now`(게시 시작)
> ③ `endAt == null || endAt > now`(게시 종료). 판정은 `NoticeModel.isVisibleAt(now)` 한 곳에만 둔다.
> ⚠ `endAt`은 **메모리에서 필터** — 서로 다른 필드에 범위 조건을 하나 더 걸면 복합 인덱스가
> 추가로 필요한데 공지 건수가 적어 얻는 게 없다. 대신 `limit`이 종료된 공지까지 세므로
> 실제 노출 건수가 limit보다 적어질 수 있다.
> ⚠ 게시 기간은 **Rules에 넣지 않는다** — 클라 시계가 서버보다 조금이라도 앞서면 쿼리 범위가
> `request.time`을 넘어 목록 전체가 permission-denied가 된다. Rules는 `isActive`만 막는다
> (게시중단 공지는 문서 ID를 알아도 못 읽음. 예약 공지는 ID를 알면 읽힐 수 있음 — 앱 경로에선
> `getNotice`가 같은 기준으로 null 처리).
> ⚠ `isPinned`는 서버 orderBy에 넣지 않고 받아온 뒤 메모리에서 위로 올린다 — 공지 건수가
> 적어 3필드 인덱스를 유지할 이유가 없고, 정렬 규칙을 바꿔도 인덱스 재배포가 불필요.
> ⚠ **읽음 상태는 저장하지 않는다.** `users/{uid}/noticeReads` 방식은 공지 열 때마다 write가
> 발생 → 베타 규모에 과함. 목록 `NEW` 배지는 `publishedAt`이 7일 이내인지로만 판정.
> 집계 필드 없음 → Cloud Functions 트리거 불필요. seed(샘플): `scripts/seed_notices.js`.

#### searchLogs/{logId}
```
logId       : string    // PK (auto)
keyword     : string    // 정규화된 검색어 (선행 '#' 제거·연속 공백 축약·2~30자, 대소문자 보존)
userId      : string    // == request.auth.uid
source      : string    // 'input' | 'suggestion' | 'hashtag' | 'trend' | 'history' | 'map'
createdAt   : timestamp // serverTimestamp
expireAt    : timestamp // createdAt + 14d — Firestore TTL 정책이 자동 삭제
```
> 인기 검색어 집계 원본. **클라는 create만, 읽기는 Admin SDK(집계 함수) 전용**.
> 쓰기 지점은 `SearchViewModel.search()` + 화면의 예외 경로(지도 모드 제출, 연관 검색어→클럽 직행).
> ⚠ **`source`가 설계 핵심** — 트렌드/해시태그 칩 탭 유입을 집계에 넣으면 1위가 계속 1위가 되는
> 되먹임이 생긴다. 랭킹은 `input`/`suggestion`만 카운트(`RANKED_SOURCES`).
> ⚠ 랭킹 기준은 raw count가 아닌 **고유 userId 수** — 1인이 반복 검색해도 1표(스팸·자기증폭 방지).
> ⚠ 비로그인 검색은 Rules상 로깅 안 됨.
> 인덱스 불필요(`createdAt` 단일 필드 = 자동 인덱스). `source`는 메모리 필터.
> TTL 정책은 콘솔/gcloud로 별도 설정 — `firestore.indexes.json`으로는 설정 안 됨.

#### searchTrends/{docId}  — 문서 2개 고정
```
// searchTrends/current — 집계 스냅샷. 앱은 이 문서 1개만 읽는다 (read 1회)
items       : array     // [{ rank, keyword, status, change, uniqueUsers }]
                        //   status: 'up'|'down'|'newEntry'|'same' (직전 스냅샷 대비)
                        //   uniqueUsers: 0이면 fallback으로 채운 자리 (실데이터 아님)
realCount   : number    // 실데이터로 채워진 항목 수
sampleSize  : number    // 집계에 쓰인 로그 건수 (디버깅용)
windowHours : number    // 집계 윈도우 (기본 24)
runKey      : string    // KST yyyyMMddHH — 중복 실행 방어
updatedAt   : timestamp // UI '07.31 22:00 기준' 표기 소스

// searchTrends/fallback — 어드민 큐레이션 백업 목록
items       : array     // [{ rank, keyword }] — 실데이터 부족 시 뒷자리를 채움
```
> ⚠ **fallback으로 채운 항목엔 증감을 표시하지 않는다** (`uniqueUsers == 0` → `TrendRow`가 숨김).
> 유저가 없는데 순위가 오르내리는 것처럼 보이면 안 되므로.
> `realCount == 0`이면 섹션 제목도 '실시간 인기 검색어' 대신 '인기 검색어'.

#### searchHashtags/{tagId}
```
tagId          : string    // = doc.id (seed: tag_<slug>)
label          : string    // '힙합' (UI 표시는 '#힙합')
linkType       : string    // 'keyword' | 'page'
linkValue      : string    // keyword: 검색어 / page: 화면 키
                           //   freeEntry|serviceDrinks|hipHop|hotPlaces|vybeRecommend
order          : number    // 큐레이션 기본 순서
popularityRank : number?   // 집계가 채우는 검색량 순위. null이면 order로 정렬
isActive       : boolean
createdAt      : timestamp
```
> 인기 해시태그 데이터 소스. **큐레이션 문서가 필수인 이유**: '입장료 무료'·'서비스 음료'·'힙합'은
> 검색어가 아니라 전용 화면(`FreeEntryScreen` 등)으로 가야 해서 검색 로그 자동 추출로는
> 라우팅을 만들 수 없다. banners의 `linkType`/`linkValue` 패턴 재사용.
> 정렬은 `popularityRank`(있는 것 우선) → `order`. **문서는 8개보다 많이 두고 상위 8개만 노출**해야
> 검색량에 따라 순서가 실제로 바뀐다. seed: `scripts/seed_search_hashtags.js`.
> ⚠ `popularityRank`는 집계 함수 소유 — seed 스크립트가 덮어쓰지 않음(updateMask에서 제외).

---

### Cloud Functions 목록

총 **15개** 함수 (`functions/src/index.ts` export 기준). Firebase 관련 서버 로직은 모두 Cloud Functions으로 처리.
구조: `functions/src/auth/` (6) · `account/` (2 + 공용 `account_common.ts` · `restore_account.ts`) · `favorites/` (2) ·
`reviews/` (3) · `performances/` (1) · `search/` (1) + `index.ts`.
(구 `search/onClubWritten`은 Algolia 전환으로 삭제 — 2026.07.19)

#### HTTP 요청 함수 (앱에서 직접 호출, `https.onCall`)

| 함수명 | 입력 | 출력 | 역할 |
|--------|------|------|------|
| `naverLogin` | `{ accessToken }` | `{ customToken, isNewUser, restored }` | 네이버 accessToken → Custom Token (`naver:{naverId}`) |
| `kakaoLogin` | `{ accessToken }` | `{ customToken, isNewUser, restored }` | 카카오 accessToken → Custom Token (`kakao:{kakaoId}`) |
| `phoneLogin` | `{ phone }` | `{ customToken, isNewUser, restored }` | 전화번호 기반 Custom Token (`phone:{phone}`) |
| `checkPhoneDuplicate` | `{ phone, method }` | `{ isDuplicate, sameAccount, pendingDeletion, purgeAt, restorable }` | 이 번호의 **주인이 지금 시도 중인 그 계정인지** 판정. `sameAccount=true`면 재로그인이라 통과, false면 다른 방식 가입이라 차단. 탈퇴 대기 계정은 **본인 + 파기 전**이면 통과(`restorable`), 그 외엔 차단 |
| `verifyIdentity` | `{ impUid }` | `{ verified }` | 본인인증 결과 검증 → phone/birthDate Firestore 저장 |
| `requestAccountDeletion` | `{ reason? }` | `{ purgeAt }` | 회원 탈퇴 — 리뷰·사진·찜 `isHidden=true` + 집계 감산 + Auth `disabled`. 삭제는 30일 뒤 |

> 로그인 3종(`naverLogin`·`kakaoLogin`·`phoneLogin`)은 Custom Token 발급 **전에**
> `restorePendingDeletionOnLogin(uid)`를 부른다 — 보관 기간(30일)이 **남아 있으면 계정을 되살리고**
> `restored: true`를 실어 보내고, 파기 시각이 이미 지났으면 `failed-precondition`(+`details.purgeAt: null`)로 막는다.
> Auth가 `disabled`인 채 토큰을 주면 앱의 `signInWithCustomToken`이 거부되므로 **발급 전에** 풀어야 한다.

#### 자동 트리거 함수

| 함수명 | 트리거 | 역할 |
|--------|--------|------|
| `onUserCreated` | Firebase Auth 신규 유저 생성 시 | users/{uid} 문서 자동 생성 (provider, createdAt). **⚠ 현재 실행 안 됨 (2026.08.18 확인)** — Custom Token 로그인으로 Auth 유저가 생겨도 호출 로그가 없다. `createdAt`은 앱(`setUserProfile`)이 쓰도록 옮겨 지금은 이 함수 없이도 동작. 원인 조사 필요 |
| `onFavoriteCreated` | favorites/{favoriteId} 생성 시 | clubs.favoriteCount += 1 (FieldValue.increment 사용) |
| `onFavoriteDeleted` | favorites/{favoriteId} 삭제 시 | clubs.favoriteCount -= 1 (0 미만 방지 처리 필요). **`isHidden==true`면 skip** |
| `onReviewCreated` | clubs/{clubId}/reviews/{reviewId} 생성 시 | ratingSum += rating, reviewCount += 1, rating = ratingSum / reviewCount |
| `onReviewDeleted` | clubs/{clubId}/reviews/{reviewId} 삭제 시 | ratingSum -= rating, reviewCount -= 1, reviewCount > 0이면 rating 재계산, 0이면 rating = 0. **`isHidden==true`면 skip** |
| `onReviewUpdated` | clubs/{clubId}/reviews/{reviewId} 수정 시 | ratingSum += (newRating - oldRating), rating = ratingSum / reviewCount. **`isHidden` 전이거나 이미 숨겨진 리뷰면 skip** |

> ⚠ **`isHidden` 가드가 왜 필요한가** — 탈퇴 시 집계 감산은 `requestAccountDeletion`이 **직접** 한다.
> `isHidden=true` 세팅은 문서 update라 `onReviewUpdated`가 발화하고, 30일 뒤 파기 때는
> `onReviewDeleted`·`onFavoriteDeleted`가 발화한다. 가드가 없으면 같은 리뷰가 **두 번 깎여**
> `rating`·`favoriteCount`가 음수가 된다.

#### 스케줄 함수 (Cloud Scheduler + Pub/Sub, Blaze 필요)

| 함수명 | 스케줄 | 역할 |
|--------|--------|------|
| `cleanupPastPerformances` | 매일 KST 04:00 | 종료된 공연 문서 삭제. `startAt < now - 8h`(PERFORMANCE_DURATION_HOURS)인 공연만 삭제 → 예정/진행 중(새벽) 공연 보존. 500개씩 배치 삭제 |
| `aggregateSearchTrends` | 매시 정각 KST (`0 * * * *`) | 검색 로그 집계 → `searchTrends/current` + `searchHashtags.popularityRank`. 매시 깨어나서 **갱신 대상 여부를 내부 판단**하고, 아니면 Firestore 접근 없이 즉시 종료 |
| `purgeDeletedUsers` | 매일 KST 04:30 | 보관 30일이 지난 탈퇴 계정 완전 파기 — Firestore 문서(리뷰·사진·찜·검색기록·users) + Storage 파일(`reviews/`·`users/`) + Auth 유저. 회차당 50명, 한 명 실패해도 다음으로 진행(다음 회차에 다시 잡힘) |

> 새벽 공연 보호 로직: 공연은 `startAt`(Timestamp) 후 최대 8시간 진행으로 가정(클럽 마감 ~06:00). 8시간 안 지난 공연은 "진행 중"으로 보존 → 오늘 밤 새벽 공연/어제 이어진 공연 안전. 마감 더 늦으면 `PERFORMANCE_DURATION_HOURS` 상수만 조정.

> **검색 트렌드 갱신 주기** (`scheduleDecision()` — `functions/src/search/compute_trends.ts`)
> | 구간 | 실시간 인기 검색어 | 인기 해시태그 |
> |------|------|------|
> | 야간 20:00~09:00 (9시 포함) | 매시 | 매시 |
> | 주간 10:00~19:00 | 2시간 (10·12·14·16·18) | 4시간 (12·16) |
>
> 주간 간격은 자정 기준 앵커(`hour % N`)라 **해시태그 갱신 시각은 항상 검색어 갱신 시각의 부분집합** →
> 로그 스캔 1회로 둘 다 처리한다. 클럽 검색이 밤에 몰리므로 야간을 촘촘하게 잡음.
> 중복 실행 방어: 스냅샷에 `runKey`(KST yyyyMMddHH) 저장 → 같은 시각 재실행 시 skip
> (안 막으면 증감이 방금 쓴 결과와 비교돼 전부 `same`으로 뭉개짐).

#### 구현 시 주의사항
- `favoriteCount`, `ratingSum`, `reviewCount`, `rating` 은 반드시 Cloud Functions으로만 업데이트 (직접 수정 금지)
- `ratingSum` / `reviewCount` 증감은 `FieldValue.increment()` 사용 (동시 요청 정합성 보장)
- `rating` 은 트랜잭션으로 `ratingSum / reviewCount` 계산 후 저장
- `onReviewDeleted` 에서 `reviewCount`가 0이 되면 `rating = 0` 처리 필요
- 네이버 UID 형식: `naver:{naverId}`
- `onUserCreated` 는 문서가 이미 존재하면 덮어쓰지 말 것 (중복 실행 방어)
- `cleanupPastPerformances` 는 `date`(YYYYMMDD)가 아닌 `startAt`(Timestamp) 기준으로 삭제 — 새벽 공연 오삭제 방지. 스케줄 함수라 Blaze 요금제 필요

---

### Security Rules

#### Firestore Rules 요약
| 컬렉션 | 읽기 | 쓰기 |
|--------|------|------|
| `users/{uid}` | 본인만 | 본인만 (uid / provider / createdAt 수정 불가) |
| `clubs/{clubId}` | 누구나 (isActive=true만) | 어드민만 |
| `clubs/.../info`, `menus` | 누구나 | 어드민만 |
| `clubs/.../photos` | 누구나 (`isHidden != true`만) | 생성: 로그인 유저(본인 userId) / 삭제: 본인 또는 어드민 |
| `clubs/.../reviews` | 누구나 (`isHidden != true`만) | 생성: 로그인 유저 / 수정·삭제: 본인 또는 어드민 (**`isHidden` 수정 불가**) |
| `{path=**}/reviews` (collectionGroup) | 본인 리뷰만 | 불가 (마이페이지 내 리뷰 조회 전용) |
| `favorites` | 본인만 | 생성·삭제: 본인만 |
| `users/.../searchHistory` | 본인만 | 본인만 |
| `notices` | 누구나 (isActive=true만 — 게시 기간은 앱에서 필터) | 어드민만 (어드민 페이지 전용) |
| `promotions` | 누구나 (isActive는 클라 필터) | 어드민만 (어드민 페이지 전용) |
| `searchLogs` | **불가** (Admin SDK 전용) | 생성만: 로그인 유저(본인 userId, keyword 2~30자, 필드 화이트리스트). 수정·삭제 불가 |
| `searchTrends`, `searchHashtags` | 누구나 | 어드민만 |
| `appConfig/{platform}` | 누구나 (**auth 조건 금지** — 로그인 전에 읽는다) | 어드민만 (어드민 페이지 전용) |

> ⚠ **숨김 판정은 `resource.data.get('isHidden', false) == false`** — `resource.data.isHidden != true`로
> 쓰면 안 된다. Rules에서 **없는 필드에 직접 접근하면 평가가 에러로 떨어져 거부**되므로,
> 백필 전 문서(= 지금 전부)가 통째로 막힌다.

#### Storage Rules 요약
| 경로 | 읽기 | 쓰기 |
|------|------|------|
| `clubs/**` | 누구나 | 어드민만, 10MB 이하, 이미지만 |
| `reviews/**` | 누구나 | 로그인 유저, 10MB 이하, 이미지만 |
| `users/{uid}/**` | 누구나 | 본인만, 5MB 이하, 이미지만 |
| `notices/**` | 누구나 | 어드민만, 10MB 이하, 이미지만 |
| `promotions/**` | 누구나 | 어드민만, 10MB 이하, 이미지만 |

#### 어드민 권한 설정
```typescript
// Admin SDK로 Custom Claim 부여
admin.auth().setCustomUserClaims(uid, { admin: true })

// Rules에서 확인
request.auth.token.admin == true
```

---

### Firebase Storage 경로 구조

실제 구조 (더 베이스 `62VaHypRMWcCySNQZEaa` 기준). 확장자는 원본 따라 `.jpg`/`.png`/`.jpeg` 혼재.

```
clubs/{clubId}/thumbnail.jpeg               // 클럽 대표 이미지 (1장, 리스트 썸네일)
clubs/{clubId}/gallery/{n}.{jpg|png}        // 갤러리 이미지 (1.jpg, 2.png, … 순번)
                                            //   → heroImageUrls(상단 슬라이더)·imageUrls(사진탭) 둘 다 이 폴더 참조
clubs/{clubId}/menus/{menuId}.{jpg|png}     // 개별 메뉴 이미지
clubs/{clubId}/menus/boards/board_{n}.png   // 메뉴판 이미지 (menuBoardUrls)
reviews/{clubId}/{reviewId}/{index}.{ext}   // 리뷰 첨부 이미지 (0~3, 최대 4장)
users/{uid}/profile.jpg                     // 프로필 이미지 (덮어쓰기)
notices/{noticeId}/{index}.{ext}            // 공지 첨부 이미지 (어드민 업로드)
promotions/{promotionId}/{index}.{ext}      // 배너 상세 히어로·본문 이미지 (어드민 업로드)
```

> **URL 토큰 차이**: `thumbnail`은 다운로드 토큰(`?alt=media&token=…`) 포함, `gallery`/`menus`는 토큰 없이 `?alt=media`만 → Storage 규칙 `clubs/** read: if true`(공개 읽기)에 의존.
>
> **사진탭 photos 서브컬렉션**: 현재 seed 데이터는 기존 `gallery/` URL을 재활용(별도 업로드 없음). 추후 유저 업로드 기능 추가 시 권장 경로 `clubs/{clubId}/photos/{photoId}.{ext}`.

---

## Notes for Claude

- 이 프로젝트는 **1인 개인 프로젝트**로, 단순하고 명확한 코드를 선호함
- 새 기능 추가 시 항상 **MVVM 레이어 분리**를 유지할 것
- Firebase 관련 코드는 반드시 `data/datasources/remote/`에만 작성할 것 (presentation/domain 레이어 Firebase import 절대 금지)
- presentation에서 현재 uid가 필요하면 반드시 `currentUidProvider` 사용 (`FirebaseAuth.instance` 직접 접근 금지)
- 새 datasource 메서드 작성 시 반드시 `logFirebaseAccess()` 호출할 것
- UI 코드에서 `ref.read` / `ref.watch` 외의 비즈니스 로직 금지
- `build_runner` 코드 생성이 필요한 파일 수정 시 반드시 안내할 것
- UI 구현 시 **Figma MCP를 통해 디자인을 먼저 확인**한 후 코드 작성할 것
- 모든 UI 수치는 반드시 **`flutter_screenutil`** 단위(`.w`, `.h`, `.sp`, `.r`)로 작성할 것
- 인증 관련 코드는 반드시 위의 **인증 플로우** 섹션을 먼저 참고할 것
- Firestore 문서 생성/수정 시 반드시 위의 **컬렉션 구조**를 따를 것
- `favoriteCount` 는 직접 수정 금지 — Cloud Functions 트리거로만 업데이트됨
- `phone` 필드는 중복 가입 방지 기준 — 회원가입 시 반드시 `checkPhoneDuplicate` 로 확인할 것.
  **"이미 있는 번호 = 무조건 차단"이 아니다** — 같은 방식의 재로그인은 통과시킨다
- UI가 이미 구현된 화면 작업 시 Figma MCP 확인 불필요, 로직 레이어만 작성할 것