# 03 — Config opencode: cần khối nào, vì sao, kiểm ra sao

> Kit **không ship config** và không pin phiên bản opencode. Trang này nói **cần những khối nào và để làm gì**; hình dạng cụ thể (tên key, giá trị) xem [`docs/examples/opencode.jsonc`](examples/opencode.jsonc) và docs chính thức của opencode.
> Khi tên key trong trang này khác với file bạn đang chạy: **docs upstream + ví dụ thắng**, tên trong này chỉ để đọc hiểu.

---

## 1. Nguyên tắc

1. **Config là của máy bạn.** Kit không phát file này để cài, cũng không có bản "đúng" duy nhất — khác provider, khác model, khác đường dẫn skill là chuyện bình thường.
2. **Đọc theo khối, không copy theo file.** Ví dụ trong kit gắn với provider/model của người viết; copy nguyên là cách nhanh nhất để có config sai.
3. **Không secret trong config.** Chỉ tham chiếu (`{env:...}` hoặc `{file:...}`); giá trị để ngoài repo — xem [docs/04](04-secrets.md).

## 2. Các khối cần có

| Khối | Để làm gì | Không có thì sao |
|---|---|---|
| Model + agent mặc định | chọn model và agent khi mở opencode | opencode hỏi, hoặc dùng mặc định của nó |
| Providers | khai provider/model bạn dùng, kèm biến môi trường | model không resolve |
| Skills | chỉ đường dẫn tới skill | skill không hiện |
| Permissions | chặn/hỏi những lệnh nguy hiểm (`git push`, `rm -rf`…) | chạy được mọi thứ — kể cả thứ bạn không muốn |
| MCP servers | tool ngoài (obsidian, serena, headroom, chrome, task store) | không có tool tương ứng |

Mỗi khối dưới đây là *cần gì*, không phải *viết thế nào*.

### Model + agent mặc định

Model tham chiếu dạng `provider/model`, có thể kèm biến thể (`#variant`) khi agent/command cần cấu hình riêng. Provider đến từ **subscription account** thì phải `/connect` trước — xem [docs/04](04-secrets.md) §3.

Dùng provider khác người viết ví dụ → **remap mọi tham chiếu model**, gồm model gốc trong config và `model:` ở frontmatter từng agent. Đây là bước bắt buộc, không phải tuỳ chọn.

### Providers

Mỗi provider cần đúng **loại** (native của client, hay qua package openai-compatible) và đúng **địa chỉ** nếu là proxy/gateway; secret đi qua env hoặc file. Không có cách viết chung cho mọi provider — đọc mục provider đó trong docs upstream, rồi đối chiếu khối tương ứng trong file ví dụ.

### Skills

Đây là **mảng đường dẫn**. Ba điều cần nhớ:

- Trỏ thẳng thư mục skill trong clone kit vào mảng này — sửa kit là máy thấy ngay, không có bản sao để lệch.
- Skill riêng của máy/dự án đặt ở thư mục khác, thêm một phần tử nữa. Đừng trộn vào clone kit.
- Nếu client của bạn tự quét một thư mục skill mặc định, biết là có — nhưng kit không dựa vào nó.

### Permissions

Dạng **danh sách rule**, áp dụng theo thứ tự, rule sau thắng. Action bao gồm đọc/ghi file, shell, subagent, skill, web, `external_directory`, và từng tool của MCP server. Tên action và tên field **đổi giữa các phiên bản** — lấy tên đúng từ docs upstream hoặc từ file ví dụ đang chạy được.

Tối thiểu nên có: chặn `git push`, hỏi trước khi ghi ra ngoài thư mục làm việc. Agent có thể khai permission riêng trong frontmatter (ví dụ subagent reviewer đặt `edit: ask`).

### MCP servers

Mỗi server là một mục: loại (tiến trình local hay remote HTTP), lệnh/URL, biến môi trường hoặc header.

- Key cho MCP thường phải là **file** chứ không phải env: service có thể được spawn không kèm env của shell bạn → biến rỗng → server `Connection closed`. Xem [docs/04](04-secrets.md) §2.
- Server remote cần **một instance thật** phía server. Kit ship hình dạng, không ship instance; không có instance thì đừng khai (hoặc tắt tường minh) — chi tiết ở [docs/07](07-task-store.md).
- Đường ghi và đường đọc có thể là hai endpoint khác nhau. Đừng tự thêm tiền tố đoán ra — sai là `404`.

## 3. Biến thể model (reasoning + temperature)

Agent cần cấu hình reasoning/nhiệt độ thì khai thành **biến thể trên model**, không nhét vào frontmatter agent. Bộ biến thể trong kit:

| Biến thể | Ai dùng | Ý định |
|---|---|---|
| `#high` | planner · impl-reviewer · code-reviewer · test-engineer · security-auditor | reasoning cao, nhiệt độ thấp — việc cần chính xác |
| `#high-warm` | developer | reasoning cao, ấm hơn — viết code |
| `#warm` | jack · anna · bard · liuliu | mặc định |
| `#creative` | rei | sáng tạo |

Đây là **thiết kế của kit**, không phải yêu cầu của client: tên biến thể bạn tự đặt, miễn agent trỏ đúng tên. Provider không nhận một khoá con nào đó thì bỏ khoá ấy; phần còn lại vẫn chạy.

## 4. Code Mode — vì sao kit tắt

**Code Mode** gom tool của mỗi MCP server sau một tool `execute`: model viết JS gọi tool, chỉ trả kết quả cuối → tiết kiệm context.

Kit tắt cho các server vì:

1. Agent hiện tại gọi tool trực tiếp theo tên (`serena_*`, `obsidian_*`) — dưới Code Mode phải viết JS, sai cách gọi.
2. Plugin `serena-reminder` đếm tool call theo tên — dưới Code Mode chỉ thấy `execute` → plugin vô hiệu.
3. Giữ hành vi giống bản trước để agent/plugin hoạt động đúng thiết kế.

Muốn thử Code Mode: bật cho **một** server, rồi sửa cách agent gọi tool của server đó.

## 5. Agent · Command · Plugin · AGENTS.md

Client đọc những thứ này từ những chỗ nó quy định — không phải từ kit. Điều cần biết:

- **Agent**: frontmatter khai `description`, `mode`, `model` (+`#variant`), `permissions`. Field cũ của phiên bản trước (`temperature`, `tools`, `prompt`, `maxSteps`…) không dùng nữa; tên field đổi thì theo docs upstream.
- **Command**: frontmatter khai `description`, `agent`, `model`, `subagent`.
- **Plugin**: file local, tự được nạp từ thư mục plugin; API của client đổi giữa các phiên bản → đối chiếu docs, đừng sửa mò.
- **AGENTS.md**: hướng dẫn global cho LLM. Một số client chỉ đọc `AGENTS.md`, không fallback `CLAUDE.md`; khối `instructions` trong config có thể **không** được load — kiểm bằng cách hỏi agent một rule trong đó.

Không chắc một field có được nhận không → kiểm bằng hành vi: chạy agent, xem nó có làm đúng điều bạn khai.

## 6. Kiểm

```bash
opencode --version            # in ra được version
opencode service status
opencode mcp list             # các server bạn khai
opencode plugin list          # các plugin bạn cài
opencode debug paths          # log/config/data
```

Nếu client của bạn hỗ trợ kiểm schema config: chạy nó, đừng dựa vào editor. Editor có thể gạch đỏ key hợp lệ vì schema public trễ hơn bản client — khi đó **tắt validation cho file này**, đừng "sửa ngược" config về dạng cũ.

## 7. Đánh đổi có ý thức

- **Supply chain không pin:** MCP server cài bằng `npx`/`uvx` thường chạy bản mới nhất của bên thứ ba. Muốn chặt hơn: pin version/tag cụ thể.
- **TLS verify tắt cho MCP local** (Obsidian Local REST API trên localhost): đổi host thì bật lại.
- **Permissions nền là allow-all** + vài rule hạn chế. Muốn chặt hơn: thêm `deny` cho lệnh phá huỷ phổ biến và `ask` cho thao tác publish/merge.
