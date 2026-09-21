---
description: Đọc phản hồi user ở cuối discuss-[n].md rồi tiếp tục thảo luận. Gõ /discuss-continue [số] — không kèm số thì tự tìm file mới nhất.
---

User vừa ghi phản hồi vào cuối file discuss và muốn tiếp tục thảo luận. Thực hiện:

## Bước 1 — Xác định file discuss

- Nếu có số: `$1` (vd `/discuss-continue 17` → `docs/discuss/discuss-17.md`).
- Nếu không có số: tự tìm file **discuss-*.md có số lớn nhất** trong thư mục discuss của repo hiện tại (ưu tiên `docs/discuss/`, nếu không có thì tìm thư mục chứa `discuss-*.md` bất kỳ).

## Bước 2 — Đọc file + phản hồi mới

- **Đọc TOÀN BỘ file** — KHÔNG dùng `offset`/`limit` (không đọc từng phần, không đọc từ đoạn giữa). Đọc trọn file trong **1 lần** (1 call `read` toàn file). Nếu file quá dài so với giới hạn hiển thị, hãy đọc **nhiều lần liên tiếp từ đầu đến hết** (offset 0 → hết), tuyệt đối không bỏ qua phần đầu vì nghĩ "đã đọc rồi".
- Phản hồi user có thể nằm ở **bất kỳ đâu** trong file (cuối mỗi Q&A, giữa file, cuối file) — không chỉ cuối file. Vì vậy bắt buộc đọc **toàn bộ** để không bỏ sót.
- Xác định **TẤT CẢ** phản hồi user (dạng `=> ...` hoặc nội dung user tự thêm) — không bỏ sót bất kỳ cái nào; chúng là input để tiếp tục.

## Bước 3 — Tiếp tục thảo luận

- Ghi nhận/append phản hồi user vào đúng chỗ trong file (theo skill `discuss-custom` — chat ngắn gọn, log Q&A vào file).
- **Tuân thủ template chuẩn** của discuss — xem `references/template.md` trong skill `discuss-custom` (`~/Documents/21.AgentSkills/discuss-custom/references/template.md`): cấu trúc Context đã nạp → Feedback user → Phân tích kỹ thuật → Q&A theo Cụm (Q + Đề xuất + `=>` user + Ghi nhận phản hồi + Bảng quyết định từng cụm) → Bảng tổng hợp → Ghi nhận kỹ thuật cho PLAN → Câu hỏi mở → Kết luận.
- Tổng hợp thành bảng quyết định "đã chốt" nếu chưa có (theo template: bảng quyết định TỪNG CỤM + bảng tổng hợp cuối).
- Nếu còn ambiguity → hỏi câu tiếp theo (cụm, kèm đề xuất — theo skill discuss-custom).
- Nếu đã hết câu hỏi → nói: `"Tôi đã hết câu hỏi, chờ bạn confirm kết thúc discuss"` và im lặng chờ.

## Quy tắc

- KHÔNG tạo plan file / KHÔNG sửa code trong lúc discuss.
- KHÔNG viết REQ/plan khi chưa hết ambiguity (trừ khi user yêu cầu).
- Chat response ngắn 1-2 dòng: trạng thái + câu hỏi/chốt gì.
