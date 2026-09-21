---
name: docs-folder-review
description: Review một folder tài liệu (trong vault — 00_TASKS_THIS_WEEK / docs / root) để xác định thông tin nào KHÔNG trace được từ git/code/docs sẵn có và thật sự cần thành tài liệu (vd flow chưa từng được mô tả) → đáng lưu; mặc định xoá an toàn. Dùng khi user nói "rà/xem xét/kiểm tra folder X có gì đáng lưu docs không", "review folder tài liệu", "dọn dẹp tài liệu". CHỈ báo cáo — không tạo/sửa/xoá file trừ khi user ra lệnh tường minh.
---

# Docs Folder Review

Rà soát 1 folder tài liệu, đánh giá file nào có giá trị đáng lưu thành docs chính thức (vault/repo), rồi **báo cáo để user quyết định**. Đây là workflow rà dọn tài liệu — output là 1 báo cáo, KHÔNG phải thay đổi file.

## Goal

Với 1 folder, xác định:
1. File nào chứa **thông tin không thể trace lại từ git/code/docs sẵn có** và thuộc dạng cần thành tài liệu (vd **flow/process chưa từng được mô tả ở đâu**) → đáng lưu.
2. File nào **không đáng giữ** (quality gates PASS, plan thiết kế, registry, dữ liệu tạm).
3. Thông tin nào **đã có SSOT** ở nơi khác (code + git, repo docs, vault) → không lưu trùng.
4. Điểm nào **còn MỞ / chưa fix / chưa chốt** → cần user biết để quyết định (tạo ADR, Known Issue, Backlog...).

### 🎯 ĐỊNH NGHĨA "CÓ GIÁ TRỊ ĐÁNG LƯU" (khớp kỳ vọng user)

> **Kí ức luôn được lưu — git là bộ nhớ.** Mọi thứ đã làm (code, commit, comment, kể cả chính các folder lifecycle) đều trace lại được qua git. Xoá 1 folder artifact KHÔNG làm mất kí ức.

"Đáng lưu" = **thông tin MỚI — chưa nơi nào ghi — mà nếu không có sẽ phải reverse-engineer hoặc làm lại, và không tìm được ở code/git/docs repo/vault hiện có.**

| KHÔNG đáng lưu (đã có git/code/docs nắm) | ĐÁNG lưu (chưa nơi nào mô tả) |
|---|---|
| Bug đã fix — commit + code + comment kể đủ cách xử lý | Flow/luồng nghiệp vụ chưa có flow doc nào |
| Quyết định đã thực thi 100% trong code (logic đọc được) | Process/quy trình vận hành (ops) chưa được ghi |
| Quyết định kiến trúc đã ăn sâu code/hạ tầng → hiển nhiên | Tri thức từ research/exploration (đo lường, benchmark, mapping) chưa có nơi lưu |
| Handover/discuss/plan — git đã giữ nguyên bản | Deviation còn ảnh hưởng mà code không tự giải thích |

→ Viết lại 1 tài liệu về thứ git + code đã ghi = **tạo bản sao phải bảo trì, giá trị 0**. Chỉ tạo tài liệu mới khi nó **tiết kiệm công reverse-engineer** (vd: flow doc cho luồng code rải rác) hoặc **bổ sung thông tin không có trong code** (vd: quyết định business đang còn mở để cân nhắc lại, không phải đã đóng).

## Instructions (MUST follow in order)

### Phase 1 — Đọc cấu trúc folder

- `read_directory` folder được chỉ định. KHÔNG mở rộng sang folder khác (kể cả folder anh em).
- Nếu có subfolder → liệt kê cả subfolder (chúng nằm trong phạm vi).

### Phase 2 — Đọc nội dung

- Đọc các file **nền tảng** trước: `plan-context.md`, `discuss-*.md`, `HANDOVER*.md` — chúng chứa quyết định + bối cảnh.
- Đọc các quality gates còn lại (`impl-review`, `code-review`, `security-audit`, `test-coverage`) để tìm bài học/bug đã phát hiện.
- Nếu có script/code thật → đọc để tìm bài học mapping/bug ghi trong comment.
- Đọc theo nhóm song song (nhiều file 1 lần) để tiết kiệm lượt.

### Phase 3 — Đánh giá từng nhóm tri thức

Áp dụng định nghĩa "đáng lưu" ở trên (thông tin KHÔNG trace được từ git/code/docs sẵn có + thuộc dạng cần thành tài liệu):

| Nội dung tìm thấy | Đáng lưu? |
|---|---|
| **Flow/process chưa từng được mô tả** ở repo/vault (luồng nghiệp vụ, quy trình ops, runbook) | ✅ Đáng lưu — tạo flow doc/runbook mới |
| **Research/exploration có số liệu** chưa có nơi lưu (vd đo lường, benchmark, cost, mapping data) | ✅ Đáng lưu — nơi lưu: repo docs/research |
| Quyết định business **đang còn MỞ** cần cân nhắc (chưa chốt trong code/docs) | ✅ → nêu để user quyết (ADR nếu cần) |
| Bug root cause + fix | ❌ Không — git + code + comment đã ghi (trừ khi root cause CHƯA có nơi ghi VÀ còn rủi ro tái diễn) |
| Quyết định đã thực thi trong code (logic đọc được, có comment) | ❌ Không — code là SSOT |
| Quyết định kiến trúc đã ăn sâu code/hạ tầng (không ai làm sai lại được) | ❌ Không — ADR chỉ cho thứ còn mở để cân nhắc |
| Handover / discuss / plan / plan-context | ❌ Không — git đã giữ nguyên bản (artifact tạm) |
| Dòng "tạo N ADR sau approve" trong plan §8 / backlog HANDOVER | ❌ Không phải việc tồn đọng thật — là text agent tự sinh, không phải cam kết user |
| Quality gates PASS (impl/code/security/test-coverage) | ❌ Không |
| subagent-registry / dữ liệu tạm (dump, outputs, jsonl) | ❌ Không (có thể đề xuất xoá) |
| File "là bản duy nhất còn lại" trong folder tạm | ❌ Không — 00_TASKS là workspace, không phải nơi lưu trữ |

**Ban-list — KHÔNG được đề xuất lưu/giữ vì:** bug đã fix + có comment/SSOT · quyết định đã thực thi/hiển nhiên trong code · "file là bản duy nhất" trong folder tạm · security Low/Info chưa fix · backlog "tạo ADR/KI" trong plan/handover. Khi task đã xong + code/docs đã self-SSOT → mặc định **"xoá an toàn, 0 action"**.

### Phase 4 — Kiểm tra SSOT (trước khi kết luận "đáng lưu")

- **Xác định project chủ quản** của folder (đọc `AGENTS.md` repo tương ứng) → grep **đúng nơi quyết định sống** của project đó:
  - **Repo docs hub:** `docs/discuss/discuss-N.md` + `docs/architecture/*` + `docs/backend/flows/` + code. (Vault ADR có thể chỉ cover một phần — grep thiếu `docs/discuss/` của repo chủ quản thì chưa được coi là đã verify.)
  - **Repo khác:** vault `02_Architecture/ADRs/` + `docs/backend/` + `09_Known_Issues/` của repo tương ứng.
- Grep nơi tri thức đó có thể đã nằm: code thật + git log/commit + repo docs (`docs/discuss/`, `docs/backend/flows/`, `docs/general/ARCHITECTURE.md`, `CODING_RULES.md`) + vault.
- Nếu **đã có SSOT** → ghi "trùng lặp — không cần lưu" (kí ức nằm trong git là đủ).
- Nếu **chưa có** và thoả định nghĩa "đáng lưu" → ghi rõ trạng thái MỞ.

> ⚠️ **Bước 0 (trước Phase 1):** nếu review folder trong `00_TASKS_THIS_WEEK/` (folder lifecycle tạm) → đọc file lessons `AGENT_LESSONS_docs-folder-review_*.md` (trong vault) (nếu có) để áp các bài học đã gom — tránh tái phạm over-report.

### Phase 5 — Báo cáo (KHÔNG hành động)

Output báo cáo theo cấu trúc:

```
## <folder> — Có gì đáng lưu docs

<1-2 câu mô tả folder: task gì, gồm những gì>

**Có giá trị cao:**
1. <tri thức> — <vì sao>

**Không đáng giữ:** <liệt kê>

**Trùng lặp:** <đã có SSOT ở đâu>

**Đáng chú ý / còn MỞ:** <ADR chưa tạo, bug chưa fix, chưa commit, chưa verify...>

**Kết luận:** <tóm tắt + câu hỏi cho user: tạo ADR/Known Issue/Backlog hay tiếp tục rà folder khác>
```

## Constraints (TUYỆT ĐỐI — đã có lần vi phạm bị user bắt revert)

- **CHỈ BÁO CÁO.** Không tạo/sửa/xoá bất kỳ file nào. Mọi hành động phải chờ user ra lệnh tường minh ("tạo/cập nhật tài liệu", "tạo ADR", "tạo backlog"...).
- **CHỈ rà trong đúng folder được yêu cầu.** Không lan sang folder khác, không liệt kê tri thức từ folder ngoài phạm vi (dù là anh em với folder đang rà).
- **Không tự ý "sửa giúp"** lỗi docs phát hiện được — chỉ báo cáo là nó chưa fix.
- Đặt tên folder thật chính xác (đọc từ user, không tự suy đoán).

## Reference — nơi lưu tri thức chính thức (khi user duyệt)

| Loại tri thức | Nơi lưu |
|---------------|---------|
| **Flow/luồng nghiệp vụ chưa từng được mô tả** (tiết kiệm reverse-engineer) | repo docs của project (`docs/architecture/FLOW_PRODUCTION.md`, `docs/backend/flows/`, `docs/general/`) |
| Research/exploration có số liệu chưa lưu | repo docs (`docs/research/`) |
| Quyết định kiến trúc (khó đảo ngược, có trade-off) | `02_Architecture/ADRs/` — template `_templates/adr-template.md` |
| Vấn đề/điểm yếu chưa fix | `09_Known_Issues/` — template `_templates/ki-template.md` |
| Công việc cần làm | `06_Backlog/` — template `_templates/backlog-template.md` |
| Behavior / test | `11_Testing/` (SCN/TC/matrix) |
| Quyết định FE/BE đã có SSOT | repo docs (KHÔNG lưu trùng vào vault) |

> **Index tự động:** `_Index.md` của ADR/Backlog/Known Issues dùng dataview query — thêm file mới KHÔNG cần sửa index.
