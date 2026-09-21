#!/usr/bin/env bash
# ws-kit — tạo vault mới từ vault-template
#
# Cách dùng:
#   ./scripts/new-vault.sh "<Tên vault>" [--parent <thư mục>]
#
# Mặc định parent: ~/Documents
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME=""
PARENT="$HOME/Documents"

while [ $# -gt 0 ]; do
  case "$1" in
    --parent)
      if [ "$#" -lt 2 ]; then echo "Thiếu giá trị cho --parent"; exit 1; fi
      case "$2" in -*) echo "Giá trị không hợp lệ cho --parent: $2"; exit 1 ;; esac
      PARENT="$2"; shift 2 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) NAME="$1"; shift ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "Thiếu tên vault. VD: ./scripts/new-vault.sh \"MyVault\""
  exit 1
fi

DEST="$PARENT/$NAME"
if [ -e "$DEST" ]; then
  echo "Đã tồn tại: $DEST — chọn tên khác hoặc xoá trước."
  exit 1
fi

mkdir -p "$DEST"
cp -R "$KIT_DIR/vault-template/." "$DEST/"

cd "$DEST"
git init -b main >/dev/null 2>&1 || git init >/dev/null 2>&1 || true
git add -A

if git commit -m "init: vault skeleton '$NAME' (from ws-kit)" >/dev/null 2>&1; then
  echo "Vault: $DEST (git: initialized + first commit)"
else
  echo "Vault: $DEST (git: initialized — commit thất bại, kiểm tra git user.name/email)"
fi

echo
echo "Bước tiếp theo:"
echo "  1. Obsidian → Open folder as vault → chọn: $DEST"
echo "  2. Cài + bật 5 community plugins + Local REST API (port 27123)"
echo "     → xem docs/05-vault-setup.md"
