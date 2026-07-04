---
title: "Agent adversarial review — RU corpus"
status: informative
lang: ru
version: "1.0-draft"
frozen: false
---

# Agent adversarial review — RU v1.0-draft

> **Informative.** Замена human external panel, когда ревьюеров нет: **три независимых AI-агента** с разными system prompts, фиксированным rubric и обязательным trace к file+§. Не нормативный документ.

## Когда применять

- Перед tag v1.0 или стартом EN-перевода
- После крупного editorial batch (как `ru-corpus-world-class-v2`)
- Периодически: раз в minor release RU corpus

## Три persona (обязательный минимум)

| Agent | Роль | Scope read | Запрет |
|---|---|---|---|
| **A1 — RE architect** | Closed lists, QG logic, schema ↔ normative | `standard/06–10`, `reference/02` | Не предлагать новые SPEC/gate types |
| **A2 — Compliance skeptic** | Ложные conformance paths, trace gaps | `standard/01`, `14`, `guide/06`, `guide/09 §E3`, `reference/07–08` | Не юридические заключения — только RE evidence |
| **A3 — Adversarial reader** | Misuse, contradictions, unsubstantiated claims | `core`, `standard/00`, `05`, `guide/07`, hotspots `reference/09` | Findings без цитаты clause — reject |

**Judge isolation:** каждый агент — **отдельная сессия**, другая модель или другой system prompt; primary author **не** triage своих findings.

## Rubric (severity)

| Severity | Критерий | Action |
|---|---|---|
| **blocker** | Normative contradiction или false conformance path | Fix до merge |
| **major** | Schema/example drift, missing mandatory cross-ref | Fix в том же epic |
| **minor** | Pedagogical gap, weak signpost | Backlog или P2 |
| **nit** | Style | Style-guide batch |

Finding **invalid**, если нет: `(file, section, quote ≤80 chars, severity, suggested fix)`.

## Procedure (1 session ≈ 2–4 h agent time)

```text
1. Baseline: node scripts/check-md-links.js && node scripts/validate-schema-examples.js && node scripts/style-guide-check.js
2. A1 pass → findings log (markdown table)
3. A2 pass → findings log
4. A3 pass → findings log
5. Human or lead agent triage: dedupe, disposition (fix / accept / defer)
6. Fix blockers + majors in corpus; re-run baseline
7. TAUSik: decide "Agent adversarial review RU v1.0-draft signed off" + link to findings file
```

## Prompt skeleton (A1 — RE architect)

```markdown
You are an adversarial RE architect reviewing RENAR RU v1.0-draft.
Read only: standard/06–10, reference/02-schemas.md.
Find: closed list violations, QG pre/post contradictions, YAML examples diverging from reference/02.
Output table: | ID | file | section | quote | severity | fix |
Reject your own finding if you cannot cite exact section.
Do NOT propose new artifact types or gates.
```

Prompts A2/A3 — аналогично; полные тексты — [guide/07 §3.5](../guide/07-failure-modes.md#35-adversarial-review-процедура) + scope table выше.

## Findings log (template)

| ID | Agent | File | § | Severity | Observation | Disposition |
|---|---|---|---|---|---|---|
| F-001 | A1 | example | §9.7 | major | … | fixed in commit … |

Хранить: `research/internal/agent-review-YYYY-MM-DD.md` (не public normative; optional commit).

## Exit criteria

- Baseline validators **0 failures**
- **0 open blocker** findings
- Majors fixed или `accepted` с rationale в log
- Не менее **1 finding per agent** OR explicit log line «no findings — scope read complete» (иначе review формальный)

## Связь с human kit

[ru-external-review-kit.md](ru-external-review-kit.md) — тот же rubric; human panel опционален. Agent review — **default path** для solo / AI-native команд.

---

*Informative — renar.tech*
