# Plan: [Tên Task]

## 1. Bối cảnh
- Mô tả ngắn module/project bị ảnh hưởng
- Lý do làm task này
- Liên kết tới task gốc (new_task.md, discuss files, user message)

## 2. Yêu cầu
- Yêu cầu functional (tóm tắt từ task input & discuss files)
- Yêu cầu non-functional (performance, security, UX)
- Tiêu chí chấp nhận (đo được, kiểm tra được)

## 3. Kiến trúc & Mapping
(Lấy từ Bước 2 — liệt kê đầy đủ)
- Files bị ảnh hưởng (đường dẫn tuyệt đối, phân loại thêm/sửa/xoá)
- Data flow
- Coding conventions cần tuân thủ
- Boundaries (Always / Ask First / Never items liên quan task này)
- Docs cần cập nhật sau task

## 4. Logic chi tiết
- Pseudocode hoặc mô tả từng bước
- Các nhánh rẽ (happy path, error path, edge case)
  - **Input normalization**: Mọi input string có so sánh/dedup — ghi rõ normalize strategy (trim, trailing slash, case, encoding). Nếu URL "A" và "A/" là cùng folder, phải normalize trước khi so sánh.
  - **Async state consistency**: Mọi flow có `await` giữa read và write state — review snapshot (Map<url, id> pattern), lock (isVerifying pattern), fallback nếu state thay đổi trong lúc chờ.
- Guard conditions, validations
- Input/output của từng bước

## 5. Vertical Slices

Chia task thành các lát cắt dọc (tracer bullet). Mỗi slice xuyên suốt tất cả layers (DB → API → Logic → UI). Mỗi slice hoàn chỉnh là chạy demo được.

### Slice 1: [Tiêu đề] — AFK / HITL
- **Xuyên suốt**: [các layers: schema → service → route → component]
- **User story**: "Khi..., tôi muốn..., để..."
- **Blocked by**: none / Slice X
- [ ] **RED**: Viết test cho slice này (unit / integration)
- [ ] **GREEN**: Implement code cho test pass
- [ ] **REFACTOR**: Clean up, verify test vẫn pass
- **Verify**: lệnh kiểm tra slice này (test + lint + typecheck)
### Slice 2: ... (lặp lại)

**Quy tắc slices:**
- Mỗi slice là 1 demo hoàn chỉnh. Nếu chưa demo được → slice quá to, cần bẻ nhỏ.
- **AFK** = AI tự làm được. **HITL** = cần human review/quyết định.
- Prefer nhiều slice mỏng > ít slice dày (tối đa 30-45 phút AI code / slice).
- Task nhỏ (1-2 files) vẫn dùng format này, chỉ khác số lượng slice.
- **BẮT BUỘC TDD**: Mỗi slice code phải theo RED → GREEN → REFACTOR. KHÔNG gom test vào 1 slice riêng cuối cùng.
  - Khi BUILD, load skill `test-driven-development` + `incremental-implementation` trước khi code slice đầu tiên.
  - Test được viết TRONG slice, không phải sau slice.
- **PHẢI có slice "Docs Update"** nếu task ảnh hưởng tới API Contract, DB Schema, Flow, ADRs.

## 6. Cách verify
- Lấy lệnh cụ thể từ AGENTS.md: `pnpm typecheck`, `pnpm lint`, `pnpm test -- run`, `pnpm build`,...
- **Static analysis bắt buộc**: Mỗi slice code phải có ít nhất 1 automated verify (lint/typecheck).
- Test commands cụ thể (không ghi chung chung "run tests").
- UI verify: responsive breakpoints, text overflow, empty states.
- Rollback plan: làm gì nếu verify fail? (fix → retry, hoặc revert → hỏi user).

## 7. Rủi ro & Open Items
- Điểm chưa chắc chắn
- Items cần user confirm trước khi code
- Ảnh hưởng tới module khác

## 8. ADR Candidates
- Quyết định nào đủ 3 tiêu chí: (1) khó đảo ngược, (2) gây ngạc nhiên, (3) có trade-off?
- Liệt kê kèm lý do
