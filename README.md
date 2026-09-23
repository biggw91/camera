# Unitconnect Thermal Monitor PoC

Honeywell HT34B-423I 열화상 카메라 기반, **NVR 없는** 열화상 이벤트 알림 시스템 PoC(Proof of Concept, 개념 검증).

```
[HT34B-423I] → 사무실 LAN → [Spring Boot 서버] → MySQL 저장 → FCM Push → [Android 앱]
```

- 영상 녹화: 카메라 내부 Micro SD (NVR 사용 안 함)
- 카메라 → 서버 이벤트 전달 방식: **카메라에서 지원 여부 확인 필요** (Phase 8에서 실제 장비로 확인)

---

## 개발 원칙 (요약)

1. 카메라에서 직접 확인하기 전까지 API(ONVIF, HTTP Event Push, MQTT 등)가 있다고 가정하지 않습니다.
2. 확인되지 않은 기능은 코드 대신 `TODO: 카메라에서 지원 여부 확인 필요` 로 남깁니다.
3. 카메라 연동은 Adapter(어댑터, 연동 방식을 갈아끼울 수 있는 구조)로 만듭니다.
4. 설정값은 `.env` / `application.yml` 로 분리하고, 비밀번호·Firebase 키는 Git에 올리지 않습니다.
5. Phase(단계)별로 하나씩 진행하고, 사용자가 요청할 때만 다음 단계로 넘어갑니다.

---

## 폴더 구조 (제안)

현재는 `tools/`, `thermal-event-server/`(Phase 2~3), `README.md`, `.gitignore`, `.env.example` 까지 만들었습니다.
나머지 폴더는 해당 Phase에서 만듭니다.

```
camera/                                  ← Git 저장소 최상위
├─ README.md                             ← 이 문서
├─ .gitignore                            ← Git에 올리면 안 되는 파일 목록
├─ .env.example                          ← 환경변수 예시 (실제 값은 .env 에, Git 제외)
│
├─ tools/
│  └─ windows/
│     ├─ check-env.bat                   ← [Phase 1] 개발환경 확인 (더블클릭 실행)
│     ├─ check-env.ps1                   ← [Phase 1] 위 bat 이 실행하는 실제 스크립트
│     ├─ run-server.bat                  ← [Phase 2] 서버 실행 (더블클릭)
│     ├─ setup-db.bat / setup-db.ps1     ← [Phase 3] MySQL DB·전용 계정 생성 + .env 기록
│     └─ check-camera-network.ps1        ← [Phase 7 예정] ping / HTTP / RTSP 확인
│
├─ docs/                                 ← [Phase 7~8 예정]
│  ├─ camera-webui-checklist.md          ← 카메라 웹 관리자 메뉴 확인 체크리스트
│  └─ test-scenarios.md                  ← TEST 01 ~ TEST 14
│
├─ thermal-event-server/                 ← [Phase 2] Spring Boot 서버
│  ├─ pom.xml                            ← 사용 라이브러리 목록 (Maven)
│  ├─ mvnw.cmd                           ← Maven 자동 다운로드·실행 스크립트
│  ├─ src/main/resources/application.yml ← 서버 설정
│  ├─ src/main/resources/db/migration/   ← [Phase 3] 테이블 생성 SQL (Flyway 가 자동 실행)
│  └─ src/main/java/com/unitconnect/thermal/
│     ├─ controller/    ← REST API(외부에서 호출하는 주소) 입구
│     ├─ service/       ← 실제 업무 처리 (이벤트 저장, 중복 방지, Push 호출)
│     ├─ repository/    ← DB 읽기/쓰기
│     ├─ entity/        ← DB 테이블과 1:1 대응하는 클래스 (camera, thermal_event, mobile_device)
│     ├─ dto/           ← API 요청/응답 데이터 모양
│     ├─ config/        ← 설정 (DB, Firebase 등)
│     ├─ integration/   ← 외부 연동 (카메라 Adapter, FCM)
│     ├─ event/         ← 이벤트 처리 흐름
│     └─ exception/     ← 오류 처리
│
├─ android-app/                          ← [Phase 6 예정] Unitconnect Thermal Monitor 앱
│
└─ (docker/ 는 만들지 않음 — PC 에 MySQL 8.0 이 직접 설치되어 있어 불필요)
```

---

## 진행 현황

| Phase | 내용 | 상태 |
|---|---|---|
| 1 | 개발환경 확인 | **완료** (2026-09-23) |
| 2 | Spring Boot 서버 생성 | **완료** – PC 실행 확인 필요 |
| 3 | MySQL 연결 | **완료** – PC 실행 확인 필요 |
| 4 | Test Event API | 대기 |
| 5 | Firebase FCM | 대기 |
| 6 | Android Push 수신 | 대기 |
| 7 | 카메라 네트워크 확인 | 대기 |
| 8 | 카메라 이벤트 전달 방식 확인 | 대기 |
| 9 | 실제 카메라 연동 | 대기 |
| 10 | SD Card / 영상 연계 | 대기 |
| 11 | 관리자 화면 | 대기 |

---

## Phase 3 — MySQL 연결 방법 (Windows)

- DB 이름 `thermal_event`, 서버 전용 계정 `thermal_app` (root 계정은 서버에 쓰지 않음)
- 테이블: `camera`, `thermal_event`, `mobile_device` — 서버가 처음 켜질 때 자동 생성 (Flyway)
- 테스트용 카메라 `CAM-001` 1대가 자동 등록됩니다 (IP 는 Phase 7 에서 입력)
- DB 에 저장되는 시간은 모두 **UTC**(세계 표준시)입니다. **한국시간 = UTC + 9시간**

1. 최신 파일 받기: 저장소 폴더에서 `git pull`
2. `tools\windows\setup-db.bat` 더블클릭
   - 서버 전용 계정의 **새 비밀번호**를 정해서 두 번 입력 (화면에 안 보임)
   - 이어서 `Enter password:` 가 나오면 **MySQL root 비밀번호** 입력 (MySQL 설치 때 정한 것)
   - `OK: database=thermal_event` 와 `.env 파일에 DB 접속 정보를 기록했습니다` 가 나오면 성공
   - 비밀번호는 저장소 최상위 `.env` 에만 저장되며 Git 에 올라가지 않습니다
3. `tools\windows\run-server.bat` 더블클릭 → 아래 로그가 나오면 성공
   ```
   [DB] connected: MySQL 8.0.xx url=jdbc:mysql://localhost:3306/thermal_event user=thermal_app@localhost
   [DB] registered cameras=1
   [SERVER] thermal-event-server started. ...
   ```
4. 브라우저에서 http://localhost:8080/api/health → `"database":"UP"` 이면 **TEST 02 성공**

서버가 켜지지 않으면 창에 나오는 `APPLICATION FAILED TO START` 아래의 한국어 안내를 확인하세요.

| 안내 문구 | 해결 방법 |
|---|---|
| MySQL 서버에 연결할 수 없습니다 | `services.msc` 에서 `MySQL80` 이 실행 중인지 확인 |
| MySQL 로그인 실패 | `setup-db.bat` 을 다시 실행 (비밀번호 새로 설정) |
| DB 가 없거나 ... 권한이 없습니다 | `setup-db.bat` 실행, `.env` 의 `DB_NAME` 확인 |

## Phase 2 — 서버 실행 방법 (Windows)

- Spring Boot 4.1.1 / Java 17 / Maven Wrapper(Maven 3.9.16 자동 다운로드)
- 현재 기능: `GET /api/health` (서버 상태 확인) 하나
- DB(MySQL)·FCM 은 아직 연결하지 않았습니다 (Phase 3, 5)

1. 최신 파일 받기 (저장소 폴더에서):
   ```bat
   git pull
   ```
2. `tools\windows\run-server.bat` 더블클릭
   (또는 cmd 에서 `cd thermal-event-server` 후 `mvnw.cmd spring-boot:run`)
   - 처음 한 번은 Maven·라이브러리를 인터넷에서 받느라 몇 분 걸립니다.
3. 창에 아래 로그가 나오면 성공입니다:
   ```
   [SERVER] thermal-event-server started. health check: http://localhost:8080/api/health
   ```
4. 브라우저에서 http://localhost:8080/api/health 접속 → 아래처럼 나오면 **TEST 01 성공**
   ```json
   {"status":"UP","application":"thermal-event-server","serverTime":"..."}
   ```
5. 서버 끄기: 서버 창에서 `Ctrl + C`

자동 테스트 실행: `cd thermal-event-server` 후 `mvnw.cmd test`

포트 변경: 저장소 최상위에 `.env` 파일을 만들고 `SERVER_PORT=9090` 처럼 적습니다 (`.env.example` 참고).
로그 파일: `thermal-event-server\logs\thermal-event-server.log`

## Phase 1 결과 (개발 PC, 2026-09-23)

| 항목 | 결과 | 비고 |
|---|---|---|
| OS | Windows 11 Pro (64비트) | |
| Java / javac | 17.0.12 | Spring Boot 3 사용 가능 |
| JAVA_HOME | 미설정 | Phase 2 전에 설정 권장 |
| Node.js / npm | v22.21.1 / 10.9.4 | 현재 계획에서는 사용 안 함 |
| MySQL | 8.0 서버 실행 중 (`MySQL80`) | `mysql.exe` 는 PATH 미등록 (문제 없음) |
| Docker | 없음 | MySQL 직접 설치로 대체 → 불필요 |
| Git | 2.54.0 | |
| Maven / Gradle | 없음 | Maven Wrapper(`mvnw.cmd`) 사용 예정 → 불필요 |
| Android Studio | **없음** | Phase 6 전에 설치 필요 |
| Flutter | 없음 | Android 네이티브 앱으로 진행 → 불필요 |

## Phase 1 — 개발환경 확인 방법 (Windows)

이 스크립트는 **확인만** 하고, 아무것도 설치·변경·삭제하지 않습니다.

1. 저장소를 PC에 받습니다 (Git 설치되어 있는 경우):
   ```bat
   git clone https://github.com/biggw91/camera.git
   cd camera
   git checkout claude/magical-bohr-1tbgth
   ```
2. 탐색기에서 `tools\windows\check-env.bat` 을 **더블클릭**합니다.
   또는 명령 프롬프트(cmd)에서:
   ```bat
   tools\windows\check-env.bat
   ```
3. 결과가 화면에 나오고 `tools\windows\env-report.txt` 에 저장됩니다.
   이 파일 내용을 복사해서 Claude 에게 붙여넣어 주세요.
   (`env-report.txt` 는 Git에 올라가지 않도록 설정되어 있습니다.)

### 확인 항목과 필요 시점

| 항목 | 용도 | 필요 시점 | 필수 여부 |
|---|---|---|---|
| OS | 운영체제 확인 | - | - |
| Java 17 이상 (JDK, Java 개발 도구) | Spring Boot 3 서버 실행 | Phase 2 | 필수 |
| Git | 소스 버전 관리 | Phase 2 | 필수 |
| MySQL 서버 **또는** Docker | 이벤트 저장 DB | Phase 3 | 둘 중 하나 필수 |
| Android Studio | Android 앱 빌드 | Phase 6 | 필수 (Phase 6부터) |
| Android SDK / adb | 스마트폰에 앱 설치 | Phase 6 | Android Studio 설치 시 함께 설치됨 |
| Node.js / npm | 현재 계획에서는 사용 안 함 | - | 선택 |
| Flutter | 현재 계획은 Android 네이티브 앱이라 사용 안 함 | - | 선택 |
| Maven / Gradle | 빌드 도구. 프로젝트에 Wrapper(자동 다운로드 스크립트)를 넣을 예정이라 없어도 됨 | - | 선택 |
