# ws-kit

> **Template repo** — dựng workspace opencode v2 hoàn chỉnh trên máy macOS mới.
> Clone repo → đọc README → làm theo (kể cả để LLM tự chạy) → có ngay môi trường hoạt động.

---

## ws-kit gồm gì

| Thành phần | Nội dung |
|---|---|
| **opencode v2 config** | `opencode.jsonc` v2-native: providers (openrouter/commandcode/headroom/opencode-go), MCP servers, permissions, model variants |
| **Agents + Commands** | 11 agents (jack, planner, developer, impl-reviewer, code-reviewer, test-engineer, security-auditor + personas anna/bard/liuliu/rei) · 7 commands |
| **Skills** | 18 skill tự viết (discuss-task, plan-custom, test-driven-development, ...) |
| **Plugins** | 2 plugin v2-native: `rtk.ts` (shell rewrite tiết kiệm token) + `serena-reminder.ts` |
| **Tooling** | headroom (proxy + MCP) + rtk + Chrome DevTools MCP + task store TMS (MCP remote, tuỳ chọn) + tmux/lazygit (git đa repo) |
| **Vault skeleton** | Obsidian: taxonomy 00→12 + 7 template + test templates + 5 community plugins |
| **Scripts** | `bootstrap-macos.sh` (kit → máy) · `capture.sh` (máy → kit, mặc định dry-run) · `new-vault.sh` · `verify.sh` |
| **Snippets** | `zsh-ws.zsh` — helper git đa repo (lazygit + tmux: `lgall`/`wsst`) |

## Yêu cầu

macOS + Xcode Command Line Tools + Homebrew. Chi tiết: [docs/01-base-install.md](docs/01-base-install.md).

## Cài đặt (P0 → P8)

```bash
# P0 — tiền đề: brew, git identity, gh auth login, ~/.local/bin trong PATH (xem docs/01)

# P1 — base tools
brew install node uv git pnpm gh gitleaks
brew install --cask obsidian google-chrome
brew install tmux lazygit      # (khuyến nghị) git workflow đa repo — docs/00 §7

# P2 — opencode v2
brew update && brew install anomalyco/tap/opencode-v2

# P3 — headroom + rtk (⚠️ đúng thứ tự, đúng lệnh — xem docs/02)
uv tool install headroom-ai
headroom install apply --providers manual    # KHÔNG dùng `auto`/`--scope provider`
headroom doctor
which rtk || brew install rtk

# P4 — config + skills
git clone <URL-repo-này> ~/ws-kit
cd ~/ws-kit && ./scripts/bootstrap-macos.sh

# P5 — secrets + account (xem docs/04)
mkdir -p ~/.secrets && touch ~/.secrets/opencode.env && chmod 600 ~/.secrets/opencode.env
# điền keys + source trong ~/.zshenv; mở opencode → /connect

# P6 — vault (xem docs/05)
./scripts/new-vault.sh "<Tên vault>"
# Obsidian → Open folder as vault → cài 5 plugins → bật Local REST API (27123)

# P7 — verify
./scripts/verify.sh --vault ~/Documents/"<Tên vault>"

# P8 — first run
cd ~/<repo-bất-kỳ> && opencode     # thử /plan-custom
```

> 📋 Checklist đầy đủ sau khi cài: [CHECKLIST.md](CHECKLIST.md)

## Giữ kit đồng bộ với máy

`bootstrap-macos.sh` chạy một chiều kit → máy. Khi bạn sửa agent/skill ngay trên máy, dùng chiều ngược lại:

```bash
./scripts/capture.sh            # dry-run: xem sẽ đổi gì
./scripts/capture.sh --apply    # ghi thật vào kit
cd ../<kit> && git diff --stat  # review rồi mới commit
```

- Hoàn toàn không sync: `opencode/AGENTS.md` (kit là template placeholder), `opencode.jsonc`, `cli.json`, `package.json`, `vault-template/`, `docs/`.
- Skill cá nhân, không muốn lên kit: thêm tên vào `.kitignore`.
- `capture.sh` mặc định **không xoá** skill trong kit mà máy không có; thêm `--prune-skills` nếu muốn xoá theo máy.

## Cấu trúc repo

```text
ws-kit/
├─ README.md / CHECKLIST.md / LICENSE
├─ docs/                    # 00→06: conventions, install, headroom, config, secrets, vault, troubleshooting
├─ opencode/                # → copy vào ~/.config/opencode (bootstrap lo phần này)
│  ├─ opencode.template.jsonc   # config v2-native (đổi tên → opencode.jsonc khi cài)
│  ├─ cli.json                  # TUI plugin (oc-tps)
│  ├─ AGENTS.md                 # hướng dẫn global (bản sạch)
│  ├─ package.json              # dependency @opencode/plugin (cho plugin local)
│  ├─ agents/                   # 11 agents + references/ (3 checklist)
│  ├─ commands/                 # 7 commands
│  └─ plugins/                  # rtk.ts + serena-reminder.ts (v2-native)
├─ skills/                  # 18 skills → cài vào ~/Documents/21.AgentSkills
├─ vault-template/          # skeleton vault → new-vault.sh copy ra ~/Documents
├─ snippets/                # zsh-ws.zsh — helper git đa repo (lgall/wsst)
└─ scripts/                 # bootstrap-macos.sh · capture.sh · new-vault.sh · verify.sh
```

## Quyết định thiết kế quan trọng

- **v2-native 100%** — không copy config v1; không dựa vào migrate tự động của client.
- **`codemode: false`** cho cả 5 MCP server — giữ tools native (`serena_*`, `obsidian_*`) như v1; plugin serena-reminder + agents hoạt động đúng. Lý do chi tiết: [docs/03 §Code Mode](docs/03-opencode-config.md).
- **Headroom chỉ daemon/proxy** — không để headroom ghi config opencode (nó ghi format v1). Xem [docs/02](docs/02-headroom.md).
- **rtk instructions là tùy chọn** — opencode v2 không tự thêm block hướng dẫn rtk vào AGENTS.md; snippet có trong [docs/02 §4](docs/02-headroom.md).
- **Không secret trong repo** — config dùng `{env:VAR}`; giá trị ở `~/.secrets/opencode.env`.
- **Bootstrap luôn backup** — config cũ rename thành `~/.config/opencode.backup-<timestamp>`; skills path có dữ liệu được backup-copy `<skills-path>.backup-<timestamp>` trước khi merge.
- **Git repo local-only cho config/skills/vault** — bootstrap (config/skills) + `new-vault.sh` (vault) tự `git init` + commit đầu; **không** cấu hình remote (muốn backup thì tự thêm remote private).
- **Git đa repo: tmux + lazygit** — session `repos`, mỗi repo 1 window chạy lazygit; snippet `snippets/zsh-ws.zsh` (`lgall`/`wsst`) copy vào `~/.zshrc`; opencode chạy riêng.
- **Model refs**: kit pin `opencode-go/deepseek-v4.1-flash` (OpenCode Go subscription). Nếu dùng provider khác → **remap model refs là bắt buộc** (xem [docs/04](docs/04-secrets.md) §3).

## Docs

| File | Nội dung |
|---|---|
| [docs/00-workspace-conventions.md](docs/00-workspace-conventions.md) | Quy ước workspace: repo layout, worktree, tài liệu, vault |
| [docs/01-base-install.md](docs/01-base-install.md) | Cài base tools + opencode v2 |
| [docs/02-headroom.md](docs/02-headroom.md) | Headroom daemon + rtk + snippet rtk-instructions |
| [docs/03-opencode-config.md](docs/03-opencode-config.md) | Giải thích config v2 + variants + Code Mode |
| [docs/04-secrets.md](docs/04-secrets.md) | Secrets + account connect |
| [docs/05-vault-setup.md](docs/05-vault-setup.md) | Obsidian + 5 plugins + MCP |
| [docs/06-troubleshooting.md](docs/06-troubleshooting.md) | Log paths, rollback, lỗi thường gặp |
| [docs/07-task-store.md](docs/07-task-store.md) | Task store qua MCP `tms` (tuỳ chọn): 6 tool · key · đường ghi/đọc · lỗi |

## License

[MIT](LICENSE)
