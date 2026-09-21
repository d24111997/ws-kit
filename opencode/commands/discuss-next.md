---
description: Đọc phản hồi user ở cuối discuss-[n].md, tạo file discuss-[n+1].md MỚI và tiếp tục thảo luận ở đó. Gõ /discuss-next [số] — không kèm số thì tự tìm số lớn nhất hiện có + 1.
---

User vừa ghi phản hồi vào cuối file discuss và muốn **mở file discuss mới (số tiếp theo)** để tiếp tục thảo luận. Thực hiện:

## Bước 1 — Xác định file discuss hiện tại (file CŨ)

- Nếu có số: `$1` (vd `/discuss-next 17` → file cũ = `docs/discuss/discuss-17.md`).
- Nếu không có số: tự tìm file **discuss-*.md có số lớn nhất** trong thư mục discuss của repo hiện tại.

## Bước 2 — Đọc phản hồi mới từ file cũ

- **Đọc TOÀN BỘ file** — KHÔNG dùng `offset`/`limit` (không đọc từng phần, không đọc từ đoạn giữa). Đọc trọn file trong **1 lần** (1 call `read` toàn file). Nếu file quá dài so với giới hạn hiển thị, hãy đọc **nhiều lần liên tiếp từ đầu đến hết** (offset 0 → hết), tuyệt đối không bỏ qua phần đầu vì nghĩ "đã đọc rồi".
- Phản hồi user có thể nằm ở **bất kỳ đâu** trong file (cuối mỗi Q&A, giữa file, cuối file) — không chỉ cuối file. Vì vậy bắt buộc đọc **toàn bộ** để không bỏ sót.
- Xác định **TẤT CẢ** phản hồi user (dạng `=> ...` hoặc user thêm ở bất kỳ đâu) — không bỏ sót; ghi nhận toàn bộ quyết định đã chốt (từng mục "đã chốt", "kết luận").

## Bước 3 — Tạo file discuss MỚI (số + 1)

- Số mới = số file cũ + 1 (vd 17 → 18).
- Header theo template chuẩn (xem `references/template.md` trong skill `discuss-custom` — `~/Documents/21.AgentSkills/discuss-custom/references/template.md`):
  ```markdown
  # Discussion [n+1]: <Chủ đề ngắn gọn>

  **Ngày:** YYYY-MM-DD
  **Dự án:** <project name>
  **Mục tiêu:** <1 câu>
  **File trước:** discuss-[n].md — <đã chốt gì>

  ---
  ```
- Mở đầu file mới bằng mục ngắn **"1. Nối tiếp"** ghi rõ: file trước `discuss-[n].md` đã chốt gì (tóm tắt quyết định liên quan) + lý do mở file mới.
- **Toàn bộ file mới tuân thủ template chuẩn** (cấu trúc 9 phần trong `references/template.md`) — không tự bịa format.

## Bước 4 — Tiếp tục thảo luận (trong file mới)

- Theo skill `discuss-custom` — chat ngắn gọn, log Q&A vào file mới.
- Nếu còn ambiguity → hỏi câu tiếp theo (cụm, kèm đề xuất).
- Nếu đã hết câu hỏi → nói: `"Tôi đã hết câu hỏi, chờ bạn confirm kết thúc discuss"` và im lặng chờ.

## Quy tắc

- KHÔNG sửa file discuss cũ (trừ khi user yêu cầu) — chỉ đọc.
- KHÔNG tạo plan file / KHÔNG sửa code trong lúc discuss.
- KHÔNG viết REQ/plan khi chưa hết ambiguity (trừ khi user yêu cầu).
- Chat response ngắn 1-2 dòng: file mới đã tạo + trạng thái + câu hỏi/chốt gì.
