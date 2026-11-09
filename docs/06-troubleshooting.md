# 06 — Troubleshooting

> Lỗi thường gặp + vị trí log/service + rollback.

---

## 1. Paths quan trọng (opencode v2)

| Thứ | Path |
|---|---|
| Log | `~/.local/share/opencode/log/opencode.log` |
| Service state | `~/.local/state/opencode/service.json` |
| DB | `~/.local/share/opencode/opencode.db` |
| CLI settings | `~/.config/opencode/cli.json` |
| Config | `~/.config/opencode/opencode.jsonc` |

Xem path tự động: `opencode debug paths`

## 2. Rollback

```bash
opencode uninstall --keep-config --keep-data     # gỡ binary, giữ config + data
```

Backup config cũ (nếu bạn tự tạo lúc dựng máy): `~/.config/opencode.backup-<timestamp>/` — muốn quay lại chỉ cần đổi tên về `opencode`.

## 3. Lỗi thường gặp

### MCP không connect

- `opencode mcp list` → server nào `disconnected`?
- **obsidian**: Obsidian app phải đang mở + plugin Local REST API bật + đúng port **27123** + `OBSIDIAN_API_KEY` có trong env shell đang chạy opencode.
- **chrome-devtools**: cần Google Chrome đã cài (`brew install --cask google-chrome`).
- **serena/headroom**: chạy `uvx --version` / `headroom doctor` để kiểm tra binary.
- Thử restart service: `opencode service restart`
- **`opencode mcp list` trả `No MCP servers configured`** — thường gặp ngay sau khi đổi config hoặc khi service đang restart, không phải config hỏng: chờ vài giây rồi chạy lại trước khi kết luận.

### headroom proxy :8787 không phản hồi

```bash
headroom install status
headroom install restart        # hoặc: headroom install apply --providers manual
curl -s http://127.0.0.1:8787/health
```

Lưu ý: `headroom doctor` trả **exit ≠ 0 cả khi chỉ có warning** (`0 failure(s), 5 warning(s)` là trạng thái bình thường). Đọc dòng tổng kết chứ đừng coi exit code là fail: `0 failure` → ổn, `>0 failure` → cần xử lý.

### chrome-devtools MCP "connected" nhưng tool báo `Could not find DevToolsActivePort`

`--autoConnect` (Chrome 144+) cần remote debugging server bật ngay trong Chrome:

1. Mở `chrome://inspect/#remote-debugging` trong Chrome.
2. Bật **Enable remote debugging**.
3. Gọi lại tool (vd `list_pages`) — không cần restart opencode.

Nếu không bật được toggle, chạy MCP không kèm `--autoConnect` để nó tự mở Chrome riêng (profile sạch).

### Plugin local không load (rtk / serena-reminder)

- Kiểm tra `opencode plugin list` có `rtk`/`serena` không.
- Kiểm tra `~/.config/opencode/node_modules/@opencode/plugin` tồn tại; nếu thiếu:
  ```bash
  cd ~/.config/opencode && npm install
  ```
- Xem log: `~/.local/share/opencode/log/opencode.log` (grep `plugin`).

### Plugin rtk không rewrite lệnh

- `which rtk` — thiếu thì `brew install rtk`.
- Plugin tự disable khi không thấy rtk trong PATH (xem warning trong log khi khởi động).

### Config lẫn format v1

```bash
grep -n '"enabled"\|@ai-sdk' ~/.config/opencode/opencode.jsonc
```

Nếu có kết quả → có tool khác đã ghi config theo v1 (thường do chạy `headroom mcp install` / `--scope provider` / `wrap opencode` — xem `docs/02-headroom.md` §3). Restore bằng cách copy lại `opencode.jsonc` từ backup của bạn; muốn xem lại hình dạng sạch thì mở `docs/examples/opencode.jsonc`.

### Skills không load

- Kiểm tra `skills` array trong config trỏ đúng path (`~/Documents/21.AgentSkills`).
- Kiểm tra từng skill có `SKILL.md` + frontmatter `description`.
- Trong opencode: skill list chỉ hiện khi agent có permission `skill` + skill có description.

### oc-tps không hiển thị TPS

- Kiểm tra `~/.config/opencode/cli.json` có `{"plugins": ["oc-tps@latest"]}`.
- Plugin TUI resolve qua npm khi khởi động — kiểm tra mạng; hoặc chạy `opencode plugin check`.

### `{env:VAR}` không được thay

- Env phải có trong **shell khởi chạy opencode** (source `~/.secrets/opencode.env` trong `~/.zshenv`).
- Kiểm tra: `echo $OPENROUTER_API_KEY` trong cùng shell.

## 4. Thu thập log khi cần debug

```bash
tail -n 200 ~/.local/share/opencode/log/opencode.log
opencode --version && opencode debug paths
headroom doctor
opencode mcp list
```
