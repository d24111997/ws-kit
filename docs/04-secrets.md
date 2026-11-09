# 04 — Secrets & Account

> Repo public — tuyệt đối không chứa secret. Config dùng `{env:VAR}`; giá trị nằm trong `~/.secrets/opencode.env` (ngoài repo).

---

## 1. Danh sách biến (tên — không giá trị)

| Biến | Dùng cho | Lấy ở đâu |
|---|---|---|
| `OPENROUTER_API_KEY` | provider `openrouter` | openrouter.ai → Keys |
| `COMMANDCODE_API_KEY` | provider `commandcode` | commandcode.ai dashboard |
| `OBSIDIAN_API_KEY` | MCP `obsidian` | Obsidian → Local REST API plugin (tạo mới, xem `docs/05-vault-setup.md`) |
| `TMS_API_KEY` | MCP `tms` (task store) | Instance TMS → `tmsd key create --label <tên-máy>` (xem `docs/07-task-store.md`) |

## 2. Tạo file secrets

```bash
mkdir -p ~/.secrets
touch ~/.secrets/opencode.env
chmod 600 ~/.secrets/opencode.env
```

Nội dung `~/.secrets/opencode.env`:

```bash
export OPENROUTER_API_KEY="<điền>"
export COMMANDCODE_API_KEY="<điền>"
export OBSIDIAN_API_KEY="<điền sau khi cài plugin Local REST API>"
```

Sau khi lấy key từ plugin Local REST API (docs/05 §5), tạo thêm file key riêng cho MCP:

```bash
printf '%s' "<key>" > ~/.secrets/obsidian-api-key
chmod 600 ~/.secrets/obsidian-api-key
```

Key của task store MCP (`tms`) đi theo cùng đường — file riêng, không qua env:

```bash
printf '%s' "<key>" > ~/.secrets/tms-api-key
chmod 600 ~/.secrets/tms-api-key
```

**Vì sao cần file riêng:** `{env:...}` chỉ resolve từ env của **process opencode service** — service có thể được macOS spawn với env mặc định (không source `~/.zshenv`), khiến MCP server nhận key rỗng và fail `Connection closed` dù shell của bạn có biến. Config kit vì vậy dùng `{file:~/.secrets/obsidian-api-key}` cho MCP obsidian.

Nạp tự động — thêm vào `~/.zshenv`:

```bash
[ -f "$HOME/.secrets/opencode.env" ] && source "$HOME/.secrets/opencode.env"
```

Mở shell mới (hoặc `exec zsh`) để env có hiệu lực.

## 3. Account connect (không phải env var)

Một số provider đến từ **subscription account** chứ không phải API key:

- Trong opencode: `/connect` → chọn provider (vd **OpenCode Go**) → làm theo hướng dẫn.
- Các agents trong kit pin model `opencode-go/deepseek-v4.1-flash` + variants.
  - Nếu bạn dùng **provider khác**: remap `model:` trong `opencode/agents/*.md` (và `model` gốc trong config) sang provider/model của bạn. Variants cần được định nghĩa lại tương ứng trong `providers`.

## 4. Nguyên tắc

- **KHÔNG** để secret trong `opencode.jsonc`, không commit `~/.secrets/*`, không commit `*.env`.
- `{env:...}` resolve từ env của process chạy opencode (service) — **không phải** env của shell bạn; nếu biến không có trong service, giá trị thành chuỗi rỗng.
- `{file:path}` **được hỗ trợ** trong config v2 (nội dung file được thay vào chỗ `{file:...}`) — dùng cho key mà MCP server phải đọc (vd `~/.secrets/obsidian-api-key`).
- GitHub: không dùng PAT trong config — dùng `gh auth login` / OAuth của MCP remote nếu cần.
- Trước khi push repo có config: quét `gitleaks detect` + grep `grep -rn "sk-\|ghp_\|github_pat" .`
