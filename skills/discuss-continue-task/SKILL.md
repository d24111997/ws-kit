---
name: discuss-continue-task
description: Tiếp tục thảo luận ngay trong file đang mở — thêm mục Ghi nhận, khoá quyết định về task bằng `decision_record`, thêm cụm câu hỏi tiếp. Use when the user answers in a discuss file and chooses to keep discussing in that same file.
---

# Skill: `discuss-continue-task`

> Đây là **đường vào "tiếp trong file đang mở"** của bộ máy `discuss-task`. Luật thảo luận, cách hỏi, cách ghi quyết định nằm ở skill `discuss-task`; khung file ở `DISCUSS_TEMPLATE.md`. Skill này chỉ quy định phần **ghi tiếp vào file hiện tại**.

## Khi dùng

Người làm đã trả lời trong file thảo luận và chọn tiếp trong chính file đó (không mở file mới).

## Bước 1 — Nạp

- Đọc `discuss-task` để lấy luật chung.
- Đọc **toàn bộ** file thảo luận đang mở; không grep `=>` thay cho việc đọc.
- Đọc task **từ store**: `task_get(ref, sections: ["Mục tiêu", "Phạm vi", "Chủ đề còn mở"])` — không kéo `body_md`; `decision_list(ref)` theo trang (`offset`/`limit`, mặc định 20). Không đọc file task kiểu cũ (nếu dự án còn giữ) — vị trí ghi ở `AGENTS.md` của repo.

## Bước 2 — Phân loại phản hồi và ghi quyết định về task

Theo `discuss-task` Bước 4: mỗi câu đã chốt gọi `decision_record(ref, text, source)` — store cấp `D-<k>`, tool trả `ref: "T-<n>/D-<k>"`; file thảo luận **chỉ trỏ** `ref` đó. Chủ đề mới thêm **một dòng** vào mục `Chủ đề còn mở` (không kèm câu hỏi, không kèm link) bằng `task_update(patch: { body_sections: [{ section: "Chủ đề còn mở", op: "append", items: ["- <chủ đề>"] }] })`; chủ đề đã rõ thì rút bằng `op: "remove"` trên đúng nguyên văn dòng cũ. Không gửi lại `body_md`.

## Bước 3 — Ghi tiếp vào chính file đang mở

- Thêm `### Ghi nhận Qx.y (ngày)` ngay dưới phản hồi tương ứng; **không sửa** phần đã viết.
- Cập nhật danh sách trỏ `T-<n>/D-<k>` ở §6/§8 của file.
- Còn ambiguity → thêm **cụm tiếp theo** vào cuối file, đánh tiếp số câu hỏi.
- Câu chưa trả lời: giữ treo ở §8, không tự đóng.

## Bước 4 — Kiểm

- [ ] Đã đọc toàn bộ file thảo luận (không chỉ grep `=>`); mọi dòng người làm thêm đã được phân loại.
- [ ] Mỗi `=>` đã phân loại và ghi nhận.
- [ ] Quyết định đã khoá đã ghi về store (`decision_list` thấy `D-<k>`).
- [ ] File thảo luận chỉ trỏ quyết định, không chép.
- [ ] Câu treo nằm ở §8 hoặc có câu hỏi làm rõ.
- [ ] Chat 1–2 dòng.

## Không được

- Tạo file thảo luận mới (đó là việc của `discuss-next-task`).
- Sửa phần đã viết của file.
- Tạo plan, sửa code, tự đổi status, tự đóng task.
