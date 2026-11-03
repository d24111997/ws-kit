#!/usr/bin/env bash
# capture.sh — đồng bộ NGƯỢC: từ máy này (home) VỀ kit.
#   bootstrap-macos.sh : kit → home  (cài đặt / deploy)
#   capture.sh         : home → kit  (thu hoạch thay đổi đã làm trên máy)
#
# MẶC ĐỊNH DRY-RUN — chỉ in ra việc sẽ làm. Thêm --apply để ghi thật.
#
# Dùng:
#   ./scripts/capture.sh                     # xem trước
#   ./scripts/capture.sh --apply             # ghi thật
#   ./scripts/capture.sh --apply --exclude-skill tiktok-to-youtube-sync
#   ./scripts/capture.sh --apply --prune-skills   # xoá skill trong kit không còn ở home
#
# Không bao giờ đồng bộ (kit sở hữu bản riêng):
#   opencode/opencode.template.jsonc · opencode/cli.json · opencode/package.json
#   opencode/AGENTS.md   ← bản kit là template placeholder; bản máy chứa path thật
#   vault-template/ · docs/
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"
SKILLS_PATH="${HOME}/Documents/21.AgentSkills"
APPLY=0
PRUNE_SKILLS=0
EXCLUDE_SKILLS=()

say()  { printf '\033[1;36m▸ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }
run()  { if [ "$APPLY" = 1 ]; then "$@"; else echo "  [dry-run] $*"; fi; }
need_value() { [ $# -ge 2 ] || { echo "Thiếu giá trị cho $1" >&2; exit 1; }; }

while [ $# -gt 0 ]; do
  case "$1" in
    --apply)         APPLY=1; shift ;;
    --prune-skills)  PRUNE_SKILLS=1; shift ;;
    --exclude-skill) need_value "$@"; EXCLUDE_SKILLS+=("$2"); shift 2 ;;
    --skills-path)   need_value "$@"; SKILLS_PATH="$2"; shift 2 ;;
    -h|--help)       sed -n '2,19p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

say "kit:         $KIT_DIR"
say "config home: $CONFIG_DIR"
say "skills:      $SKILLS_PATH"
[ "$APPLY" = 1 ] || warn "DRY-RUN — thêm --apply để ghi thật"

BASE_OPTS=(-a --itemize-changes --exclude '.DS_Store')
OWNED_OPTS=(-a --delete --itemize-changes --exclude '.DS_Store')

# ── 1. agents / commands / plugins / references (home sở hữu hoàn toàn) ──────
for d in agents commands plugins references; do
  if [ -d "$CONFIG_DIR/$d" ]; then
    say "sync home → kit: $d/  (delete: có)"
    run rsync "${OWNED_OPTS[@]}" "$CONFIG_DIR/$d/" "$KIT_DIR/opencode/$d/"
  else
    warn "bỏ qua $d (không có ở home)"
  fi
done

# ── 2. skills (KHÔNG delete mặc định — kit có thể ship skill không nằm ở home) ─
KITIGNORE="${KIT_DIR}/.kitignore"
if [ -f "$KITIGNORE" ]; then
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    EXCLUDE_SKILLS+=("$line")
  done < "$KITIGNORE"
fi

if [ -d "$SKILLS_PATH" ]; then
  SKILL_OPTS=("${BASE_OPTS[@]}")
  [ "$PRUNE_SKILLS" = 1 ] && SKILL_OPTS=("${OWNED_OPTS[@]}")
  for s in ${EXCLUDE_SKILLS[@]+"${EXCLUDE_SKILLS[@]}"}; do SKILL_OPTS+=(--exclude "$s"); done
  say "sync home → kit: skills/  (loại trừ: ${EXCLUDE_SKILLS[*]:-không} · delete: $([ "$PRUNE_SKILLS" = 1 ] && echo có || echo không))"
  run rsync "${SKILL_OPTS[@]}" "$SKILLS_PATH/" "$KIT_DIR/skills/"
else
  warn "không thấy skills path: $SKILLS_PATH"
fi

# ── 3. nhắc những thứ cố ý không sync ────────────────────────────────────────
warn "KHÔNG sync: opencode/AGENTS.md (kit là template), opencode.jsonc, cli.json, package.json"
warn "Vừa đổi luật chung ở ~/.config/opencode/AGENTS.md? → sửa tay bản template trong kit."

if [ "$APPLY" = 1 ]; then
  say "Xong. Kiểm tra:"
  echo "  cd \"$KIT_DIR\" && git status --short"
  echo "  git diff --stat && git add -A && git commit -m 'chore(kit): capture từ máy'"
else
  say "Dry-run xong. Chưa ghi gì."
fi
