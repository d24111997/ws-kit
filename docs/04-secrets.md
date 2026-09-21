# 04 — Secrets & Account

> Repo public — tuyệt đối không chứa secret. Config dùng `{env:VAR}`; giá trị nằm trong `~/.secrets/opencode.env` (ngoài repo).

---

## 1. Danh sách biến (tên — không giá trị)

| Biến | Dùng cho | Lấy ở đâu |
|---|---|---|
| `OPENROUTER_API_KEY` | provider `openrouter` | openrouter.ai → Keys |
| `COMMANDCODE_API_KEY` | provider `commandcode` | commandcode.ai dashboard |
| `OBSIDIAN_API_KEY` | MCP `obsidian` | Obsidian → Local REST API plugin (tạo mới, xem `docs/05-vault-setup.md`) |

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
- `{file:...}` **không được hỗ trợ** trong docs v2 → dùng `{env:...}` (kit đã chọn cách này).
- GitHub: không dùng PAT trong config — dùng `gh auth login` / OAuth của MCP remote nếu cần.
- Trước khi push repo có config: quét `gitleaks detect` + grep `grep -rn "sk-\|ghp_\|github_pat" .`
