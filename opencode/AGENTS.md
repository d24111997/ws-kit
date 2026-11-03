# Global AGENTS.md — opencode

> Hướng dẫn chung áp dụng cho mọi project trên máy này. Thêm quy ước của bạn tại đây.

## Vault & repos — nguồn sự thật duy nhất

> Agent · command · skill **KHÔNG hardcode đường dẫn**. Cần path thì trỏ về bảng này; chưa chắc thì đọc lại, không đoán.

| Tên | Path | Dùng cho |
|---|---|---|
| `vault` | `<ĐIỀN: /Users/<user>/Documents/<vault>` | docs dự án, specs, test plan, scenario, handover |
| `BE` | `<ĐIỀN: path repo backend>` | source backend |
| `FE` | `<ĐIỀN: path repo frontend>` | source frontend |

Quy ước:

- "vault" trong agent/skill = vault chính của bạn, trừ khi nói rõ là vault khác.
- Truy cập vault bằng **filesystem path**, không dùng Obsidian MCP (`write_note`/`read_note`).
- Đường dẫn con trong vault giữ **tương đối** với root (`11_Testing/{feature}/...`), không ghép thành path tuyệt đối trong prompt.
- Repo source: dùng tên trong bảng (`BE`, `FE`), không viết path tuyệt đối.

<!--
TÙY CHỌN — rtk instructions:
opencode v2 KHÔNG tự thêm block hướng dẫn rtk vào file này.
Muốn LLM chủ động dùng rtk → copy block "rtk instructions" từ docs/02-headroom.md
(rất khuyến khích: giúp tiết kiệm token 60–90% cho mọi lệnh shell).
-->
