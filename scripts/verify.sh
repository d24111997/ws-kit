#!/usr/bin/env bash
# ws-kit — verify workspace (opencode v2-native)
#
# Cách dùng:
#   ./scripts/verify.sh [--vault <path-vault>]
#
# Ghi chú:
#   - Optional tools (jq/lazygit/colima/tmux...) không có → SKIP, không tính FAIL.
#   - chrome-devtools cần Google Chrome → thiếu thì WARN, không FAIL toàn bộ.
set -uo pipefail

PASS=0; FAIL=0; WARN=0
ok()   { printf '\033[1;32m PASS\033[0m %s\n' "$*"; PASS=$((PASS+1)); }
bad()  { printf '\033[1;31m FAIL\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }
warn() { printf '\033[1;33m WARN\033[0m %s\n' "$*"; WARN=$((WARN+1)); }
skip() { printf '\033[1;34m SKIP\033[0m %s\n' "$*"; }

VAULT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --vault)
      if [ "$#" -lt 2 ]; then echo "Thiếu giá trị cho --vault"; exit 1; fi
      case "$2" in -*) echo "Giá trị không hợp lệ cho --vault: $2"; exit 1 ;; esac
      VAULT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

CONF="$HOME/.config/opencode/opencode.jsonc"

echo "── opencode ──────────────────────────────────────────"
if command -v opencode >/dev/null 2>&1; then
  V="$(opencode --version 2>/dev/null | head -1)"
  VN="$(printf '%s' "$V" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  case "$VN" in
    2.*) ok "opencode $V" ;;
    *)   warn "opencode version '$V' — kỳ vọng >= 2.0.x" ;;
  esac
  opencode service status >/dev/null 2>&1 && ok "opencode service status OK" || warn "opencode service chưa chạy (sẽ tự chạy khi mở opencode)"
else
  bad "opencode không có trong PATH → brew install anomalyco/tap/opencode-v2"
fi

echo "── config ────────────────────────────────────────────"
if [ -f "$CONF" ]; then
  ok "config tồn tại: $CONF"
  if grep -qE '"enabled"[[:space:]]*:' "$CONF" 2>/dev/null; then bad "config còn key v1 'enabled'"; else ok "config không lẫn key v1 'enabled'"; fi
  if grep -q '@ai-sdk' "$CONF" 2>/dev/null; then bad "config còn npm v1 '@ai-sdk'"; else ok "config không lẫn '@ai-sdk'"; fi
  if grep -q '"codemode": false' "$CONF" 2>/dev/null || grep -q '"codemode":false' "$CONF" 2>/dev/null; then
    ok "codemode: false có trong config"
  else
    warn "thiếu codemode: false — MCP tools sẽ chạy qua Code Mode"
  fi
else
  bad "thiếu $CONF → chạy scripts/bootstrap-macos.sh"
fi

echo "── skills ────────────────────────────────────────────"
if [ -d "$HOME/Documents/21.AgentSkills" ]; then
  N="$(find "$HOME/Documents/21.AgentSkills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  ok "skills path tồn tại ($N skill)"
else
  bad "thiếu skills path ~/Documents/21.AgentSkills → chạy bootstrap"
fi

echo "── references ────────────────────────────────────────"
if [ -d "$HOME/.config/opencode/references" ]; then
  R="$(ls "$HOME/.config/opencode/references"/*.md 2>/dev/null | wc -l | tr -d ' ')"
  ok "references có $R checklist"
else
  bad "thiếu ~/.config/opencode/references → chạy lại bootstrap"
fi

echo "── MCP + plugins ─────────────────────────────────────"
if command -v opencode >/dev/null 2>&1; then
  # `opencode mcp list` trả lời qua background service. Ngay sau khi đổi config
  # (hoặc khi service đang restart) lệnh trả về "No MCP servers configured" dù MCP
  # vẫn chạy bình thường → check sẽ báo FAIL sai. Thử lại trước khi kết luận.
  MCP=""
  for _ in 1 2 3; do
    MCP="$(opencode mcp list 2>/dev/null || true)"
    printf '%s' "$MCP" | grep -qiE 'connected|disabled|disconnected' && break
    sleep 2
  done
  if ! printf '%s' "$MCP" | grep -qiE 'connected|disabled|disconnected'; then
    warn "không đọc được danh sách MCP (service đang khởi động?) — bỏ check MCP, xem lại: opencode mcp list"
    MCP="SKIP_NO_LIST"
  fi
  for s in obsidian serena headroom chrome-devtools tms; do
    [ "$MCP" = "SKIP_NO_LIST" ] && break
    MCPLINE="$(printf '%s\n' "$MCP" | grep -E " +$s +" | head -1)"
    if printf '%s' "$MCPLINE" | grep -qi "connected"; then
      ok "mcp: $s connected"
    elif [ "$s" = "chrome-devtools" ]; then
      warn "mcp: chrome-devtools chưa kết nối (cần Google Chrome đã cài)"
    elif [ "$s" = "obsidian" ]; then
      warn "mcp: obsidian không bật — kit không dùng (agent đọc vault bằng filesystem)"
    elif [ "$s" = "tms" ] && [ -z "$MCPLINE" ]; then
      warn "mcp: tms không khai trong config — bỏ qua (task store tuỳ chọn, docs/07)"
    elif [ "$s" = "tms" ]; then
      warn "mcp: tms chưa kết nối (kiểm key + url — docs/07 §5)"
    else
      bad "mcp: $s chưa kết nối (xem: opencode mcp list)"
    fi
  done
  PL="$(opencode plugin list 2>/dev/null || true)"
  if echo "$PL" | grep -qi "rtk\|serena"; then
    ok "plugin local có trong danh sách (rtk / serena-reminder)"
  else
    warn "chưa thấy plugin local — kiểm tra node_modules/@opencode/plugin trong ~/.config/opencode"
  fi
fi
[ -f "$HOME/.config/opencode/cli.json" ] && ok "cli.json tồn tại (oc-tps)" || warn "thiếu cli.json (plugin TUI oc-tps)"

echo "── headroom + rtk ────────────────────────────────────"
if command -v headroom >/dev/null 2>&1; then
  # headroom doctor trả exit≠0 cả khi chỉ có warning (0 failure, N warning) → không
  # được coi exit code là FAIL. Đọc dòng tổng kết "X failure(s), Y warning(s)".
  HD="$(headroom doctor 2>&1 || true)"
  HD_FAIL="$(printf '%s\n' "$HD" | grep -oE '[0-9]+ failure' | tail -1 | grep -oE '[0-9]+')"
  HD_WARN="$(printf '%s\n' "$HD" | grep -oE '[0-9]+ warning' | tail -1 | grep -oE '[0-9]+')"
  if [ -z "$HD_FAIL" ]; then
    warn "headroom doctor không đọc được kết quả — chạy 'headroom doctor' để xem"
  elif [ "$HD_FAIL" -eq 0 ]; then
    ok "headroom doctor OK (0 failure · ${HD_WARN:-0} warning — chi tiết: headroom doctor)"
  else
    bad "headroom doctor $HD_FAIL failure — chạy 'headroom doctor' để xem"
  fi
  HRS="$(headroom install status 2>/dev/null || true)"
  if printf '%s' "$HRS" | grep -qiE "running|active|loaded|8787"; then
    ok "headroom install status OK"
  else
    warn "headroom install status — kiểm tra thủ công: headroom install status"
  fi
  if curl -fsS --max-time 3 http://127.0.0.1:8787/health >/dev/null 2>&1; then
    ok "headroom proxy :8787 /health OK"
  else
    warn "headroom proxy :8787 chưa phản hồi"
  fi
else
  bad "headroom không có trong PATH → uv tool install headroom-ai"
fi
if command -v rtk >/dev/null 2>&1; then
  ok "rtk $(rtk --version 2>/dev/null | head -1)"
else
  bad "rtk không có trong PATH → brew install rtk"
fi

echo "── gh + vault ────────────────────────────────────────"
if command -v gh >/dev/null 2>&1; then
  gh auth status >/dev/null 2>&1 && ok "gh auth OK" || warn "gh chưa login → gh auth login"
else
  skip "gh không cài (optional cho git workflow)"
fi

if [ -n "$VAULT" ]; then
  if [ -f "$VAULT/AGENTS.md" ] && [ -d "$VAULT/_templates" ]; then
    ok "vault hợp lệ: $VAULT"
  else
    bad "vault thiếu AGENTS.md/_templates: $VAULT"
  fi
  if [ -d "$VAULT/.git" ]; then ok "vault là git repo (local-only)"; else warn "vault chưa init git → xem scripts/new-vault.sh"; fi
else
  skip "vault check (truyền --vault <path> để kiểm tra)"
fi

echo "── git repo local (config/skills) ────────────────────"
for p in "$HOME/.config/opencode" "$HOME/Documents/21.AgentSkills"; do
  if [ ! -d "$p" ]; then skip "repo local: $p (chưa tồn tại)"
  elif [ -d "$p/.git" ]; then ok "repo local: $p"
  else warn "chưa init repo: $p → chạy scripts/bootstrap-macos.sh"; fi
done

echo "── optional tools ────────────────────────────────────"
for t in jq lazygit colima tmux; do
  if command -v "$t" >/dev/null 2>&1; then ok "optional: $t"; else skip "optional: $t"; fi
done

echo
echo "Tổng kết: PASS=$PASS FAIL=$FAIL WARN=$WARN"
if [ "$FAIL" = 0 ]; then
  echo "→ OK (warn/skip không tính fail)"
  exit 0
else
  echo "→ Có FAIL — xem docs/06-troubleshooting.md"
  exit 1
fi
