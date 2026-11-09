# ws-kit

> **Nguồn chuẩn của skill + cách dựng một workspace chuẩn** (opencode, Obsidian, task store).
> Kit **không cài gì lên máy bạn**: nó chứa skill, hướng dẫn và ví dụ. Máy mới đọc rồi tự dựng — hoặc để agent đọc và dựng.

---

## Kit chứa gì

| Thành phần | Kit cho gì |
|---|---|
| **Skills** | 18 skill (`discuss-*`, `plan-custom`, `test-driven-development`, `to-test-scenario`…) — bản generic, không gắn dự án |
| **Hướng dẫn** | `docs/00` → `docs/07`: workspace convention, cài base tools, headroom, config, secrets, vault, troubleshooting, task store |
| **Ví dụ tham chiếu** | `docs/examples/opencode.jsonc` (config) + `docs/examples/opencode/` (agents · commands · plugins · references · `cli.json` · `package.json`) — **để đọc, không để cài** |
| **Vault skeleton** | `vault-template/`: taxonomy 00→12 + templates + `.obsidian` config |
| **Script** | `scripts/new-vault.sh` — tạo vault mới từ `vault-template/` |
| **Snippets** | `snippets/zsh-ws.zsh` — helper git đa repo (lazygit + tmux: `lgall`/`wsst`) |

## Workspace chuẩn cần gì

Kit **nêu** danh sách; cách đưa từng thứ lên máy là việc của bạn (hoặc agent). Không có lệnh cài chung, không quy định đường dẫn trên máy.

| Cần | Để làm gì |
|---|---|
| opencode | runtime |
| Config (`opencode.jsonc`) | providers · MCP servers · permissions · skills path |
| `agents/` · `commands/` | agent + slash command |
| `plugins/` (+ deps) | `rtk.ts` (tiết kiệm token) · `serena-reminder.ts` |
| `references/` | checklist mà agent đọc khi cần |
| `AGENTS.md` | hướng dẫn global cho LLM |
| Skills | bộ skill dùng chung |
| Vault | nơi làm việc, tài liệu dự án |
| Tool ngoài | `brew` · `uv` · `pnpm` · `gh` (và tuỳ chọn: `tmux`, `lazygit`, `jq`, `gitleaks`) |

Chi tiết từng mục + cách tự kiểm: [docs/01-base-install.md](docs/01-base-install.md). Tick theo [CHECKLIST.md](CHECKLIST.md).

## Bắt đầu

1. Đọc [docs/00-workspace-conventions.md](docs/00-workspace-conventions.md) — quy ước workspace.
2. Cài base tools + opencode: [docs/01](docs/01-base-install.md) · headroom + rtk: [docs/02](docs/02-headroom.md).
3. Viết config của bạn — mở [docs/examples/opencode.jsonc](docs/examples/opencode.jsonc) để xem hình dạng, đọc [docs/03](docs/03-opencode-config.md) để biết cần khối nào và vì sao. **Không copy nguyên file** — nó gắn với provider/model của người viết.
4. Secrets: [docs/04](docs/04-secrets.md). Vault: [docs/05](docs/05-vault-setup.md) (+ `./scripts/new-vault.sh "<Tên vault>"`).
5. Task store qua MCP (tuỳ chọn): [docs/07](docs/07-task-store.md).
6. Chạy `opencode` trong một repo → kiểm agent/skill nạp đúng.

## Dùng skill của kit

Skill trong `skills/` là **nguồn chuẩn**. Không cần chép ra chỗ khác: khai thẳng đường dẫn thư mục skill trong clone vào mảng `skills` của config, ví dụ:

```jsonc
"skills": ["<đường-dẫn-clone>/skills"]
```

Kit sửa thì máy thấy ngay — không có bản sao để lệch. Skill riêng của máy/dự án để ở thư mục khác, thêm một phần tử nữa vào mảng. Kit không quản thư mục skill riêng của bạn.

## Cấu trúc repo

```text
ws-kit/
├─ README.md / CHECKLIST.md / LICENSE
├─ docs/
│  ├─ 00…07                # hướng dẫn setup + quy ước
│  └─ examples/            # VÍ DỤ THAM CHIẾU — để đọc, không để cài
│     ├─ opencode.jsonc
│     └─ opencode/         # agents/ commands/ plugins/ references/ cli.json package.json AGENTS.md
├─ skills/                 # 18 skill — bản generic, không gắn dự án
├─ vault-template/         # skeleton vault → new-vault.sh copy ra ngoài
├─ snippets/               # zsh-ws.zsh — helper git đa repo (lgall/wsst)
└─ scripts/                # new-vault.sh
```

## Nguyên tắc thiết kế

- **Kit là chuẩn, không phải bản sao của một máy.** Sửa skill/agent/template là sửa trong repo này; máy đọc lại từ đây.
- **Không ship config cho một phiên bản opencode.** Kit cam kết mọi phiên bản: nó nói *cần khối nào* và *kiểm ra sao*, hình dạng cụ thể nằm ở `docs/examples/`. Không pin version, không kiểm version.
- **Không script cài đặt.** Máy mới đi theo docs; mỗi lệnh kèm bước kiểm ngay sau (`--version`, `--help`), lệnh fail thì đọc docs upstream của tool chứ không đoán. Script cứng chết lặng lẽ khi tool đổi cách cài; docs thì sửa một dòng.
- **Skill dùng chung phải generic.** Đường dẫn repo, ví dụ riêng của dự án thuộc tài liệu của dự án đó (`AGENTS.md`), không nằm trong skill của kit.
- **Không secret trong repo** — dùng `{env:VAR}` / `{file:path}`, giá trị để ở `~/.secrets/`.
- **`docs/examples/` chỉ để đọc.** Không copy vào máy rồi quên: config của bạn là của bạn.

## Docs

| File | Nội dung |
|---|---|
| [docs/00-workspace-conventions.md](docs/00-workspace-conventions.md) | Quy ước workspace: repo layout, worktree, tài liệu, vault |
| [docs/01-base-install.md](docs/01-base-install.md) | Workspace cần gì · base tools · opencode |
| [docs/02-headroom.md](docs/02-headroom.md) | Headroom daemon + rtk + snippet rtk-instructions |
| [docs/03-opencode-config.md](docs/03-opencode-config.md) | Config cần khối nào, vì sao, kiểm ra sao |
| [docs/04-secrets.md](docs/04-secrets.md) | Secrets + account connect |
| [docs/05-vault-setup.md](docs/05-vault-setup.md) | Obsidian + 5 plugins + MCP |
| [docs/06-troubleshooting.md](docs/06-troubleshooting.md) | Log paths, rollback, lỗi thường gặp |
| [docs/07-task-store.md](docs/07-task-store.md) | Task store qua MCP `tms` (tuỳ chọn): 6 tool · đọc/ghi theo mục · key · đường ghi/đọc · lỗi |

## License

[MIT](LICENSE)
