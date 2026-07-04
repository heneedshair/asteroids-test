---
title: "Mapping to External Standards"
description: "Informative. Extended catalog of informative references from standard/14 §14.5."
order: 11
lang: en
version: "1.0-draft"
---

# Mapping to External Standards

> **Informative.** Elaboration of [standard/14 §14.5](../../standard/en/14-normative-refs.md#14.5). Does not alter the mandatory clauses.

## 1. SAFe 6.0

A scaled-Agile framework. RENAR borrows the hierarchy mapping ([§4.13.1](../../standard/en/04-terms.md#4.13.1)): Portfolio Epic → BR, Feature → SR, Story → TR. Built-in quality (TC up to approved), WSJF for the `priority` field.

## 2. Spec-Driven Development

An industry term from 2024–2025: under AI acceleration, the correctness of the specification becomes critical. RENAR formalizes the Source-of-Truth inversion ([§2.3.1](../../standard/en/02-methodology-positioning.md#2.3.1)) — a normative structure not tied to a single vendor tool.

## 3. EARS (Mavin et al., 2009)

Controlled-natural-language templates for SR ([§6.6.3](../../standard/en/06-requirements-hierarchy.md#6.6.3)) and Pass/Fail in TC.

## 4. BDD / Gherkin / Specification by Example

Prior art for a full-fledged TC ([§9](../../standard/en/09-test-cases.md)): Given/When/Then, pos/neg as a blocking gate, version pin V5.

## 5. NIST AI RMF 1.0

Govern / Map / Measure / Manage — a functional mapping to RENAR roles ([§5](../../standard/en/05-roles.md)), metrics ([§12](../../standard/en/12-metrics.md)), and the deprecate lifecycle.

## 6. IEEE 830-1998 (deprecated)

Withdrawn in favor of ISO/IEC/IEEE 29148. The normative successor is [§14.4.2](../../standard/en/14-normative-refs.md#14.4.2).

## 7. BABOK v3

Gap: elicitation is out of scope (the TZ is already fixed); Solution Evaluation — partially QG-4 and [§12.5](../../standard/en/12-metrics.md#12.5).

## 8. PMBOK 7

"Principles over processes" — RENAR standardizes **what**, not **how** ([§2.5](../../standard/en/02-methodology-positioning.md#2.5)).

## 9. ISTQB Foundation

A testing vocabulary; `tc-type` is compatible with the component/integration/system/acceptance levels.

## 10. CMMI v2.0

Prior art for the RENAR-1..5 levels ([§11](../../standard/en/11-maturity-model.md)); CMMI's process-heavy artifacts are not the baseline level.

## 11. ISO/IEC 42001:2023 (AIMS)

Organizational governance; RENAR provides the evidence base for the requirements slice (ai-provenance, manifest).

## 12. ISO/IEC 25059:2023

An extension of SQuaRE for AI; a vocabulary for the `quality-characteristic` of AI components.

## 13. EU AI Act (Reg. 2024/1689)

The `ai-act.risk-class` field in BR; legal conformance is outside RENAR.

## 14. SysML / MBSE

Prior art for "requirements as a graph" — [reference/05](../05-knowledge-graph-schema.md); RENAR derives the graph from textual artifacts.

---

*Reference RENAR 1.0-draft — renar.tech*
