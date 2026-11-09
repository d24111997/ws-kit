import { Plugin } from "@opencode/plugin"

// Serena Reminder Plugin — opencode v2
//
// Mục đích: Nudge agent dùng Serena symbol tools thay vì grep/read thủ công.
// Tương tự serena-hooks remind (Claude Code/VSCode), nhưng chạy native trong opencode.
//
// Cơ chế:
//  - Đếm số lần agent gọi "search-heavy" tools liên tiếp (shell grep/rg, read, glob, grep)
//    mà KHÔNG gọi serena_* ở giữa.
//  - Khi vượt ngưỡng (5 lần liên tiếp), gắn 1 text reminder vào kết quả tool
//    (execute.after) để agent biết nên chuyển sang serena_find_symbol / serena_get_symbols_overview.
//  - Reset counter khi agent gọi bất kỳ serena_* tool nào.
//
// Ngưỡng có thể tinh chỉnh qua THRESHOLD (mặc định 5).

const THRESHOLD = 5
const SEARCH_TOOLS = new Set(["bash", "shell", "glob", "read", "grep"])
const SERENA_PREFIX = "serena_"

const REMINDER = [
  "",
  "ℹ️ [serena-reminder] Bạn đã gọi nhiều lần grep/read liên tiếp. ",
  "Nếu đang tìm hiểu code, hãy ưu tiên dùng Serena symbol tools:",
  "  - serena_find_symbol: tìm symbol theo tên",
  "  - serena_get_symbols_overview: xem cấu trúc 1 file",
  "  - serena_find_referencing_symbols: ai gọi symbol này",
  "  - serena_search_for_pattern: tìm pattern (khi không biết tên symbol)",
  "Các tool này token-efficient hơn grep/read và luôn đúng với code hiện tại.",
  "",
].join("\n")

export default Plugin.define({
  id: "serena.reminder",

  async setup(ctx) {
    let consecutiveSearch = 0
    let lastTool = ""
    let reminded = false

    await ctx.tool.hook("execute.before", (event) => {
      const tool = String(event.tool ?? "").toLowerCase()

      // Reset counter khi agent dùng serena — nó đang đi đúng hướng
      if (tool.startsWith(SERENA_PREFIX)) {
        consecutiveSearch = 0
        reminded = false
        lastTool = tool
        return
      }

      if (!SEARCH_TOOLS.has(tool)) {
        // Tool khác — giảm nhẹ để không tính chuỗi search quá dài
        if (tool !== lastTool) consecutiveSearch = Math.max(0, consecutiveSearch - 1)
        lastTool = tool
        return
      }

      // Shell: chỉ đếm khi command có vẻ là grep/find/rg/ls
      if (tool === "bash" || tool === "shell") {
        const input = event.input as { command?: unknown } | undefined
        const cmd = String(input?.command ?? "")
        if (!/\b(grep|rg|find|rtk grep|rtk find|ls)\b/.test(cmd)) {
          lastTool = tool
          return
        }
      }

      consecutiveSearch++
      lastTool = tool
    })

    await ctx.tool.hook("execute.after", (event) => {
      if (consecutiveSearch < THRESHOLD || reminded) return
      if (event.status !== "completed") return
      reminded = true

      const result = event.result as {
        content?: string | ReadonlyArray<{ type: string; text?: string }>
      }
      const existing = result?.content
      let content: string | ReadonlyArray<{ type: string; text?: string }>
      if (typeof existing === "string") {
        content = existing + REMINDER
      } else if (Array.isArray(existing)) {
        content = [...existing, { type: "text", text: REMINDER }]
      } else {
        content = REMINDER
      }
      event.result = { ...result, content }
    })
  },
})
