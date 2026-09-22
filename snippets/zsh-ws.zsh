# ws-kit — helper git đa repo (lazygit + tmux)
#
# Copy vào ~/.zshrc (hoặc source trực tiếp). Sửa WS_REPOS theo máy bạn.
# Chi tiết: docs/00-workspace-conventions.md §7

# Danh sách repo quản lý chung
WS_REPOS=(
  ~/ws-kit
  ~/Documents/Vault
  ~/.config/opencode
  ~/Documents/21.AgentSkills
)

alias lg='lazygit'

# lgall — mở TẤT CẢ repo trong 1 tmux session (mỗi repo 1 window chạy lazygit).
# opencode chạy riêng — session này chỉ để quản lý git.
lgall() {
  local session=repos r name
  if tmux has-session -t "$session" 2>/dev/null; then
    if [ -n "${TMUX:-}" ]; then tmux switch-client -t "$session"; else tmux attach -t "$session"; fi
    return
  fi
  for r in "${WS_REPOS[@]}"; do
    [ -d "$r" ] || continue
    name="$(basename "$r")"
    if tmux has-session -t "$session" 2>/dev/null; then
      tmux new-window -t "$session" -n "$name" -c "$r" 'lazygit'
    else
      tmux new-session -d -s "$session" -n "$name" -c "$r" 'lazygit'
    fi
  done
  if tmux has-session -t "$session" 2>/dev/null; then
    if [ -n "${TMUX:-}" ]; then tmux switch-client -t "$session"; else tmux attach -t "$session"; fi
  else
    echo "lgall: không có repo nào tồn tại trong WS_REPOS"
  fi
}

# wsst — status nhanh tất cả repo
wsst() {
  local r
  for r in "${WS_REPOS[@]}"; do
    printf '\n── %s\n' "$r"
    git -C "$r" status -sb
  done
}
