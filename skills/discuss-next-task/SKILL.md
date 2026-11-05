---
name: discuss-next-task
description: Mở một file thảo luận mới cho task — đọc phản hồi ở file trước, ghi quyết định vào file task, tạo discuss-<N+1>-t<n>.md theo DISCUSS_TEMPLATE.md. Use when the user answers in a discuss file and chooses to open the next discussion file.
---

# Skill: `discuss-next-task`

> Đây là **đường vào "mở file mới"** của bộ máy `discuss-task`. Luật thảo luận, cách hỏi, cách ghi quyết định nằm ở skill `discuss-task`; khung file ở `DISCUSS_TEMPLATE.md`. Skill này chỉ quy định phần **mở file**.

## Khi dùng

Người làm đã trả lời trong file thảo luận và chọn mở file tiếp theo (không tiếp trong file đang mở).

## Bước 1 — Nạp

- Đọc `discuss-task` để lấy luật chung (Nguyên tắc · Bước 3 · Bước 4 · Không được).
- Đọc **toàn bộ** file thảo luận trước và file task (mục tiêu, phạm vi, chủ đề mở, quyết định, thảo luận).

## Bước 2 — Phân loại phản hồi và ghi quyết định về task

Theo `discuss-task` Bước 4: mỗi câu đã chốt thêm `D-<k>` vào mục `Quyết định` của file task; file thảo luận **chỉ trỏ** `T-<n>/D-<k>`; chủ đề mới thêm **một dòng** vào mục `Chủ đề còn mở` của task (không kèm câu hỏi, không kèm link), chủ đề đã rõ thì rút ra.

## Bước 3 — Tạo file mới

- Số mới = **số lớn nhất hiện có trong folder + 1** (không dùng file đếm; mất file thì lấy số lớn nhất còn lại, git giữ lịch sử). Số là phần chữ số ngay sau `discuss-`.
- Tên file mới: `discuss-<N+1>-t<n>.md` — `<n>` là số task của cuộc đang mở (`T-40` → `discuss-95-t40.md`). Đuôi `-t<n>` giữ để hai dòng việc song song không đụng tên file dù trùng số.
- Dựng theo `DISCUSS_TEMPLATE.md`, gồm:
  - **Nối tiếp**: phản hồi đã nhận ở file trước (trích ngắn) · danh sách `T-<n>/D-<k>` đã khoá · chỗ còn treo · lý do mở file.
  - Câu chưa trả lời ở file trước: nêu lại nguyên câu đó, không tự đóng.
  - Cụm câu hỏi tiếp theo, nếu còn ambiguity.
- Không chép nội dung quyết định sang file mới.

## Bước 4 — Cập nhật task

- Không sửa mục `Thảo luận` của task: nó là một dòng cố định trỏ folder; file mới chỉ cần khai `**Task:** T-<n>`.
- Không đổi `status` của task.

## Bước 5 — Kiểm

- [ ] Mỗi `=>` đã phân loại và ghi nhận.
- [ ] Quyết định đã khoá có `D-<k>` trong file task.
- [ ] File mới chỉ trỏ quyết định, không chép.
- [ ] File mới khai `**Task:** T-<n>`; mục `Thảo luận` của task không đổi.
- [ ] Tên file đúng mẫu `discuss-<N+1>-t<n>.md` — số lấy từ số lớn nhất trong folder, đuôi `-t<n>` khớp task.
- [ ] Chat 1–2 dòng.

## Không được

- Sửa file thảo luận cũ.
- Tự mở file mới khi người làm chọn tiếp trong file đang mở.
- Tạo plan, sửa code, tự đổi status, tự đóng task.
