# 00 — Workspace Conventions

> Quy ước chung cho workspace: layout repo, worktree, tài liệu, vault.

---

## 1. Repo layout

- Tất cả repo nằm trong 1 workspace chung (ví dụ `~/Documents/<workspace>/`) theo pattern `NN.<tên-repo>` (NN = số thứ tự 2 chữ số).
- Mỗi repo là một git repo độc lập, có `AGENTS.md` riêng ở root.
- Vault (Obsidian) nằm riêng ở `~/Documents/<Tên-vault>/`.

## 2. Worktree

Khi làm task lớn, tạo worktree **cạnh repo** (mirror path):

```bash
git worktree add -b <branch> ../<repo>.wt/<branch> <base-branch>
# ví dụ:
git worktree add -b feat_week_1/my-task ../my-repo.wt/feat_week_1/my-task origin/dev
```

- Naming convention branch: `feat_week_N/<task-name>` — đổi cho khớp team bạn.
- Luôn confirm **branch name + base branch** trước khi tạo — không tự đoán base.
- Worktree dùng chung `.git` — commit/push/fetch bình thường; mỗi worktree 1 branch riêng.
- Cleanup: `git worktree remove <path>` + `rm -rf <path>`.

## 3. Tài liệu per-repo

Mỗi repo có bộ tài liệu riêng:

| File | Vai trò |
|---|---|
| `AGENTS.md` | Entry point cho AI — conventions, commands, workflow của repo |
| `DOCS_INDEX.md` | Index tài liệu — biết file nào tồn tại, đọc khi nào |
| `docs/` | Tài liệu chi tiết: general/, backend/, frontend/, testing/... |
| `docs/discuss/`, `docs/handover/`, `docs/research/` | Artifact lịch sử (discuss-N.md, HANDOVER_N_*.md...) — record tại thời điểm, không rewrite |

## 4. Vault = shared brain

- Vault (Obsidian) chứa **cross-project knowledge**: kiến trúc, ADRs, flows, backlog, known issues, test docs.
- Mỗi project repo có `AGENTS.md` riêng — **không ghi conventions của project vào vault**.
- Vault giữ "khuôn" tổ chức (taxonomy + templates); dùng `scripts/new-vault.sh` để tạo vault mới từ skeleton.

## 5. Ranh giới

- **Repo code**: code + tài liệu về chính repo đó.
- **Vault**: tài liệu cross-project + quyết định chung + ký ức dài hạn.
- **Artifact** (discuss/plan/handover/review reports): ghi tại thời điểm, không sửa lại — để truy vết quyết định.

## 6. Vòng đời task (gợi ý)

1. **Discuss** — làm rõ yêu cầu, log vào `discuss-[n].md` (trong repo/worktree).
2. **Plan** — plan.md với vertical slices.
3. **Build** — implement theo TDD, từng slice.
4. **Review** — impl-review → test coverage → code review + security (song song).
5. **Verify** — full test suite + lint + build.
6. **Handover** — `docs/handover/HANDOVER_N_*.md` khi kết thúc session.

> Các bước trên được hỗ trợ bởi bộ agents/commands/skills trong `ws-kit` (jack, planner, developer, ... — xem `docs/03-opencode-config.md`).
