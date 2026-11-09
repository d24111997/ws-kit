# 05 — Vault Setup (Obsidian + MCP)

> Tạo vault từ skeleton + cài 5 community plugins + bật Local REST API cho MCP `obsidian`.

---

## 1. Tạo vault

```bash
cd <clone-kit>
./scripts/new-vault.sh "<Tên vault>"          # tạo <parent>/<Tên vault> + git init + commit đầu
```

Vault skeleton gồm: taxonomy `00_TASKS_THIS_WEEK → 12_bug` (+ `04_Research`, `07_Infra`, `10_unclassified`), `_templates/` (7 template + `_Index.md`), `_diagrams/`, `_Index.md`, `11_Testing/` (templates test + `test-plan-general.md`), `AGENTS.md`.

## 2. Mở bằng Obsidian

1. Mở Obsidian → **Open folder as vault** → chọn `~/Documents/<Tên vault>`.
2. Settings → **Community plugins** → **Turn on community plugins**.

## 3. Cài + bật 5 community plugins

> Vault template chỉ chứa `community-plugins.json` (danh sách enable) — **không kèm code plugin**. Cần cài từ Obsidian store:
>
> 💡 Obsidian sẽ báo "plugin not installed" cho các ID này ở lần mở vault đầu tiên — **bình thường**, cài xong 5 plugin là hết.

| Plugin (ID chính xác) | Vai trò |
|---|---|
| `obsidian-local-rest-api` | REST API cho MCP obsidian |
| `markitdown` | Convert tài liệu → markdown |
| `dataview` | Query dữ liệu trong vault |
| `templater-obsidian` | Template engine (dùng `_templates/`) |
| `obsidian-meta-bind-plugin` | Bind metadata trong note |

## 4. Bật Local REST API

1. Settings → **Local REST API** → bật plugin.
2. Port: plugin 5.x mặc định HTTPS **27124** (insecure 27123 mặc định tắt). Config MCP trong kit dùng `OBSIDIAN_BASE_URL=https://127.0.0.1:27124` — nếu bạn đổi port thì sửa lại cho khớp.
3. Copy **API key**.

## 5. Thêm key vào secrets

```bash
# 1) file key riêng cho MCP ({file:} — không phụ thuộc env của service, xem docs/04 §4)
printf '%s' "<key vừa copy>" > ~/.secrets/obsidian-api-key
chmod 600 ~/.secrets/obsidian-api-key

# 2) (tuỳ chọn) export cho shell — trong ~/.secrets/opencode.env
export OBSIDIAN_API_KEY="<key vừa copy>"
```

Key riêng không cần restart service — config `{file:...}` được đọc lại khi MCP khởi động.

> API key nằm ở `.obsidian/plugins/obsidian-local-rest-api/data.json` — file này **không bao giờ commit** (vault repo local; nếu push public phải chắc chắn đã ignore `.obsidian/plugins/*/data.json`).

## 6. Verify MCP obsidian

```bash
# mở opencode → gọi thử MCP obsidian đọc 1 note (vd _Index.md)
# key sai/thiếu → xem docs/06 §MCP
```

## 7. Commit

Vault template đã ship sẵn `.gitignore` — chặn `.obsidian/plugins/*/data.json` (chứa API key), workspace state và plugin code. Kiểm tra nhanh trước khi commit:

```bash
cd ~/Documents/"<Tên vault>"
git status --short        # đảm bảo KHÔNG thấy data.json / workspace.json
git add -A && git commit -m "setup: vault + plugins"
```

---

## Ghi chú

- MCP obsidian trong config giữ đúng như máy nguồn: `npx -y obsidian-mcp-server` + env `OBSIDIAN_HOST=localhost`, `OBSIDIAN_PORT=27123`, `OBSIDIAN_VERIFY_SSL=false`.
- Vault mới = **cấu trúc + template**, không có nội dung dự án cũ. Bắt đầu bằng cách điền `01_Project/` + `_Index.md` theo hệ thống của bạn.
- `.obsidian/` trong template đã loại: `workspace.json`, `graph.json`, hotkeys, plugin code, data.json (API key).

## 8. Mở một repo đã có như vault (docs repo)

Với repo tài liệu đã tồn tại (không tạo vault mới từ skeleton):

1. Obsidian → **Open folder as vault** → chọn thư mục repo.
2. Cài **`dataview`** (bắt buộc nếu repo có dashboard `.md` dùng `dataviewjs`); **`obsidian-meta-bind-plugin`** chỉ cần khi muốn ô chọn filter.
3. Thêm vào `.gitignore` của repo:
   ```gitignore
   .obsidian/
   ```
   Cấu hình vault là của từng máy; chỉ commit nội dung note và dashboard.
4. Dashboard của repo đọc **frontmatter** của từng file, không đọc file index sửa tay. Quy ước trường (ví dụ `id`, `status`, `status_note`, `area`, `updated`) do repo đó khai trong README của nó — dashboard chỉ là lớp xem.

> Nếu repo đã có `.obsidian/` untracked từ trước, kiểm `git status` để chắc nó không bị commit.
