# RENAR — Requirements Engineering & Normative Adaptive Regulation

![Version](https://img.shields.io/badge/version-1.0--draft-blue)
![License](https://img.shields.io/badge/license-CC%20BY--SA%204.0-green)

**Нормативный стандарт инженерии требований для разработки с AI-агентами. Дополняет SENAR; работает независимо.**

[renar.tech](https://renar.tech) · [Read in English](README.md)

> **Читаешь впервые → [RENAR Core](core/renar-core.md) (≤ 10 минут).** Концептуальный обзор без технических деталей. После — [быстрый старт](guide/00-quickstart.md) (≈30 мин сквозной пример). Нормативные главы — [standard/](standard/README.md) — когда нужны точные «обязан / должен / следует».

## Структура корпуса

| Каталог | Назначение | Кому |
|---|---|---|
| [core/](core/renar-core.md) | Концептуальный обзор RENAR (single doc, non-normative) | PM, юристы, regulators, первое знакомство |
| [guide/](guide/README.md) | 11 practical guides: quickstart, walkthrough, compliance, failure modes, examples | Implementer, RE engineer |
| [standard/](standard/README.md) | 15 нормативных глав — единственный normative source of truth | Assessor, AI-агент, RE engineer для deep-dive |
| [reference/](reference/README.md) | 10 приложений: глоссарий, schemas, AI risk register, RU style guide | Lookup при работе |

## Скачать и читать

- [RENAR v1.0-draft — Стандарт (PDF, RU)](docs/RENAR-v1.0-draft-ru-standard.pdf) — нормативное ядро (core + 15 глав); основной документ для чтения
- [RENAR v1.0-draft — Практическое руководство (PDF, RU)](docs/RENAR-v1.0-draft-ru-guide.pdf)
- [RENAR v1.0-draft — Справочник (PDF, RU)](docs/RENAR-v1.0-draft-ru-reference.pdf)
- [RENAR v1.0-draft — полный архив (PDF, RU)](docs/RENAR-v1.0-draft-ru.pdf) — всё вместе + авторские мета-документы
- **English edition (2026-06):** полный перевод в `<секция>/en/` — [Standard (EN)](standard/en/README.md) · [Guide (EN)](guide/en/README.md) · [Reference (EN)](reference/en/README.md) · [Core (EN)](core/en/README.md); PDF: [Standard](docs/RENAR-v1.0-draft-en-standard.pdf) · [Full](docs/RENAR-v1.0-draft-en.pdf)
- [Стандарт для агента (MD, RU)](RENAR-AGENT-RU.md) — самодостаточная операционная редакция всего стандарта в одном файле: скачайте, положите рядом с AI-агентом, работайте на 100% RENAR
- [renar.tech/docs/](https://renar.tech/docs/) — сайт с поиском (MkDocs Material)

## Статус и лицензия

- **v1.3-draft** (2026-06-05) — ADAPT temporal/multiplicity/supersession (ADR-007, GitLab #7): стадийно-независимый триггер, множественность, дезавуирование (`superseded`).
- **v1.2-draft** (2026-05-26) — partner pushback iteration; ADAPT-reactive (ADR-006) + Core pivot (ADR-005).
- **v1.0** — после согласования партнёров + EN-перевод. См. [CHANGELOG.md](CHANGELOG.md) для подробной истории.
- [CC BY-SA 4.0](LICENSE) — свободное использование с указанием авторства.

**Авторы:** Вадим Соглаев, Андрей Юмашев
