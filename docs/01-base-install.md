# 01 — Workspace cần gì & cài base tools

> Máy Mac mới: đọc mục 1 để biết workspace cần những gì, rồi cài từng nhóm và tự kiểm ngay sau mỗi nhóm.
> Kit không có script cài: mỗi lệnh fail thì đọc `--help` / docs upstream của tool, **không đoán**.

---

## 1. Workspace chuẩn cần gì

| Thành phần | Để làm gì | Tự kiểm bằng |
|---|---|---|
| opencode | runtime | `opencode --version` |
| Config (`opencode.jsonc`) | providers · MCP · permissions · skills path | `opencode` khởi động không lỗi parse |
| `agents/` · `commands/` | agent + slash command | trong opencode, gọi agent thử |
| `plugins/` + deps | tiết kiệm token · nhắc serena | `opencode plugin list` |
| `references/` | checklist agent đọc khi cần | agent đọc được file |
| `AGENTS.md` | hướng dẫn global cho LLM | agent nhắc lại được rule trong đó |
| Skills | bộ skill dùng chung | skill hiện trong danh sách |
| Vault | tài liệu dự án | Obsidian mở được |
| Tool ngoài | `brew` · `uv` · `pnpm` · `gh` | `--version` từng tool |

Hình dạng cụ thể của config và các thư mục thành phần: `docs/examples/` — **đọc để tham khảo, không copy**. Bản của bạn do bạn viết, khớp provider/model bạn dùng.

## P0 — Tiền đề

```bash
# 1. Xcode Command Line Tools + Homebrew (nếu chưa có)
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Git identity
git config --global user.name "<Tên bạn>"
git config --global user.email "<email>"

# 3. GitHub auth (dùng cho clone/PR)
gh auth login

# 4. Thêm ~/.local/bin vào PATH (uv cài tool ở đây) — thêm vào ~/.zshenv:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshenv
```

## P1 — Base tools

```bash
# Core (bắt buộc)
brew install node uv git pnpm gh gitleaks
brew install --cask obsidian
brew install --cask google-chrome        # cần cho MCP chrome-devtools
# python3: dùng bản hệ thống hoặc brew install python@3.13 (dự án Python dùng venv riêng)
# Ghi chú: formula opencode-v2 tự kéo ripgrep — không cài riêng

# Tuỳ chọn
brew install jq                           # tiện dụng cho scripts/JSON
brew install tmux lazygit                 # git workflow đa repo — xem docs/00 §7
brew install colima docker docker-compose # container runtime (hoặc Docker Desktop / OrbStack — chọn 1)
# rustup                                  # nếu làm việc với dự án Rust
```

Kiểm ngay sau khi cài: `brew --version`, `uv --version`, `pnpm --version`, `node --version`.

## P2 — opencode

```bash
brew update && brew install anomalyco/tap/opencode-v2
# ⚠️ formula conflicts_with "opencode" (v1) — máy mới chỉ cài v2
# Fallback: npm install -g @opencode/cli  |  curl -fsSL https://opencode.ai/<phiên-bản>/install | bash

opencode --version        # in ra được version
opencode debug paths      # in path config/data/log
```

## P3 — headroom + rtk

Xem chi tiết: `docs/02-headroom.md`

```bash
uv tool install headroom-ai
headroom install apply --providers manual   # KHÔNG để auto-detect ghi config tool
headroom doctor
which rtk || brew install rtk
```

> ⚠️ Làm P3 **trước** khi viết config: config trỏ provider `headroom` ở `http://127.0.0.1:8787/v1`.

## P4 — Config + thành phần agent

Không có bước cài sẵn. Việc của bạn (hoặc agent) là đưa những thứ ở mục 1 vào chỗ opencode đọc:

- **Config**: tự viết theo `docs/03` (cần khối nào, vì sao) và mở `docs/examples/opencode.jsonc` để xem hình dạng.
- **Agent · command · plugin · references**: `docs/examples/opencode/` là ví dụ nội dung; khai/đặt theo cách opencode của bạn đọc (xem `docs/03` §5).
- **Plugin deps**: trong thư mục plugin, cài deps của `package.json` rồi kiểm:

```bash
cd <thư-mục-plugin> && npm install && node -e "require.resolve('@opencode/plugin')" && echo OK
```

Lệnh fail → đọc lỗi của `npm`, đối chiếu `package.json`, không tự đoán version.

- **Skills**: khai đường dẫn thư mục skill trong clone kit vào mảng `skills` của config; không copy.

Kiểm: `opencode` khởi động được, `opencode plugin list` thấy plugin, skill hiện trong danh sách.

## P5 — Secrets + account

Xem chi tiết: `docs/04-secrets.md`

```bash
mkdir -p ~/.secrets && touch ~/.secrets/opencode.env && chmod 600 ~/.secrets/opencode.env
# điền các biến (OPENROUTER_API_KEY, COMMANDCODE_API_KEY, OBSIDIAN_API_KEY...)
# thêm vào ~/.zshenv:  [ -f ~/.secrets/opencode.env ] && source ~/.secrets/opencode.env
exec zsh                                # nạp lại shell
# mở opencode → /connect để kết nối account (vd OpenCode Go)
```

## P6 — Vault

Xem chi tiết: `docs/05-vault-setup.md`

```bash
cd <clone-kit> && ./scripts/new-vault.sh "<Tên vault>"
# Obsidian → Open folder as vault → chọn thư mục vault vừa tạo
# cài + bật 5 community plugins, bật Local REST API (port 27123), thêm key vào chỗ cấu hình dùng
```

## P7 — Đối chiếu

Mở [CHECKLIST.md](../CHECKLIST.md) và tick từng dòng — mỗi dòng có cách tự kiểm riêng. Không có script kiểm tổng: kit chỉ nêu thành phần, máy bạn tự xác nhận.

## P8 — First run

```bash
cd <repo-bất-kỳ> && opencode
# thử: /plan-custom — kiểm tra agents/skills load
```

---

## Ghi chú phiên bản (tham khảo, không ràng buộc)

Đã chạy thử ngày 2026-09-21: opencode 2.0.x · headroom ≥ 0.38 (`uv tool install "headroom-ai[proxy]"`) · rtk 0.45.0 · node LTS.

Đây là ghi chú để tra khi lệnh lạ, **không phải** mức tối thiểu bắt buộc. Tool đổi cách cài thì đọc docs upstream của tool đó.
