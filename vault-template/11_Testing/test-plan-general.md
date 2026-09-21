---
title: Test Plan Template (General)
date: 2026-05-30
type: template
tags:
  - testing
  - template
  - test-plan
aliases:
  - General Test Plan
---

# Test Plan Template

> Template này áp dụng cho mọi feature. Copy sang `{feature}/testplan/test-plan.md`, điền thông tin feature-specific, xoá hướng dẫn trong `[]`.

---

## 1. Test Objective

Xác minh luồng `[feature name]` từ đầu đến cuối: `[tóm tắt flow: input → xử lý → output → real-time events → history]`. Đảm bảo `[các behavior quan trọng: async processing, error handling, session recovery, ...]` hoạt động đúng.

---

## 2. Scope

### 2.1. In Scope (Based on Code)

Liệt kê các layer và module được test, dựa trên `[file spec]` và `[code base]`:

| # | Layer | Scope | Detail |
|---|-------|-------|--------|
| 1 | **BE API** | `[endpoint paths]` | `[methods + routes]` |
| 2 | **BE Service** | `[service name]` | `[key functions]` |
| 3 | **BE Core** | `[use case / processor]` | `[business logic]` |
| 4 | **BE Background Jobs** | `[worker name]` | `[task wiring, retry, cleanup]` |
| 5 | **BE Infrastructure** | `[Redis / DB / external API]` | `[rate limiter, lock, Pub/Sub, etc.]` |
| 6 | **BE DB** | `[model name]` | `[data lifecycle, states]` |
| 7 | **FE** | `[page / component]` | `[UI logic, state, localStorage]` |
| 8 | **E2E** | `[critical user journey]` | `[full stack path]` |

> **⚠️ Hướng dẫn:** Sau khi hiểu code, điền scope từng layer. Gạch đầu dòng ngắn gọn, chỉ liệt kê module thực sự tồn tại trong code. Scope quá rộng = scope vô dụng.

### 2.2. Dead Code / Blocked Paths

- **`[path A]`**: `[mô tả]` — Path không reachable qua UI. Chỉ test ở BE unit.
- **`[path B]`**: `[mô tả]` — Dead code từ spec cũ, chưa cleanup.

### 2.3. Spec-Code Mismatches

> Đối chiếu spec với code. Nếu spec nói A nhưng code làm B → **code là truth, spec cần update.** Nếu spec nói đúng code → "Không còn mismatch."

### 2.4. Notable Implementation Details (Code as Truth)

Ghi lại những detail implementation mà spec không đề cập nhưng ảnh hưởng đến test:

| # | Detail | Note | Đã có trong spec? |
|---|--------|------|-------------------|
| 1 | `[implementation detail]` | `[impact analysis]` | ✅/❌ `[lý do]` |

---

## 3. Test Strategy

### 3.1. Design Techniques

- [x] Equivalence Partitioning (EP)
- [ ] Boundary Value Analysis (BVA)
- [ ] State Transition Testing (mô tả state machine)
- [ ] Decision Table Testing (mô tả decision table)
- [ ] Error Guessing

> **Hướng dẫn:** Tick các kỹ thuật áp dụng. Thêm mô tả state machine / decision table cụ thể nếu có.

### 3.2. Layer Testing Approach

#### 3.2.1. BE Unit

##### 3.2.1.1. Approach
Classicist (In-Memory Fakes) ưu tiên. Mockist dùng khi cần assert interaction/error flow (finally block, call ordering, exception propagation).

##### 3.2.1.2. Rules
- Pure logic (helpers, normalize) → test class thật.
- I/O (DB, Redis, external API) → Fake class.
- External third-party API (AI, payment, captcha) → Mock.

##### 3.2.1.3. Tooling
pytest + In-Memory Fakes + `unittest.mock` cho các deps không có Fake.

##### 3.2.1.4. Coverage Expectation
Mỗi module có tối thiểu 1 test cho happy path, error path, boundary value, fail-safe behavior (nếu có).

#### 3.2.2. BE Integration

##### 3.2.2.1. Approach
Integration tests verify behavior qua HTTP (TestClient), không gọi function trực tiếp. Dùng real DB, real Redis cho endpoint test; mock chỉ ở boundary ({auth provider}, third-party APIs).

##### 3.2.2.2. Rules
- Mỗi endpoint có ít nhất 1 test happy path + 1 test error path (400/403/404/409/429)
- Error path test assert cả HTTP status lẫn error code trong response body
- Dùng TestClient, không gọi hàm endpoint trực tiếp
- Ownership check và multi-tenant isolation test qua header thay đổi token

##### 3.2.2.3. Tooling
`fastapi.testclient.TestClient` cho HTTP request/response assertion. `unittest.mock` cho external dependencies. PostgreSQL container + Redis container cho data layer.

##### 3.2.2.4. Coverage Expectation
Mỗi endpoint có happy path + error path (assert HTTP status + error code). Tham chiếu `validation-matrix.md` cho danh sách field constraints, error codes, business rules cần test.

#### 3.2.3. BE Integration (Real Infra)

##### 3.2.3.1. Approach
Test gọi real external APIs ({service A, service B...}) — không mock, real credentials. Mục đích: phát hiện authentication failure, request/response contract thay đổi từ phía provider, quota, rate limit thật. Chạy opt-in, không tự động trong CI unit test.

##### 3.2.3.2. Rules
- Đặt trong `tests_integration/`, tách biệt `tests/`
- Dùng `@pytest.mark.integration` marker
- Yêu cầu env var cho credentials + network — fail early nếu thiếu
- Không chạy trong `test` job CI — chỉ chạy lúc deploy dev (script riêng `scripts/run-integration-tests.sh`) và local trước MR
- Không assert implementation detail — assert behavior thật (số lượng file, attributes, sorting)

##### 3.2.3.3. Tooling
pytest + real SDK client ({provider SDK}) + service account credentials.

##### 3.2.3.4. Coverage Expectation
Happy path cho critical external integrations (list files, verify permission). 
Error path cho invalid credentials, resource không tồn tại. 
Unit test sẽ lo phần edgecase, nếu thực sự cần thiết mới test thêm ở real integration layer này.

#### 3.2.4. FE Unit

##### 3.2.4.1. Approach
Một runner (Vitest), một DOM (jsdom), một infra (MSW) cho mọi cấp độ test FE. Phân loại dựa trên **mức độ mock**, không tách layer Unit/Component/Integration riêng.

| # | Level | Test approach | Mock strategy | Note |
|---|-------|--------------|---------------|------|
| 1 | **Pure logic** | Test thật, input → assert output | Zero mock | — |
| 2 | **Service** | `vi.mock` `apiClient` module | Mock `apiClient` ở module level | Chỉ test normalize đáng test |
| 3 | **Component** | Props/state → DOM. Assert conditional render, display priority, user interaction | Mock i18n + router hooks nếu cần | Chỉ test component có logic điều kiện. Wrapper/layout/delegate pure bỏ qua |
| 4 | **Hook** | State/input → state transition + side effect. Assert loading/success/error states, error code → UX mapping | Mock service + deps không thuần | Chỉ test hook có logic thật. React-query wrapper không cần test |
| 5 | **Page** | MSW handlers + QueryClient provider. Service + hook chạy thật, MSW intercept network. Hạn chế mock hooks | MSW intercept (preferred) | 1 screen, render + interaction trong page context |
| 6 | **Flow** | MSW bắt buộc. Real RouterProvider + memory history. Test navigation, URL change, redirect, multi-step user journey | MSW intercept + `server.use()` override | Nhiều page, user journey hoàn chỉnh. `.integration.` trong tên file |

##### 3.2.4.2. Rules
- Pure logic: không mock, không wrapper, input → assert output.
- Service: chỉ smoke test (mock `apiClient`). Không test normalize 1-to-1.
- Component: Props/state → assert DOM. Ưu tiên `getByRole`/`getByTestId`. Cần test component có conditional render logic.
- Hook: State/input → assert state transition + side effect. Không test hook là wrapper react-query / delegation pure.
- Page: MSW handler từ `handlers.ts`, override `server.use()` cho test-specific. Wrapper: `QueryClientProvider`. Mock hooks chỉ khi render state đặc thù khó tạo qua MSW.
- Flow: MSW bắt buộc. Real RouterProvider + memory history. Assert navigation, URL, redirect. Convention `.integration.` trong tên file.
- i18n mock cho component/page/flow: `vi.mock('react-i18next', () => ({ useTranslation: () => ({ t: (s) => s, i18n: { language: 'en' } }) }))`.

##### 3.2.4.3. Tooling
Vitest + `@testing-library/react` + `@testing-library/user-event` + MSW v2 (server.ts + handlers.ts) + jsdom.

##### 3.2.4.4. Coverage Expectation
Mỗi level trong 6 levels trên đều cần có test cho happy path + error path + edge case đặc thù của level đó (boundary, null/empty, conditional render, navigation guard, multi-step interaction).

#### 3.2.5. E2E

##### 3.2.5.1. Approach
Full stack thật (BE + worker + PostgreSQL + Redis + FE). 
Worker chạy thật với DI container override — chỉ mock external APIs. 
{Auth test harness} cho authentication.

##### 3.2.5.2. Rules
- Mỗi critical path có ít nhất 1 E2E test
- External API mock qua DI container override, không qua `page.route()` — trừ khi cần simulate BE error path cụ thể
- Hạn chế `page.route()` — ưu tiên chạy BE + worker thật
- Chỉ test các edge case không cover được bởi các layer thấp hơn
- Cleanup data trong `beforeEach` (DB + Redis), không dùng `afterEach`

##### 3.2.5.3. Tooling
Playwright + Docker compose (BE + worker + DB + Redis) + {Auth test harness} + helper scripts cho DI override + e2e helper cho auth/test data/cleanup

##### 3.2.5.4. Coverage Expectation
Critical user journey + error path cần real BE validation. Các behavior cần browser thật: real-time events (SSE/WebSocket), multi-tab, worker thật, Redis Pub/Sub.

---

## 4. Test Environment

| # | Component | Details |
|---|-----------|---------|
| 1 | Backend | `[port, config file]` |
| 2 | Database | `[DB type, container]` (test DB, auto-migrate) |
| 3 | Redis | `[purpose]` |
| 4 | Worker / BG Jobs | `[runner approach: eager / real worker]` |
| 5 | Frontend | `[dev server port]`. MSW on cho FE Unit, off cho E2E (FE gọi BE thật) |
| 6 | E2E | `[runner: headed/headless, stack, mock approach]` |
| 7 | Auth | `{Auth test harness}` |
| 8 | Test data | `[seed data: user + prerequisite records]` |
| 9 | External API (Real Infra test) | `tests_integration/`. Yêu cầu env var URLs + service credentials. Không cần Docker. |
| 10 | Orchestration | `[script: 1-command runner]` |

---

## 5. Entry Criteria

| # | Criterion |
|---|-----------|
| 1 | Feature source code explored and analyzed |
| 2 | Validation matrix completed |
| 3 | Test environment ready (BE + DB + Redis + FE) |
| 4 | DB migrations applied |
| 5 | Test data seeded (nếu cần) |

---

## 6. Exit Criteria

| # | Criterion |
|---|-----------|
| 1 | All test cases from detailed test suite executed |
| 2 | No P0/P1 bugs open |
| 3 | Traceability matrix complete |
| 4 | Known issues documented |

---

## 7. Risk Assessment

| # | Risk | Probability | Impact | Mitigation |
|---|------|-------------|--------|------------|
| 1 | External API không available offline | High | High | Mock qua DI container override ở tất cả layers |
| 2 | Multi-tenant isolation | Medium | High | Auth emulator tạo user programmatically |
| 3 | E2E worker/async timing — flaky test | Medium | High | DI override cho external APIs, retry + timeout trong config |
| 4 | Real-time event miss khi reconnect | Medium | Medium | Snapshot/buffer cho reconnect; Flow test cover logic; E2E assert DB state cuối cùng |
| 5 | Third-party service credential không configured | Low | High | Env validation check trong BE startup |
| 6 | Infrastructure unavailable — fail-safe behavior | Low | Medium | Test fail-safe path riêng (fallback default) |
| 7 | BE Integration (Real Infra) chạy chậm (real network I/O) | Medium | Low | Chạy 1 ít local trước MR + 1 lần khi CI deploy dev. Không chạy trong `test` job CI. |

> **Hướng dẫn:** Điều chỉnh xác suất/tác động theo feature. Thêm risk đặc thù nếu có.

---

## 8. Assumptions

### 8.1. Technical

| # | Assumption |
|---|------------|
| 1 | Auth: {Auth test harness} |
| 2 | Worker/BG: eager mode cho BE Unit; Docker compose worker cho E2E |
| 3 | Redis có thể dùng `fakeredis` hoặc container riêng |
| 4 | E2E: chạy full stack (BE + worker + DB + Redis + FE). Chỉ mock external APIs qua DI container override |

### 8.2. Business

| # | Assumption |
|---|------------|
| 1 | `[business rule A]` |
| 2 | `[business rule B]` |

> **Hướng dẫn:** Business assumptions = điều feature phụ thuộc vào nhưng không kiểm soát được. Ví dụ: "Mỗi customer chỉ có 1 session đồng thời", "Field X là optional ở BE nhưng FE bắt buộc".
