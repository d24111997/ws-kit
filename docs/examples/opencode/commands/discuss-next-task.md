---
description: Tiếp tục thảo luận của task tại một file mới. Gõ /discuss-next-task [T-n] — không kèm thì suy task từ file thảo luận mới nhất.
---

Dùng skill `discuss-next-task`.

Người làm đã trả lời trong file thảo luận và chọn mở file tiếp theo.

1. Xác định task: `$1` là `T-<n>` nếu có; không thì tìm file `discuss-*.md` có số lớn nhất (chữ số ngay sau `discuss-`) trong workstream và suy task từ header `**Task:**`.
2. Đọc **toàn bộ** file thảo luận trước; đọc task **từ store** bằng `task_get` + `decision_list` — không đọc file task kiểu cũ (nếu dự án còn giữ).
3. Phân loại từng `=>` (đã chốt · hỏi ngược · chưa rõ · không trả lời); mỗi câu đã chốt gọi `decision_record` — store cấp `D-<k>`.
4. Tạo `discuss-<N+1>-t<n>.md` theo `DISCUSS_TEMPLATE.md`; số = số lớn nhất hiện có + 1 (không file đếm), `<n>` = số task. Mục **Nối tiếp** ghi phản hồi đã nhận, danh sách `T-<n>/D-<k>`, chỗ còn treo, lý do mở file.
5. Không sửa mục `Thảo luận` của task (một dòng cố định trỏ folder); file mới chỉ cần khai `**Task:** T-<n>`.
6. Không chép nội dung quyết định sang file thảo luận; không sửa file cũ; không đổi status; chat 1–2 dòng.
