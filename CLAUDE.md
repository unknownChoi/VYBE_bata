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
│   ├── core/            # 상수, 테마, 유틸, 라우터
│   ├── data/            # datasources, models, repositories
│   ├── domain/          # entities, repository 인터페이스
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
| 백엔드 | Firebase (Firestore, Auth, Storage) |
| 지도 | `google_maps_flutter` |
| 라우팅 | `go_router` |
| 코드 생성 | `riverpod_generator`, `freezed`, `json_serializable` |
| 아이콘 | `cupertino_icons` |
| 반응형 | `flutter_screenutil` |

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
```

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

---

## Notes for Claude

- 이 프로젝트는 **1인 개인 프로젝트**로, 단순하고 명확한 코드를 선호함
- 새 기능 추가 시 항상 **MVVM 레이어 분리**를 유지할 것
- Firebase 관련 코드는 반드시 `data/datasources/`에만 작성할 것
- UI 코드에서 `ref.read` / `ref.watch` 외의 비즈니스 로직 금지
- `build_runner` 코드 생성이 필요한 파일 수정 시 반드시 안내할 것
- UI 구현 시 **Figma MCP를 통해 디자인을 먼저 확인**한 후 코드 작성할 것
- 모든 UI 수치는 반드시 **`flutter_screenutil`** 단위(`.w`, `.h`, `.sp`, `.r`)로 작성할 것