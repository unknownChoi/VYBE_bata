# 업주(파트너) 테이블 배치 편집기

업주가 자기 클럽의 **테이블 배치·가격**을 직접 고치는 페이지. 저장하면 앱 클럽 상세의
'테이블' 섹션과 가격표 화면이 그대로 바뀐다.

```
partner/
  index.html   업주용 실서비스 페이지 (Firebase Auth 로그인 → Firestore 직접 쓰기, Rules 적용)
  editor.js    편집 로직 — 로컬 도구와 공용 (단일 소스)
  editor.css   스타일 — 공용
```

로컬 확인용 도구는 `scripts/table_editor_server.js` + `scripts/table_editor.html`.
**두 페이지는 `editor.js` 하나를 같이 쓴다** — 복붙으로 나눠 가지면 두 화면이 같은 배치도를
다르게 그리게 되고, "웹과 앱의 데이터가 같아야 한다"가 조용히 깨진다.

| | 업주 웹 (`partner/index.html`) | 로컬 도구 (`scripts/`) |
|---|---|---|
| 인증 | Firebase Auth (이메일/비밀번호) | 없음 — `gcloud` 자격증명 |
| 권한 | **Security Rules** 가 판정 | **Rules 우회** (관리자 권한으로 붙는다) |
| 볼 수 있는 클럽 | 클레임 `clubIds` 에 적힌 것만 | 전부 |
| 용도 | 실서비스 | 화면 확인·데이터 손보기 |

> ⚠ 로컬 도구는 127.0.0.1 에만 바인딩된다. **외부에 열지 말 것** — 열면 인증 없이
> 모든 클럽의 가격을 고칠 수 있는 창구가 된다.

---

## 배포 전 준비 (아직 안 된 것)

### 1. 이메일/비밀번호 로그인 제공자 켜기 — **미완료**

2026.08.22 현재 이 프로젝트는 이메일/비밀번호 로그인이 **꺼져 있다**
(REST 확인: `PASSWORD_LOGIN_DISABLED`). 켜기 전까지 업주 페이지는 로그인 단계에서
"이메일/비밀번호 로그인이 아직 켜져 있지 않습니다" 만 띄운다.

Firebase 콘솔 → Authentication → Sign-in method → 이메일/비밀번호 → 사용 설정.

> ⚠ **켤 때 '가입 사용 중지(user sign-up disabled)'도 같이 켤 것.**
> 그냥 켜면 이 Firebase 프로젝트에 **아무나 이메일로 계정을 만들 수 있게 된다.**
> 업주 계정은 운영자가 콘솔에서 만들어 전달하는 방식이어야 한다.
> (앱의 로그인 3종은 Custom Token 경로라 이 설정과 무관 — 영향 없다.)

### 2. 배포 도메인을 승인된 도메인에 추가

현재 승인 목록: `localhost` · `vybe-bata-c07aa.firebaseapp.com` · `vybe-bata-c07aa.web.app`.
`vybe.inertent.com` 은 **없다**. Firebase 콘솔 → Authentication → Settings → 승인된 도메인에 추가.

### 3. Firestore Rules — **배포 완료 (2026.08.22)**

`clubs/{clubId}/tableLayout/{docId}` 규칙이 실서버에 올라가 있다. 실측 확인:
비인증 read `200`, 비인증 write `403 PERMISSION_DENIED`.

---

## 업주 계정 만들기 (운영 절차)

### 1) 계정 생성
Firebase 콘솔 → Authentication → Users → 사용자 추가. 이메일 + 임시 비밀번호를 넣고
업주에게 전달, 첫 로그인 후 비밀번호 변경을 안내한다.

### 2) 담당 클럽 지정 (커스텀 클레임)

```bash
# 클럽 id 는 Firestore clubs 문서 id
node scripts/set_partner_claim.js --email=owner@example.com --clubs=abc123,def456

# 확인만
node scripts/set_partner_claim.js --email=owner@example.com --show

# 회수
node scripts/set_partner_claim.js --email=owner@example.com --revoke
```

부여하면 `{ partner: true, clubIds: [...] }` 가 계정에 붙는다. 업주 페이지는 이 목록에 있는
클럽만 보여주고, Rules 도 이 목록으로 쓰기를 판정한다.

> ⚠ **반영 시점** — 클레임은 ID 토큰에 실려 온다. 업주가 이미 로그인 중이면
> **다시 로그인**하거나 토큰이 갱신(최대 1시간)돼야 보인다. 페이지는 진입할 때마다
> `getIdTokenResult(true)` 로 강제 갱신하므로 새로고침이면 대개 충분하다.
>
> ⚠ **회수는 즉시 반영되지 않는다** — `--revoke` 를 해도 그 업주의 기존 토큰이
> 만료될 때까지(최대 1시간) 쓰기가 통과한다. 계약 해지처럼 즉시 끊어야 하면
> `revokeRefreshTokens` + Rules 의 `auth_time` 검사가 필요한데 지금은 그 경로가 없다.
> 급하면 해당 클럽 문서 쪽에서 막을 것.
>
> ⚠ **클레임 전체는 1000바이트 제한.** 업주 한 명이 클럽 수십 곳을 갖는 구조가 되면
> `clubIds` 배열 대신 `clubs.ownerUids` + Rules `get()` 방식으로 옮겨야 한다
> (그때는 Rules get 이 read 1회로 과금된다).

### 3) 어드민이 대신 편집할 때
`admin: true` 클레임 계정은 `clubIds` 가 없으므로 **URL 로 클럽을 지정**해 들어간다:
`https://…/partner/?clubId=abc123`

---

## 배포

이 폴더는 정적 파일 3개뿐이라 어디에 올려도 된다 —
`vybe.inertent.com/partner/content/tables` 경로에 그대로 얹으면 된다.

- 빌드 과정 없음. Firebase SDK 는 gstatic CDN 에서 ES 모듈로 받는다.
- `file://` 로는 안 열린다(ES 모듈이라 http 필요).
- 이 리포의 Firebase Hosting(`firebase.json`)은 `legal/` 을 서빙하고 있어 **여기와 무관**하다.
  Firebase Hosting 에 올리려면 hosting 설정을 따로 손봐야 한다.

로컬 확인:
```bash
cd partner && python3 -m http.server 5600 --bind 127.0.0.1
# → http://127.0.0.1:5600
```

---

## 데이터 규칙 (편집기가 강제하는 것)

저장 전에 편집기가 막는 항목. 앱 파서도 같은 규칙으로 한 번 더 방어한다.

| 규칙 | 이유 |
|---|---|
| 테이블 최소 **2×2**, 열 최대 **14** | 짝을 이뤄 **탭 타겟 44px 하한**을 보장한다. 가장 좁은 흔한 기기(iPhone SE 375)에서 셀 ≈23px × 2칸 ≈46px. 늘리면 앱에서 손가락으로 못 누르는 테이블이 생긴다 |
| 테이블끼리 **겹침 금지** | 겹치면 앱에서 글자가 뭉갠다. 구조물은 벽·바닥처럼 겹쳐 쓰므로 허용 |
| 격자 밖 배치 금지 | 앱은 clamp 하지만, clamp 된 결과는 업주가 의도한 배치가 아니다 |
| 격자를 줄일 때 밖으로 나가는 항목 있으면 저장 차단 | 위와 같은 이유 |
| `id` 는 층 안에서 유일, **기존 id 를 바꾸지 않는다** | id 가 자리의 신원이다 |
| 금액은 **원 단위 정수** | `100만원`/`100만`/`1000000` 이 섞이면 정렬·비교가 불가능해진다. 표기는 앱이 만든다 |
| 저장은 **문서 전체 교체** | 부분 update 면 지운 테이블·층이 남는다. 원자적이라 앱이 반쯤 옮겨진 배치도를 읽는 상태가 없다 |
| 테이블 0자리면 저장 차단 | 앱이 섹션을 통째로 안 그린다 |

색(`colorKey`)과 구조물 타입은 **영문 키만** 저장하고 실제 색·라벨은 앱이 갖는다.
`editor.js` 의 `TIER_STYLE`·`FX_LABEL` 은 앱의
`lib/data/models/table_layout_palette.dart` 와 **같은 값이어야 한다** — 어긋나면 업주가 보는
색과 앱이 보여주는 색이 달라진다.

스키마 전문은 `firebase_structure.html#feature-tables`.
