---
title: RENAR Documentation
description: Полная нормативная спецификация RENAR — стандарт инженерии требований для AI-нативной разработки.
---

# RENAR Documentation

**RENAR** — самостоятельный нормативный стандарт и методология инженерии требований для AI-нативной разработки. Дополняет [SENAR](https://senar.tech); работает независимо.

## Четыре документа

<div class="grid cards" markdown>

- :material-book-open-variant: **[Стандарт](standard/)** — нормативная спецификация
    ---
    15 нормативных глав (00–14): термины, роли, иерархия BR/SR/TR, ADAPT, 9 типов SPEC, тест-кейсы, lifecycle и Quality Gates, substrate versioning V1–V6, maturity model RENAR-1..5, метрики, conformance.

- :material-compass: **[Руководство](guide/)** — практическое применение
    ---
    Quickstart за 30 минут, end-to-end walkthrough, transition с текущей практики, tool guides для git и Raven, compliance mapping, failure modes.

- :material-bookshelf: **[Справочник](reference/)** — глоссарий и схемы
    ---
    Canonical термины, JSON Schemas артефактов, AI Risk Register, AI Style Guide, Knowledge Graph schema, RU Style Guide для RU normative wording.

- :material-school: **[Core](core/)** — мягкое введение
    ---
    Минимальное входное руководство — для индивидуальных разработчиков и небольших команд, кто хочет начать применять требования-как-SoT прямо сейчас без полного внедрения.

</div>

## С чего начать

- **Знакомы с SENAR?** → перейдите к [полному стандарту](standard/).
- **Первый раз слышите про RENAR?** → откройте [Core](core/renar-core/).
- **Применяете уже сейчас?** → [Quickstart](guide/00-quickstart/) (30 мин) → [Walkthrough](guide/01-walkthrough/) (end-to-end).

## Ключевые концепции

- **Иерархия BR → SR → TR** — бизнес-требование, системное требование, требование к задаче.
- **Артефакт ADAPT** — двусторонняя адаптация между immutable ТЗ и BR/SR/SPEC.
- **9 типов SPEC** (закрытый список): ARCH / API / DATA / INT / PROC / UI / AI / SEC / OPS.
- **Substrate-agnostic V1–V6** — те же нормативные правила для git, Mercurial, SVN, Raven.
- **RENAR-1..5 maturity** — одна из размерностей общей SENAR-зрелости.

## Версия

**v1.0-draft** · 21.05.2026 · [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) · Нормативный язык по [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).
