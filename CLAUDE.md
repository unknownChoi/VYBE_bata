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
│   │   │       └── firebase_favorite_datasource.dart
│   │   ├── models/      # Freezed 모델
│   │   └── repositories/# domain 인터페이스 구현체
│   ├── domain/          # entities, repository 인터페이스 (Firebase 의존 금지)
│   ├── presentation/
│   │   ├── common/widgets/  # 공통 위젯 (Vybe prefix)
│   │   ├── clubs/
│   │   ├── map/
│   │   ├── search/
│   │   └── auth/
│   └── main.dart
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
| 상태관리 | `flutter_riverpod` |
| 백엔드 | Firebase (Firestore, Auth, Storage, Functions) |
| 지도 | `google_maps_flutter` |
| 라우팅 | `go_router` |
| 코드 생성 | `riverpod_generator`, `freezed`, `json_serializable` |
| 아이콘 | `cupertino_icons` |
| 반응형 | `flutter_screenutil` |
| 네이버 로그인 | `flutter_naver_login` |
| 카카오 로그인 | `kakao_flutter_sdk_user` |
| 환경변수 관리 | `flutter_dotenv` (Flutter) / `dotenv` (Cloud Functions) |

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
KAKAO_NATIVE_APP_KEY=your_key_here
NAVER_CLIENT_ID=your_id_here
NAVER_CLIENT_SECRET=your_secret_here
```

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

## 현재 구현 상태 (2026.04.18 기준)

### 완료 ✅
- 디자인 시스템 (colors, typography, spacing)
- 앱 테마 설정
- Firebase 초기화 (firebase_options.dart)
- 인증 UI 화면 전체 (welcome, OTP, 본인인증, 약관, 가입완료)
- 공통 위젯 (VybeButton, VybeTextField 등)

### 미구현 ✗
- Flutter 데이터 레이어 전체 (models, datasources, repositories, viewmodels)
- Cloud Functions 전체 7개 (naverLogin, onUserCreated, verifyIdentity, deleteUser, onFavoriteCreated, onFavoriteDeleted)
- Firestore / Storage Security Rules 배포
- 인증 플로우 실제 연결 (SDK → Functions → Firebase)
- 홈 / 지도 / 클럽 상세 / 검색 / 찜 / 프로필 화면

---

## 작업 순서 (로드맵)

```
1. Cloud Functions 구현 및 배포
   - onUserCreated (Auth 트리거) — 신규 유저 Firestore 문서 자동 생성
   - verifyIdentity (본인인증)
   - onFavoriteCreated / onFavoriteDeleted (찜 카운트)
   - deleteUser (회원탈퇴)
        ↓
2. Firestore / Storage Security Rules 배포
        ↓
3. Flutter 인증 플로우 완성
   - 본인인증 완료 → Firestore users/{uid} 생성
   - 로그인 상태 유지 (go_router redirect)
        ↓
4. Flutter 데이터 레이어 구현
   - Freezed 모델 (UserModel, ClubModel 등)
   - DataSources / Repositories / ViewModels
        ↓
5. 홈 / 지도 화면
        ↓
6. 클럽 상세 화면 (정보, 메뉴, 리뷰, 찜)
        ↓
7. 검색 / 찜 목록 / 프로필 화면
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
clubId              : string    // Firestore 자동 생성 (PK)
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
rating              : double    // 평점 (앱 내 리뷰 기반)
closeTime           : string    // 마감 시간 (예: "03:00", "06:00")
entryFeeMin         : number    // 입장료 최소 (원, 0이면 무료)
entryFeeMax         : number    // 입장료 최대 (원)
imageUrls           : array     // 상세 이미지 URL 목록
thumbnailUrl        : string    // 리스트 대표 이미지 URL
tags                : array     // 태그 목록
favoriteCount       : number    // 찜 수 (Cloud Functions 자동 업데이트, 직접 수정 금지)
isActive            : boolean   // false면 앱에 노출 안 됨
isOpen              : boolean   // 현재 영업 중 여부
isVybeRecommended   : boolean   // vybe 추천 여부
createdAt           : timestamp
updatedAt           : timestamp
```

#### clubs/{clubId}/info/{clubId}
```
operatingHours  : string    // 영업시간
parking         : string    // 주차 안내
dressCode       : string    // 드레스코드
ageLimit        : string    // 나이 제한
sns             : array     // 추가 SNS 링크
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
createdAt       : timestamp
```

#### clubs/{clubId}/reviews/{reviewId}
```
reviewId        : string    // PK
clubId          : string    // FK → clubs
userId          : string    // FK → users
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

---

### Cloud Functions 목록

총 7개 함수. Firebase 관련 서버 로직은 모두 Cloud Functions으로 처리.

#### HTTP 요청 함수 (앱에서 직접 호출)

| 함수명 | 입력 | 출력 | 역할 |
|--------|------|------|------|
| `naverLogin` | `{ accessToken }` | `{ customToken, isNewUser }` | 네이버 accessToken → Firebase Custom Token 발급 |
| `verifyIdentity` | `{ impUid }` | `{ verified }` | 본인인증 결과 검증 → phone/birthDate Firestore 저장 |
| `deleteUser` | Auth 헤더 | `{ success }` | 회원탈퇴 (Auth + Firestore + Storage 일괄 삭제) |

#### 자동 트리거 함수

| 함수명 | 트리거 | 역할 |
|--------|--------|------|
| `onUserCreated` | Firebase Auth 신규 유저 생성 시 | users/{uid} 문서 자동 생성 (provider, isVerified: false, createdAt 세팅) |
| `onFavoriteCreated` | favorites/{favoriteId} 생성 시 | clubs.favoriteCount += 1 (FieldValue.increment 사용) |
| `onFavoriteDeleted` | favorites/{favoriteId} 삭제 시 | clubs.favoriteCount -= 1 (0 미만 방지 처리 필요) |

#### 구현 시 주의사항
- `favoriteCount` 는 반드시 `FieldValue.increment()` 사용 (동시 요청 정합성 보장)
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

```
clubs/{clubId}/thumbnail.jpg           // 클럽 대표 이미지 (1장)
clubs/{clubId}/gallery/{filename}      // 갤러리 이미지 (여러 장)
clubs/{clubId}/menus/{menuId}.jpg      // 메뉴 이미지
reviews/{clubId}/{reviewId}/{filename} // 리뷰 첨부 이미지
users/{uid}/profile.jpg                // 프로필 이미지 (덮어쓰기)
```

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