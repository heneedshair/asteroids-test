---
title: "Roadmap: RU theoretical agent-ready + SENAR distribution parity"
status: active
lang: ru
version: "1.0-draft"
---

# Roadmap: теоретическая v1.0-draft + parity с SENAR

> **Epic:** `ru-theoretical-agent-ready`  
> **Цель:** корпус, который агент может понять и имплементировать на **любом** substrate-native runtime **без пилота**; репозиторий оформлен как SENAR: MD + PDF + сайт. Vendor tooling (TAUSIK и др.) — **только лендинг** renar.tech, не corpus.

## Критерий готовности (Definition of Done)

1. Норматив (`standard/`) — 0 vendor-leak (gate `check-substrate-leakage.js` green).
2. Каждый MVR + §14.3 mandatory clause — запись в `reference/normative-index.yaml`.
3. `reference/10-agent-implementation-profile.md` — abstract agent contract (vendor-neutral).
4. **Distribution parity:** `docs/RENAR-v1.0-draft-ru.pdf`, README «PDF Downloads», MkDocs на `/docs/`, Astro landing на `/`.
5. Все validators PASS (links, frontmatter, schema-examples, site-parity, leakage).

---

## Story A — Distribution parity (SENAR-like)

| ID | Задача | Приоритет | Статус |
|---|---|---|---|
| A1 | `scripts/pdf-manifest-ru.json` + `build-pdf-ru.js` → `docs/` + `site/public/` | P0 | done |
| A2 | README.md / README.ru.md — секция «PDF Downloads» | P0 | done |
| A3 | `docs/README.md` — актуальное описание артеfactов | P0 | done |
| A4 | `mkdocs.yml` — repo_url на req-standart (не senar) | P1 | done |
| A5 | `package.json` scripts: `pdf:ru`, `docs:build`, `docs:serve` | P1 | done |
| A6 | Hero `/ru/` — ссылка на PDF | P2 | done |
| A7 | CI: optional PDF build job (after local verify) | P3 | pending |

## Story B — Substrate hygiene (normative purity)

| ID | Задача | Приоритет | Статус |
|---|---|---|---|
| B1 | `[system].req/` → `[requirements-substrate]/` в §6/§8/§9 | P0 | done |
| B2 | §11.8 «manifest commit» → atomic change unit | P0 | done |
| B3 | `RENAR-SUMMARY-RU.md` — v1.0-draft, без Raven, QG-0..4 | P0 | done |
| B4 | `scripts/check-substrate-leakage.js` + npm script | P0 | done |

## Story C — Agent implementability (theoretical)

| ID | Задача | Приоритет | Статус |
|---|---|---|---|
| C1 | `reference/normative-index.yaml` — MVR + §14.3 + QG-0..2 | P0 | done |
| C2 | `reference/10-agent-implementation-profile.md` — scaffold | P0 | done |
| C3 | Walkthrough substrate-agnostic (без vendor CLI) | P1 | done |
| C4 | — (TAUSIK только на лендинге; отдельный guide не нужен) | — | cancelled |
| C5 | RFC modal audit §07/§09/§10/§14 | P2 | pending |
| C6 | `reference/mkdocs.yml` + nav — §10 | P1 | done |

## Story D — Вне scope (осознанно)

- Field pilot, skill `req`, KAI runtime
- EN translation
- Git tag `v1.0`

## Порядок выполнения

```
A1 → B1-B4 → C1-C2 → A2-A5 → C3-C6 → A6-A7
```
