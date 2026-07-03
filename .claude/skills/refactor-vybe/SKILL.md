---
name: refactor-vybe
description: >-
  vybe 프로젝트에서 방금 작성·수정한 코드를 리팩토링·최적화·세분화한다. 동작을 바꾸지 않고
  구조만 개선 — 긴 위젯 분리, 비즈니스 로직을 ViewModel/Repository로 이동, 중복 제거,
  디자인 시스템/공통 위젯 재사용, 성능 개선(불필요 rebuild·read), MVVM 레이어 위반 교정.
  "리팩토링", "최적화", "코드 세분화", "정리해줘", "refactor", "clean up", 기능 구현 완료
  직후에 사용. 새 기능 추가가 아니라 기존 코드 품질 개선 작업.
---

# refactor-vybe

방금 만든/고친 코드를 vybe 규칙에 맞게 다듬는다. **동작 불변, 구조만 개선.**

## 대원칙

> 리팩토링 = 겉보기 동작 그대로, 내부 구조만 개선. 새 기능·버그수정 섞지 말 것.
> 확신 없는 동작 변경이 필요하면 멈추고 사용자에게 물을 것.

## 대상 확정

1. 방금 대화에서 수정한 파일이면 그대로 대상.
2. 불명확하면 `git diff --name-only` 로 변경 파일 목록 확인 후 대상 좁히기.
3. 스코프 넘는 대규모 리팩토링은 먼저 계획 제시 → 승인 후 진행.

## 체크리스트 (vybe 아키텍처 기준)

### 1. MVVM 레이어 분리
- [ ] Widget 안에 비즈니스 로직 없나? → ViewModel(`Notifier`/`AsyncNotifier`)로 이동
- [ ] `presentation/`·`domain/`에 `firebase_*` import 없나? → datasource로 이동 (절대 금지 규칙)
- [ ] `data/repositories/`가 Firebase 직접 호출 안 하나? → datasource 경유
- [ ] Firebase 코드가 `data/datasources/remote/`에만 있나?
- [ ] presentation에서 uid는 `currentUidProvider` 쓰나? `FirebaseAuth.instance` 직접 접근 금지
- [ ] 새 datasource 메서드에 `logFirebaseAccess()` 있나?

### 2. 위젯 세분화
- [ ] `build()` 100줄 넘거나 중첩 깊으면 → 하위 위젯으로 분리
- [ ] 반복되는 UI 블록 → 재사용 위젯 추출 (`presentation/common/widgets/` Vybe prefix)
- [ ] `StatefulWidget` 남발 → `StatelessWidget`/`ConsumerWidget` 우선
- [ ] 큰 build 트리 → `const` 생성자로 잘라 rebuild 범위 축소

### 3. 디자인 시스템 재사용
- [ ] 하드코딩 색상 중 `VybeColors`에 있는 것 → 교체
- [ ] 하드코딩 `TextStyle` 중 `VybeTypography`에 있는 것 → 교체
- [ ] 기본 위젯 중 `common/widgets/`에 대응(VybeButton 등) 있는 것 → 교체
  > ⚠ 디자인 시스템에 **없으면 하드코딩 허용** — 억지로 만들지 말 것
- [ ] 모든 수치 `.w`/`.h`/`.sp`/`.r` (screenutil) 쓰나? 고정 px 금지

### 4. 성능 최적화
- [ ] `ref.watch` vs `ref.read` 올바른가 — 이벤트 콜백은 `read`, 빌드 의존은 `watch`
- [ ] 넓은 provider watch로 과도 rebuild 안 하나 → `select`로 좁히기
- [ ] 리스트 `ListView.builder`/`itemBuilder` 쓰나 (전체 생성 지양)
- [ ] 인라인 객체 prop으로 자식 매번 rebuild 안 시키나 → `const`/캐싱
- [ ] Firestore 쿼리 낭비 없나 — 필요 필드/페이지네이션/본 만큼만 read

### 5. 중복·가독성
- [ ] 복붙 코드 → 함수/위젯/extension 추출
- [ ] 매직 넘버·문자열 → 상수화 (`core/constants/` 또는 `core/theme/`)
- [ ] 죽은 코드·미사용 import·주석처리 코드 제거
- [ ] 네이밍 규칙 — 파일 `snake_case`, 클래스 `PascalCase`, provider `camelCase`+`Provider`

### 6. Cloud Functions (TS) 리팩토링 시
- [ ] 자동 집계 필드는 `FieldValue.increment()`/트랜잭션 유지 (정합성)
- [ ] 배치 500개 한도 지키나
- [ ] 공통 로직 → helper 함수 추출, 무한루프 방어 유지

## 절차

1. 대상 파일 읽고 위 체크리스트로 진단 → 문제점 목록화
2. 각 항목 **행동 보존** 확인하며 수정 (한 번에 하나 유형씩)
3. 코드 생성 필요 파일(freezed/riverpod) 건드렸으면 안내:
   `flutter pub run build_runner build --delete-conflicting-outputs`
4. 검증:
   - `flutter analyze` (경고/에러 0 목표)
   - Functions면 `cd functions && npm run build`
5. 변경 요약 보고 — 무엇을 왜 바꿨는지, 동작 불변임을 명시

## 규칙

- **동작 절대 불변.** 리팩토링 중 기능·버그수정 섞지 말 것.
- 서버 계약(스키마·함수 시그니처)이 바뀌면 → `sync-server-docs` 스킬로 문서도 갱신.
- 디자인 시스템에 없는 값 억지 추상화 금지 (CLAUDE.md: 없으면 하드코딩 허용).
- 큰 구조 변경은 diff 커지므로 논리 단위로 쪼개 설명.
- 확신 없는 최적화(체감 이득 불명)는 하지 말고 넘어갈 것 — 과최적화 금지.
