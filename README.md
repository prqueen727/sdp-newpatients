# 성동필한방병원 초진 통계 사이트

상담실에서 초진 환자의 **내원 종류, 지역, 내원 동기, 클리닉**을 체크해 쌓고,
월간·연간 통계와 크로스 통계를 보고 PDF로 받는 사이트입니다.

- 화면: `index.html` 한 파일 (서버 프로그램 없음)
- 데이터 저장과 비밀번호: **Supabase** (무료 요금제로 충분)
- 사이트 주소: **Vercel** (무료)

비밀번호를 모르면 화면만 열리고 **데이터는 서버에서 아예 내려오지 않습니다**
(Supabase 로그인 + 접근 규칙).

---

## 1단계. Supabase 프로젝트 만들기 (약 10분)

1. https://supabase.com 에 로그인 → **New project**
   - 이름: `chojin-stats` (자유), 지역: **Northeast Asia (Seoul)**
   - Database password는 아무거나 길게 정하고 따로 보관 (사이트 비밀번호와 다름)
2. **직원 계정 만들기**: 왼쪽 메뉴 **Authentication → Users → Add user → Create new user**
   - Email: 관리자 이메일 (비밀번호 재설정 메일을 받을 주소)
   - Password: **직원들이 쓸 사이트 비밀번호** (8자 이상 권장)
   - **Auto Confirm User** 체크
3. **외부인 가입 막기 (중요)**: **Authentication → Sign In / Providers**
   → **Allow new users to sign up** 를 **끄기**
4. **표 만들기**: 왼쪽 **SQL Editor → New query** 에
   `supabase/schema.sql` 내용을 전부 붙여넣고 **Run**
   - SQL 맨 아래 staff 목록에 로그인할 계정 이메일을 모두 넣으세요 (admin / counselor).
5. **접속 정보 복사**: **Project Settings → API** (또는 **Connect** 버튼)
   - `Project URL` (https://xxxx.supabase.co)
   - `anon public` 키 (긴 문자열)

## 2단계. index.html 에 접속 정보 넣기

`index.html` 위쪽의 이 부분을 바꿉니다.

```js
window.APP_CONFIG = {
  SUPABASE_URL: "https://xxxx.supabase.co",   // Project URL
  SUPABASE_ANON_KEY: "sb_publishable_..."     // publishable(anon) 키
};
```

> anon 키는 공개돼도 괜찮은 키입니다. 데이터는 로그인한 직원 계정만 읽고 쓸 수 있게
> SQL에서 막아 두었습니다. **service_role 키는 절대 넣지 마세요.**

## 3단계. 사이트로 올리기 (GitHub + Vercel)

1. GitHub에서 새 저장소 만들기 (예: `chojin-stats`, **Private** 권장)
2. 이 폴더의 파일(`index.html`, `manifest.webmanifest`, `icon.svg`, `vercel.json`, `supabase/`)을 올리기
3. https://vercel.com → **Add New → Project** → 그 저장소 선택 → **Deploy**
   - 병원 Vercel 계정과 개인 계정 중 어느 쪽에 둘지 먼저 정하세요.
4. 발급된 주소(예: `chojin-stats.vercel.app`)를 상담실 PC에서 열고 비밀번호로 로그인

## 앱처럼 쓰기 (선택)

- **PC 크롬/엣지**: 주소창 오른쪽의 *설치* 아이콘 → 바탕화면에 앱 아이콘이 생깁니다.
- **아이폰**: 사파리 공유 → *홈 화면에 추가* / **안드로이드**: 크롬 메뉴 → *홈 화면에 추가*

## 운영 메모

- **비밀번호 바꾸기 / 잊었을 때**: 로그인 화면의 *비밀번호를 잊으셨나요?* → 관리자 메일로 온 링크를 누르면
  사이트에서 새 비밀번호를 정합니다. 이 링크가 사이트로 돌아오려면 Supabase →
  Authentication → URL Configuration 의 **Site URL** 이 Vercel 주소여야 합니다.
  바꾸면 다른 PC는 다음 로그인 때 새 비밀번호가 필요합니다.
- 한 번 로그인하면 그 PC에서는 로그인이 유지됩니다. 공용 PC면 **로그아웃**을 눌러 주세요.
- 다른 PC에서 입력한 내용은 통계 화면의 **새로고침** 버튼이나 창을 다시 열 때 반영됩니다.
- **백업**: 연간 통계 화면의 **CSV** 버튼으로 엑셀 파일을 받아 두세요.
- Supabase 무료 프로젝트는 **1주일 동안 접속이 없으면 일시정지**됩니다.
  매일 입력하면 문제없고, 정지되면 Supabase 대시보드에서 *Restore* 를 누르면 됩니다.

## 항목 바꾸기

`index.html` 의 `TYPES`, `REGIONS`, `MOTIVES`, `CLINICS` 목록을 고치면 입력 화면과 통계에
바로 반영됩니다. 이미 저장된 항목 이름을 바꾸면 예전 기록은 옛 이름으로 따로 집계되니,
이름 변경보다는 새 항목 추가를 권합니다.
