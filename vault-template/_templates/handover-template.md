---
tags: [handover]
status: draft
created: <% tp.date.now("YYYY-MM-DD") %>
updated: <% tp.date.now("YYYY-MM-DD") %>
---

# Handover — <tên task>

**Date:** <% tp.date.now("YYYY-MM-DD") %>  
**Session summary:** <1-2 câu tóm tắt phiên làm việc>

---

## 1. Tài liệu cần đọc để nắm context

> Đọc theo thứ tự. Optional — tuỳ task mà chọn tài liệu phù hợp.

| # | File | Cung cấp |
|---|------|----------|
| 1 | `HANDOVER-N-xxx.md` | Tổng quan task từ handover trước |
| 2 | `discuss-N.md` | Quyết định flow/architecture |
| 3 | `plan-context.md` | Confirmed decisions |
| 4 | `plan.md` | Implementation plan |
| 5 | `seq-*.md` | Sequence diagram |
| 6 | SCN trong vault (`11_Testing/...`) | Behavior từ góc nhìn user |

## 2. Task đang làm ở đâu?

Mô tả task hiện tại: phase nào, scope gồm những gì, không gồm những gì.

### Trạng thái hiện tại

- [ ] Chưa bắt đầu
- [ ] Đang DISCUSS / PLAN / BUILD / REVIEW / ...
- [ ] Đã hoàn thành

### Phase N scope

- **Gồm:**
- **Không gồm:**
- **Phase tiếp theo (N+1) sẽ làm:**

## ⚠️ Key Decisions — DO NOT VIOLATE

> Các decisions đã confirm xuyên suốt feature. Nếu AI định implement khác — dừng lại, kiểm tra mục này trước.

| Decision | Source | Ghi chú |
|----------|--------|--------|
| | | |

---

## 3. Những gì đã làm

### Danh sách thay đổi

| File | Change | Lý do |
|------|--------|-------|
| `path/to/file` | Mô tả ngắn | Optional |

### Vấn đề đã phát hiện và xử lý

> Các bug, scope creep, sai sót tìm thấy trong phiên.

| Vấn đề | Mức độ | Cách xử lý |
|---------|--------|------------|
| | | |

### Backlog mới tạo

> Nếu có issue cần theo dõi riêng.

| Backlog | Lý do |
|---------|-------|
| `BL-NNN` | Mô tả |

## 4. Vấn đề còn tồn đọng / chưa review

> Những thứ chưa giải quyết, cần session sau xử lý.

- Item 1
- Item 2

## 5. Files changed

### BE

| File | Action | Mô tả |
|------|--------|-------|
| | 🟢 Tạo mới / 🟡 Sửa / 🔴 Xoá | |

### FE

| File | Action | Mô tả |
|------|--------|-------|
| | 🟢 Tạo mới / 🟡 Sửa / 🔴 Xoá | |

### Vault / Docs

| File | Action | Mô tả |
|------|--------|-------|
| | 🟢 Tạo mới / 🟡 Sửa | |

## 6. Công việc tiếp theo (gợi ý)

> Optional. Có thể làm ngay hoặc defer.

- Item 1 — <lý do>
- Item 2 — <lý do>

## 7. Ghi chép khác

> Dashboard links, kết quả test number, cảnh báo CI/CD, v.v.

- Test: X passed / Y failed
- BE lint: clean / N issues
- FE typecheck: clean / N errors
- Secret scan: clean / N false positives
