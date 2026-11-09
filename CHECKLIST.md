# CHECKLIST — workspace đã đủ chưa

> Danh sách thành phần của một workspace chuẩn. Mỗi dòng ghi **cách tự kiểm**, không ghi kết quả mong đợi của một phiên bản cụ thể.
> Dùng lúc dựng máy mới, và khi nghi có gì đó thiếu. Agent ở máy mới đọc file này để tự đối chiếu.

## Tool ngoài

- [ ] `brew --version` → in ra được version
- [ ] `git config --global user.name` và `user.email` → có giá trị
- [ ] `gh auth status` → đang đăng nhập
- [ ] `uv --version` · `pnpm --version` · `node --version` → in ra được version
- [ ] `gitleaks version` → in ra được version
- [ ] (tuỳ chọn) `jq --version` · `tmux -V` · `lazygit --version` · `which headroom` · `rtk --version`

## opencode + headroom

- [ ] `opencode --version` → in ra được version
- [ ] `opencode debug paths` → in ra config/data/log paths
- [ ] `headroom doctor` → đọc **dòng tổng kết** (`N failure(s)`), không đọc exit code
- [ ] `curl -s http://127.0.0.1:8787/health` → có phản hồi
- [ ] Chưa từng chạy `headroom mcp install` / `--scope provider` / `wrap opencode` (chúng ghi config sai dạng)

## Config

Cần có: `opencode.jsonc` ở chỗ opencode đọc. Không có bản mẫu để copy — hình dạng xem `docs/examples/opencode.jsonc`.

- [ ] File config tồn tại; `opencode` khởi động không báo lỗi parse
- [ ] Có khối providers, khớp provider/model bạn thật sự dùng
- [ ] Có khối MCP servers — hoặc đã cố ý bỏ
- [ ] Có permissions (tối thiểu chặn `git push`)
- [ ] `skills` trỏ đúng thư mục skill
- [ ] Không có secret trong file (`grep -i "sk-\|ghp_\|api_key" opencode.jsonc` → không có giá trị thật)

## Thành phần agent

- [ ] Thư mục `agents/` có file agent + `references/` nếu dùng
- [ ] Thư mục `commands/` có slash command bạn cần
- [ ] Thư mục `plugins/` có plugin + deps đã cài (`npm install` trong thư mục plugin)
- [ ] `AGENTS.md` cho LLM (global) tồn tại nếu bạn dùng
- [ ] `opencode plugin list` → thấy plugin bạn cài
- [ ] Trong opencode: gọi một agent → agent trả lời, không báo thiếu model

## Skills

- [ ] `skills` trong config trỏ tới đúng thư mục (clone kit, hoặc thư mục riêng của bạn)
- [ ] Trong opencode: skill hiện trong danh sách skill khả dụng
- [ ] Chạy thử một skill (`/plan-custom`, `/discuss-task`) → chạy được

## Secrets + account

- [ ] File secrets tồn tại + `chmod 600` (mặc định `~/.secrets/opencode.env`)
- [ ] `~/.zshenv` source file đó (nếu bạn dùng env var)
- [ ] Shell mới: `echo $OPENROUTER_API_KEY` → có giá trị (hoặc biến bạn dùng)
- [ ] Key dạng file (`{file:...}`) tồn tại + `chmod 600`
- [ ] Đã `/connect` account nếu provider đến từ subscription

## Vault (Obsidian)

- [ ] Vault tạo từ `./scripts/new-vault.sh "<Tên vault>"`; `git -C <vault> log` có commit đầu
- [ ] Obsidian mở được vault (Open folder as vault)
- [ ] 5 community plugins cài + bật: local-rest-api · markitdown · dataview · templater · meta-bind
- [ ] Local REST API bật, port 27123; key đã vào chỗ cấu hình dùng
- [ ] `.obsidian/plugins/*/data.json` và `workspace.json` không bị commit
- [ ] MCP obsidian đọc/ghi thử một note

## Task store (tuỳ chọn)

> Chỉ khi bạn có một instance TMS thật. Không có → đừng khai block `tms`, và bỏ 3 skill `discuss-*` vì chúng gọi `task_get`/`decision_record`.

- [ ] File key (`~/.secrets/tms-api-key`) tồn tại + `chmod 600`
- [ ] `url` trong block `tms` trỏ `<tms-host>/write/mcp` — không có tiền tố `/read/`
- [ ] Gọi thử `task_list` → trả danh sách, không `401`
- [ ] `401` → kiểm key + còn hiệu lực phía server; `404` → sai đường (ghi ở `/write/mcp`, đọc ở `/sse`)

## Git workflow đa repo (khuyến nghị)

- [ ] Đã copy `snippets/zsh-ws.zsh` vào `~/.zshrc` + sửa `WS_REPOS`
- [ ] `lgall` mở tmux session; `wsst` chạy được

## Ghi chú vận hành

- [ ] Backup config cũ (nếu có) giữ đến khi chắc mọi thứ OK
- [ ] Chưa từng commit secret: `gitleaks detect --no-banner` trong repo config/vault
