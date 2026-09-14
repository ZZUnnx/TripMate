# Architecture

TripMate는 Flutter 클라이언트, Spring Boot 백엔드, MySQL 데이터베이스, 외부 AI API를 사용하는 구조로 구성한다.

```text
Flutter
  -> REST / WebSocket
Spring Boot
  -> MySQL
  -> AI API
  -> Map API
```

## 서버 상태

### 서버 환경

- OS: Ubuntu Server
- 프로젝트 경로: `/srv/tripmate/app`
- 원격 접속: SSH
- 내부 접속: Tailscale
- 컨테이너 관리: Docker / Docker Compose

### 프로젝트 구조

```text
/srv/tripmate/app
├── backend/
│   ├── build.gradle
│   ├── gradlew
│   ├── gradle/
│   ├── settings.gradle
│   └── src/
│
├── database/
├── docs/
├── frontend/
├── .env
├── docker-compose.yml
└── README.md
```

## MySQL

MySQL은 Docker 컨테이너로 실행하도록 구성되어 있다.

- Docker Image: `mysql:8.4.11`
- Container Name: `tripmate-mysql`
- Container Port: `3306`
- Host Binding: `127.0.0.1:3306`
- 데이터 저장: Docker Volume `mysql_data`
- DB 계정 및 비밀번호: `.env` 파일에서 관리

현재 `docker-compose.yml` 구성:

```yaml
services:
  db:
    image: mysql:8.4.11
    container_name: tripmate-mysql
    restart: unless-stopped

    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}

    ports:
      - "127.0.0.1:3306:3306"

    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

MySQL이 `127.0.0.1`에만 바인딩되어 있기 때문에 외부에서 DB 포트에 직접 접근할 수 없도록 설정되어 있다.

개발 PC에서 MySQL Workbench 등을 이용할 경우 SSH 터널을 사용하여 접속한다.

```bash
ssh -L 3307:127.0.0.1:3306 dwsdd02@100.79.181.89
```

이후 DB 클라이언트에서는 다음과 같이 접속한다.

```text
Host: 127.0.0.1
Port: 3307
```

## Spring Boot Backend

Backend는 Gradle 기반 Spring Boot 프로젝트로 구성되어 있다.

```text
backend/
├── build.gradle
├── gradlew
├── gradlew.bat
├── gradle/
├── settings.gradle
└── src/
```

현재 Spring Boot 프로젝트는 서버에 업로드되어 있으며, Docker 컨테이너 배포 작업을 진행할 예정이다.

예정 구성:

```text
Ubuntu Server
│
└── Docker Compose
    ├── tripmate-mysql
    │   └── MySQL :3306
    │
    └── tripmate-backend
        └── Spring Boot :8080
```

Spring Boot에서는 Docker Compose 내부의 MySQL 서비스 이름인 `db`를 이용해 DB에 연결한다.

예정 DB 연결 주소:

```text
jdbc:mysql://db:3306/${MYSQL_DATABASE}
```

## 주요 명령어

프로젝트 이동:

```bash
cd /srv/tripmate/app
```

최신 코드 가져오기:

```bash
git pull
```

컨테이너 상태 확인:

```bash
docker compose ps
```

컨테이너 실행:

```bash
docker compose up -d
```

컨테이너 종료:

```bash
docker compose down
```

MySQL 로그 확인:

```bash
docker compose logs -f db
```

## 현재 진행 상황

```text
[완료] Ubuntu 서버 구축
[완료] SSH 접속
[완료] Tailscale 연결
[완료] GitHub 프로젝트 서버 Clone
[완료] Docker / Docker Compose 설치
[완료] MySQL Docker 구성
[완료] MySQL 데이터 Volume 구성
[완료] SSH Tunnel을 이용한 외부 DB 개발 환경 구성

[진행 예정] Spring Boot Dockerfile 작성
[진행 예정] Spring Boot Docker Compose 연결
[진행 예정] Spring Boot ↔ MySQL 연결
[진행 예정] Backend API 외부 접근 구성
```
