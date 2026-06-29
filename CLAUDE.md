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
│   │   ├── providers/   # 전역 Riverpod providers (auth_providers.dart 등)
│   │   ├── theme/       # 앱 테마
│   │   └── utils/       # 유틸리티 (firebase_logger.dart 등)
│   ├── data/
│   │   ├── datasources/
│   │   │   └── remote/  # Firebase 전담 datasource (Firebase 코드는 여기에만)
│   │   │       ├── firebase_auth_datasource.dart
│   │   │       ├── firebase_user_datasource.dart
│   │   │       ├── firebase_storage_datasource.dart
│   │   │       ├── firebase_club_datasource.dart
│   │   │       ├── firebase_search_history_datasource.dart
│   │   │       ├── firebase_review_datasource.dart
│   │   │       ├── firebase_favorite_datasource.dart
│   │   │       └── firebase_banner_datasource.dart
│   │   ├── models/      # Freezed 모델 (user, club, club_info, menu, photo,
│   │   │                #   review, favorite, banner, search_history, operating_hours)
│   │   └── repositories/# domain 인터페이스 구현체 (*_repository_impl.dart, Riverpod provider 포함)
│   ├── domain/
│   │   └── repositories/    # repository 인터페이스 (Firebase 의존 금지)
│   ├── presentation/
│   │   ├── common/widgets/  # 공통 위젯 (Vybe prefix)
│   │   ├── main_scaffold/   # 루트 IndexedStack + 하단 탭바
│   │   ├── home/            # 홈
│   │   ├── nearby/          # 내 주변 (지도 기반)
│   │   ├── saved/           # 찜 (favorites, viewmodels/)
│   │   ├── pass_wallet/     # 패스/지갑 (플레이스홀더, 현재 탭에서 미연결)
│   │   ├── search/          # 검색
│   │   ├── clubs/           # 클럽 상세 (tabs/, widgets/, viewmodels/)
│   │   ├── my_page/         # 마이페이지
│   │   ├── profile/         # 프로필
│   │   └── auth/            # 인증 플로우
│   └── main.dart
│
├── functions/           # Cloud Functions (TypeScript, src/auth · favorites · reviews)
├── scripts/             # Firestore/Storage seed·migration 스크립트 (Node.js)
│
└── assets/
    ├── images/          # 로고 등 이미지
    ├── icons/
    │   ├── common/      # 범용 아이콘
    │   └── social/      # 소셜 로그인 아이콘
    └── fonts/
```

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
| 미디어 | `video_player` |
| UI 보조 | `flutter_spinkit`(로딩), `flutter_staggered_grid_view`(갤러리) |
| 반응형 | `flutter_screenutil` |
| 네이버 로그인 | `flutter_naver_login` |
| 카카오 로그인 | `kakao_flutter_sdk_user` |
| 환경변수 관리 | `flutter_dotenv` (Flutter) / `dotenv` (Cloud Functions) |

> ⚠️ `go_router` / `google_maps_flutter` / `json_serializable` 미사용. 화면 전환은
> 하단 탭(`MainScaffold`) + 탭별 `Navigator.push`. 지도는 네이버 지도.

---

## Commands

```bash
# 앱 실행
flutter run

# 테스트
flutter test

# 코드 분석
flutter analyze

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
```

> main.dart 초기화 순서: `dotenv.load` → `Firebase.initializeApp` → `KakaoSdk.init` → 네이버 지도(`NAVER_MAP_CLIENT_ID`).
> 네이버 **로그인** secret(`NAVER_CLIENT_ID`/`NAVER_CLIENT_SECRET`)은 Cloud Functions(`functions/.env`)에서만 사용.

사용법:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// main.dart에서 초기화
await dotenv.load(fileName: '.env');

// 어디서나 접근
final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY']!;
```

### Cloud Functions (`dotenv`)
파일 위치: `functions/.env`

```
# functions/.env (git 제외)
KAKAO_ADMIN_KEY=your_key_here
NAVER_CLIENT_ID=your_id_here
NAVER_CLIENT_SECRET=your_secret_here
```

### .gitignore 규칙
- `.env` — Flutter 키
- `functions/.env` — Cloud Functions 키
- `.env.example` 파일은 커밋 (실제 값 없이 키 이름만 포함)

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
- **Cloud Functions 13개 전부 구현** (auth 7 + favorites 2 + reviews 3 + index)
- **Flutter 데이터 레이어 전부 구현** — Freezed 모델 11종, datasource 9종,
  repository 인터페이스 8종 + impl 8종 (각 Riverpod provider 포함)
- 인증 플로우 연결 (SDK → Functions → Firebase)
- `MainScaffold` 5탭 (홈 / 주변 / 찜 / 검색 / 내 정보)
- 홈 (배너·추천), 내 주변 (네이버 지도 + geohash), 검색 화면
- 클럽 상세 (정보·메뉴·사진·리뷰 탭, 찜, 스켈레톤 로딩)
- **찜 탭 (`saved/`) — favorites 실연동** (정렬, 리스트↔그리드 뷰, 찜 해제)

### 미구현 / 진행 중 ✗
- 패스·지갑 탭 (`pass_wallet_screen.dart` 플레이스홀더 — 현재 탭 슬롯엔 미연결)
- 주변 페이지 ↔ 상세 페이지 연동 마무리 (최근 커밋 진행 중)
- 마이페이지 / 프로필 세부 (리뷰 내역 등)
- Storage Security Rules 배포 검증 (Firestore Rules는 배포됨)
- Apple 로그인 (이후 구현)

---

## 작업 순서 (로드맵)

핵심 백엔드·데이터 레이어·주요 화면은 완료. 남은 작업:

```
1. 주변 ↔ 상세 페이지 연동 마무리 (진행 중)
        ↓
2. 마이페이지 / 프로필 (리뷰 내역 화면)
        ↓
3. 패스·지갑 탭 실제 구현 (탭 슬롯 재배치 포함)
        ↓
4. Security Rules 배포 검증 + 본인인증(verifyIdentity) 실연동 점검
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
- `phone` 필드로 중복 가입 방지 (같은 전화번호 재가입 불가)
- `isVerified: false` 로 초기 생성 → 본인인증 완료 시 `true` 로 업데이트

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
profileImageUrl : string    // Storage 프로필 이미지 URL
provider        : string    // "naver" | "apple"
isVerified      : boolean   // 본인인증 완료 여부 (초기값: false)
createdAt       : timestamp
updatedAt       : timestamp
```

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
entryFeeMin         : number    // 입장료 최소 (원, 0이면 무료)
entryFeeMax         : number    // 입장료 최대 (원)
heroImageUrls       : array     // 상단 슬라이더 이미지 URL 목록 (상세 페이지 히어로)
imageUrls           : array     // 갤러리(사진탭) 이미지 URL 목록
menuBoardUrls       : array     // 메뉴판 이미지 URL 목록
thumbnailUrl        : string    // 리스트 대표 이미지 URL
tags                : array     // 태그 목록
favoriteCount       : number    // 찜 수 (Cloud Functions 자동 업데이트, 직접 수정 금지)
searchTokens        : array     // 검색용 접두사 토큰(name/area/genre/tags 분해).
                                //   onClubWritten 트리거가 자동 생성 — 직접 수정 금지.
                                //   앱 검색: isActive=true + searchTokens arrayContainsAny
                                //   + orderBy(rating desc) + startAfter 서버 페이지네이션(10개씩).
                                //   firebase_club_datasource.searchClubsPage (본 만큼만 read).
                                //   ⚠ 평점순 고정 — 관련도(점수) 정렬 아님(B안 한계).
isActive            : boolean   // false면 앱에 노출 안 됨
isVybeRecommended   : boolean   // vybe 추천 여부
serviceDrink        : object    // 무료 서비스 음료 정보 (서비스 음료 페이지 데이터 소스)
                                //   { isOffered: boolean, comment: string, drinks: string[] }
                                //   isOffered : 제공 여부 (필터/노출 기준). 미제공이면 필드 생략 or false
                                //   comment   : 제공 코멘트 (예: "1인 음료 무제한", "테이블당 맥주 6병")
                                //   drinks    : 음료 종류 ["양주","샴페인","칵테일","맥주","와인"]
                                //   서비스 음료 페이지: isOffered=true 필터 + drinks로 종류 필터
freeEntryCondition  : string    // 입장비 무료 조건 코멘트 (입장비 무료 페이지 데이터 소스)
                                //   예: "여성 무료입장", "새벽 2시까지 무료", "게스트리스트 등록 시 무료"
                                //   입장비 무료(entryFeeMin=0) 클럽마다 서로 다른 코멘트. 빈 값이면 '입장비 무료' fallback
                                //   seed_free_entry.js로 배정 (entryFeeMin=0 클럽 대상)
                                //   입장비 무료 페이지: isActive=true + entryFeeMin=0 필터 (getFreeEntryClubs)
createdAt           : timestamp
updatedAt           : timestamp
```

#### clubs/{clubId}/info/{clubId}
```
nearbySubways   : array     // 주변 지하철역 목록 [{ stationName: string, distanceM: number, lines: string[] }]
                            //   lines: 호선 목록 (예: ["9호선"]) — SubwayLineBadge 표시용
openChatUrl     : string    // 카카오 오픈채팅방 URL
cautions        : array     // 유의사항 목록 (string[])
updatedAt       : timestamp
```

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
rating          : number    // 별점 1~5
content         : string    // 리뷰 텍스트
imageUrls       : array     // 첨부 이미지 URL 목록
createdAt       : timestamp
updatedAt       : timestamp
```

#### favorites/{favoriteId}
```
favoriteId      : string    // PK
userId          : string    // FK → users
clubId          : string    // FK → clubs (favoriteCount 자동 연동)
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
linkType        : string    // 링크 종류 (예: "club", "url" 등)
linkValue       : string    // 링크 대상 값
order           : number    // 정렬 순서 (오름차순)
isActive        : boolean   // 노출 여부
startAt         : timestamp // 노출 시작
endAt           : timestamp // 노출 종료
createdAt       : timestamp
```
> 홈 배너 데이터 소스. `firebase_banner_datasource.getActiveBanners()`는
> `isActive=true` 쿼리 후 클라이언트에서 `startAt < now < endAt` 필터 + `order` 정렬.

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

---

### Cloud Functions 목록

총 **14개** 함수 (`functions/src/index.ts` export 기준). Firebase 관련 서버 로직은 모두 Cloud Functions으로 처리.
구조: `functions/src/auth/` (7) · `favorites/` (2) · `reviews/` (3) · `search/` (1) + `index.ts`.

#### HTTP 요청 함수 (앱에서 직접 호출, `https.onCall`)

| 함수명 | 입력 | 출력 | 역할 |
|--------|------|------|------|
| `naverLogin` | `{ accessToken }` | `{ customToken, isNewUser }` | 네이버 accessToken → Custom Token (`naver:{naverId}`) |
| `kakaoLogin` | `{ accessToken }` | `{ customToken, isNewUser }` | 카카오 accessToken → Custom Token (`kakao:{kakaoId}`) |
| `phoneLogin` | `{ phone }` | `{ customToken, isNewUser }` | 전화번호 기반 Custom Token (`phone:{phone}`) |
| `checkPhoneDuplicate` | `{ phone }` | `{ isDuplicate }` | users 컬렉션 phone 중복 체크 (가입 전 검사) |
| `verifyIdentity` | `{ impUid }` | `{ verified }` | 본인인증 결과 검증 → phone/birthDate Firestore 저장 |
| `deleteUser` | Auth 헤더 | `{ success }` | 회원탈퇴 (Auth + Firestore + Storage 일괄 삭제) |

#### 자동 트리거 함수

| 함수명 | 트리거 | 역할 |
|--------|--------|------|
| `onUserCreated` | Firebase Auth 신규 유저 생성 시 | users/{uid} 문서 자동 생성 (provider, isVerified: false, createdAt 세팅) |
| `onFavoriteCreated` | favorites/{favoriteId} 생성 시 | clubs.favoriteCount += 1 (FieldValue.increment 사용) |
| `onFavoriteDeleted` | favorites/{favoriteId} 삭제 시 | clubs.favoriteCount -= 1 (0 미만 방지 처리 필요) |
| `onReviewCreated` | clubs/{clubId}/reviews/{reviewId} 생성 시 | ratingSum += rating, reviewCount += 1, rating = ratingSum / reviewCount |
| `onReviewDeleted` | clubs/{clubId}/reviews/{reviewId} 삭제 시 | ratingSum -= rating, reviewCount -= 1, reviewCount > 0이면 rating 재계산, 0이면 rating = 0 |
| `onReviewUpdated` | clubs/{clubId}/reviews/{reviewId} 수정 시 | ratingSum += (newRating - oldRating), rating = ratingSum / reviewCount |
| `onClubWritten` | clubs/{clubId} 생성·수정 시 | name/area/genre/tags → searchTokens(접두사 토큰) 자동 생성. 동일하면 skip(무한루프 방지) |

#### 구현 시 주의사항
- `favoriteCount`, `ratingSum`, `reviewCount`, `rating` 은 반드시 Cloud Functions으로만 업데이트 (직접 수정 금지)
- `ratingSum` / `reviewCount` 증감은 `FieldValue.increment()` 사용 (동시 요청 정합성 보장)
- `rating` 은 트랜잭션으로 `ratingSum / reviewCount` 계산 후 저장
- `onReviewDeleted` 에서 `reviewCount`가 0이 되면 `rating = 0` 처리 필요
- `deleteUser` 는 Admin SDK로만 처리 (클라이언트에서 직접 삭제 불가)
- 네이버 UID 형식: `naver:{naverId}`
- `onUserCreated` 는 문서가 이미 존재하면 덮어쓰지 말 것 (중복 실행 방어)

---

### Security Rules

#### Firestore Rules 요약
| 컬렉션 | 읽기 | 쓰기 |
|--------|------|------|
| `users/{uid}` | 본인만 | 본인만 (uid / provider / createdAt 수정 불가) |
| `clubs/{clubId}` | 누구나 (isActive=true만) | 어드민만 |
| `clubs/.../info`, `menus` | 누구나 | 어드민만 |
| `clubs/.../photos` | 누구나 | 생성: 로그인 유저(본인 userId) / 삭제: 본인 또는 어드민 |
| `clubs/.../reviews` | 누구나 | 생성: 로그인 유저 / 수정·삭제: 본인 또는 어드민 |
| `favorites` | 본인만 | 생성·삭제: 본인만 |
| `users/.../searchHistory` | 본인만 | 본인만 |

#### Storage Rules 요약
| 경로 | 읽기 | 쓰기 |
|------|------|------|
| `clubs/**` | 누구나 | 어드민만, 10MB 이하, 이미지만 |
| `reviews/**` | 누구나 | 로그인 유저, 10MB 이하, 이미지만 |
| `users/{uid}/**` | 누구나 | 본인만, 5MB 이하, 이미지만 |

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
reviews/{clubId}/{reviewId}/{filename}      // 리뷰 첨부 이미지
users/{uid}/profile.jpg                     // 프로필 이미지 (덮어쓰기)
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
- `phone` 필드는 중복 가입 방지 기준 — 회원가입 시 반드시 중복 체크할 것
- UI가 이미 구현된 화면 작업 시 Figma MCP 확인 불필요, 로직 레이어만 작성할 것