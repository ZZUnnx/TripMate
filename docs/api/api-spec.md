# API Specification

TripMate 백엔드 API 명세서이다.

현재 구현된 API와 구현 예정 API를 구분해서 관리한다.

## 기본 정보

- Base URL: `/api`
- Request Body: `application/json`
- Response Body: `application/json`
- 인증 방식: JWT Bearer Token 예정

인증이 필요한 API는 아래 헤더를 사용한다.

```http
Authorization: Bearer {accessToken}
```

현재 코드 기준으로 JWT 발급은 구현되어 있으나, JWT를 검증하는 인증 필터는 아직 구현되어 있지 않다.

## 공통 응답 상태

| Status | 설명 |
| --- | --- |
| `200 OK` | 요청 성공 |
| `400 Bad Request` | 요청 값 검증 실패 |
| `401 Unauthorized` | 인증 실패 또는 토큰 누락 |
| `403 Forbidden` | 접근 권한 없음 |
| `404 Not Found` | 리소스 없음 |
| `500 Internal Server Error` | 서버 내부 오류 |

## 구현 상태 요약

| 구분 | Method | Path | 상태 |
| --- | --- | --- | --- |
| Auth | `POST` | `/api/auth/signup` | 구현됨 |
| Auth | `POST` | `/api/auth/login` | 구현됨 |
| AI | `GET` | `/api/ai/test` | 구현됨 |
| Trip | `POST` | `/api/trips` | 예정 |
| Trip | `GET` | `/api/trips` | 예정 |
| Trip | `GET` | `/api/trips/{tripId}` | 예정 |
| Trip Member | `POST` | `/api/trips/{tripId}/members` | 예정 |
| Chat | WebSocket | `/ws/chat` | 예정 |
| Schedule Candidate | `GET` | `/api/trips/{tripId}/schedule-candidates` | 예정 |
| Schedule Candidate | `PATCH` | `/api/schedule-candidates/{candidateId}/approve` | 예정 |
| Schedule | `POST` | `/api/trips/{tripId}/schedules` | 예정 |
| Schedule | `GET` | `/api/trips/{tripId}/schedules` | 예정 |
| Schedule | `PATCH` | `/api/schedules/{scheduleId}` | 예정 |
| Schedule | `DELETE` | `/api/schedules/{scheduleId}` | 예정 |

---

## Auth

### 회원가입

```http
POST /api/auth/signup
```

사용자 계정을 생성한다.

#### Request Body

| 필드 | 타입 | 필수 | 제약 |
| --- | --- | --- | --- |
| `email` | `string` | O | 이메일 형식 |
| `password` | `string` | O | 최소 6자 |
| `nickname` | `string` | O | 최대 50자 |

#### Request Example

```json
{
  "email": "user@example.com",
  "password": "password123",
  "nickname": "여행자"
}
```

#### Response

```http
200 OK
```

```text
회원가입 성공
```

#### Error

| Status | 상황 |
| --- | --- |
| `400 Bad Request` | 이메일 형식 오류, 필수 값 누락, 비밀번호 길이 부족 |
| `500 Internal Server Error` | 이미 사용 중인 이메일 등 현재 전역 예외 처리 미구현으로 인한 서버 오류 |

> 현재 `IllegalArgumentException`에 대한 전역 예외 처리가 없어 중복 이메일 등 서비스 예외가 `500`으로 내려갈 수 있다.

---

### 로그인

```http
POST /api/auth/login
```

이메일과 비밀번호로 로그인하고 JWT Access Token을 발급한다.

#### Request Body

| 필드 | 타입 | 필수 | 제약 |
| --- | --- | --- | --- |
| `email` | `string` | O | 이메일 형식 |
| `password` | `string` | O | 빈 값 불가 |

#### Request Example

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Response

```http
200 OK
```

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | `number` | 사용자 ID |
| `email` | `string` | 사용자 이메일 |
| `nickname` | `string` | 사용자 닉네임 |
| `accessToken` | `string` | JWT Access Token |

#### Response Example

```json
{
  "id": 1,
  "email": "user@example.com",
  "nickname": "여행자",
  "accessToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### Error

| Status | 상황 |
| --- | --- |
| `400 Bad Request` | 이메일 형식 오류, 필수 값 누락 |
| `500 Internal Server Error` | 이메일 또는 비밀번호 불일치 등 현재 전역 예외 처리 미구현으로 인한 서버 오류 |

---

## AI

### Gemini 테스트 요청

```http
GET /api/ai/test?message={message}
```

Gemini API에 메시지를 전달하고 응답 텍스트를 반환한다.

현재 테스트용 API이며, 인증은 적용되어 있지 않다.

#### Query Parameters

| 이름 | 타입 | 필수 | 설명 |
| --- | --- | --- | --- |
| `message` | `string` | O | Gemini에 전달할 메시지 |

#### Request Example

```http
GET /api/ai/test?message=서울 여행 일정을 추천해줘
```

#### Response

```http
200 OK
```

```text
서울 여행 일정 추천 응답 문자열
```

#### Error

| Status | 상황 |
| --- | --- |
| `400 Bad Request` | `message` 파라미터 누락 |
| `500 Internal Server Error` | Gemini API 호출 실패 |

---

## 구현 예정 API

아래 API는 요구사항과 엔티티 구조를 기준으로 한 예정 명세이다. 실제 컨트롤러 구현 시 경로와 요청/응답 구조가 변경될 수 있다.

## Trip

### 여행 생성

```http
POST /api/trips
Authorization: Bearer {accessToken}
```

#### Request Body

```json
{
  "title": "부산 여행",
  "destination": "부산",
  "startDate": "2026-10-01",
  "endDate": "2026-10-03"
}
```

#### Response Example

```json
{
  "id": 1,
  "title": "부산 여행",
  "destination": "부산",
  "startDate": "2026-10-01",
  "endDate": "2026-10-03",
  "ownerId": 1,
  "createdAt": "2026-09-14T18:00:00"
}
```

### 여행 목록 조회

```http
GET /api/trips
Authorization: Bearer {accessToken}
```

#### Response Example

```json
[
  {
    "id": 1,
    "title": "부산 여행",
    "destination": "부산",
    "startDate": "2026-10-01",
    "endDate": "2026-10-03"
  }
]
```

### 여행 상세 조회

```http
GET /api/trips/{tripId}
Authorization: Bearer {accessToken}
```

## Trip Member

### 여행 멤버 추가

```http
POST /api/trips/{tripId}/members
Authorization: Bearer {accessToken}
```

#### Request Body

```json
{
  "email": "member@example.com",
  "role": "MEMBER"
}
```

## Chat

### 채팅 연결

```text
WebSocket /ws/chat
```

여행방별 실시간 채팅을 위한 WebSocket 엔드포인트이다.

#### Message Example

```json
{
  "tripId": 1,
  "senderId": 1,
  "content": "내일 오전에 해운대 갈까?"
}
```

## Schedule Candidate

### 일정 후보 목록 조회

```http
GET /api/trips/{tripId}/schedule-candidates
Authorization: Bearer {accessToken}
```

### 일정 후보 승인

```http
PATCH /api/schedule-candidates/{candidateId}/approve
Authorization: Bearer {accessToken}
```

승인된 일정 후보는 확정 일정으로 등록된다.

## Schedule

### 일정 등록

```http
POST /api/trips/{tripId}/schedules
Authorization: Bearer {accessToken}
```

#### Request Body

```json
{
  "title": "해운대 산책",
  "category": "관광",
  "scheduledDate": "2026-10-01",
  "scheduledTime": "10:00:00",
  "placeName": "해운대해수욕장",
  "url": "https://example.com/place",
  "description": "오전 산책 일정",
  "sortOrder": 1
}
```

### 일정 목록 조회

```http
GET /api/trips/{tripId}/schedules
Authorization: Bearer {accessToken}
```

### 일정 수정

```http
PATCH /api/schedules/{scheduleId}
Authorization: Bearer {accessToken}
```

### 일정 삭제

```http
DELETE /api/schedules/{scheduleId}
Authorization: Bearer {accessToken}
```
