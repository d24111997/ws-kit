# 03 — opencode Config (v2-native)

> Giải thích config `opencode.jsonc` trong kit — **render v2-native**, không dựa vào cơ chế migrate của v1.
> Tham chiếu docs: https://opencode.ai/v2/docs/config

---

## 1. Vị trí file

| File | Vị trí sau bootstrap | Vai trò |
|---|---|---|
| `opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | Config chính (providers, MCP, permissions, skills...) |
| `cli.json` | `~/.config/opencode/cli.json` | TUI plugins (oc-tps) |
| `AGENTS.md` | `~/.config/opencode/AGENTS.md` | Hướng dẫn global cho LLM |
| `agents/`, `commands/`, `plugins/`, `references/` | `~/.config/opencode/` | Auto-discovery — không cần khai báo |

v2 chỉ đọc `AGENTS.md` (không fallback `CLAUDE.md`); field `instructions` trong config là **inert** (được nhận nhưng không load).

> Lưu ý `$schema`: giá trị `https://opencode.ai/config.json` giữ theo docs v2 — nhưng schema public hiện có thể **trễ hơn v2**, nên editor có thể gạch đỏ các key v2 (`providers`, `permissions`, `mcp.servers`, `codemode`...). Nếu gặp: tạm tắt validation cho file này — **đừng "sửa ngược" về format v1**.

## 2. Các key chính trong config

### Model + default agent

```jsonc
"model": "opencode-go/deepseek-v4.1-flash",
"default_agent": "jack",
```

- Model refs dạng `provider/model` (+ `#variant` khi agent/command chọn variant).
- `opencode-go` đến từ **account connect** (`/connect` → OpenCode Go). Nếu dùng provider khác → đổi refs (xem `docs/04-secrets.md`).

### Providers

| Provider | Package | Ghi chú |
|---|---|---|
| `openrouter` | (catalog native) | secret `OPENROUTER_API_KEY`; model DeepSeek V4 alias + reasoning |
| `commandcode` | `@opencode/ai/providers/openai-compatible` | secret `COMMANDCODE_API_KEY`; baseURL riêng |
| `headroom` | `@opencode/ai/providers/openai-compatible` | proxy local `http://127.0.0.1:8787/v1` |
| `opencode-go` | (account) | chỉ override `models.variants` — xem §3 |

Mapping từ v1: `npm` → `package`; `options.apiKey` inline → `env: ["VAR"]`; `options.baseURL` → `settings.baseURL`; model `id` → `modelID`; `interleaved` → `compatibility.reasoningField`; `reasoningEffort` → `settings.reasoningEffort`; `thinking` → `body.thinking`.

### Skills

```jsonc
"skills": ["~/Documents/21.AgentSkills"],
```

- Hỗ trợ `~/` path; bootstrap tự cập nhật nếu bạn dùng `--skills-path` khác.
- Ngoài ra v2 auto-discover `~/.config/opencode/skills/` — kit không dùng chỗ này (giữ skills tập trung 1 nơi).

### Permissions

v2 dùng **mảng rule** `{action, resource, effect}`, last-match-wins; `bash` đổi tên thành `shell`:

```jsonc
"permissions": [
  { "action": "shell", "resource": "git commit *", "effect": "ask" },
  { "action": "shell", "resource": "git push *", "effect": "deny" }
]
```

- Base policy mặc định của v2: allow-all + `external_directory: ask` + `.env` reads ask.
- Action list: `read`, `edit`, `glob`, `grep`, `shell`, `subagent`, `skill`, `question`, `webfetch`, `websearch`, `external_directory`, `<server>_<tool>`, `execute`.
- Agents có thể khai báo `permissions` riêng trong frontmatter (vd 4 subagent reviewer có `edit: ask`).

### MCP servers

```jsonc
"mcp": { "servers": { "<tên>": { "type": "local", "command": [...], "codemode": false } } }
```

- `enabled: true` (v1) → bỏ field; muốn tắt → `disabled: true`.
- `{env:VAR}` dùng được trong `environment`/`headers`; `{file:path}` dùng được cùng chỗ — kit dùng `{file:}` cho key vì service có thể spawn không có env (docs/04 §2).
- 5 server trong kit: `tms` (remote HTTPS + `Authorization` từ `~/.secrets/tms-api-key`), `obsidian` (npx obsidian-mcp-server + env), `chrome-devtools` (npx + autoConnect), `headroom` (PATH-based), `serena` (uvx + `--open-web-dashboard False`).
- `tms` là server duy nhất cần **một instance thật** phía server: kit ship hình dạng config, không ship task store. Không có instance → để `disabled: true` hoặc bỏ block, và bỏ 3 skill `discuss-*` khỏi `21.AgentSkills` (chúng gọi `task_get`/`decision_record`). Xem `docs/07-task-store.md`.
- Đường ghi và đường đọc là hai endpoint khác nhau: ghi ở `/write/mcp` (bearer key), đọc SQL thô ở `/sse` + `/messages/`. Đừng thêm tiền tố `/read/` — sẽ `404`.

## 3. Model variants (reasoning + temperature)

6 subagent cần reasoning config (như v1). v2 không còn `temperature`/`reasoningEffort` trong agent frontmatter → chuyển thành **variants** trên model:

```jsonc
"opencode-go": {
  "models": {
    "deepseek-v4.1-flash": {
      "variants": [
        { "id": "high",      "settings": { "reasoningEffort": "high" }, "body": { "thinking": {"type":"enabled","budgetTokens":32000}, "temperature": 0.2 } },
        { "id": "high-warm", "settings": { "reasoningEffort": "high" }, "body": { "thinking": {"type":"enabled","budgetTokens":32000}, "temperature": 0.3 } },
        { "id": "warm",      "body": { "temperature": 0.3 } },
        { "id": "creative",  "body": { "temperature": 0.4 } }
      ]
    }
  }
}
```

| Variant | Agent dùng |
|---|---|
| `#high` | planner, impl-reviewer, code-reviewer, test-engineer, security-auditor |
| `#high-warm` | developer |
| `#warm` | jack, anna, bard, liuliu |
| `#creative` | rei |

> ⚠️ Verify trên máy mới: nếu provider `opencode-go` không nhận model override → kiểm tra bằng cách chạy 1 agent có variant. `thinking` key là provider-specific — nếu không được nhận, chỉ `reasoningEffort` vẫn hoạt động.

## 4. Code Mode — vì sao `codemode: false`

**Code Mode** (mặc định ON trong v2): thay vì expose từng MCP tool riêng lẻ, v2 gom tools của mỗi server sau **1 tool `execute`** — model viết JS giới hạn, gọi tools qua `tools.<server>.<tool>(...)`, chỉ trả kết quả cuối về context (tiết kiệm context).

**Vì sao kit tắt (`codemode: false`) cho cả 4 server:**

1. **Agents hiện tại reference tool trực tiếp** (`serena_find_symbol`, `obsidian_*`) — dưới Code Mode phải viết JS trong `execute` → sai cách gọi.
2. **Plugin `serena-reminder`** đếm tool call theo tên (`serena_*`, `read`, `grep`) — dưới Code Mode chỉ thấy tool `execute` → plugin vô hiệu.
3. Parity với hành vi v1 → mọi agent/plugin hoạt động đúng như thiết kế.

> Muốn thử Code Mode: xoá `"codemode": false` của server tương ứng. Chấp nhận phải cập nhật lại cách agents gọi tool.

## 5. Agents / Commands / Plugins (auto-discovery)

- Agents: `~/.config/opencode/agents/*.md` — frontmatter v2 (`description`, `mode`, `model` (+`#variant`), `permissions`, `steps`...). **KHÔNG dùng** `temperature`, `top_p`, `prompt`, `permission` (object), `tools`, `disable`, `maxSteps` (legacy v1).
- Commands: `~/.config/opencode/commands/*.md` — frontmatter: `description`, `agent`, `model`, `subagent`.
> Ghi chú `subagent` tool (v2): param key (`agent`, `description`, `prompt`, `sessionID`) được suy luận từ docs prose — nên xác nhận 1 lần trên máy v2 thật (`opencode` TUI: hỏi agent spawn thử 1 subagent).

- Plugins local: `~/.config/opencode/plugins/*.ts` — **auto-discovered**; viết theo API v2: `Plugin.define({id, setup})` + `ctx.tool.hook(...)` / `ctx.shell.hook(...)`, import từ `@opencode/plugin`. Kit ship 2 plugin đã port v2 (`rtk.ts`, `serena-reminder.ts`).

## 6. Verify

```bash
opencode --version            # >= 2.0.x
opencode service status
opencode mcp list             # obsidian / serena / headroom / chrome-devtools
opencode plugin list          # rtk / serena-reminder
opencode debug paths          # log ~/.local/share/opencode/log/opencode.log ...
```

Check không lẫn format v1:

```bash
grep '"enabled"\|@ai-sdk' ~/.config/opencode/opencode.jsonc   # kỳ vọng: không có kết quả
```

## 7. Known trade-offs (có ý thức)

- **Supply chain unpinned:** `npx -y obsidian-mcp-server` (không pin version), `chrome-devtools-mcp@latest`, `uvx ... git+https://github.com/oraios/serena` (branch mặc định), `oc-tps@latest` — luôn chạy bản mới nhất của bên thứ ba. Muốn chặt hơn: pin version/tag cụ thể trong config + `cli.json`.
- **`OBSIDIAN_VERIFY_SSL: "false"`** — bỏ TLS verify cho Local REST API (chỉ dùng trên localhost; nếu đổi host thì bật lại).
- **Permissions base = allow-all** (mặc định của v2) + 5 rule hạn chế git/ssh. Muốn chặt hơn: thêm `deny` cho lệnh phá huỷ phổ biến (`rm -rf /*`, `curl * | sh`) và `ask` cho `gh pr create` / `gh release`.
