#!/usr/bin/env bash
# ws-kit — bootstrap workspace opencode (macOS)
#
# Cách dùng:
#   ./scripts/bootstrap-macos.sh [--skills-path <path>] [--target-dir <path>] [--dry-run]
#
# Mặc định:
#   --target-dir   ~/.config/opencode        (backup rename nếu đã tồn tại)
#   --skills-path  ~/Documents/21.AgentSkills (backup-copy trước khi merge)
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$HOME/.config/opencode"
SKILLS_PATH="$HOME/Documents/21.AgentSkills"
DEFAULT_SKILLS="$HOME/Documents/21.AgentSkills"
DRY_RUN=0

need_value() { # $1 = option name
  if [ "$#" -lt 2 ]; then
    echo "Thiếu giá trị cho $1 — xem ./scripts/bootstrap-macos.sh --help"
    exit 1
  fi
  case "$2" in
    -*) echo "Giá trị không hợp lệ cho $1: $2"; exit 1 ;;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    --skills-path) need_value "$@"; SKILLS_PATH="$2"; shift 2 ;;
    --target-dir)  need_value "$@"; TARGET="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    -h|--help)     sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
run()  { if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

say "ws-kit bootstrap"
echo "  kit:         $KIT_DIR"
echo "  target:      $TARGET"
echo "  skills path: $SKILLS_PATH"
[ "$DRY_RUN" = 1 ] && echo "  (dry-run — không ghi gì)"

# ── 1. Backup config cũ (rename sang .backup-<timestamp>) ─────────────────────
if [ -d "$TARGET" ]; then
  BACKUP="${TARGET}.backup-$(date +%Y%m%d-%H%M%S)"
  say "Backup config cũ: $TARGET → $BACKUP"
  run mv "$TARGET" "$BACKUP"
fi

# ── 2. Copy opencode config (v2-native) ───────────────────────────────────────
say "Copy config → $TARGET"
run mkdir -p "$TARGET"
run cp -R "$KIT_DIR/opencode/agents" "$KIT_DIR/opencode/commands" "$KIT_DIR/opencode/plugins" "$KIT_DIR/opencode/references" "$TARGET/"
run cp "$KIT_DIR/opencode/cli.json" "$KIT_DIR/opencode/package.json" "$KIT_DIR/opencode/AGENTS.md" "$TARGET/"
run cp "$KIT_DIR/opencode/opencode.template.jsonc" "$TARGET/opencode.jsonc"

# ── 3. Skills (backup-copy nếu path đã có dữ liệu, rồi merge) ────────────────
if [ -d "$SKILLS_PATH" ] && [ -n "$(ls -A "$SKILLS_PATH" 2>/dev/null)" ]; then
  SKILLS_BACKUP="${SKILLS_PATH}.backup-$(date +%Y%m%d-%H%M%S)"
  say "Skills path đã có dữ liệu → backup-copy: $SKILLS_BACKUP"
  run cp -R "$SKILLS_PATH" "$SKILLS_BACKUP"
fi
say "Copy skills → $SKILLS_PATH"
run mkdir -p "$SKILLS_PATH"
run cp -R "$KIT_DIR/skills/." "$SKILLS_PATH/"

if [ "$SKILLS_PATH" != "$DEFAULT_SKILLS" ]; then
  case "$SKILLS_PATH" in
    "$HOME"/*) NEWP="~/${SKILLS_PATH#"$HOME"/}" ;;
    *)         NEWP="$SKILLS_PATH" ;;
  esac
  say "Skills path khác mặc định → cập nhật 'skills' array trong config ($NEWP)"
  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] replace '~/Documents/21.AgentSkills' → '$NEWP' in $TARGET/opencode.jsonc"
  else
    python3 - "$TARGET/opencode.jsonc" "$NEWP" <<'PY'
import pathlib, sys
conf = pathlib.Path(sys.argv[1])
newp = sys.argv[2]
t = conf.read_text(encoding="utf-8")
t = t.replace("~/Documents/21.AgentSkills", newp)
conf.write_text(t, encoding="utf-8")
print(f"  updated skills path → {newp}")
PY
  fi
fi

# ── 4. Plugin deps (optional — npm install) ───────────────────────────────────
if command -v npm >/dev/null 2>&1; then
  say "Cài deps cho plugin local (npm install trong $TARGET)"
  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] (cd '$TARGET' && npm install)"
  else
    (cd "$TARGET" && npm install --silent --no-audit --no-fund >/dev/null 2>&1) \
      || warn "npm install thất bại — plugin local có thể không load (kiểm tra node_modules/@opencode/plugin)"
  fi
else
  warn "npm không có → bỏ qua cài deps plugin (kiểm tra lại sau khi cài node)"
fi

# ── 5. Kết thúc ───────────────────────────────────────────────────────────────
say "Bootstrap xong. Các bước tiếp theo:"
cat <<'EOF'
  1. Secrets: tạo ~/.secrets/opencode.env (chmod 600) + source trong ~/.zshenv
     → xem docs/04-secrets.md
  2. Connect account: mở opencode → /connect (vd OpenCode Go subscription)
  3. Vault: ./scripts/new-vault.sh "<Tên vault>" rồi mở bằng Obsidian
     → xem docs/05-vault-setup.md
  4. Kiểm tra: ./scripts/verify.sh
EOF
