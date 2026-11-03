---
description: Tiếp tục thảo luận của task ngay trong file đang mở. Gõ /discuss-continue-task [T-n] — không kèm thì suy task từ file thảo luận mới nhất.
---

Dùng skill `discuss-continue-task`.

Người làm đã trả lời trong file thảo luận và chọn tiếp trong chính file đó.

1. Xác định task: `$1` là `T-<n>` nếu có; không thì tìm file `discuss-*.md` số lớn nhất trong workstream và suy task từ header `**Task:**`.
2. Đọc **toàn bộ** file thảo luận + toàn bộ file task.
3. Phân loại từng `=>` (đã chốt · hỏi ngược · chưa rõ · không trả lời); ghi `D-<k>` vào mục `Quyết định` của file task.
4. Thêm `### Ghi nhận Qx.y` ngay dưới phản hồi tương ứng; cập nhật danh sách trỏ `T-<n>/D-<k>`; còn ambiguity thì thêm cụm tiếp vào cuối file.
5. Không tạo file mới; không sửa phần đã viết; không đổi status; chat 1–2 dòng.
