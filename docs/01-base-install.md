# 01 — Base Install (macOS)

> Cài đặt base tools cho máy Mac mới. Chạy theo thứ tự; verify sau mỗi nhóm.

---

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

# Optional (verify.sh: có → check, không có → SKIP, KHÔNG tính FAIL)
brew install jq                           # tiện dụng cho scripts/JSON
brew install tmux lazygit                 # git workflow đa repo — xem docs/00 §7
brew install colima docker docker-compose # container runtime (hoặc Docker Desktop / OrbStack — chọn 1)
# rustup                                  # nếu làm việc với dự án Rust
```

## P2 — opencode v2

```bash
brew update && brew install anomalyco/tap/opencode-v2
# ⚠️ formula conflicts_with "opencode" (v1) — máy mới chỉ cài v2
# Fallback: npm install -g @opencode/cli  |  curl -fsSL https://opencode.ai/v2/install | bash

opencode --version        # kỳ vọng >= 2.0.x
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

> ⚠️ Thứ tự: P3 **trước** P4 (bootstrap phủ config v2-native sạch).

## P4 — Config + skills

```bash
git clone <repo-ws-kit> ~/ws-kit        # sau khi bạn push repo lên GitHub
cd ~/ws-kit
./scripts/bootstrap-macos.sh            # flags: --skills-path, --target-dir, --dry-run
```

Bootstrap sẽ: backup `~/.config/opencode` cũ (nếu có) → copy config v2-native + agents/commands/plugins → cài 25 skills vào `~/Documents/21.AgentSkills` → `npm install` deps cho plugin local → `git init` + commit đầu cho `~/.config/opencode` và skills path (**repo local-only**, không cấu hình remote — xem docs/00 §1).

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
cd ~/ws-kit && ./scripts/new-vault.sh "<Tên vault>"
# Obsidian → Open folder as vault → chọn ~/Documents/<Tên vault>
# cài + bật 5 community plugins, bật Local REST API (port 27123), thêm key vào ~/.secrets/opencode.env
```

## P7 — Verify

```bash
cd ~/ws-kit && ./scripts/verify.sh --vault ~/Documents/"<Tên vault>"
```

Kết quả mong đợi: PASS toàn bộ, một vài WARN/SKIP hợp lệ (optional tools, chrome-devtools chưa cài Chrome).

## P8 — First run

```bash
cd ~/<repo-bất-kỳ> && opencode
# thử: /plan-custom hoặc /collect-context — kiểm tra agents/skills load
```

---

## Ghi chú version (2026-09-21)

| Tool | Version tham chiếu |
|---|---|
| opencode | v2 stable 2.0.x (`@opencode/cli` latest = 2.0.11) |
| headroom | PyPI `headroom-ai` ≥ 0.38 — cài kèm extra: `uv tool install "headroom-ai[proxy]"` |
| rtk | 0.45.0 (homebrew-core) |
| node | LTS hiện hành |
