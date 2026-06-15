# my-diary-frontend

React + Vite 기반의 Public 서버용 프론트엔드 저장소입니다.  
Nginx를 통해 React 정적 파일을 서비스하고, `/api` 요청은 Private 서버의 backend로 proxy 처리합니다.

## 실행 위치

NCP Public Subnet 서버

## 역할

- 다이어리 작성 화면 제공
- 다이어리 목록 카드뷰 제공
- 무한 스크롤 조회 제공
- 카드 클릭 시 모달창 상세/수정/삭제 제공
- 첨부파일 다운로드 버튼 제공
- Nginx reverse proxy로 backend API 연결

## 주요 구조

```text
my-diary-frontend/
├─ public/
├─ src/
│  ├─ assets/
│  ├─ App.jsx
│  ├─ App.css
│  ├─ index.css
│  └─ main.jsx
├─ nginx/
│  └─ default.conf.template
├─ deploy/
│  ├─ install-docker-ubuntu.sh
│  └─ run-public-frontend.sh
├─ Dockerfile
├─ index.html
├─ package.json
├─ vite.config.js
└─ README.md
```

## 로컬 실행

로컬에서는 backend 서버가 먼저 실행되어 있어야 합니다.

backend 실행 예시:

```bash
cd my-diary-backend
npm install
npm start
```

frontend 실행:

```bash
cd my-diary-frontend
npm install
npm run dev
```

로컬 개발 시 Vite proxy가 `/api` 요청을 backend로 전달합니다.

```text
http://localhost:5173/api/diaries
→ http://localhost:3000/api/diaries
```

## 빌드

```bash
npm run build
```

빌드 결과는 `dist/` 폴더에 생성됩니다.

## 최초 1회 Docker 설치

Public 서버에서 실행합니다.

```bash
chmod +x deploy/install-docker-ubuntu.sh
./deploy/install-docker-ubuntu.sh
```

## 직접 배포

Public 서버에서 frontend 저장소를 받은 뒤 실행합니다.

```bash
git clone https://github.com/YOUR_GITHUB_ID/my-diary-frontend.git
cd my-diary-frontend
```

실행 권한을 부여합니다.

```bash
chmod +x deploy/run-public-frontend.sh
```

Private backend 서버의 private IP를 넣고 실행합니다.

```bash
BACKEND_HOST=PRIVATE_BACKEND_IP \
./deploy/run-public-frontend.sh
```

예시:

```bash
BACKEND_HOST=10.0.2.10 \
./deploy/run-public-frontend.sh
```

## Docker 실행 구조

Dockerfile은 두 단계로 동작합니다.

```text
1단계: node:24-slim 이미지에서 React 빌드
2단계: nginx:alpine 이미지에서 빌드 결과물 서비스
```

Nginx는 아래 역할을 합니다.

```text
/      → React 화면 응답
/api   → Private backend 서버로 proxy
```

## Nginx proxy 구조

```text
사용자 브라우저
→ Public 서버 Nginx
→ /api 요청만 Private backend 서버로 전달
```

예시 흐름:

```text
http://PUBLIC_SERVER_IP/api/diaries
→ http://PRIVATE_BACKEND_IP:3000/api/diaries
```

## ACG

Public 서버 inbound:

```text
22  : 내 IP만 허용
80  : 0.0.0.0/0 허용
443 : HTTPS 적용 시 0.0.0.0/0 허용
```

Public 서버 outbound:

```text
3000 : Private backend 서버 private IP 허용
80/443 : Docker 설치, 패키지 다운로드가 필요할 때 허용
```

Private 서버 inbound도 함께 확인해야 합니다.

```text
3000 : Public 서버 private IP만 허용
```

## 확인 명령어

Public 서버에서 backend 연결 확인:

```bash
curl http://PRIVATE_BACKEND_IP:3000/api/diaries
```

브라우저에서 frontend 접속 확인:

```text
http://PUBLIC_SERVER_IP
```

API proxy 확인:

```text
http://PUBLIC_SERVER_IP/api/diaries
```

정상 응답 예시:

```json
{
  "items": [],
  "hasMore": false
}
```

## 자주 발생하는 오류

### 1. Unexpected token '<' 오류

원인:

```text
/api 요청이 backend가 아니라 React index.html로 응답된 경우
```

확인:

```text
http://PUBLIC_SERVER_IP/api/diaries
```

JSON이 아니라 HTML이 나오면 Nginx proxy 설정을 확인해야 합니다.

### 2. 502 Bad Gateway

원인:

```text
Nginx가 Private backend 서버에 접근하지 못하는 경우
```

확인 항목:

```text
- BACKEND_HOST 값이 Private backend IP인지 확인
- Private backend 컨테이너가 실행 중인지 확인
- Private 서버 ACG inbound 3000 확인
- Public 서버에서 curl http://PRIVATE_BACKEND_IP:3000/api/diaries 확인
```

### 3. 무한스크롤 요청 반복

원인:

```text
API 실패 상태에서 loader 영역이 계속 화면에 보여 IntersectionObserver가 반복 실행되는 경우
```

해결:

```text
App.jsx에서 loadFailed 상태로 실패 후 추가 요청을 중단합니다.
```

## frontend와 backend 연결 기준

frontend 코드에서는 API 주소를 상대 경로로 사용합니다.

```js
const API_BASE_URL = '/api';
```

이렇게 해야 로컬에서는 Vite proxy가 처리하고, 배포 환경에서는 Nginx proxy가 처리합니다.

## GitHub 업로드 전 제외할 파일

`.gitignore`에 의해 아래 파일은 GitHub에 올리지 않습니다.

```text
node_modules/
dist/
.env
.DS_Store
.vscode/
.idea/
```
