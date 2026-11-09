# 02 — Headroom + rtk

> Headroom = proxy tiết kiệm token (compress tool output) + MCP retrieve.
> Headroom **chỉ chạy daemon/proxy**. Không để nó ghi config opencode (nó ghi dạng cũ) — config do bạn viết, xem `docs/03`.

---

## 1. Cài đặt

```bash
uv tool install "headroom-ai[proxy]"
#   ^ headroom-ai >= 0.38 tách proxy deps vào extra [proxy].
#     Thiếu extra → proxy không start được:
#       "Error: Proxy dependencies not installed. Run: pip install headroom-ai[proxy]"
#     và `headroom install apply` báo: Deployment 'default' did not become ready after start.
```

## 2. Deploy daemon (BẮT BUỘC đúng cách)

```bash
headroom install apply --providers manual
#   ^ --providers manual: chặn auto-detect ghi config tool (default `auto` sẽ tự
#     detect opencode đã cài và ghi config theo format V1 — KHÔNG dùng được cho v2)
headroom doctor
```

Verify:

```bash
headroom install status          # profile default, proxy port 8787
curl -s http://127.0.0.1:8787/health
```

## 3. ⚠️ Các lệnh KHÔNG được chạy (ghi format V1)

Headroom hiện viết config opencode theo **format V1** (`mcp.<tên>` + `"enabled": true`; provider npm `@ai-sdk/openai-compatible`) — không chạy được với opencode v2:

- ❌ `headroom mcp install` (cho opencode)
- ❌ `headroom install apply --scope provider`
- ❌ `headroom wrap opencode` (ngoài việc ghi config v1, còn inject block rtk — xem §4)

> Nếu sau này chạy lệnh headroom có ghi config → kiểm tra lại: `grep '"enabled"\|@ai-sdk' ~/.config/opencode/opencode.jsonc`
> Thứ tự đúng: **P3 (headroom) TRƯỚC khi viết config** — config trỏ provider `headroom` ở `http://127.0.0.1:8787/v1`.

## 4. rtk instructions (TÙY CHỌN — thêm riêng)

**Bối cảnh:** opencode v2 **không tự thêm** block "rtk instructions" vào `~/.config/opencode/AGENTS.md`. Block này giúp LLM chủ động prefix `rtk` cho mọi lệnh shell (tiết kiệm token 60–90%). Trước đây block được thêm bởi `headroom wrap opencode` — lệnh này KHÔNG có trong flow cài đặt (xem §3).

**Muốn dùng?** Copy block dưới vào `~/.config/opencode/AGENTS.md` (thêm riêng, thủ công):

```markdown
<!-- headroom:rtk-instructions -->
# RTK (Rust Token Killer) - Token-Optimized Commands

When running shell commands, **always prefix with `rtk`**. This reduces context
usage by 60-90% with zero behavior change. If rtk has no filter for a command,
it passes through unchanged — so it is always safe to use.

## Key Commands
```bash
# Git (59-80% savings)
rtk git status          rtk git diff            rtk git log

# Files & Search (60-75% savings)
rtk ls <path>           rtk read <file>         rtk grep <pattern>
rtk find <pattern>      rtk diff <file>

# Test (90-99% savings) — shows failures only
rtk pytest tests/       rtk cargo test          rtk test <cmd>

# Build & Lint (80-90% savings) — shows errors only
rtk tsc                 rtk lint                rtk cargo build
rtk prettier --check    rtk mypy                rtk ruff check

# Analysis (70-90% savings)
rtk err <cmd>           rtk log <file>          rtk json <file>
rtk summary <cmd>       rtk deps                rtk env

# GitHub (26-87% savings)
rtk gh pr view <n>      rtk gh run list         rtk gh issue list

# Infrastructure (85% savings)
rtk docker ps           rtk kubectl get         rtk docker logs <c>

# Package managers (70-90% savings)
rtk pip list            rtk pnpm install        rtk npm run <script>
```

## Rules
- In command chains, prefix each segment: `rtk git add . && rtk git commit -m "msg"`
- For debugging, use raw command without rtk prefix
- `rtk proxy <cmd>` runs command without filtering but tracks usage
<!-- /headroom:rtk-instructions -->
```

> **Lưu ý:** plugin `rtk.ts` (trong kit) đã tự động rewrite shell command qua rtk — block trên là lớp bổ sung giúp LLM chủ động dùng rtk (kể cả khi hook không áp dụng, ví dụ trong nội dung prompt). Hai cơ chế không xung đột (rewrite idempotent).

## 5. rtk

```bash
which rtk || brew install rtk
rtk --version
```

Plugin `rtk.ts` (trong `docs/examples/opencode/plugins/`) tự load khi đặt vào thư mục plugin của client — rewrite mọi shell command qua `rtk rewrite`.
