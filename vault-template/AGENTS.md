---
title: AGENTS.md — Vault Entry Point
date: <YYYY-MM-DD>
last_updated: <YYYY-MM-DD>
type: overview
tags:
  - agents
  - vault
---

# AGENTS.md — Vault Entry Point

> Hướng dẫn cho AI Agent khi làm việc với vault này.
> Vault này là **shared brain** của hệ thống — chứa kiến trúc, quyết định, flows chung.

---

## 1. Vault Overview

| Khu vực | Nội dung |
|---|---|
| `00_TASKS_THIS_WEEK/` | Workspace tạm cho task đang làm trong tuần |
| `01_Project/` | Tổng quan dự án, tech stack |
| `02_Architecture/` | System architecture, DB schema, API contract, ADRs |
| `03_Flows/` | Luồng nghiệp vụ chi tiết (BE / FE) |
| `04_Research/` | Nghiên cứu kỹ thuật |
| `05_Meeting_note/` | Biên bản họp |
| `06_Backlog/` | Backlog items |
| `07_Infra/` | Hạ tầng, deploy, services |
| `08_Behavior-spec/` | Behavior specs |
| `09_Known_Issues/` | Known issues |
| `10_unclassified/` | Tài liệu chưa phân loại |
| `11_Testing/` | Test docs: templates, test plans, scenarios, validation matrices, traceability |
| `12_bug/` | Bug reports |
| `_templates/` | Template file (note, ADR, backlog, handover...) |
| `_diagrams/` | Sơ đồ (export) |
| `_Index.md` | MOC — danh sách toàn bộ file trong vault |

**Quy tắc:** Vault chỉ chứa phần chung + trao đổi cross-project. Code thực tế nằm ở project repos.

---

## 2. Đọc gì trước tiên?

Khi mới vào vault, đọc theo thứ tự:

1. **`01_Project/`** — Bối cảnh, mục tiêu, tech stack
2. **`02_Architecture/`** — Kiến trúc tổng thể + các ADRs gần nhất
3. **`_Index.md`** — toàn bộ file trong vault (MOC)

---

## 3. Liên kết tới Project Repos

Mỗi project repo có `AGENTS.md` riêng — **phải đọc file đó** trước khi code.

| Dự án | Đường dẫn | Đọc tiếp |
|---|---|---|
| <BE> | `<đường dẫn repo BE>` | `AGENTS.md` ở root repo |
| <FE> | `<đường dẫn repo FE>` | `AGENTS.md` ở root repo |

### Khi làm task ở một project:
1. Đọc `AGENTS.md` vault này → hiểu bối cảnh hệ thống
2. Đọc `AGENTS.md` của project → hiểu conventions, commands, workflow
3. Vào `docs/` của project → đọc các file hướng dẫn tương ứng
4. Tham chiếu vault này khi cần: architecture, ADRs, flows, API contract

---

## 4. Documentation Map

| Nếu cần... | Đọc ở đây |
|---|---|
| Hiểu tổng quan hệ thống | `01_Project/` |
| Kiến trúc, DB schema, API contract | `02_Architecture/` |
| Quyết định kiến trúc (ADR) | `02_Architecture/ADRs/` |
| Luồng nghiệp vụ cụ thể | `03_Flows/` |
| Backlog items chưa làm | `06_Backlog/` |
| Test plans / scenarios / matrices | `11_Testing/` (+ template tại `11_Testing/templates/`) |
| Test strategy tổng thể | `11_Testing/test-plan-general.md` |
| Lỗi đã biết | `09_Known_Issues/` |
| Toàn bộ file trong vault | `_Index.md` (MOC) |

---

## 5. Conventions

- **ADRs** follow template tại `_templates/adr-template.md`
- **Flow docs** follow pattern: sequence diagram → steps → error codes → reference
- **Notes** dùng Obsidian wiki links (`[[...]]`) để liên kết nội bộ
- Mỗi project có AGENTS.md riêng — không ghi conventions chung của project vào vault này

### 📄 Timeless Writing (bắt buộc cho mọi tài liệu tổng quan)

**Định nghĩa: Timeless = câu văn đọc ở BẤT KỲ mốc thời gian nào vẫn ĐÚNG.**

- Mọi tài liệu **tổng quan** (`AGENTS.md`, `DOCS_INDEX.md`, SYSTEM_CONTEXT, ARCHITECTURE, flow docs...) phải mô tả **vai trò + chức năng + tech** của mỗi thành phần — mô tả như 1 hệ thống đang tồn tại, không so sánh với quá khứ.
- **Khuyến khích** các tài liệu khác (spec, hướng dẫn, ghi chú kỹ thuật...) cũng viết theo lối timeless để tăng tuổi thọ nội dung; riêng file artifact (xem dưới) là ngoại lệ.
- **Cấm từ thời điểm tương đối** — "hiện tại", "bây giờ", "gần đây", "mới", "chưa", "đã xoá" (không kèm ngày), "trước đây", "hiện vẫn"... → câu này hết hạn ngay ngày hôm sau.
- **Sự kiện có thời gian → bắt buộc gắn mốc ngày cụ thể** (YYYY-MM-DD). VD đúng: `2026-09-02: đã xoá mock + BFF route` — đọc ngày 3/9 hay 10/9 vẫn hiểu đúng sự thật lịch sử. VD sai: `hiện tại đã xoá mock` — sang ngày 3/9 đọc là sai.
  - Cách viết: sự kiện có ngày tháng **ưu tiên ghi trong Changelog** của tài liệu. Nếu cần nhắc trong thân tài liệu → phải kèm mốc ngày.
- Lý do: câu không gắn mốc thời gian ("chưa tạo", "đã xoá", "mới deploy") hết hạn ngay khi code thay đổi; câu gắn mốc ngày hoặc mô tả vai trò thì đọc ở thời điểm nào cũng đúng.
- Ngoại lệ duy nhất: file **artifact** (`docs/discuss/*`, `docs/handover/*`, `docs/research/*`) là record lịch sử — ghi đúng trạng thái tại thời điểm đó.

### 📐 Template tài liệu tổng quan (Overview Doc Template)

- Mọi tài liệu tổng quan (overview/context/architecture) **bắt buộc follow template**: `_templates/overview-doc-template.md`.
- Cấu trúc chuẩn:
  1. **Frontmatter** — `title`, `date`, `last_updated`, `type`, `feature`, `tags`
  2. **Nội dung timeless** — mô tả vai trò + chức năng + tech (theo rule Timeless Writing ở trên)
  3. **Changelog cuối file** — sự kiện có ngày tháng, **theo thứ tự thời gian (mới nhất ở trên)**

---

## Changelog

| Date | Change |
|------|--------|
| <YYYY-MM-DD> | Khởi tạo vault skeleton (từ ws-kit) |
