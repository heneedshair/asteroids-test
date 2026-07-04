---
title: "Сопоставление с внешними стандартами"
description: "Informative. Расширенный каталог информативных ссылок из standard/14 §14.5."
order: 11
lang: ru
version: "1.0-draft"
---

# Сопоставление с внешними стандартами

> **Informative.** Детализация [standard/14 §14.5](../standard/14-normative-refs.md#14.5). Не изменяет обязательные положения.

## 1. SAFe 6.0

Framework масштабированного Agile. RENAR заимствует маппинг иерархии ([§4.13.1](../standard/04-terms.md#4.13.1)): Portfolio Epic → BR, Feature → SR, Story → TR. Встроенное качество (TC до approved), WSJF для поля `priority`.

## 2. Spec-Driven Development

Индустриальный термин 2024–2025: при AI-ускорении критична корректность спецификации. RENAR формализует инверсию источника истины ([§2.3.1](../standard/02-methodology-positioning.md#2.3.1)) — нормативная структура, не привязанная к одному vendor-tool.

## 3. EARS (Mavin et al., 2009)

Шаблоны контролируемого естественного языка для SR ([§6.6.3](../standard/06-requirements-hierarchy.md#6.6.3)) и Pass/Fail в TC.

## 4. BDD / Gherkin / Specification by Example

Prior art для полноценного TC ([§9](../standard/09-test-cases.md)): Given/When/Then, pos/neg как блокирующий gate, version pin V5.

## 5. NIST AI RMF 1.0

Govern / Map / Measure / Manage — функциональное сопоставление с ролями RENAR ([§5](../standard/05-roles.md)), метриками ([§12](../standard/12-metrics.md)), жизненный цикл deprecate.

## 6. IEEE 830-1998 (deprecated)

Отозван в пользу ISO/IEC/IEEE 29148. Нормативный правопреемник — [§14.4.2](../standard/14-normative-refs.md#14.4.2).

## 7. BABOK v3

Gap: elicitation вне scope (ТЗ уже зафиксировано); Solution Evaluation — частично QG-4 и [§12.5](../standard/12-metrics.md#12.5).

## 8. PMBOK 7

«Принципы вместо процессов» — RENAR нормирует **что**, не **как** ([§2.5](../standard/02-methodology-positioning.md#2.5)).

## 9. ISTQB Foundation

Словарь тестирования; `tc-type` совместим с уровнями component/integration/system/acceptance.

## 10. CMMI v2.0

Prior art для уровней RENAR-1..5 ([§11](../standard/11-maturity-model.md)); process-heavy артефакты CMMI не базовый уровень.

## 11. ISO/IEC 42001:2023 (AIMS)

Организационный governance; RENAR даёт доказательную базу для requirements-среза (ai-provenance, манифест).

## 12. ISO/IEC 25059:2023

Расширение SQuaRE для AI; vocabulary для `quality-characteristic` AI-компонент.

## 13. EU AI Act (Reg. 2024/1689)

Поле `ai-act.risk-class` в BR; юридическое соответствие — вне RENAR.

## 14. SysML / MBSE

Prior art «требования как граф» — [reference/05](05-knowledge-graph-schema.md); RENAR выводит граф из текстовых артефактов.

---

*Reference RENAR 1.0-draft — renar.tech*
