---
title: "RU Style Amendment 002: EN translation UPPERCASE convention"
status: proposed
phase: "Phase 2.x amendment"
epic: ru-normative-pass-v1
task: ru-style-amendment-002-en-uppercase
draft-date: 2026-05-19
target-section: "§2.2.4 + new §2.2.5 + §2.3 + §5 of reference/06-ru-style-guide.md"
lang: ru
---

# RU Style Amendment 002: EN translation UPPERCASE convention

## Rationale

Style Guide v1.0/v1.0.1 фиксирует RU canonical wording (§2.2.2 — Option C, RU lowercase modals). EN-перевод RENAR Standard (epic `en-{standard,guide,reference,core}`) требует **явного нормативного правила** для RFC-2119 keywords.

Текущий §2.2.4 содержит **descriptive** statement о направлении («EN version будет следовать EN convention (UPPERCASE) per Phase 6/7»), но помечен «(TBD)» — формально не normative. Phase 6/7 при старте en-эпика получит ambiguous Style Guide policy.

### Decision basis

1. **RFC 8174** (опубликован 2017): только UPPERCASE формы (`MUST`, `SHALL`, `SHOULD`, ...) несут RFC-2119 normative weight в EN; lowercase EN modal verbs — обычный язык. Это **caveat для EN convention**, не для RU.
2. **RU carve-out (§2.1.3)**: RENAR Style Guide делает explicit carve-out для русского — RU lowercase modals = canonical normative. Carve-out **по сторонам**: только для RU. EN translation должен следовать стандартной EN convention.
3. **International standard practice**: ISO/IEC/IEEE EN normative texts (29148, 12207, 15288) используют UPPERCASE RFC-2119 keywords. Reader expectation для EN technical standard — UPPERCASE markers.
4. **Bidirectional mapping unambiguous**: §2.3 mapping table уже фиксирует RU↔EN соответствия. Дополнительный direction note делает таблицу dual-use.

### Alternatives considered

| Option | Pros | Cons | Decision |
|---|---|---|---|
| (A) EN UPPERCASE per RFC 8174 | Standard EN practice; ISO compatible; reader expectation matched | None | **Selected** |
| (B) EN lowercase mirror (parallel RU carve-out) | Parallel structure RU/EN | 0 precedent в international standards; reader confusion; violates RFC 8174 default | Rejected |
| (C) Mixed (UPPERCASE для MUST/SHALL только, lowercase для SHOULD/MAY) | Some standards do this informally | Inconsistent; violates RFC 8174 (all-or-nothing UPPERCASE policy) | Rejected |

## Proposed change

### Delta 1 — §2.2.4 sharpen (remove TBD)

Old:
```
- §2.2.2 **не** запрещает RFC-2119 UPPERCASE keywords в EN translation (`standard/en/` future epic). EN version будет следовать EN convention (UPPERCASE) per Phase 6/7 (TBD).
```

New:
```
- §2.2.2 **не** запрещает RFC-2119 UPPERCASE keywords в EN translation (`standard/en/` future epic). EN version следует EN convention (UPPERCASE) per [§2.2.5](#225-en-translation-convention) — normative.
```

### Delta 2 — New §2.2.5 (normative)

Добавить новый sub-section после §2.2.4:

```markdown
#### §2.2.5 EN translation convention

**Rule:** EN-перевод RENAR Standard (`standard/en/`, `guide/en/`, `reference/en/`, `core/en/`) использует **UPPERCASE RFC-2119 keywords** как canonical normative wording.

**Rationale:**

1. RFC 8174 (May 2017) явно фиксирует: только UPPERCASE формы (`MUST`, `SHALL`, `SHOULD`, `MAY`, `REQUIRED`, `RECOMMENDED`, `OPTIONAL` + negations) несут RFC-2119 normative weight в EN context. Lowercase EN modals не имеют normative weight.
2. RU carve-out (§2.1.3) — narrow exemption для русского, основанный на ГОСТ Р / ISO 29148 RU translation tradition. Carve-out **не распространяется** на EN.
3. International standard practice (ISO/IEC/IEEE 29148, 12207, 15288 в EN) — UPPERCASE consistent.

**Применение:**

- EN translator использует §2.3 mapping table как **bidirectional reference**: RU lowercase canonical → EN UPPERCASE canonical.
- `должен` (MUST) → `MUST`, `обязан` (SHALL) → `SHALL`, `следует` (SHOULD) → `SHOULD`, `может` (MAY) → `MAY`, etc.
- MVR таблица в `standard/00-introduction.md §0.5`: RU `обязан` (SHALL) → EN `SHALL` (восстанавливает Phase 1 EN baseline в EN translation).
- Descriptive carve-out (§2.7): EN translation `04-ai-style-guide.md` сохраняет existing EN UPPERCASE в descriptive RFC mentions — без re-keyword миграции.

**Anti-patterns в EN translation:**

1. Lowercase EN modals (`must`, `should`) — нет normative weight per RFC 8174. **Anti-pattern.**
2. Mixed UPPERCASE/lowercase в одной clause (`MUST must ...`) — paste-error. **Anti-pattern.**
3. RU lowercase в EN clause (`must должен ...`) — translation incomplete. **Anti-pattern.**

**Pilot validation:** при старте en-standard эпика — pilot chapter (recommended: `standard/en/03-terms.md` per RU pilot precedent §5.1) проверяет §2.2.5 applicability. Если pilot выявит edge-cases — отдельный amendment NNN.
```

### Delta 3 — §2.3 bidirectional mapping note

Insert после opening line «11 RFC-2119/RFC-8174 keywords + RU canonical equivalents...»:

```markdown
**Bidirectional usage:** Таблица применяется в обоих направлениях per [§2.2.5](#225-en-translation-convention):
- RU normative pass (Phase 5): EN UPPERCASE → RU lowercase canonical.
- EN translation (Phase 6+): RU lowercase canonical → EN UPPERCASE canonical.

Semantic preservation rule (§2.5) одинаково применима в обоих направлениях: modal verb LEVEL changes запрещены.
```

### Delta 4 — Frontmatter version

```diff
-version: "1.0.1"
+version: "1.1"
```

### Delta 5 — §5 Change history (insert §5.1.2)

Добавить sub-entry после §5.1.1 v1.0.1 с записью v1.1 minor.

## Pilot impact

- **Affected chapters (Phase 5 RU retroactive scan):** 0 — правило адресуется только EN translation (которого ещё нет).
- **Pilot trigger:** при старте en-standard эпика — pilot validation на 1 EN chapter (рекомендация: `standard/en/03-terms.md` per §5.1 RU pilot precedent).
- **Re-pass tasks (RU):** 0.
- **Re-pass tasks (EN):** N/A до старта эпика.

## Migration plan

1. **Текущий момент:** §2.2.5 фиксирован как normative; en-standard / en-guide / en-reference / en-core tasks в planning queue включают §2.2.5 как PRIMARY POLICY.
2. **При старте первой EN-task:** pilot validation per §5.2.3 на pilot chapter; user checkpoint.
3. **Если pilot pass:** amendment 002 lock-in полный, EN epic продолжается.
4. **Если pilot fail (unexpected edge-cases):** отдельный amendment 003 patch fix.
