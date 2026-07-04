---
title: "Style Guide §3 (draft): Formatting conventions"
status: draft
phase: "Phase 2 Style Guide §3 — compile в ru-style-lock"
epic: ru-normative-pass-v1
task: ru-style-formatting
draft-date: 2026-05-16
target-final-path: "reference/06-ru-style-guide.md (после compile в Phase 2 lock-in)"
lang: ru
---

# Style Guide §3: Formatting conventions (DRAFT)

> **Phase 2 draft.** Этот документ — рабочий черновик §3 будущего [`reference/06-ru-style-guide.md`](../reference/06-ru-style-guide.md). Задача [`ru-style-lock`](#) (Phase 2 final) скомпилирует §1+§2+§3 в финальный normative artifact.
> Статус: **draft** — может быть скорректирован Phase 3 pilot checkpoint feedback.
> Cross-link: [§1 terminology draft](ru-style-guide-draft-section-1-terminology.md), [§2 RFC-2119 wording draft](ru-style-guide-draft-section-2-rfc2119.md), [`research/ru-editorial-audit.md`](ru-editorial-audit.md) (F3 systemic finding), [`research/ru-style-inconsistencies.md`](ru-style-inconsistencies.md) §3.2-§3.5 (citations + fences + headings + tables data).

## §3.0 Назначение

§3 фиксирует **canonical formatting conventions** для RU normative корпуса RENAR Standard. Регламентирует:

- citation conventions (bare `§X.Y` / markdown link / inline «глав* X») — закрывает Phase 1 F3;
- code-fence language tag policy (whitelist + plain-text + markdown-examples);
- heading conventions (standard/ dotted vs guide/ plain split + depth rule);
- tables / lists de-facto convention endorsement (bullets `-`, alignment-less `---`);
- inline code (backticks) vs emphasis (bold / italic) conventions;
- frontmatter YAML formatting (field order, quoting, lang field);
- RU typography (кавычки `«»`, em-dash, non-breaking space, числительные форматы);
- cross-file link conventions (relative paths, anchor case, dead-link protection).

§3 — **normative** часть Style Guide. Phase 5 chapter pass обязан валидировать соответствие §3 по каждой главе (см. [§3.10 Validation](#310-validation)).

## §3.1 Принципы

Шесть нормативных принципов §3, применяемых ко всем formatting decisions:

### §3.1.1 Substrate-readable первичен

Markdown — substrate-readable text format. Formatting decisions должны:
- сохранять git-blame readability (no force-wrap mid-sentence per character-count),
- не ломать syntax highlighting в site/PDF rendering,
- быть стабильными при substrate-нативной обработке (markdown lint, frontmatter validator).

**Применение:** see §3.3 (fences must have lang tags для PDF), §3.7 (frontmatter must validate per `scripts/validate-frontmatter.js`), §3.9 (links must use anchor format compatible с Astro static-site generator).

### §3.1.2 Scan-readable вторичен

Reader сканирует normative document; формат — service of scanning:
- numbered sections для cross-ref (§3.4 dotted-number convention);
- consistent bullets (§3.5 `-` only);
- typographic quotes для readability (§3.8 `«»`).

**Применение:** see §3.4, §3.5, §3.8.

### §3.1.3 No tool dependency

Convention должна быть applicable manual editor (Markdown в Notepad++ / VS Code / любой text editor). Не должна требовать specific IDE plugin.

**Применение:** §3.3 fence lang tags — manually addable; §3.7 frontmatter — validated post-edit, не at-edit; §3.8 typography — soft rule (replacement scripts допустимы pre-commit, не in-flow).

### §3.1.4 Accessibility

PDF / HTML / screen-reader compatibility:
- alt-text для images (TBD when imagery introduced — Phase 6/7 epic);
- semantic heading hierarchy (no skip, H1 → H2 → H3 monotonic);
- typed code-fences для syntax-highlighting.

**Применение:** §3.3 fence lang policy + §3.4 heading depth rule.

### §3.1.5 De-facto convention endorsement

Phase 1 audit зафиксировал 100% bullet consistency (`-` only) + 100% table alignment-less (`---`) + 0 heading depth jumps. Style Guide §3 **endorses** эти de-facto conventions explicitly без forced revisitation.

**Применение:** §3.5 — explicit endorsement.

### §3.1.6 RU typography first-class

Не trogать RU prose с ASCII-only mindset. `«»` (typographic quotes), `—` (em-dash), non-breaking space — RU normative typography baseline.

**Применение:** §3.8 — explicit rules.

## §3.2 Citations & cross-refs

Phase 1 audit ([style-inconsistencies §3.2](ru-style-inconsistencies.md#32-b-citations--cross-references)): 1 264 `§X.Y` refs total, 416 bare (32%), 1 041 markdown-file-links, 86 anchor-only, 152 inline «глав* X», 98 «см.», 0 «see».

### §3.2.1 Convention — three classes

| Class | Pattern | When |
|---|---|---|
| (A) Bare intra-file | `§3.5` | Reference внутри того же файла |
| (B) Markdown link cross-file | `[§3.5](../standard/03-terms.md#3.5)` | Reference на другой файл |
| (C) Anchor-only intra-file | `[§3.5](#35-tables--lists)` | Clickable intra-file reference (explicit anchor) |

**Hard rule:** cross-file reference **обязан** быть markdown link (Class B). Bare `§X.Y` для cross-file ссылки — anti-pattern (не clickable, no PDF outline integration).

**Soft rule:** intra-file reference — Class A или Class C по choice. Class A — minimal syntactic overhead (acceptable in dense reference sections); Class C — clickable, better for sites/PDF.

### §3.2.2 Inline «глав* X» pattern

| Form | Treatment |
|---|---|
| «в [главе 3](../standard/03-terms.md)» | Canonical для cross-file narrative reference |
| «глава 3 содержит» (no link) | Anti-pattern when cross-file; convert to (B) |
| «глава 3» when intra-file context already clear | Acceptable (Class A equivalent) |

**Phase 5 action:** 152 inline «глав* X» occurrences ([style-inconsistencies §3.2](ru-style-inconsistencies.md#32-b-citations--cross-references)) — review per occurrence; cross-file → convert to link.

### §3.2.3 «См.» (RU) — endorsed

Convention: «см.» (lowercase, RU) — canonical. «see» (EN) — banned. Phase 1 audit: 98 «см.», 0 «see». **Endorse de-facto.**

**Pattern:**

```markdown
... (см. [§3.5](#35-tables--lists)).
```

«См.» allowed без link, когда intra-file context (parenthetic mention without need to navigate).

### §3.2.4 Anchor format

| Heading | Anchor (auto-generated by Astro/CommonMark) |
|---|---|
| `## §3.5 Tables / lists` | `#35-tables--lists` |
| `### §1.10.3 Affected file (Phase 5 priority 1)` | `#1103-affected-file-phase-5-priority-1` |
| `## Назначение` | `#назначение` |

**Rule:** anchors lowercase, hyphens вместо spaces/dots, RU keywords lowercase Cyrillic.

**Hard rule:** anchor validity verified post-edit via cross-ref dead-link scan ([memory #31 принцип 6](#)).

### §3.2.5 Phase 5 migration priorities

Per editorial-audit §6 — citation cleanup priority:

| Order | File | Bare §-refs | Treatment |
|---|---|---:|---|
| 1 | `standard/01-scope.md` | 69 | Highest — intro chapter, many cross-file refs |
| 2 | `standard/13-metrics.md` | 48 | Medium-high |
| 3 | `standard/03-terms.md` | 39 | Medium — terminology cross-refs (intra-file often OK) |
| 4 | `standard/14-conformance.md` | 38 | Medium |
| 5 | `standard/10-lifecycle-qg.md` | 35 | Medium |
| 6+ | Remaining files | low-medium | Per-chapter as encountered |

## §3.3 Code-fences

Phase 1 audit ([style-inconsistencies §3.3](ru-style-inconsistencies.md#33-c-code-fences)): 195 total fences, 77 no-lang (39%), 118 typed. Top no-lang offenders: `guide/01` (20), `guide/08` (13).

### §3.3.1 Language tag whitelist

Допустимые language tags (endorse Phase 1 de-facto):

| Tag | Purpose | Phase 1 count |
|---|---|---:|
| `yaml` | Frontmatter / config examples | 64 |
| `bash` | CLI commands / shell snippets | 15 |
| `cypher` | Knowledge graph queries (reference/05) | 15 |
| `markdown` | Markdown examples внутри docs | 14 |
| `json` | JSON schema examples / API payloads | 7 |
| `python` | Python script examples | 2 |
| `sql` | SQL queries | 1 |
| `text` | Plain text / tree fragments / generic output | (new — replaces no-lang) |

**Closed list policy** ([§1.1.4](ru-style-guide-draft-section-1-terminology.md#114-closed-list-canonical-terms)): добавление нового tag — formal Style Guide amendment. Phase 5 chapter pass не выбирает «exotic» tags.

### §3.3.2 No-lang fences — anti-pattern

**Hard rule:** все fences обязаны иметь language tag. No-lang fences — anti-pattern.

**Treatment per content type:**

| Content type | Lang tag |
|---|---|
| YAML frontmatter / config | `yaml` |
| Shell command / output | `bash` |
| Markdown structural example | `markdown` |
| Directory tree fragment | `text` |
| Plain output dump (e.g. tool output) | `text` |
| JSON payload | `json` |
| SQL query | `sql` |
| Cypher query | `cypher` |
| Python script | `python` |
| Mixed-language pseudo-code | `text` |

### §3.3.3 Migration plan для 77 no-lang occurrences

Per editorial-audit §6 priority:

| Order | File | No-lang fences | Mostly |
|---|---|---:|---|
| 1 | `guide/01-walkthrough.md` | 20 | Tree fragments + directory layouts → `text` |
| 2 | `guide/08-developer-guide.md` | 13 | Mixed CLI / tree → `bash` или `text` |
| 3 | `standard/06-requirements-hierarchy.md` | 7 | Identifier schema examples → `yaml` или `text` |
| 4 | `standard/10-lifecycle-qg.md` | 6 | State machine examples → `text` |
| 5+ | Remaining 8 files | 1-5 each | Per-file judgement |

**Phase 5 procedure:** для каждого no-lang fence — read 2-3 lines content, choose lang tag per §3.3.2 mapping, replace ` ``` ` → ` ```<tag> `. No content change.

### §3.3.4 Indentation policy внутри fence

| Rule | Detail |
|---|---|
| YAML frontmatter inside fence | 2-space indent (matches existing corpus) |
| Bash commands | No leading whitespace (each command starts at column 0 inside fence) |
| Tree fragment | Indentation reflects directory depth (4 spaces per level recommended) |
| Markdown example | Preserve markdown formatting authentically (no escape) |

### §3.3.5 Inline code (backticks)

Single backticks для:
- Identifiers: `` `SR-001` ``, `` `commit` ``, `` `frontmatter` ``.
- File / path references: `` `standard/03-terms.md` ``, `` `reference/01-glossary.md` ``.
- Type / field names: `` `parent: BR-001` ``, `` `status: approved` ``.
- Short CLI fragment: `` `git commit -m "..."` ``.

**Anti-pattern:** backticks вокруг whole sentences («This is `inline-coded sentence`»). Reserve backticks для technical identifiers.

Double-backticks `` ` ` `` — для literal backtick-containing content (rare).

## §3.4 Headings

Phase 1 audit ([style-inconsistencies §3.4](ru-style-inconsistencies.md#34-d-section-numbering--heading-depth)): 1012 total headings, max depth H4 (3 occurrences), depth jumps 0 (monotonic).

### §3.4.1 Numbering convention — endorse split

| Directory | Convention | Rationale |
|---|---|---|
| `standard/` | Dotted-number (`## 3.5 Tables / lists`) | Normative clauses — numbered for cross-ref precision |
| `reference/` | Dotted-number (matches standard/ — reference is normative companion) | Same as standard/ |
| `core/` | Plain (`## Что вы получите`) | Pedagogical narrative |
| `guide/` | Plain (`## Quickstart` / numbered «Phase 0..9») | Narrative + numbered phase walkthroughs |
| `research/` | Plain (or numbered if explicit structure preferred per author) | Research drafts — author choice |

**Endorse Phase 1 de-facto** ([style-inconsistencies §3.4](ru-style-inconsistencies.md#34-d-section-numbering--heading-depth)): 746 dotted-number / 266 plain. Most `standard/` dotted; `guide/00`, `guide/03`, `guide/08`, `reference/02-03`, `core/renar-core` plain.

### §3.4.2 Depth rule

| Rule | Detail |
|---|---|
| Max depth normative | H3 (3 levels) |
| H4 — exception | Allowed только для substructure внутри large H3 sections; ≤5 per chapter |
| H5/H6 — banned | Restructure parent H3/H4 instead |
| Depth jumps | **Banned** — no H1 → H3 без intermediate H2. Phase 1 audit: 0 jumps (excellent baseline). |

Phase 5 chapter pass — preserve depth monotonicity. Если правка добавляет H4 — verify ≤5 per chapter.

### §3.4.3 Heading text — RU canonical

| Pattern | Examples |
|---|---|
| Noun phrase | `## §3.5 Tables / lists` (mixed RU/EN — EN domain word in title acceptable) |
| Subject-predicate | `## Что вы получите` (guide / core narrative) |
| Imperative | `## Установите зависимости` (guide / core) |

**Anti-pattern:** sentence-as-heading («## Этот раздел описывает основные принципы»). Heading — short label, not sentence.

### §3.4.4 RU casing

Headings — sentence-case RU (capitalize only first word + proper nouns). NOT title-case English («## Tables And Lists»).

Exception: `## §3.5 Tables / lists` — mixed-script when first word — number + EN domain term acceptable per [§1.3 Bucket A](ru-style-guide-draft-section-1-terminology.md#13-bucket-a-technical-identifiers-keep-latin).

## §3.5 Tables / lists

Phase 1 audit ([style-inconsistencies §3.5](ru-style-inconsistencies.md#35-e-tables--lists)): 100% bullet consistency (`-` only), 100% table alignment-less (`---`), 0 mixed-bullet files.

### §3.5.1 Bullet style — endorse `-` only

**Hard rule:** `-` only. `*` / `+` — banned. Mixed bullets within file — banned.

```markdown
- item 1
- item 2
  - sub-item (4-space nested indent)
- item 3
```

### §3.5.2 Ordered list `1.` — endorse

Phase 1: 274 ordered lists. Convention:

```markdown
1. Step one.
2. Step two.
3. Step three.
```

Auto-numbered (`1.` для каждого item) acceptable per CommonMark — renderer auto-numbers. Manual `1.`, `2.`, `3.` — preferred (explicit count visible в source).

### §3.5.3 Table alignment — endorse `---` only

**Hard rule:** alignment markers `:---` / `---:` / `:---:` — banned (Phase 1: 0 occurrences, 644 alignment-less, 100% consistency). Endorse de-facto.

```markdown
| Col A | Col B | Col C |
|---|---|---|
| a1 | b1 | c1 |
```

**Rationale:** alignment markers вводят rendering variance per renderer; alignment-less — universal.

### §3.5.4 Nested lists indent

| Type | Indent |
|---|---|
| Unordered nesting | 2 spaces (matches CommonMark default) — `-` continues at offset 2 |
| Ordered nesting | 3 spaces (matches CommonMark default) — `1.` continues at offset 3 |

Phase 5 chapter pass — verify indent consistency per file (Phase 1 не quantified, default assumption: existing corpus consistent).

### §3.5.5 Table header normalization

| Rule | Detail |
|---|---|
| First column — left-justified by default (no alignment marker) | Most readable |
| Right-justified columns — допустимо когда numerical column (Phase 1: 0 occurrences — endorse banning) |
| Header row — bold не required (renderer adds visual weight automatically) |

## §3.6 Inline code & emphasis

### §3.6.1 Inline code (backticks)

См. [§3.3.5](#335-inline-code-backticks).

### §3.6.2 Bold — `**text**`

Использовать для:
- Term introduction (first definition mention): «**Closed list policy** — формальный механизм …».
- Emphatic normative («**Hard rule:** …»).
- Negative scenario flag («**Anti-pattern:** …»).

**Hard rule:** bold **не используется** как replacement для UPPERCASE (§2.1.4). Bold — additive emphasis, не shouting.

### §3.6.3 Italic — `*text*`

Restricted use:
- Foreign-language phrase: «*ad hoc*», «*de facto*» (latin).
- Title of external work: «*Software Requirements* (Wiegers)».
- Technical term in introduction где bold уже used: «*RFC 2119* — IETF RFC».

**Anti-pattern:** italic для general emphasis (use bold). Italic для длинных passages (читаемость падает).

### §3.6.4 Code-fence vs inline-code discrimination

| Content | Inline (backticks) | Fence |
|---|---|---|
| Single identifier (`commit`, `frontmatter`) | ✓ | Excess |
| Path (`standard/03-terms.md`) | ✓ | Excess (unless context-bearing) |
| Short command (≤80 chars, no newlines) | ✓ | Optional |
| Multi-line command / multi-statement | Excess | ✓ |
| YAML frontmatter example | Excess | ✓ |
| Markdown structural example | Excess | ✓ |

## §3.7 Frontmatter YAML

### §3.7.1 Field order

Canonical field order per RENAR convention (matches existing `research/` + `standard/` corpus):

```yaml
---
title: "Document title"
status: draft  # | proposed | approved | verified | obsolete | frozen | ...
phase: "Phase N description"  # optional, epic-context
epic: epic-slug  # optional
task: task-slug  # optional
draft-date: 2026-05-16  # ISO 8601
scan-date: 2026-05-16  # для audit artifacts
target-final-path: "reference/06-...md"  # для drafts с known lock-in target
lang: ru  # primary language
sources: 3  # для audit aggregations
corpus: "standard/ + guide/ + reference/ + core/"  # для audits scope
---
```

### §3.7.2 Quoting policy

| Value type | Quoting |
|---|---|
| Pure ASCII identifier (`status: draft`, `lang: ru`, `epic: ru-normative-pass-v1`) | No quotes |
| String с пробелами или special chars (`title: "..."`, `phase: "..."`) | Double quotes |
| ISO date (`2026-05-16`) | No quotes |
| Numeric (sources: 3) | No quotes |
| Boolean (rare, e.g. `frozen: true`) | No quotes |

### §3.7.3 Required fields per artifact type

| Type | Required |
|---|---|
| `standard/*.md` | `title`, `lang`, optionally `status` |
| `guide/*.md` | `title`, `lang`, optionally `status` |
| `reference/*.md` | `title`, `lang`, optionally `status` |
| `research/*-audit.md` | `title`, `status` (`frozen` after publish), `phase`, `epic`, `task`, `scan-date`, `corpus`, `lang` |
| `research/*-draft-*.md` | `title`, `status` (`draft`), `phase`, `epic`, `task`, `draft-date`, `target-final-path`, `lang` |

### §3.7.4 Validation

`node scripts/validate-frontmatter.js` runs as quality signal (Phase 5 per chapter, also pre-commit). Validates: required-field presence + type correctness + closed-value-list (status, lang).

**Phase 5 expectation:** 30/30 чек должен остаться («frontmatter validator clean»). Если стандарт растёт — validator принимает новые files automatically.

### §3.7.5 `lang:` field — closed list

Currently allowed: `ru` (primary), `en` (planned для `standard/en/` Phase 6/7).

**Future-proof:** при добавлении EN translations — validator должен distinguish `lang: ru` vs `lang: en` artifacts.

## §3.8 RU typography

### §3.8.1 Кавычки — «»

**Canonical:** ёлочки `«»` для outer quotes. `"…"` (ASCII straight) — anti-pattern в prose.

```markdown
# Correct
… concept «closed list policy» — formal RENAR mechanism …

# Wrong
… concept "closed list policy" — formal RENAR mechanism …
```

**Inner quotes** (nested): `„…"` (German low-9 + high-9 quotes) — when sufficient. Phase 1 audit corpus — inner quotes rare; defer to author discretion case-by-case.

**Exceptions:** ASCII quotes допустимы:
- Внутри code-fences (preserve verbatim).
- В URL / file paths (preserve syntactic).
- В EN citation внутри RU prose («Per RFC 2119 §2, "the use of …"»).

### §3.8.2 Em-dash — `—`

**Canonical:** em-dash `—` (U+2014) для:
- Парные em-dashes — separators в complex sentences («Term X — described as Y — applies …»).
- Definition predicate: «X — Y» (§2.4.2 canonical form).
- List-item separator: «item A — description».

**Anti-pattern:** `-` (hyphen) или `--` (double-hyphen) instead of `—`.

**Exceptions:**
- Hyphen `-` correct в compound words («closed-list», «source-of-truth»).
- Hyphen `-` correct в file paths / identifiers (`ru-style-rfc2119`).
- En-dash `–` (U+2013) для number ranges («§3.5–3.7») — rare, acceptable.

### §3.8.3 Non-breaking space

Required:
- Между числом и единицей: `100 ms` (NBSP between 100 and ms), `≥1 chapter`.
- Между initials и фамилией: «И. М. Сеченов» (NBSP after И.).
- Перед em-dash в pair: «слово — описание» (NBSP перед —).

**Implementation:** markdown source может содержать literal NBSP (U+00A0) или HTML entity `&nbsp;`. Astro / CommonMark renders correctly.

**Phase 5 — soft rule:** NBSP insertion — author discretion; не gated check.

### §3.8.4 Числительные форматы

| Form | Convention |
|---|---|
| Whole numbers ≤999 | No separator: `42`, `999` |
| Whole numbers ≥1000 | Space separator: `1 000`, `50 649` |
| Percentages | `33%` (no space между number и `%`) |
| Decimals (rare) | Russian decimal comma `0,5` или English period `0.5` — pick one per file; corpus default English period |
| Ordinals | `1-й`, `2-й` (RU suffix) или `1st/2nd` (EN, rare) |

**Phase 1 baseline:** `50 649` (space separator) used в editorial-audit. Endorse.

### §3.8.5 Math operators

| Symbol | Use |
|---|---|
| `≥` (U+2265) / `≤` (U+2264) | Inequality |
| `≠` (U+2260) | Not equal |
| `±` (U+00B1) | Plus-minus |
| `→` (U+2192) | Implication / transformation |
| `↔` (U+2194) | Bidirectional |

Plain ASCII `>=`, `<=`, `!=`, `+/-`, `->`, `<->` — anti-pattern в prose; acceptable inside code-fences.

## §3.9 Cross-file link conventions

### §3.9.1 Relative paths

Cross-file links use **relative** paths from the linking file's directory:

```markdown
# from research/ru-style-guide-draft-section-2-rfc2119.md
[§3.5](../standard/03-terms.md#35)
[§1 draft](ru-style-guide-draft-section-1-terminology.md)  # intra-directory
```

**Anti-pattern:** absolute paths (`/standard/03-terms.md`) — break при site build / portable usage.

### §3.9.2 Anchor case

Anchor portion lowercase, hyphens, RU keywords Cyrillic. См. [§3.2.4](#324-anchor-format).

### §3.9.3 Link label conventions

| Pattern | Use |
|---|---|
| `[§3.5](file.md#35)` | Cross-ref to numbered section |
| `[term name](file.md#term-name)` | Cross-ref to RU heading (sentence-case lowercase) |
| `[file path](path)` | Reference to file (label = path verbatim в backticks) — `` [`standard/03-terms.md`](../standard/03-terms.md) `` |

### §3.9.4 Dead-link prevention

Phase 5 chapter pass — после правки запустить cross-ref dead-link scan ([memory #31 принцип 6](#)). Expected: 0 dead links.

**Tooling:** Astro build обычно flags broken links; CI gate (future) verify pre-merge.

## §3.10 Validation

Phase 5 chapter pass обязан выполнить per главу:

### §3.10.1 Automated checks

1. **Bare §-ref scan:** grep `§\d+\.\d+` не внутри `[...]` — flag для cross-file refs.
2. **No-lang fence scan:** grep ` ``` ` followed by newline (no lang tag) — flag every occurrence.
3. **Heading depth scan:** count H1/H2/H3/H4 — verify monotonic + H4 ≤5.
4. **Bullet style scan:** grep `^\s*[*+]\s` — flag (must be `-` only).
5. **Table alignment scan:** grep `:---|---:|:---:` — flag (must be `---` only).
6. **ASCII-quote scan:** grep `[^/]\"[^\"]+\"[^/]` в prose (exclude code-fences) — flag (must be `«»`).
7. **Hyphen-as-em-dash scan:** grep ` -- ` или ` - ` (with surrounding spaces, prose-context) — flag (must be `—`).
8. **Frontmatter validation:** run `node scripts/validate-frontmatter.js`.

### §3.10.2 Human spot-check

Per [memory #31 принцип 8](#):
- (a) Anchor cases verified (no broken intra-file anchors).
- (b) Citation classes (§3.2.1) applied correctly.
- (c) Typography (§3.8) applied without over-editing existing correct usage.
- (d) Frontmatter — required fields present, status correct.

### §3.10.3 Phase 3 pilot checkpoint

Pilot chapter — `standard/03-terms.md` (canonical voice exemplar):

1. **Apply §3 ruleset** в pilot.
2. **Re-run §3.10.1 automated checks** — verify counts drop.
3. **User checkpoint:** review pilot diff (citation conversion + fence tagging + typography normalization).
4. **Lock-in §3** after pilot approval; Phase 5 commences.

## §3.11 Phase 5 priority order (combined §3 axes)

Per editorial-audit §6 + §3.2.5 / §3.3.3:

| Order | File | Combined formatting issues |
|---|---|---|
| 1 | `reference/01-glossary.md` | Phase 1.5 prerequisite (F1 reconciliation) + per-§3 cleanup |
| 2 | `standard/01-scope.md` | 69 bare §-refs (top citation hot) |
| 3 | `standard/13-metrics.md` | 48 bare §-refs |
| 4 | `standard/03-terms.md` | 39 bare §-refs (intra-file часто OK — judgement-heavy pass) |
| 5 | `standard/14-conformance.md` | 38 bare §-refs |
| 6 | `standard/10-lifecycle-qg.md` | 35 bare §-refs + 6 no-lang fences |
| 7 | `guide/01-walkthrough.md` | 20 no-lang fences (top fence hot) |
| 8 | `guide/08-developer-guide.md` | 13 no-lang fences |
| 9 | `standard/06-requirements-hierarchy.md` | 7 no-lang fences |
| 10+ | Remaining files | Per-chapter as encountered |

## §3.12 AC mapping

| AC# | Criterion | Evidence |
|---|---|---|
| 1 | Artifact в `research/`, status:draft | этот файл, frontmatter |
| 2 | Cross-link на §1, §2 + 3 inventories + editorial audit | intro callout + §3.13 Источники |
| 3 | Citation convention — explicit rules | §3.2.1 3 classes + §3.2.2 inline + §3.2.3 «см.» + §3.2.4 anchor + §3.2.5 priority |
| 4 | Code-fence lang whitelist + policies | §3.3.1 whitelist + §3.3.2 anti-pattern + §3.3.3 migration + §3.3.4 indent + §3.3.5 inline-code |
| 5 | Heading split + depth rule | §3.4.1 split + §3.4.2 depth + §3.4.3 text + §3.4.4 casing |
| 6 | Tables/lists endorsement | §3.5.1 bullets + §3.5.2 ordered + §3.5.3 alignment + §3.5.4 nesting + §3.5.5 header |
| 7 | Inline code vs emphasis | §3.6.1-§3.6.4 (backticks / bold / italic / discrimination) |
| 8 | Frontmatter YAML rules | §3.7.1 order + §3.7.2 quoting + §3.7.3 required + §3.7.4 validation + §3.7.5 lang |
| 9 | RU typography | §3.8.1 кавычки + §3.8.2 em-dash + §3.8.3 NBSP + §3.8.4 числа + §3.8.5 операторы |
| 10 | Cross-file link conventions | §3.9.1 relative + §3.9.2 anchor + §3.9.3 labels + §3.9.4 dead-link |
| 11 | Validation section | §3.10.1 automated + §3.10.2 human + §3.10.3 pilot |
| 12 | AC mapping table | этот § |
| 13 | Read-only invariant | git status: единственный новый research/-файл |

## §3.13 Limitations & follow-ups

1. **Draft status.** §3 — Phase 2 draft; Phase 3 pilot checkpoint может потребовать revision (e.g. `«см.»` convention может расшириться на parenthetic-only).
2. **Tooling gap.** §3.10.1 automated checks reference manual grep сейчас. Lock-in (`scripts/style-guide-check.js`) — future task (matches §1.13.1 / §2.10.1 limitation).
3. **Astro renderer specifics** (§3.2.4 anchor format) — assumed CommonMark-compatible. Phase 3 pilot должен verify Astro actually generates expected anchors.
4. **NBSP soft rule** (§3.8.3) — not gated. Phase 5 chapter pass — opportunistic improvement, not blocker.
5. **EN translation impact** (`standard/en/` Phase 6/7) — §3 conventions designed для RU; EN translation may need parallel §3-EN (TBD).
6. **`research/` formatting** — frontmatter rules §3.7.3 apply; otherwise author discretion для drafts. Frozen audits (this convention applies post-freeze).
7. **Image policy deferred.** §3.1.4 mentions accessibility (alt-text); imagery introduction (Phase 6/7 epic regenerate-png-ico-og-image) will require §3 amendment.

## §3.14 Источники

- Memory #31 `ru-pass-principles` (epic `ru-normative-pass-v1`)
- Decision #24 «RU normative pass v0.1→v1.0 — 7-фазный подход»
- Phase 1 deliverable: [`research/ru-editorial-audit.md`](ru-editorial-audit.md) (F3 systemic finding)
- Source audits:
  - [`research/ru-style-inconsistencies.md §3.2`](ru-style-inconsistencies.md#32-b-citations--cross-references) (citations baseline)
  - [`research/ru-style-inconsistencies.md §3.3`](ru-style-inconsistencies.md#33-c-code-fences) (fences baseline)
  - [`research/ru-style-inconsistencies.md §3.4`](ru-style-inconsistencies.md#34-d-section-numbering--heading-depth) (headings baseline)
  - [`research/ru-style-inconsistencies.md §3.5`](ru-style-inconsistencies.md#35-e-tables--lists) (tables/lists baseline)
- Phase 2 §1: [`research/ru-style-guide-draft-section-1-terminology.md`](ru-style-guide-draft-section-1-terminology.md)
- Phase 2 §2: [`research/ru-style-guide-draft-section-2-rfc2119.md`](ru-style-guide-draft-section-2-rfc2119.md)
- CommonMark Specification ([https://spec.commonmark.org/](https://spec.commonmark.org/))
- Astro site framework ([site/](../site/))
