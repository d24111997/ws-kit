---
name: discuss-task
description: Thảo luận có cấu trúc gắn với task của workspace — đọc task từ store TMS (MCP `task_get` · `decision_list`), viết câu hỏi/phương án vào file thảo luận theo DISCUSS_TEMPLATE.md, khoá quyết định về task bằng `decision_record`. Use when a task needs clarification, when stress-testing a decision, or when the user answers inline in a discuss file and the discussion must continue.
---

# Skill: `discuss-task`

> Quy trình gốc: `TASK_SYSTEM.md` §5 · §6 · §7 · §8 · §9 · §10. Khung file: `DISCUSS_TEMPLATE.md`. Vị trí hai file này ghi ở `AGENTS.md` §0 của repo (HRIS: `08-task-system/`).

## Nguyên tắc

1. **Thảo luận trong file, không trong chat.** Chat chỉ 1–2 dòng: file nào, cụm nào đang mở.
2. **Quyết định thuộc về task.** Thảo luận giữ *vì sao* và *phương án đã loại*; điều đã chốt ghi về task bằng `decision_record` (store cấp `D-<n>`, `D-1`, `D-2`…).
3. **Chỉ thêm.** Không sửa phần đã viết của file thảo luận; lệch với quyết định thì quyết định đúng.
4. **Đọc toàn bộ trước khi xử lý.** Trước khi phân loại phản hồi, đọc file thảo luận từ đầu đến cuối; grep `=>` hoặc trích dòng không thay được việc đọc. Mọi dòng người làm thêm vào file — kể cả không có `=>`, không có dấu `?` — đều phải được phân loại: trả lời · câu hỏi · ghi chú.
5. **Phương án đánh chữ in hoa `A · B · C · D`.** Người làm trả lời bằng chữ in hoa, inline sau `=>`.
6. Agent **không** tự chốt quyết định, không tự đóng câu hỏi, không tự đóng task, không tự thêm khái niệm hay luật vào mô hình.

## Bước 1 — Nạp dữ kiện (không nạp cả repo)

Đọc theo thứ tự, dừng khi đủ:

1. Task `T-<n>` **từ store TMS**: `task_get(ref: "T-<n>")` cho mục tiêu · phạm vi · trạng thái · phụ thuộc · chủ đề còn mở (trong `body_md`) và `decision_list(ref: "T-<n>")` cho các quyết định đã ban hành. Không đọc `05-mvp/tasks/*.md` — 35 file đó chỉ còn giá trị lịch sử, có banner, không sửa.
2. `DISCUSS_TEMPLATE.md` — khung file và checklist đóng cuộc.
3. Chỉ những tư liệu task liệt kê, và chỉ phần cần cho chủ đề đang hỏi.

Task chưa có trong store → dừng và báo người làm; không tự tạo task (chỉ `task_create` khi người làm bảo).

## Bước 2 — Xác định chỗ ghi

| Tình huống | Làm gì |
|---|---|
| Task chưa có cuộc thảo luận | Tạo `discuss-<N>-t<n>.md` theo template; `N` = số lớn nhất trong folder workstream + 1, `<n>` = số task (`T-40` → `-t40`) |
| Người làm chọn tiếp trong file đang mở | Thêm cụm mới + mục Ghi nhận vào cuối file đó (chỉ thêm, không sửa phần cũ) |
| Người làm chọn mở file mới | Tạo `discuss-<N+1>-t<n>.md`, mở đầu bằng **Nối tiếp**: phản hồi đã nhận · `T-n/D-k` đã khoá · chỗ còn treo · lý do mở file |
| Không rõ ý người làm | Hỏi đúng một câu: tiếp file này hay mở file mới |

Skill **không** tự quyết chỗ ghi; hai đường vào là `discuss-continue-task` (tiếp file đang mở) và `discuss-next-task` (mở file mới). File thảo luận tự khai `**Task:** T-<n>`; dòng `## Thảo luận` nằm trong `body_md` của task và chỉ trỏ folder — **không sửa task** khi mở cuộc.

## Bước 3 — Viết câu hỏi theo cụm

Mỗi cụm:

1. Nêu dữ kiện đã biết — không hỏi lại điều trả lời được bằng code/tài liệu.
2. Phân tích kỹ thuật nếu tự trả lời được.
3. Câu hỏi: số hiệu · phạm vi chạm tới · phương án `A/B/C/D` kèm hệ quả · **đề xuất** kèm lý do.
4. Chừa chỗ `=>` cho người làm.

Câu trong cùng cụm phải độc lập nhau; câu phụ thuộc → cụm sau.

## Bước 4 — Xử lý phản hồi `=>`

Phân loại trước khi ghi:

| Loại | Dấu hiệu | Làm gì |
|---|---|---|
| Đã chốt | Chọn `A/B/C…` hoặc nêu một giá trị cụ thể | Ghi `### Ghi nhận Qx.y (ngày)` + thêm dòng vào bảng quyết định cụm |
| Hỏi ngược | Hỏi lại, xin ý kiến, "nên kiểu nào" | Trả lời ngay dưới câu hỏi đó; **không** tính là chốt; nêu lại phương án để người làm chọn |
| Chưa rõ | Trả lời lệch phạm vi câu hỏi | Ghi nhận nguyên văn + một câu hỏi làm rõ, cùng cụm |
| Câu hỏi xen giữa | Dòng người làm thêm không có `=>`, có ý hỏi | Trả lời ngay dưới dòng đó; nếu không được sửa file cũ thì trả lời ở mục **Trả lời câu hỏi ở file trước** của file mới |
| Ghi chú | Dòng người làm thêm không có `=>`, chỉ là nhận xét/bổ sung | Ghi nhận nguyên văn; không suy thành phương án |
| Không trả lời | Không có `=>` và không phải câu hỏi/ghi chú | Giữ treo; ghi vào §8 Câu hỏi mở |

Không suy diễn phương án khi người làm chỉ nhận xét.

## Bước 5 — Khoá cụm, ghi về task, đồng bộ chủ đề

- **Chủ đề mới**: cuộc mở ra một điểm chưa rõ chưa có trong mục `Chủ đề còn mở` → thêm **một dòng chủ đề** (bằng lời; không câu hỏi, không link tới file thảo luận) ngay khi mở cụm, bằng `task_update(ref: "T-<n>", patch: { body_md })` với **toàn bộ** `body_md` đã cập nhật.
- **Chủ đề đã rõ** thì rút khỏi mục `Chủ đề còn mở` — cũng bằng `task_update(patch: { body_md })`; dấu vết nằm ở `D-<k>` và ở file thảo luận.
- **Câu hỏi** ở lại trong cụm của file thảo luận — không chép câu hỏi vào task.

- Khoá cụm → gọi **ngay** `decision_record(ref: "T-<n>", text: "<một câu thi hành được>", source: "discuss-<N> Q<x.y>")`. Store cấp `D-<n>` (max+1), không đánh tay, không dùng lại số; tool trả `{ n, ref: "T-<n>/D-<k>" }` — ghi đúng `ref` đó vào file thảo luận.
- File thảo luận **chỉ trỏ** `T-<n>/D-<k>`, không chép nội dung quyết định (không có cột "Giá trị").
- Không tự đổi `status` của task; chỉ gọi `task_update(patch: { status })` hoặc `{ status_note }` khi người làm bảo.

## Bước 6 — Đóng cuộc

Chỉ đóng khi checklist `DISCUSS_TEMPLATE.md` §4 đủ:

- đã đọc toàn bộ file; mọi dòng người làm thêm (kể cả không có `=>`) đã được phân loại;
- mọi câu trong cụm có `=>` + Ghi nhận;
- quyết định đã khoá đã ghi về store (`decision_list` thấy đủ `D-<k>`);
- file thảo luận khai `**Task:**` + nguyên văn chủ đề;
- bảng tổng hợp khớp `decision_list` của task;
- câu hỏi mở còn lại nằm ở §8 của file thảo luận.

Đóng xong: `"Tôi đã hết câu hỏi, chờ bạn xác nhận kết thúc thảo luận"` rồi im lặng.

## Không được

- Thay việc đọc toàn bộ file thảo luận bằng grep `=>` hoặc trích dòng.
- Tạo plan, sửa code, hoặc gọi `task_update` với trường ngoài `body_md`/`status`/`status_note` khi người làm chưa bảo.
- Tự đổi `status`, tự đóng task, tự đóng câu hỏi.
- Tự tạo task con hoặc task mới.
- Ghi quyết định chỉ trong file thảo luận mà không gọi `decision_record`.
- Hỏi từng câu trong chat rồi chép vào file.
