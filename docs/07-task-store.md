# 07 — Task store qua MCP (`tms`)

> Kit ship ba skill `discuss-*` gọi tool của một **task store** (`task_get` · `decision_record` · …).
> Kit **không** ship task store đó. File này mô tả hình dạng client và cách kiểm.
> Không có instance → xem §7.

---

## 1. Vai trò

Task store giữ dữ kiện của task ngoài file: `project` · `task` · `decision`, mỗi task một số hiệu `T-<n>`, mỗi quyết định một số `D-<n>` do store cấp. Văn xuôi (mục tiêu, phạm vi, đầu ra, lý do quyết định) vẫn ở file thảo luận/plan trong vault.

Hệ quả với agent: đọc tiến độ bằng `task_list` / `task_get`, ghi trạng thái bằng `task_update`, khoá quyết định bằng `decision_record` — **không** sửa file task bằng tay.

## 2. Hợp đồng tool

6 tool: `task_list` · `task_get` · `task_create` · `task_update` · `decision_record` · `decision_list`.

Kit nêu **việc cần làm với tool**, không chép chữ ký tham số: store có thể đổi tham số mà không đổi tên tool — chép vào kit thì mỗi lần store đổi lại phải sửa kit. Hình dạng tham số theo tài liệu của instance đang dùng.

- **Đọc** — `task_list` cho tiến độ · `task_get` cho một task (đọc được từng mục, không nhất thiết kéo cả thân) · `decision_list` cho quyết định (phân trang khi nhiều).
- **Ghi** — `task_create` tạo task · `task_update` sửa task (sửa được từng mục, một lời gọi là một transaction; sửa một dòng thì không gửi lại cả thân task) · `decision_record` khoá quyết định.
- **Nhiều máy cùng ghi** — store có khoá lạc quan: đọc trước khi ghi, lệch thì không ghi và báo lại.

## 3. Đường vào

| Đường | Server | Quyền | Dùng khi |
|---|---|---|---|
| `/write/mcp` | `tmsd` | 6 tool: tạo · đọc · sửa task, ghi · đọc quyết định | Agent làm việc — đường chính |
| `/sse` + `/messages/` | `postgres-mcp` | chỉ `SELECT` trên `task` · `decision` · `project` | Cần truy vấn SQL thô |

Hai đường **khác gốc**, không có tiền tố chung: đọc ở `/sse`, ghi ở `/write/mcp`. Gọi `/read/sse` hay `/read/write/mcp` → `404`.

Xác thực: bearer key **theo máy**. Store chỉ giữ `sha256` của key; key thô in ra đúng một lần lúc tạo, không xem lại được.

## 4. Khai trong config

Hình dạng block (ví dụ tham chiếu trong `docs/examples/opencode.jsonc`, §`mcp.servers`):

```jsonc
"tms": {
  "type": "remote",
  "url": "https://<tms-host>/write/mcp",
  "oauth": false,
  "headers": { "Authorization": "Bearer {file:~/.secrets/tms-api-key}" },
  "codemode": false
}
```

- `url` phải trỏ `/write/mcp`; `<tms-host>` là host thật của instance.
- Key đọc bằng `{file:}` chứ không `{env:}`: opencode service có thể được macOS spawn không kèm env của shell, làm MCP nhận key rỗng rồi fail `Connection closed` (xem `docs/04-secrets.md` §2).
- `codemode: false` để tool hiện native (`task_get`, …) đúng như skill mô tả.

## 5. Lưu key

```bash
mkdir -p ~/.secrets
printf '%s' '<key>' > ~/.secrets/tms-api-key
chmod 600 ~/.secrets/tms-api-key
```

Nếu nhóm của bạn có runbook riêng cho task store, chỗ lưu key do runbook quyết định — chỉ cần đường dẫn trong `{file:}` khớp. Không đưa key qua chat, không commit vào repo.

Nhãn key nên đặt **đúng tên máy** (`macbook-pro`, `mac-mini`, …): nhãn là thứ duy nhất để chọn đúng key khi cần thu hồi.

## 6. Kiểm và lỗi thường gặp

```bash
KEY=$(cat ~/.secrets/tms-api-key)
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://<tms-host>/write/mcp \
  -H "Authorization: Bearer $KEY" -H 'Content-Type: application/json' -d '{}'
```

| Mã | Nghĩa | Xử |
|---|---|---|
| `200` / `4xx` có JSON-RPC | Qua được cổng xác thực | Lỗi còn lại là của tool, đọc message |
| `401` | Thiếu header · key sai · key đã thu hồi | Kiểm `Authorization: Bearer <key>`; xem danh sách key còn hiệu lực, tạo key mới nếu mất |
| `404` | Gọi đường đọc có tiền tố, hoặc đường ghi sai | Đọc `/sse` + `/messages/`, ghi `/write/mcp` |
| `429` | Vượt rate limit | Giãn nhịp; hạn mức tính theo IP nên nhiều agent cùng máy dùng chung |

Thu hồi là **mềm**: dòng key giữ nguyên, chỉ đặt mốc thu hồi; key đó trả `401` ngay từ lời gọi kế tiếp.

## 7. Khi chưa có instance

Task store là thành phần tuỳ chọn của workspace. Không có instance thì:

1. Bỏ block `tms` khỏi config (hoặc để `"disabled": true`).
2. Bỏ ba skill `discuss-task` · `discuss-continue-task` · `discuss-next-task` khỏi thư mục skill bạn dùng — chúng gọi tool không tồn tại, agent sẽ lặp lại lời gọi lỗi.
3. Giữ nguyên phần còn lại: skill, agent, vault, plan/SCN không phụ thuộc task store.

Đừng khai `url` giả để "cho đủ bộ": agent sẽ thử, fail, rồi coi như task không đọc được — tốn một vòng debug vô ích.
