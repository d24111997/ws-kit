# Testing Patterns Reference

Quick reference for common testing patterns across the stack. Use alongside the `test-driven-development` skill.

## Table of Contents

- [Test Structure (Arrange-Act-Assert)](#test-structure-arrange-act-assert)
- [Test Naming Conventions](#test-naming-conventions)
- [Common Assertions](#common-assertions)
- [Mocking Patterns](#mocking-patterns)
- [React/Component Testing](#reactcomponent-testing)
- [API / Integration Testing (Python FastAPI)](#api--integration-testing-python-fastapi)
- [E2E Testing (Playwright)](#e2e-testing-playwright)
- [Test Anti-Patterns](#test-anti-patterns)

## Test Structure (Arrange-Act-Assert)

### TypeScript (Jest)
```typescript
it('describes expected behavior', () => {
  // Arrange: Set up test data and preconditions
  const input = { title: 'Test Task', priority: 'high' };

  // Act: Perform the action being tested
  const result = createTask(input);

  // Assert: Verify the outcome
  expect(result.title).toBe('Test Task');
  expect(result.priority).toBe('high');
  expect(result.status).toBe('pending');
});
```

### Python (pytest)
```python
def test_describes_expected_behavior():
    # Arrange: Set up test data and preconditions
    input_data = {"title": "Test Task", "priority": "high"}

    # Act: Perform the action being tested
    result = create_task(input_data)

    # Assert: Verify the outcome
    assert result.title == "Test Task"
    assert result.priority == "high"
    assert result.status == "pending"
```

## Test Naming Conventions

### TypeScript
```typescript
// Pattern: [unit] [expected behavior] [condition]
describe('TaskService.createTask', () => {
  it('creates a task with default pending status', () => {});
  it('throws ValidationError when title is empty', () => {});
  it('trims whitespace from title', () => {});
  it('generates a unique ID for each task', () => {});
});
```

### Python (pytest)
```python
# Pattern: test_[unit]_[expected_behavior]_[condition]

class TestTaskService:
    def test_create_task_returns_pending_status(self):
        ...

    def test_create_task_raises_error_for_empty_title(self):
        ...

    def test_create_task_trims_whitespace(self):
        ...

    def test_create_task_generates_unique_id(self):
        ...
```

## Common Assertions

### TypeScript (Jest)
```typescript
// Equality
expect(result).toBe(expected);           // Strict equality (===)
expect(result).toEqual(expected);        // Deep equality (objects/arrays)
expect(result).toStrictEqual(expected);  // Deep equality + type matching

// Truthiness
expect(result).toBeTruthy();
expect(result).toBeFalsy();
expect(result).toBeNull();
expect(result).toBeDefined();
expect(result).toBeUndefined();

// Numbers
expect(result).toBeGreaterThan(5);
expect(result).toBeLessThanOrEqual(10);
expect(result).toBeCloseTo(0.3, 5);

// Strings
expect(result).toMatch(/pattern/);
expect(result).toContain('substring');

// Arrays / Objects
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(object).toHaveProperty('key', 'value');

// Errors
expect(() => fn()).toThrow();
expect(() => fn()).toThrow(ValidationError);
expect(() => fn()).toThrow('specific message');

// Async
await expect(asyncFn()).resolves.toBe(value);
await expect(asyncFn()).rejects.toThrow(Error);
```

### Python (pytest)
```python
# Equality
assert result == expected                # __eq__
assert result is expected                # identity (is)
assert result is None

# Truthiness
assert result                            # truthy
assert not result                        # falsy
assert result is None
assert result is not None

# Numbers
assert result > 5
assert result <= 10
assert result == pytest.approx(0.3, rel=1e-5)  # floating point

# Strings
import re
assert re.search(r"pattern", result)
assert "substring" in result

# Lists / Dicts
assert item in my_list
assert len(my_list) == 3
assert my_dict["key"] == "value"

# Errors
import pytest
with pytest.raises(ValueError) as exc_info:
    fn()
assert "specific message" in str(exc_info.value)

# Async
import pytest
result = await async_fn()                # pytest-asyncio
assert result == expected

with pytest.raises(ValueError):
    await async_fn_failing()
```

## Mocking Patterns

### TypeScript (Jest)

```typescript
// Mock functions
const mockFn = jest.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue({ data: 'test' });
mockFn.mockImplementation((x) => x * 2);

expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledTimes(3);

// Mock an entire module
jest.mock('./database', () => ({
  query: jest.fn().mockResolvedValue([{ id: 1, title: 'Test' }]),
}));
```

### Python (pytest — use `mocker` fixture from pytest-mock)

```python
# Mock functions
mocker.patch("module.function", return_value=42)
mocker.patch("module.async_function", return_value={"data": "test"})
mocker.patch("module.function", side_effect=lambda x: x * 2)

# Verify calls
mock_fn.assert_called_once()
mock_fn.assert_called_with("arg1", "arg2")
mock_fn.assert_called_once_with("arg1", "arg2")
assert mock_fn.call_count == 3

# Mock at class method level
mocker.patch.object(MyClass, "method", return_value="mocked")

# Mock context manager
mock_db = mocker.patch("module.Database")
mock_db.return_value.__enter__.return_value.query.return_value = [...]

# Classicist alternative — Fake (preferred over mock for I/O)
class FakeRepository:
    def __init__(self):
        self._items = []
    def add(self, item):
        self._items.append(item)
    def find_all(self):
        return self._items

repo = FakeRepository()
service = MyService(repo)
```

### Mock at Boundaries Only

```
Mock these:                    Don't mock these:
├── Database calls             ├── Internal utility functions
├── HTTP requests              ├── Business logic
├── File system operations     ├── Data transformations
├── External API calls         ├── Validation functions
└── Time/Date (when needed)    └── Pure functions
```

Classicist preferred: dùng Fake cho I/O (in-memory DB, fake HTTP server), chỉ mock khi không thể dùng real/fake (external API, time).

## React/Component Testing

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';

describe('TaskForm', () => {
  it('submits the form with entered data', async () => {
    const onSubmit = jest.fn();
    render(<TaskForm onSubmit={onSubmit} />);

    // Find elements by accessible role/label (not test IDs)
    await screen.findByRole('textbox', { name: /title/i });
    fireEvent.change(screen.getByRole('textbox', { name: /title/i }), {
      target: { value: 'New Task' },
    });
    fireEvent.click(screen.getByRole('button', { name: /create/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({ title: 'New Task' });
    });
  });

  it('shows validation error for empty title', async () => {
    render(<TaskForm onSubmit={jest.fn()} />);

    fireEvent.click(screen.getByRole('button', { name: /create/i }));

    expect(await screen.findByText(/title is required/i)).toBeInTheDocument();
  });
});
```

## API / Integration Testing (Python FastAPI)

```python
import pytest
from httpx import ASGITransport, AsyncClient
from src.main import app


@pytest.mark.asyncio
async def test_create_task_returns_201():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as client:
        response = await client.post(
            "/api/tasks",
            json={"title": "Test Task"},
            headers={"Authorization": f"Bearer {test_token}"},
        )

    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test Task"
    assert data["status"] == "pending"
    assert "id" in data


@pytest.mark.asyncio
async def test_create_task_returns_422_for_invalid_input():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as client:
        response = await client.post(
            "/api/tasks",
            json={"title": ""},
            headers={"Authorization": f"Bearer {test_token}"},
        )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


@pytest.mark.asyncio
async def test_create_task_returns_401_without_auth():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as client:
        response = await client.post(
            "/api/tasks",
            json={"title": "Test"},
        )

    assert response.status_code == 401
```

For synchronous FastAPI or Starlette test client:
```python
from fastapi.testclient import TestClient

def test_create_task_returns_201():
    client = TestClient(app)
    response = client.post(
        "/api/tasks",
        json={"title": "Test Task"},
        headers={"Authorization": f"Bearer {test_token}"},
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Test Task"
```

## E2E Testing (Playwright)

Playwright uses the same API across Python and TypeScript. Below is the TypeScript version; Python uses `page` fixture from `pytest-playwright`.

### TypeScript
```typescript
import { test, expect } from '@playwright/test';

test('user can create and complete a task', async ({ page }) => {
  // Navigate and authenticate
  await page.goto('/');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'testpass123');
  await page.click('button:has-text("Log in")');

  // Create a task
  await page.click('button:has-text("New Task")');
  await page.fill('[name="title"]', 'Buy groceries');
  await page.click('button:has-text("Create")');

  // Verify task appears
  await expect(page.locator('text=Buy groceries')).toBeVisible();

  // Complete the task
  await page.click('[aria-label="Complete Buy groceries"]');
  await expect(page.locator('text=Buy groceries')).toHaveCSS(
    'text-decoration-line', 'line-through'
  );
});
```

### Python
```python
import re
from playwright.sync_api import Page, expect

def test_user_can_create_and_complete_task(page: Page):
    page.goto("/")
    page.fill("[name='email']", "test@example.com")
    page.fill("[name='password']", "testpass123")
    page.click("button:has-text('Log in')")

    page.click("button:has-text('New Task')")
    page.fill("[name='title']", "Buy groceries")
    page.click("button:has-text('Create')")

    expect(page.locator("text=Buy groceries")).to_be_visible()

    page.click("[aria-label='Complete Buy groceries']")
    expect(page.locator("text=Buy groceries")).to_have_css(
        "text-decoration-line", "line-through"
    )
```

## Test Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| Testing implementation details | Breaks on refactor | Test inputs/outputs |
| Snapshot everything | No one reviews snapshot diffs | Assert specific values |
| Shared mutable state | Tests pollute each other | Setup/teardown per test |
| Testing third-party code | Wastes time, not your bug | Mock the boundary |
| Skipping tests to pass CI | Hides real bugs | Fix or delete the test |
| Using `@pytest.mark.skip` permanently | Dead code | Remove or fix it |
| Overly broad assertions | Doesn't catch regressions | Be specific |
| No async error handling | Swallowed errors, false passes | Always `await` async tests |
