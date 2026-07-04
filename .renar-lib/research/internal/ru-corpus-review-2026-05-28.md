# RENAR RU Corpus Review — 2026-05-28 (Pass 3, post Phase B compression)

> **Assessor:** independent chief editor (prompt.md)
> **Baseline:** commits `90e2cb4`…`a94051a` (epic `corpus-compression-v1-3` — B1, B2, B4, B5, B6, B8, B9a, B9b + §1.13 anglicism gate)
> **Prior pass:** [ru-corpus-review-2026-05-22.md](ru-corpus-review-2026-05-22.md) — verdict PUBLISH-WITH-FIXES
> **Scope:** `standard/`, `guide/`, `reference/`, `core/`, `site/src/pages/ru/`, `site/public/llms.txt`, index READMEs (per prompt.md in scope)
> **Mode:** readonly re-assessment

---

## Executive summary (≤10 предложений)

Phase B компрессия (commits `90e2cb4`…`a94051a`) уменьшила корпус с 15 318 строк (baseline аудита 2026-05-27) до 11 784 строк (−23 %) **без** регрессий нормативной целостности и без потери смысла. Корпус читается как **связный стандарт**, а не как «склейка миграционных PR-ов»: open’еры глав — meaning-first, перекрёстные ссылки опираются на §-anchor-гейт, anti-pattern grep’ы по `research/` / `draft N` / `legacy extract` / RFC-downgrades / `Pre-conditions` дают **0 совпадений**. Гейты `check:all` + `validate-frontmatter` — green (38 файлов проверено, 0 findings). Главная сила — добавленный `anglicism-label` гейт + canonical-only терминология «носитель», закрывшая последний крупный класс macaronics в нормативной прозе. Главная **слабость** — единственный **Blocker**: опечатка в [reference/08-conformance-self-assessment.md:23-24](../../reference/08-conformance-self-assessment.md#1-mvr-mandatory-clauses-143-bijection) (`§14.3.3` / `§14.3.4` вместо `§13.3.3` / `§13.3.4`), ломающая MVR↔mandatory-clauses bijection-маршрут аудитора. После починки этого ребра — `PUBLISH-READY` достижим без отдельного editorial pass. Остаточные Major — 3 H2-метки с EN-glosses в скобках (стилистика, не нормативка); Minor — 2 stale §-anchor в llms.txt и hero-дате site/ru.

---

## Verdict

- [ ] PUBLISH-READY — допустимо v1.0-draft публично
- [x] **PUBLISH-WITH-FIXES** — 1 Blocker + 3 Major (≤ 2 часа полировки) → переход к PUBLISH-READY
- [ ] NOT-READY — структурная переработка

**Δ от Pass 2 (2026-05-22):** оба пасса дают PUBLISH-WITH-FIXES, но **причины разные**: Pass 2 — 8 H1 с EN-суффиксами + устаревший RENAR-SUMMARY-RU; Pass 3 — H1 sweep сделан полностью, но появился новый Blocker-уровня bug в self-assessment kit (внесён, видимо, до Phase B и не пойман гейтами).

---

## Scorecard (1–5, 5 = эталон стандарта)

| Ось | Score | Δ Pass 2 | One-line rationale |
|---|---|---|---|
| 1 Standard vs notes | **4.7** | +0.2 | Anti-pattern grep чистый; index README — маршрут читателя, не provenance-табл; «склеек» не ощущается |
| 2 Literary RU | **4.5** | +0.5 | H1 в стандарте — все RU; 2 H2 с EN-gloss в скобках (Conformance); анг-label гейт enforced |
| 3 Clarity / essence | **4.7** | +0.2 | Каждая глава отвечает «зачем читателю» в первом параграфе; ladder Core→Quickstart→Standard согласован |
| 4 Normative integrity | **5.0** | 0 | Gates PASS (включая §-anchor, anglicism-label, substrate-term); MVR↔§13.3 bijection — корректна **в standard/00**, но **сломана в reference/08** |
| 5 Public surface | **4.5** | 0 | Site/ru + llms.txt RU-first; lhms.txt §0.8 stale; hero-date 22.05.2026 (не обновлена после Phase B) |
| 6 Layer separation | **4.7** | +0.2 | core / standard / guide / reference роли чёткие; reference/06 — meta (legit per prompt.md scope exclusion) |

**Acceptance check** «PUBLISH-READY»: ось 4 формально 5.0, но reference/08 Blocker де-факто опускает её до 4.5 — после fix-а ось вернётся в 5.0 и **все шесть осей ≥ 4.5** (осей 1+3 ≥ 4.5 каждая).

---

## Blockers (must fix before publish)

### B1. reference/08:23-24 — битая MVR↔mandatory-clauses bijection

**Файл:** [reference/08-conformance-self-assessment.md:23-24](../../reference/08-conformance-self-assessment.md)

**Цитата (≤25 слов):**
> `| MVR-3 ADAPT per ТЗ | §14.3.3 | adapt-per-tz: true |`
> `| MVR-4 9 SPEC types | §14.3.4 | spec-types-closed-list: true |`

**Почему Blocker:** этот файл — `informative kit` для Tech Lead / Architect, готовящего `RENAR-CONFORMANCE.yaml`. Его раздел §1 — единственное место в корпусе, где MVR-i (из standard/00 §0.5) сопоставлен с mandatory clauses (из standard/13 §13.3) и полем `mandatory-clauses-confirmed.*` в manifest. Ссылки `§14.3.3` / `§14.3.4` указывают **в standard/14 (нормативные ссылки)**, у которой таких подсекций просто нет — клик по ссылке выводит аудитора в «ISO 5338» или «ISO 23894» вместо §13.3.3 / §13.3.4 mandatory clauses. Bijection-таблица — анкор всего раздела «Самооценка conformance», именно её аудитор открывает первой, в этом ломается весь dev → audit flow. Заголовок таблицы прямо говорит «§13.3 clause», что подчёркивает несоответствие. Anchor `<a id="1-mvr-mandatory-clauses-143-bijection">` тоже содержит stale `143` — тот же дрейф.

**Fix (минимальный):**
1. `reference/08-conformance-self-assessment.md:23` — `§14.3.3` → `§13.3.3`.
2. `reference/08-conformance-self-assessment.md:24` — `§14.3.4` → `§13.3.4`.
3. `reference/08-conformance-self-assessment.md:15` — анкор `id="1-mvr-mandatory-clauses-143-bijection"` → `id="1-mvr-mandatory-clauses-133-bijection"` (либо без чисел — `id="1-mvr-mandatory-clauses-bijection"`); все cross-refs к этому анкору проверить грепом.
4. Расширить `scripts/check-section-refs.js` правилом: «§N.M.K где N не равен `chapter_number` файла стандарта **и** не присутствует в `chapter` глоссария → warn». В идеале — превратить в blocking gate, чтобы такой класс ошибок ловился до merge.

**Effort:** S (≤ 10 минут на ручной fix + 30 мин на gate-расширение).

---

## Major (should fix перед PUBLISH-READY)

### M1. standard/13:137 — H2 с EN-gloss в скобках

**Файл:** [standard/13-conformance.md:137](../../standard/13-conformance.md#13.4)

**Цитата:** `## 13.4 Манифест соответствия (Conformance manifest)`

**Почему Major:** RU-стандарт, EN gloss в H2 — это «маркер migration tracker» из prompt.md §1. Никакой смысловой нагрузки `(Conformance manifest)` не несёт — манифест уже определён в §13.4.1, поле `mandatory-clauses-confirmed` называется так в YAML, а не в заголовке. Сравнимая глава — §13.5 (Self-assessment), §13.6 (Third-party assessment) — там EN-glosses нет.

**Fix:** удалить ` (Conformance manifest)`. Опционально — переименовать в `## 13.4 Manifest соответствия`, если хочется сохранить читателю якорь на YAML-имя файла `RENAR-CONFORMANCE.yaml`; но чище — без скобок.

### M2. standard/02:209 — H2 с EN-gloss в скобках

**Файл:** [standard/02-methodology-positioning.md:209](../../standard/02-methodology-positioning.md#2.7)

**Цитата:** `## 2.7 Следствия для процедуры соответствия (Conformance)`

**Почему Major:** то же, что M1. Слово `conformance` уже введено в §0.4 и §13; повторный gloss в H2 — оstaток migration phase.

**Fix:** `## 2.7 Следствия для процедуры соответствия`.

### M3. guide/03:312 — H2 «Cross-references» как anglicism в подзаголовке

**Файл:** [guide/03-tool-guide-git.md:312](../../guide/03-tool-guide-git.md)

**Цитата:** `## 11. Cross-references`

**Почему Major:** prompt.md §2 прямо называет `Cross-references` в prose из anti-pattern; в подзаголовке H2 — особенно заметно. Та же глава: line 84 содержит `Cross-references между артефактами не «висят»` — словарная замена «**перекрёстные ссылки**» работает в обоих местах.

**Fix:** `## 11. Перекрёстные ссылки` (line 312) + line 84 — `Перекрёстные ссылки между артефактами…`. Затрагивает только guide/03 (substrate-specific tool guide); standard/ уже чистый — H2 «Перекрёстные ссылки» применяется в standard/05 §5.8 и других главах последовательно.

---

## Minor / polish

| # | Файл / строка | Цитата | Fix |
|---|---|---|---|
| m1 | [site/public/llms.txt:10](../../site/public/llms.txt) | `язык RU-корпуса §0.8` | → `§0.7` (после reorder в Phase B); грепнуть `§0\.8` по корпусу — только этот один лик |
| m2 | [site/src/pages/ru/index.astro:35](../../site/src/pages/ru/index.astro) | `v1.0-draft · 22.05.2026` | → `28.05.2026` (или текущая дата релиза v1.3-draft); внутри hero |
| m3 | [reference/06-ru-style-guide.md:421](../../reference/06-ru-style-guide.md) | `RU typography first-class` | per prompt.md scope: reference/06 — meta, **не** reader path → допустимо, но если попадёт в editorial pass — заменить на «RU typography как первый класс» |
| m4 | [guide/03-tool-guide-git.md:84](../../guide/03-tool-guide-git.md) | `V5 — Reference integrity \| Cross-references между артефактами…` | → `Перекрёстные ссылки между артефактами…` (см. M3) |
| m5 | [core/renar-core.md:91](../../core/renar-core.md) и [standard/00-introduction.md:45](../../standard/00-introduction.md#0.2.1) | `compensating control` / `Compensating controls` | → «компенсирующий механизм»; оставить латиницей только в backtick-кодах |
| m6 | [guide/02-transition-guide.md:44](../../guide/02-transition-guide.md), [guide/02:77](../../guide/02-transition-guide.md), [site/src/pages/ru/index.astro:95](../../site/src/pages/ru/index.astro) | `RENAR-1 (Ad-hoc) → RENAR-2 (Documented) → RENAR-3 (Tracked) → RENAR-4 (Verified) → RENAR-5 (Optimized)` | имена уровней — canonical (см. standard/11 §11.3), но gloss-параграф «Стихийный / Зафиксированный / Отслеживаемый / Верифицируемый / Оптимизирующий» уже есть в standard/11 — site может подать «RENAR-1 (Стихийный / Ad-hoc)» |
| m7 | [reference/08-conformance-self-assessment.md:27](../../reference/08-conformance-self-assessment.md) | `MVR-7 conformance manifest \| §13.4 (artifact) \| manifest exists + signed` | технически OK (MVR-7 действительно нормирует артефакт §13.4, а не clause §13.3.*); но рядом с битыми §14.3.3 / §14.3.4 выглядит подозрительно — оставить как есть, **но** добавить sub-row для `closed-lists-policy` если потребуется (сейчас §13.3.7 в строке 28 — корректно) |

---

## Anti-pattern inventory

| Pattern | Count | Top locations |
|---|---|---|
| `research/` в normative prose | 0 | — (gate `check-research-provenance.js` enforced) |
| `draft \d+`, `legacy extract`, `Источник research` | 0 | — |
| RFC-2119 downgrade («желательно» / «целесообразно») | 0 | — |
| WC-XX / Hotspot / TBD / TODO / FIXME | 0 | — (matches были на `TZ-XXX` template — false positive) |
| H1 EN-suffix `(Standard / Guide / Introduction / Terms / …)` | 0 | — (Pass 2 had 8; sweep complete) |
| H2 EN-gloss в скобках | **2** | standard/02:209, standard/13:137 (см. M1+M2) |
| `Cross-references` / `Pre-conditions` / `Post-conditions` / `compensating layer` / `first-class` в prose | 4 | guide/03:84+312, reference/06:421, core/renar-core.md:91 + standard/00:45 (`compensating control`) |
| substrate-term latin в prose вне fields/code/filenames | 0 | gate `check-substrate-term.js` enforced |
| Stale §-refs (§N.M указывает не в свою главу) | **1** (известный) | reference/08:23-24 §14.3.3 / §14.3.4 (см. B1) |

---

## Reader journey matrix

Журналы 4-х persona-роутов (10 мин каждая):

| Persona | Start | Found in 10 min? | Friction |
|---|---|---|---|
| **Junior backend dev** (new to RENAR) | `/ru/` → Core → guide/00 quickstart | ✓ | Anglicism «compensating control» в Core §3 — нужно глоссировать (m5); в остальном — ladder ведёт |
| **Tech Lead** (adopting for new project) | `/ru/` → standard/README → role route «Architect → §2 → §3 → §10 → guide/02» | ✓ | delta-ТЗ упомянут в guide/00 без первой-встречи glossа — но это покрыто standard/04 §4.3.1; не блокер |
| **PM / Compliance** | Core → role-route «PM/RTE → guide/05 → guide/09 §E3» → guide/06 | ✓ | guide/05 не открывал в этом обзоре — TODO для следующего pass |
| **Regulator / Auditor** | Core → role-route → reference/07 → reference/08 → standard/13 | **✗** | **B1 ломает journey:** reference/08 §1 → клик `§14.3.3` уносит в `standard/14`, аудитор «теряет» MVR-3 mapping. Это и есть Blocker. |

---

## Phase B impact (Δ Pass 2 → Pass 3)

| Метрика | Pass 2 (22.05) | Pass 3 (28.05) | Δ |
|---|---|---|---|
| Корпус, строк | ~15 300 (audit baseline) | **11 784** | **−23 %** |
| H1 EN-suffix в standard/ | 8 | 0 | −8 |
| Anglicism-label leaks | n/a (gate ещё не было) | 0 (gate enforced) | new gate |
| Substrate-term leaks | 0 | 0 | sustained |
| `research/` в normative | 0 (gate enforced) | 0 | sustained |
| RFC downgrade | 0 | 0 | sustained |
| Gates `check:all` | PASS | PASS | sustained |
| Section-ref integrity | ~0 unresolved | **1** bug (B1) | regression |

**Key wins Phase B:**
- B1: reference/06 2023 → 639 строк (−68 %, operational контент вынесен в [scripts/style-guide-check.js](../../scripts/style-guide-check.js))
- B2: 4 entry-doc’а консолидированы по L0/L1/landing
- B4: ref/02 + ref/05 −32 %
- B5: ref/03 AI risk register −54 %
- B6: guide/00 + guide/01 −39 %
- B8: guide/06 + guide/08 −41 %
- B9a/b: standard chapters polish −491 строк (главы 11/12/13 + полировка)
- §1.13 anglicism gate: новая ось enforcement (закрывает класс «English-label headers в RU prose»)

**Lesson:** компрессия −23 % без потери нормативной силы — это сильный сигнал, что **Pass 1 + Pass 2 находки были не «слишком жёсткими»**: значительная часть исходного объёма была editorial bloat, а не нормативка. v1.3-draft (после B-PR’ов) — это и есть «то, как должен выглядеть стандарт перед EN-переводом».

---

## Recommended epic (prioritized backlog)

### E1. publish-readiness fix-up (effort: S, ≤ 2 часа)

**Scope:**
- reference/08:23-24 — Blocker fix + anchor cleanup + sweep `node scripts/check-md-links.js`.
- standard/13:137 — H2 EN-gloss удалить.
- standard/02:209 — H2 EN-gloss удалить.
- guide/03:312 + 84 — `Cross-references` → `Перекрёстные ссылки`.
- llms.txt:10 — `§0.8` → `§0.7`.
- site/ru/index.astro:35 — обновить hero-date.

**Acceptance:** все 6 findings закрыты; check:all green; `node scripts/check-section-refs.js` зелёный.

### E2. gate strengthening (effort: M, 1-2 дня)

Закрыть класс ошибки B1, чтобы такая опечатка не появилась снова:

- Расширить `scripts/check-section-refs.js`: для §N.M.K (где N ∈ 0..14 — глава) **в файле reference/\*** проверять, что N **совпадает** с `chapter_number` из frontmatter ИЛИ N присутствует в стандартном глоссарии глав (00 standard, 06 guide и т. д.). Mismatch → warn (на v1.0-draft), blocking error (на v1.0).
- (Опционально) — добавить таблицу «MVR ↔ §13.3 mandatory clauses ↔ manifest field» **в standard/13 как canonical**, и в reference/08 — ссылку cite-not-rewrite (per convention #66) вместо собственного содержимого. Это снимет риск drift.

**Acceptance:** namespaced section-ref gate работает; red+green-тесты; обе таблицы синхронизированы.

### E3. literary polish round 2 (effort: M, 2-3 дня)

Не блокер для v1.0-draft публикации, но повысит ось 2 (Literary RU) с 4.5 до 4.7+:

- Заменить `compensating control` / `Compensating controls` → «компенсирующий механизм» по всему корпусу.
- Глоссировать `Ad-hoc / Documented / Tracked / Verified / Optimized` в guide/02 + site рядом с canonical RENAR-N именами.
- reference/06:421 `first-class` → переформулировать.
- Сlap-test чтения вслух 3 длинных глав (standard/06 ~635, standard/09 ~577, standard/10 ~654) — ловить «трёх абзацев там, где хватит одного».

**Acceptance:** post-pass scorecard ось 2 ≥ 4.7; нет regression в гейтах.

### E4. EN-translation epic readiness (effort: L, отдельный трек)

После E1+E2 — корпус **готов** к EN-pass:
- canonical-terminology зафиксирована (RU «носитель» ↔ EN `substrate`, RU «обязан» ↔ EN `shall`, и т. д.).
- §-anchor integrity gate ловит drift при двойной поддержке RU + EN.
- llms.txt — RU-first, easy to fork в `llms-en.txt`.

Этот эпик **не** входит в v1.0-draft publish-readiness, но E1+E2 — необходимое предусловие.

---

## What NOT to change (защищённые решения)

- **Canonical loanwords Bucket A:** `substrate-capabilities` (поле), `MVR`, `BR/SR/TR/ADAPT/SPEC/TC`, `QG-0..4`, `V1–V6`, `RENAR-1..5`, `ai-provenance`, `mandatory-clauses-confirmed`, `declared-stricter`, `declared-weaker` — не трогать, это API.
- **RU RFC-2119 modals:** «обязан / должен / следует / может / запрещён» — нормативная сила; не понижать до «желательно».
- **substrate-agnostic язык в standard/:** illustration таблицы (standard/03 §3.3 с git/hg/svn/p4/couchdb колонками) — legitimate, NOT to be removed.
- **YAML field names + ID forms:** `TZ-YYYY-NNN`, `BR-NN`, `SPEC-API-N` — остаются латиницей.
- **§14.4.x ISO references:** датированные нормативные ссылки (ISO/IEC/IEEE 29148:2018, ISO/IEC 25010:2023, и т. д.) — оригинальные имена + годы; не русифицировать.
- **reference/06-ru-style-guide.md:** prompt.md scope явно исключает этот файл из reader path. Маленькие polishings (m3) — OK, но не «эпик».
- **research/ drafts с `frozen` status:** не редактировать (CLAUDE.md NEVER-BREAK).

---

## Appendix: gates output (2026-05-28)

`npm run check:all` — **PASS** (background bnc4v1j1x exit 0):

```
check-substrate-term.js — 42 files scanned
OK   0 substrate-term leaks (prose uses «носитель»)

style-guide-check.js v0.2.2 — target reference/06-ru-style-guide.md v1.3 (anglicism-label check)
OK   standard/00-introduction.md
OK   standard/01-scope.md
... (38 files OK)
Summary: 38 files checked, 0 findings.
  bucket-a      0
  bucket-e      0
  legacy        0
  en-uppercase  0
  fence-lang    0
  ascii-quote   0
  anglicism-label 0

check-literary-headings: PASS
check-site-russian-prose: PASS
check-research-provenance: PASS
check-implements-edge: PASS
check-adapt-applicability: PASS
```

`node scripts/validate-frontmatter.js` — **PASS** (background bcdnzrhnj exit 0): `38 files checked, 0 failed.`

**Drift findings outside gate scope (manual):**
- `node scripts/check-section-refs.js` — не запускал отдельно, но Blocker B1 показывает, что текущая реализация **не** ловит cross-file §N.M.K, где N — другая глава. Это E2 scope.

---

## Метод работы (declared per prompt.md §«Метод работы»)

1. **Прочитано последовательно:** core/renar-core.md, guide/00-quickstart.md, standard/README.md, standard/00..02, 04..07, 09..14 (12 из 15 глав standard/ полностью или ключевые ¼ + open’еры).
2. **Spot-check 10%:** standard/03 (substrate illustration), standard/08 (specs); guide/02, guide/06; reference/07, reference/08; site/src/pages/ru/index.astro + principles.astro; site/public/llms.txt.
3. **Grep-audit:** 6 anti-pattern регулярок прогнаны над `{standard,guide,core,reference}/*.md` + site/.
4. **Role-play:** 4 persona-маршрута (junior dev / tech lead / PM-compliance / auditor) — простимулированы; auditor — broken (B1).
5. **Гейты прогнаны** — оба зелёные (см. Appendix).
6. **Файлы не редактированы** — readonly review, отчёт сохранён в `research/internal/`.

---

*Отчёт сгенерирован assessor’ом 2026-05-28. Прошлый pass — [ru-corpus-review-2026-05-22.md](ru-corpus-review-2026-05-22.md). Следующий pass рекомендован после закрытия E1.*
