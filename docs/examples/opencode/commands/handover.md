---
description: Viết handover theo template vault, đặt vào folder handover của project hiện tại
---

Viết file handover cho session hiện tại theo đúng template vault.

## Các bước bắt buộc

1. **Đọc template** từ Obsidian vault: dùng `obsidian_get_note` với target `{"type": "path", "path": "_templates/handover-template.md"}` format `full` — lấy nguyên frontmatter + cấu trúc (mục 1-7).

2. **Xác định folder handover:**
   - Mặc định: folder `docs/handover/` trong repo hiện tại (working directory).
   - Nếu `$ARGUMENTS` có chỉ định project/path (vd "prj 12", "12.<repo>", hoặc đường dẫn cụ thể) → dùng folder handover của project đó.
   - Nếu folder không tồn tại → tạo mới `docs/handover/` (hoặc hỏi user nếu không chắc).

3. **Xác định số handover kế tiếp:** liệt kê files trong folder handover, tìm số lớn nhất (`HANDOVER_N_*.md`) → file mới là `N+1`. Ngày lấy hôm nay (YYYY-MM-DD).

4. **Thu thập nội dung từ session hiện tại** (dùng conversation context + `git status`/`git diff` nếu cần):
   - **Session summary:** 1-2 câu tóm tắt phiên.
   - **Files changed:** mọi file đã tạo/sửa trong session này (gồm cả file ở repo khác nếu có).
   - **Key Decisions — DO NOT VIOLATE:** các quyết định user đã chốt trong session (từ discuss/handover liên quan).
   - **Vấn đề phát hiện:** bugs, hiểu sai, scope creep đã xử lý.
   - **Backlog + Công việc tiếp theo:** issue cần theo dõi.
   - **Ghi chép khác:** test/lint results, số liệu quan trọng.

5. **Viết file** tại `<folder-handover>/HANDOVER_<N>_<YYYY-MM-DD>.md` — giữ nguyên cấu trúc + frontmatter template, điền nội dung thật.

6. **Báo user:** đường dẫn file + tóm tắt 3-5 mục chính.

## Quy tắc

- KHÔNG xoá/sửa file handover cũ.
- KHÔNG đổi template — chỉ điền nội dung theo đúng các mục template.
- Nếu thông tin thiếu (vd không biết file nào changed) → kiểm tra git, vẫn thiếu thì ghi rõ "chưa rõ" thay vì đoán.
