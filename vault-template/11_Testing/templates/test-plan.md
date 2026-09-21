---
status: draft
feature: {feature-code}
date: {YYYY-MM-DD}
---

# Test Plan: {Feature Name}

> [Mô tả 1-2 câu về feature này]
> Template: `templates/test-plan.md` — xoá hướng dẫn trong [] sau khi điền.

---

## 1. Test Objective

Xác minh luồng {feature} từ đầu đến cuối: {input → xử lý → output → real-time events → history}.
Đảm bảo {các behavior quan trọng: async processing, error handling, session recovery, ...} hoạt động đúng.

---

## 2. Scope

### 2.1. In Scope (Based on Code)

| # | Layer | Scope | Detail |
|---|-------|-------|--------|
| 1 | **BE API** | {endpoint paths} | {methods + routes} |
| 2 | **BE Service** | {service name} | {key functions} |
| 3 | **BE Core** | {use case / processor} | {business logic} |
| 4 | **BE Webhook / BG Jobs** | {webhook / worker name} | {task wiring, retry, cleanup} |
| 5 | **BE Redis / Infra** | {rate limiter, lock, Pub/Sub} | {coverage} |
| 6 | **BE DB** | {model name} | {data lifecycle, states} |
| 7 | **FE** | {page / component} | {UI logic, state, localStorage} |
| 8 | **E2E** | {critical user journey} | {full stack path} |

> **Chỉ liệt kê module thực sự tồn tại trong code.** Scope quá rộng = scope vô dụng.

### 2.2. Dead Code / Blocked Paths

- **{path A}**: {mô tả} — Path không reachable qua UI. Chỉ test ở BE unit.
- **{path B}**: {mô tả} — Dead code từ spec cũ, chưa cleanup.

### 2.3. Spec-Code Mismatches

> Code là truth. Nếu spec khác code → ghi nhận. Nếu spec đúng code → "Không còn mismatch."

### 2.4. Notable Implementation Details (Code as Truth)

| # | Detail | Note | Đã có trong spec? |
|---|--------|------|-------------------|
| 1 | {implementation detail} | {impact analysis} | ✅/❌ |

---

## 3. Test Strategy

### 3.1. Design Techniques

- [ ] Equivalence Partitioning (EP)
- [ ] Boundary Value Analysis (BVA)
- [ ] State Transition Testing ({mô tả state machine nếu có})
- [ ] Decision Table Testing ({mô tả decision table nếu có})
- [ ] Error Guessing

### 3.2. Layer Testing Approach

> Chi tiết approach, tooling, coverage expectation tại [`test-plan-general.md §3.2`](../test-plan-general.md#32-layer-testing-approach).
> Ở template này chỉ tóm tắt. Feature-specific rules ghi vào subsection tương ứng.

#### 3.2.1. BE Unit

**Approach:** Classicist (In-Memory Fakes) ưu tiên. Mockist dùng khi cần assert interaction/error flow.

**Rules:**
- Pure logic (helpers, normalize) → test class thật.
- I/O (DB, Redis, external API) → Fake class.
- External third-party API (AI, payment, captcha) → Mock.

**Tooling:** pytest + In-Memory Fakes + `unittest.mock`.

**Coverage Expectation:** Mỗi module ≥ 1 happy path + error path + boundary + fail-safe.

#### 3.2.2. BE Integration

**Approach:** TestClient + real DB. Mock chỉ ở external boundary ({auth provider}, third-party APIs).

**Rules:**
- Mỗi endpoint ≥ 1 happy path + 1 error path (400/403/404/409/429)
- Error path assert cả HTTP status lẫn error code trong response body
- Ownership check và multi-tenant isolation test qua header thay đổi token

**Tooling:** `fastapi.testclient.TestClient` + PostgreSQL container + Redis container.

**Coverage Expectation:** Mỗi endpoint happy + error. Tham chiếu `validation-matrix.md`.

#### 3.2.3. BE Integration (Real Infra)

**Approach:** Gọi real external APIs ({service A, service B...}) — không mock, real credentials. Phát hiện authentication failure, request/response contract thay đổi, quota, rate limit thật. Chạy opt-in, không tự động trong CI unit test.

**Rules:**
- Đặt trong `tests_integration/`, tách biệt `tests/`
- Dùng `@pytest.mark.integration` marker
- Yêu cầu env var cho credentials + network — fail early nếu thiếu
- Không chạy trong `test` job CI — chỉ chạy lúc deploy dev và local trước MR
- Không assert implementation detail — assert behavior thật

**Tooling:** pytest + real SDK client + service account credentials.

**Coverage Expectation:** Happy path cho critical external integrations. Error path cho invalid credentials, resource không tồn tại.

#### 3.2.4. FE Unit

**Approach:** 6 levels — Pure Logic → Service → Component → Hook → Page → Flow.

**Rules:**
- Pure logic: input → assert output, zero mock
- Service: mock `apiClient`, chỉ smoke test
- Component: Props/state → DOM assert. Ưu tiên `getByRole`
- Hook: State → state transition + side effect
- Page: MSW handlers + QueryClient, service chạy thật
- Flow: MSW + RouterProvider + memory history, assert navigation/URL

**Tooling:** Vitest + RTL + MSW v2 + jsdom.

**Coverage Expectation:** Mỗi level happy + error + edge case đặc thù.

#### 3.2.5. E2E

**Approach:** Full stack thật (BE + worker + DB + Redis + FE). Mock external APIs qua DI container override.

**Rules:**
- Critical path ≥ 1 E2E test
- Hạn chế `page.route()` — ưu tiên real BE + worker
- Chỉ test edge case không cover bởi layer thấp hơn
- Cleanup data trong `beforeEach`

**Tooling:** Playwright + Docker compose + DI override helpers.

**Coverage Expectation:** Critical user journey + error path cần real BE validation.

---

## 4. Test Environment

| # | Component | Details |
|---|-----------|---------|
| 1 | Backend | {port, config file} |
| 2 | Database | {DB type, container} (test DB, auto-migrate) |
| 3 | Redis | {purpose} |
| 4 | Worker / BG Jobs | {eager / real worker} |
| 5 | Frontend | {dev server port}. MSW on cho FE Unit, off cho E2E |
| 6 | E2E | {headed/headless, stack, mock approach} |
| 7 | Auth | {Auth test harness / custom token / other} |
| 8 | Test data | {seed data: customer, plan, prerequisite records} |
| 9 | Orchestration | {1-command runner} |

---

## 5. Entry Criteria

| # | Criterion |
|---|-----------|
| 1 | Feature source code explored and analyzed |
| 2 | Validation matrix completed |
| 3 | Test environment ready |
| 4 | DB migrations applied |
| 5 | Test data seeded (nếu cần) |

---

## 6. Exit Criteria

| # | Criterion |
|---|-----------|
| 1 | All test cases executed |
| 2 | No P0/P1 bugs open |
| 3 | Traceability matrix complete |
| 4 | Known issues documented |

---

## 7. Risk Assessment

| # | Risk | Probability | Impact | Mitigation |
|---|------|-------------|--------|------------|
| 1 | External API unavailable offline | High | High | Mock qua DI container ở tất cả layers |
| 2 | Multi-tenant isolation | Medium | High | Auth tạo user programmatically |
| 3 | E2E worker/async timing — flaky | Medium | High | Retry + timeout trong config |
| 4 | Real-time event miss khi reconnect | Medium | Medium | Snapshot/buffer; assert DB state cuối cùng |
| 5 | Third-party credential not configured | Low | High | Env validation check trong BE startup |
| 6 | Infrastructure unavailable — fail-safe | Low | Medium | Test fail-safe path riêng |

---

## 8. Assumptions

### 8.1. Technical

| # | Assumption |
|---|------------|
| 1 | Auth: {Auth test harness / custom token} |
| 2 | Worker/BG: eager cho BE Unit; Docker compose worker cho E2E |
| 3 | Redis: fakeredis hoặc container riêng |

### 8.2. Business

| # | Assumption |
|---|------------|
| 1 | {business rule A} |
| 2 | {business rule B} |
