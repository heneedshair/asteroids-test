---
title: "INTERNAL — Raven tool guide (archived)"
description: "Архив vendor-specific implementation guide. Не часть публичного RENAR corpus."
lang: ru
status: internal
---

> **INTERNAL ONLY — не часть публичного RENAR.** Vendor-specific implementation guide (Kibertum). Удалён из `guide/` nav; публичная замена — [guide/04-document-store-substrate.md](../../guide/04-document-store-substrate.md). Ссылки ниже могут быть относительными к старому расположению `guide/`.

---
# Tool guide — Raven / CouchDB substrate

> Конкретная реализация RENAR на Raven — связке CouchDB (хранилище) + Meilisearch (полнотекстовый поиск) + Gateway (REST API + auth). Doc-types, `_rev` versioning, `validate_doc_update` как substrate hook аналог, Hub UI workflow, API endpoints, миграция git ↔ Raven. Substrate-agnostic альтернатива — [guide/03-tool-guide-git](03-tool-guide-git.md).
>
> **Статус Raven (на 2026-05-15):** приёмка in progress. Этот guide описывает **целевое** состояние API и doc-types, требующееся для RENAR-conformant реализации. Текущее состояние Raven runtime может отличаться — авторитетный источник actuals — OpenAPI спека `api/routers/` в Raven repo. Известные расхождения целевое ↔ actuals перечислены в [§12 Open questions](#12-open-questions).
>
> **Предпосылки:** [standard/11-substrate-versioning](../standard/11-substrate-versioning.md) (нормативные capability V1-V6), [reference/02-schemas](../reference/02-schemas.md) (frontmatter schemas).

---

## 1. Когда выбрать Raven substrate

Raven — substrate выбора для:
- Enterprise-окружения с несколькими проектами на общей Raven runtime.
- Команд с большим количеством non-technical stakeholder (PM / юристы / DPO), которым нужен UI без git CLI.
- Проектов с high concurrent editing (несколько авторов работают с одним артефактом без merge conflicts).
- Запросов на встроенный полнотекстовый поиск и graph-traversal без внешних tooling.
- Federation между несколькими проектами в одной организации.

Raven **не** оптимален, если:
- Команда работает на TAUSIK runtime для внешнего клиента (Raven не ставится для каждого external project).
- Проект — open source / public (требования должны быть видимы через VCS, не через managed runtime).
- Нет ресурсов поддерживать сервер CouchDB + Meilisearch + Gateway.

В таких случаях — git, [guide/03](03-tool-guide-git.md).

---

## 2. Архитектура Raven

```text
┌─────────────────────────────────────────────────────┐
│                    Hub UI (Web)                     │
│        approve / comment / diff / search            │
└────────────────────┬────────────────────────────────┘
                     │ REST / WebSocket
                     ▼
┌─────────────────────────────────────────────────────┐
│                  Gateway (FastAPI)                  │
│   auth, RBAC, validation, business logic, MCP       │
└──────┬──────────────────────┬───────────────────────┘
       │                      │
       ▼                      ▼
┌──────────────────┐  ┌──────────────────────────────┐
│     CouchDB      │  │       Meilisearch            │
│  doc-types,      │  │  FTS index по body + tags    │
│  _rev versioning │  │  per-database deployment     │
└──────────────────┘  └──────────────────────────────┘
```

Каждая RENAR-сущность — документ в CouchDB. Изменения проходят через Gateway (не прямой write в CouchDB). Meilisearch индексирует body артефактов для FTS-поиска.

---

## 3. Capability mapping V1-V6 на Raven

| Capability | Норматив | Raven-механизм |
|---|---|---|
| V1 — Versioned content addressing | Stable identifier + content hash | CouchDB `_id` (формат `<project>:<doc-type>:<slug>`) + `_rev` (auto-generated content hash) |
| V2 — Schema validation | Структура артефактов проверяется автоматически | `validate_doc_update` функция в design-document; запускается на каждый write в CouchDB |
| V3 — Lifecycle state enforcement | Переходы статусов следуют state machine | Gateway endpoint `/transition` с pre/post-condition проверкой; CouchDB `validate_doc_update` блокирует прямые status edits |
| V4 — Reporting / aggregation | Coverage / status reports auto-generated | CouchDB views (`_design/coverage`) + reduce-функции; пересчёт on-change |
| V5 — Reference integrity | Cross-refs не «висят» | Gateway middleware: при write проверяет `parent`, `verified-by`, `constrained-by` существование |
| V6 — Drift detection | Дрейф ловится автоматически | Tool_event audit log + scheduled job в Gateway; сравнивает `requirement_meta` с linked `verification_runs` |

---

## 4. Doc-types

CouchDB документы организованы в `kai_<project>` database. Каждый doc-type имеет фиксированную schema.

### 4.1 `requirement_meta`

Соответствует BR / SR / TR в RENAR-нотации.

```json
{
  "_id": "myproj:requirement_meta:BR-12",
  "_rev": "3-abc...",
  "slug": "BR-12",
  "doc_type": "requirement_meta",
  "level": "BT",                  // BT (business) | ST (system) | TR (task)
  "title": "...",
  "body": "<markdown>",
  "status": "approved",
  "parent": null,
  "verified_by": ["TC-23"],
  "data_classification": { "contains_pii": true, ... },
  "ai_provenance": { "generated_by": "claude-opus-4-7", "generated_at": "..." },
  "created_at": "2026-05-15T10:00:00Z",
  "updated_at": "2026-05-15T11:30:00Z",
  "created_by_order": "TZ-2026-042",
  "last_modified_by_order": "TZ-2026-042"
}
```

### 4.2 `spec_meta`

Соответствует SPEC-{ARCH,API,DATA,INT,PROC,UI,AI,SEC,OPS}.

```json
{
  "_id": "myproj:spec_meta:SPEC-ARCH-01",
  "_rev": "2-def...",
  "slug": "SPEC-ARCH-01",
  "doc_type": "spec_meta",
  "spec_type": "ARCH",            // closed list: ARCH/API/DATA/INT/PROC/UI/AI/SEC/OPS
  "title": "...",
  "body": "<markdown>",
  "status": "approved",
  "constrained_by_for": ["SR-05", "SR-08"],
  "implements": []
}
```

### 4.3 `adapt_meta`

Bridge artefact между ТЗ и иерархией требований.

```json
{
  "_id": "myproj:adapt_meta:ADAPT-01",
  "doc_type": "adapt_meta",
  "tz_ref": "TZ-2026-042",
  "forward_section": "<markdown>",
  "backward_section": "<markdown>",
  "status": "approved",
  "double_signature": { "architect": "@arch1", "stakeholder": "@po1" }
}
```

### 4.4 `test_case` (planned doc-type — Raven roadmap, RENAR mandatory)

First-class артефакт TC согласно [standard/09 §9.2 P1](../standard/09-test-cases.md#9.2) — нормативно обязателен для RENAR-conformance. **Статус в Raven runtime (на 2026-05-15):** doc-type не реализован в текущей версии; реализация — на стороне Raven project (upstream). Адаптация RENAR-conformance для Raven substrate требует завершения этого doc-type.

**Migration plan (до момента появления native `test_case` doc-type):**

1. **Не объявлять RENAR-conformance** для проектов на Raven substrate, использующих TC как нормативный артефакт, до выпуска Raven runtime с `test_case`. Объявление conformance в этой ситуации — non-conformant (нарушение [standard/14 §14.3.4](../standard/14-conformance.md#14.3.4) mandatory clause closed list типов TC).
2. **Альтернатива на git substrate.** Проекты, которым TC нужны сейчас, могут начать с [03-tool-guide-git](03-tool-guide-git.md) substrate и мигрировать на Raven после релиза `test_case` doc-type.
3. **Tracking:** статус реализации `test_case` в Raven отслеживается на стороне Raven project; ссылку на upstream issue/release notes — см. в release notes RENAR при появлении.

Целевая структура doc-а после реализации:

```json
{
  "_id": "myproj:test_case:TC-23",
  "doc_type": "test_case",
  "slug": "TC-23",
  "test_type": "system",          // closed list: acceptance/ux/system/contract/eval/security
  "status": "passing",
  "verifies": [{"id": "SR-05", "version": "1.2"}],
  "automation_location": "tests/test_login.py::test_sr05",
  "last_run": { "result": "pass", "at": "...", "requirement_version": "1.2" }
}
```

### 4.5 `verification_runs`

Аудит-лог прогонов TC.

```json
{
  "_id": "myproj:verification_runs:run-2026-05-15-001",
  "doc_type": "verification_runs",
  "tc_id": "TC-23",
  "ran_at": "...",
  "result": "pass",
  "duration_ms": 142,
  "requirement_version_at_run": "1.2",
  "evidence_link": "..."
}
```

### 4.6 `tool_event`

Универсальный audit log; capability V6 источник.

```json
{
  "_id": "myproj:tool_event:evt-...",
  "doc_type": "tool_event",
  "actor": "@user-or-bot",
  "action": "transition_status",
  "target": "myproj:requirement_meta:BR-12",
  "before": { "status": "draft" },
  "after": { "status": "approved" },
  "at": "..."
}
```

---

## 5. `_rev` token как version pin

В git-substrate реализация ссылается на конкретный commit submodule. В Raven эквивалент — `_rev` token документа.

### 5.1 Pinning в TC

```yaml
verifies:
  - id: "SR-05"
    version: "1.2"
    rev: "5-abc..."     # CouchDB _rev на момент создания TC
```

При write в CouchDB Gateway проверяет: `_rev` указанный в `verifies[].rev` соответствует current `_rev` linked SR. Если разошлось — TC становится stale (V6 ловит).

### 5.2 Atomic delta

Изменение требования = новый `_rev`. Никакого «merge conflict» — последний write побеждает (CouchDB last-write-wins на conflict). Gateway добавляет business-rule: write в `approved` requirement требует delta-ТЗ workflow (см. §7).

---

## 6. Hub UI workflow

Hub UI — web-frontend для Raven, единственный человеческий интерфейс для non-technical stakeholder.

### 6.1 Approve workflow

1. Reviewer открывает артефакт в Hub.
2. Видит diff против предыдущего `_rev`.
3. Inline comments по body / frontmatter.
4. «Approve» button → Gateway endpoint `/transition` с проверкой:
   - У reviewer есть RBAC permission «approve» для этого doc-type.
   - Previous status — legitimate predecessor нового status.
   - Если AI-generated: adversarial critic уже прошёл (для RENAR-5).
5. Gateway создаёт `tool_event` с before/after status; CouchDB пишет новую ревизию.

### 6.2 diff и history

Hub UI рисует diff между любыми двумя `_rev` через CouchDB `?revs_info=true` API. История — линейная (без branches; для branching используется git substrate или специальный `proposed_changes` doc-type).

### 6.3 Comment threads

Comments — отдельный doc-type `comment_thread` с `target: <artefact-id>:<rev>`. Привязаны к конкретной ревизии — после новой ревизии открываются как «outdated» (как в GitHub PR review).

---

## 7. Delta-ТЗ workflow в Raven

Аналог 14-шагового git-flow ([03 §7](03-tool-guide-git.md)):

1. **Создать delta-ТЗ:** Hub UI → New → ТЗ doc-type → forward от previous TZ.
2. **AI-агент** через Gateway MCP делает impact analysis; помечает затронутые TC через update `test_case.status: obsolete-pending`.
3. AI-агент создаёт / обновляет `requirement_meta` / `spec_meta` / `test_case` через MCP. Каждое изменение — новая ревизия с новым `_rev`.
4. Adversarial critic (RENAR-5) запускается автоматически — Gateway hook на pre-approve.
5. **Reviewer в Hub** видит «pending changes» bundle (все ревизии в этом delta-ТЗ).
6. Approve каждого артефакта → status transition → `tool_event` audit.
7. Coverage / Requirements views (V4) пересчитываются автоматически (CouchDB design view reduce).
8. Implementation: TR-задачи создаются в KAI / TAUSIK с linked `requirement_meta._rev`.
9. После прохождения TC (`verification_runs.result: pass`) — status promotion в `verified`.

Никакого «отдельного submodule bump» — `_rev` pinning встроен в `verifies[].rev` поле TC.

---

## 8. Изоморфизм Raven ↔ Git (migration)

Каждое поле git frontmatter имеет точное соответствие в CouchDB документе. Миграция — механическая операция, не «переписывание».

| Git frontmatter | CouchDB документ |
|---|---|
| `id: "BR-01"` (filename + frontmatter) | `slug: "BR-01"` + `_id: "<project>:requirement_meta:BR-01"` |
| `type: BR` | `level: "BT"` |
| `status: approved` | `status: "approved"` |
| `parent.id: BR-01` | `parent: "BR-01"` |
| `verified-by: [TC-01]` | `verified_by: ["TC-01"]` |
| `verifies[].requirement-version: 1.2` | `verifies: [{"id": "SR-01", "version": "1.2", "rev": "..."}]` |
| Git commit history | `_rev` chain + `tool_event` audit log |

### 8.1 Migration git → Raven

Tooling: `tausik renar migrate --to raven --project <slug>`:
1. Парсит все .md файлы в `<project>.req/`.
2. Конвертирует frontmatter → JSON по таблице соответствия.
3. POST в Gateway `/bulk_import` endpoint.
4. CouchDB пишет документы; Gateway генерирует `tool_event` для каждого с `actor: migration-bot`, `action: import`.
5. После миграции `req.substrate: raven` в `<project>.src/.tausik/config.json` — substrate переключён.

### 8.2 Export Raven → git snapshot

Обратное: `tausik renar export --to git --project <slug>`:
1. Gateway `/export` endpoint возвращает tarball с .md файлами.
2. Распаковка в `<project>.req/` директорию; начинается new git history.
3. Используется для: backup, federation с external partners, миграция назад если Raven не подошёл.

Export — snapshot, не bidirectional sync. В каждый момент времени только один substrate — SSoT ([07-failure-modes §2.3](07-failure-modes.md)).

---

## 9. Meilisearch FTS

CouchDB не имеет встроенного полнотекстового поиска; для этого — Meilisearch.

- Each `<project>` имеет свою Meilisearch index с body всех `requirement_meta` / `spec_meta` / `adapt_meta`.
- Index обновляется через CouchDB changes feed → Gateway → Meilisearch (eventually consistent, обычно < 1s lag).
- Hub UI поиск: `GET /search?q=...` → Meilisearch → возвращает ranked артефакты.
- TAUSIK MCP-tool `mcp__codebase-rag__search_code` использует тот же endpoint для cross-проектного поиска (federation, §10).

---

## 10. Federation между проектами

Окружение с несколькими проектами на общей Raven runtime. Federation:

- Cross-project references: `requirement_meta.parent: "<other-project>:requirement_meta:BR-99"` — CouchDB позволяет cross-database refs.
- Cross-project search: Meilisearch federation поверх per-project indices; query одной командой по всем проектам.
- SPEC-INT (integration spec) — живёт в `system.req` Raven database, ссылается на SR в подсистемных databases.
- RBAC на уровне Gateway: `org-admin` видит все проекты; team — только свой.

---

## 11. Cross-references

- [standard/11-substrate-versioning](../standard/11-substrate-versioning.md) — нормативные требования к substrate (V1-V6).
- [reference/02-schemas](../reference/02-schemas.md) — frontmatter schemas; те же поля mapping на CouchDB JSON.
- [03-tool-guide-git](03-tool-guide-git.md) — substrate alternative; изоморфизм git ↔ Raven.
- [07-failure-modes §2.3](07-failure-modes.md) — source-of-truth drift между substrates.
- [02-transition-guide](02-transition-guide.md) — путь от pre-RENAR к RENAR-N через любой substrate.

---

## 12. Open questions

- **`test_case` doc-type — закрыт по дизайну, остаётся upstream Raven implementation gap.** Целевая схема описана в §4.4; migration plan для проектов до релиза — также в §4.4 (не заявлять RENAR-conformance / использовать git substrate). Owned by Raven project.
- **Meilisearch federation:** cross-project query API не finalized; нужен design. Owned by Raven project.
- **Backup / disaster recovery для CouchDB:** native replication работает, но что про восстановление после полного data loss? Owned by Raven project (operational concern).
- **`tool_event` retention:** бесконечно или TTL? Если TTL — что считается audit trail для compliance (см. [06-compliance](06-compliance.md))? Owned by Raven project + RENAR-side: closed list compliance frameworks и их retention requirements ([guide/06](06-compliance.md)).
- **RBAC granularity:** на уровне проекта или на уровне doc-type? Сейчас на уровне проекта. Owned by Raven project.

