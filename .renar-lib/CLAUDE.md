# RENAR — Requirements Engineering & Normative Adaptive Regulation

AI-нативный самостоятельный стандарт и методология инженерии требований. Дополняет SENAR; работает независимо.

## Stack
Markdown (normative spec) | Astro (site, renar.tech — local docker dev на порту 4321) | TAUSIK / KAI (implementation, planned)

## What Lives Here
- `standard/` — normative spec, 15 chapters (00-14), RU (primary) + EN (`standard/en/`)
- `core/` — gentle single-doc intro (RENAR Core)
- `guide/` — practical guides (11 chapters: quickstart through v1 migration)
- `reference/` — appendices (glossary, schemas, AI risk register, style guides, ISO trace matrix, conformance kit, pedagogical density)
- `research/` — drafts (обоснования, не нормативка); `ru-world-class-gaps.md` — WC roadmap
- `scripts/` — sync-site-content, validate-frontmatter, validate-schema-examples, check-md-links, check-site-parity, git-substrate утилиты
- `site/` — Astro RENAR site (bilingual RU/EN: /ru/ default + /en/, switcher, hreflang)

## Boundaries
- RENAR = стандарт, НЕ реализация
- Реализация — TAUSIK skill `req` (planned)
- Координация — через Finka (TBD)

## NEVER BREAK
- Git: ALWAYS ask before commit/push
- Substrate-agnostic язык в normative главах; git-specifics — только в `guide/` или приложениях
- Не редактировать `research/` drafts с `frozen` статусом
- Не вписывать `git`, `commit`, `PR` в normative тексте — V1-V6 capabilities only (draft 19)
- Closed list policy: новые типы SPEC / категории backward / гейты добавляются только через PR в стандарт
- **Англицизмы в прозе** (CRITICAL при компрессии bullet-списков в inline-параграфы): bold-label headers (`**Actor:**`, `**Default:**`, `**Override:**`) и стандалоны английских слов мид-prose (`actor`, `evidence`, `cadence`, `trigger`, `denial`, `result`, `recovery`, `review`, `signal`, `manifest` без определителя) — **запрещены вне backtick-кода / YAML / canonical-API-полей**. Канонические русские эквиваленты — [`reference/06 §1.10`](reference/06-ru-style-guide.md). Quick synonym map: Actor=Участник, Methodology=Методология, Evidence=Доказательная база/Свидетельства, Default=По умолчанию, Override=Переопределение, Cadence=Периодичность, Result=Результат/Итог, Denial=Отказ, Joint=Совместный, Single=Одиночный, Split=Разделённый, Recovery=Восстановление, Trigger=Триггер (русифицировано) или «поводом для», Signal=Сигнал, Review=Обзор (если не canonical RENAR-термин). Backtick-код и YAML-поля `actor`, `result` — ОК, это API.

## Версионирование стандарта
- v0.1-draft: foundation (research drafts + skeleton structure), 2026-05-13
- v1.0-draft: RU corpus world-class (label 2026-05-22)
- v1.1-draft: partner-GAPs integration (ADR-001..004, 2026-05-26):
  - GAP-03: §0.2.4 AI-агент как штатный исполнитель (нерасширяющее)
  - GAP-01: BR.implements[] межуровневое ребро §6.5.2/§6.8.2/§6.10.3/§13.3.8 + scripts/check-implements-edge.js
  - GAP-04: BR-light в core/renar-core.md (Core non-normative)
  - GAP-02: ADAPT-full/light §7.4.1 + §7.12 (ТЗ↔RENAR) + MVR-3 reformulation + scripts/check-adapt-mode.js
- v1.2-draft: partner pushback на #2 и #4 (ADR-005, ADR-006; ADR-002 + ADR-004 → superseded; 2026-05-26):
  - Issue #2 буквальная альт. B (ADR-006): ADAPT-reactive — создаётся только при наличии findings; full/light режимы удалены; source.adapt conditional; source.tz-section + adversarial-review-ref всегда mandatory; scripts/check-adapt-mode.js → check-adapt-applicability.js; MVR-3 reformulation
  - Issue #4 (ADR-005): Core pivot — концептуальный обзор для человека-читателя, без техдеталей; core-mode (§1.5.4) deprecated; §0.6 переориентирован; ≤ 200 строк
- v1.3-draft: ADAPT temporal/multiplicity/supersession (ADR-007, GitLab #7 — партнёр ответил Q1-Q5 2026-06-04, принят 2026-06-05):
  - Стадийно-независимый реактивный триггер ADAPT (§7.1/§7.3/§7.4.1) — находка на любой стадии деривации, не только при импорте ТЗ
  - Множественность: MVR-3 #3 → «ноль или более» корневых ADAPT на ТЗ (Q3 полная N, Alt C); поле trigger-stage
  - Supersession (§7.5/§7.6.4): superseding-ADAPT отменяет ранее верное решение; status += superseded; client-signature всегда при contractual outcome (Q2); отдельного QG нет — QG-3 (Q5); scripts/check-adapt-supersession.js
- EN edition (epic en-translation, 2026-06-06, decision #79 ADR-008 + #80): полный второй язык EN рядом с RU (primary). EN Style Guide (reference/en/06, инверсия RFC-2119 полярности) + EN глоссарий (reference/en/01) + конвенция `<секция>/en/<имя>.md` + «ТЗ»→TZ. Переведены standard/en (16), reference/en (12), core/en (2), guide/en (12). Гейты: RU-scoped checks исключают lang:en; check-rfc-modals двойной RU/EN; новый check-en-parity.js (двусторонний паритет) в check:all. Интеграция: build-pdf-en.js (npm pdf:en, 4 PDF), bilingual Astro site (/en/, switcher, hreflang, RU default), repoint-en-crosslinks.js (cross-section ссылки → EN-аналоги). EN-блокер для v1.0 снят.
- v1.0: после согласования партнёров (EN translation выполнен)

<!-- DYNAMIC:START -->
## Current State
Session: none | Branch: main | Version: 1.4.0
Tasks: 86/86 done, 0 active, 0 blocked
<!-- DYNAMIC:END -->
