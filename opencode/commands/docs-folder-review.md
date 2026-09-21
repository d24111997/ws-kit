---
description: Rà 1 folder tài liệu — xác định gì đáng lưu docs (báo cáo, không sửa file). Usage: /docs-folder-review <folder-path>
---

# Docs Folder Review

Load skill `docs-folder-review` từ `~/Documents/21.AgentSkills/docs-folder-review/SKILL.md`.

Sau đó thực thi đúng theo hướng dẫn trong skill đó, **follow đầy đủ 5 phases theo thứ tự bắt buộc**:

1. **Phase 1 — Đọc cấu trúc folder** (đúng folder `$ARGUMENTS` chỉ định, không lan sang folder khác)
2. **Phase 2 — Đọc nội dung** (file nền tảng trước: plan-context/discuss/HANDOVER → quality gates → code/script nếu có)
3. **Phase 3 — Đánh giá theo bảng tiêu chí** (chỉ bug root cause / quyết định business chốt / deviation / bài học vận hành mới "đáng lưu"; plan + quality gates PASS + registry → KHÔNG)
4. **Phase 4 — Kiểm tra SSOT** (bắt buộc grep cả **code thật** + repo docs + vault — nếu đã có SSOT → ghi "trùng lặp, không cần lưu")
5. **Phase 5 — Báo cáo** theo đúng cấu trúc: Có giá trị cao / Không đáng giữ / Trùng lặp / Đáng chú ý-còn MỞ / Kết luận

**Constraint tuyệt đối:** CHỈ BÁO CÁO — không tạo/sửa/xoá bất kỳ file nào. Mọi hành động chờ user ra lệnh tường minh. Không tự ý "sửa giúp" lỗi phát hiện. Folder đích = `$ARGUMENTS` (đọc chính xác từ user, không tự suy đoán).

Báo cáo cuối bằng tiếng Việt, ngắn gọn, kèm câu hỏi cho user ở phần Kết luận (tạo ADR/Known Issue/Backlog hay tiếp tục rà folder khác).
