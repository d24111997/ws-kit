import { Plugin } from "@opencode/plugin"
import { execFile } from "node:child_process"

// RTK OpenCode plugin (V2) — rewrites shell commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

const REWRITE_TIMEOUT_MS = 10_000

function run(cmd: string, args: string[]): Promise<{ ok: boolean; stdout: string }> {
  return new Promise((resolve) => {
    execFile(cmd, args, { timeout: REWRITE_TIMEOUT_MS }, (error, stdout) => {
      resolve({ ok: !error, stdout: String(stdout ?? "") })
    })
  })
}

export default Plugin.define({
  id: "rtk.rewrite",

  async setup(ctx) {
    // Disable silently when rtk is not installed.
    const check = await run("rtk", ["--version"])
    if (!check.ok) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.shell.hook("create.before", async (event) => {
      const command = event.command
      if (typeof command !== "string" || !command) return

      const result = await run("rtk", ["rewrite", command])
      if (!result.ok) return // rtk rewrite failed — pass through unchanged

      const rewritten = result.stdout.trim()
      if (rewritten && rewritten !== command) {
        event.command = rewritten
      }
    })
  },
})
