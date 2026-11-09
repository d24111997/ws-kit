# CHECKLIST — sau khi cài đặt

> Tick từng mục sau khi chạy P0→P8 (README). Chạy `./scripts/verify.sh` để check tự động phần lớn các mục.

## P0–P2 — Base + opencode

- [ ] `brew --version` OK; `git config --global user.name/user.email` đã set
- [ ] `gh auth status` → logged in
- [ ] `opencode --version` → `2.0.x` (v2)
- [ ] `opencode debug paths` chạy được (thấy config/data/log paths)
- [ ] (Khuyến nghị) `tmux` + `lazygit` đã cài — git workflow đa repo (docs/00 §7)

## P3 — headroom + rtk

- [ ] `headroom doctor` → OK
- [ ] `headroom install status` → profile default, port 8787
- [ ] `curl -s http://127.0.0.1:8787/health` → phản hồi
- [ ] `rtk --version` OK
- [ ] Đã **KHÔNG** chạy `headroom mcp install` / `--scope provider` / `wrap opencode`

## P4 — config + skills

- [ ] `~/.config/opencode/opencode.jsonc` tồn tại (từ kit)
- [ ] Config không lẫn key v1: `grep '"enabled"\|@ai-sdk' ~/.config/opencode/opencode.jsonc` → rỗng
- [ ] `ls ~/.config/opencode/agents` → 11 file (+ references/)
- [ ] `ls ~/.config/opencode/commands` → 7 file
- [ ] `ls ~/.config/opencode/plugins` → `rtk.ts`, `serena-reminder.ts`
- [ ] `ls ~/Documents/21.AgentSkills` → 18 skill
- [ ] `~/.config/opencode/node_modules/@opencode/plugin` tồn tại (npm install OK)
- [ ] Config + skills đã được init git repo local (bootstrap) — `git -C ~/.config/opencode log` có commit đầu

## P5 — secrets

- [ ] `~/.secrets/opencode.env` tồn tại + `chmod 600`
- [ ] `~/.zshenv` có dòng source file trên
- [ ] Shell mới: `echo $OPENROUTER_API_KEY` → có giá trị
- [ ] Đã `/connect` account (vd OpenCode Go) — hoặc đã **remap model refs** trong `opencode/agents/*.md` + config nếu dùng provider khác (xem docs/04 §3)

## P6 — vault + MCP obsidian

- [ ] Vault tạo bằng `new-vault.sh` + `git log` có commit đầu
- [ ] Obsidian mở được vault (Open folder as vault)
- [ ] 5 community plugins đã cài + bật: local-rest-api, markitdown, dataview, templater, meta-bind
- [ ] Local REST API bật, port 27123, key đã thêm vào `~/.secrets/opencode.env`
- [ ] `git status --short` trong vault: **KHÔNG** thấy `.obsidian/plugins/*/data.json` / `workspace.json` trước khi commit
- [ ] MCP obsidian đọc/ghi thử 1 note OK

## P6b — task store (tuỳ chọn)

> Chỉ làm khi bạn có một instance TMS thật. Không có → bỏ block `tms` trong config và bỏ 3 skill `discuss-*`. Xem `docs/07-task-store.md`.

- [ ] `~/.secrets/tms-api-key` tồn tại + `chmod 600`
- [ ] `opencode/opencode.template.jsonc` (hoặc config đã cài): `url` trỏ đúng `<tms-host>/write/mcp`, không có tiền tố `/read/`
- [ ] Gọi thử 1 tool đọc (`task_list`) → trả danh sách, không `401`
- [ ] `401` → kiểm key + `tmsd key list` còn hiệu lực; `404` → sai đường, đọc ở `/sse` ghi ở `/write/mcp`

## P7 — verify

- [ ] `./scripts/verify.sh --vault ~/Documents/"<Tên vault>"` → không có FAIL
- [ ] `opencode mcp list` → obsidian / serena / headroom connected (+ `tms` nếu có instance) (chrome-devtools: cần Chrome)
- [ ] `opencode plugin list` → thấy rtk + serena-reminder
- [ ] TUI hiển thị TPS (oc-tps hoạt động)

## P8 — first run

- [ ] Mở opencode trong 1 repo → agents load (thấy jack + subagents)
- [ ] Chạy thử `/plan-custom` → OK
- [ ] (Optional) Thêm block rtk-instructions vào `~/.config/opencode/AGENTS.md` — snippet tại `docs/02-headroom.md §4`

## Giữ kit đồng bộ (định kỳ)

- [ ] Sau khi sửa agent/skill trên máy: `./scripts/capture.sh` (dry-run) → `--apply`
- [ ] Review `git diff --stat` trong kit rồi commit — không để drift 2 tháng
- [ ] Skill cá nhân không muốn lên kit: thêm tên vào `.kitignore`

## Git workflow đa repo (khuyến nghị)

- [ ] Đã copy `snippets/zsh-ws.zsh` vào `~/.zshrc` + sửa `WS_REPOS`
- [ ] `lgall` mở tmux session (lazygit từng repo); `wsst` chạy OK

## Ghi chú vận hành

- [ ] Backup config cũ nằm ở `~/.config/opencode.backup-<timestamp>/` — giữ đến khi chắc chắn mọi thứ OK
- [ ] Chưa từng commit secret: `gitleaks detect --no-banner` trong bất kỳ repo config nào
