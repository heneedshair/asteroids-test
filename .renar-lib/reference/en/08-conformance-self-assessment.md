---
title: "Conformance Self-Assessment"
description: "Printable checklist, MVR↔§13.3 bijection, RENAR-CONFORMANCE.yaml template for self-assessment."
order: 8
lang: en
version: "1.0-draft"
---

# Conformance Self-Assessment

> **Purpose:** a practical kit for the Tech Lead / Architect before releasing [RENAR-CONFORMANCE.yaml](../../standard/en/13-conformance.md#13.4). The normative basis is [standard/13](../../standard/en/13-conformance.md). This document is **informative**; on conflict, standard/13 wins.

---

<a id="1-mvr-mandatory-clauses-133-bijection"></a>

## 1. MVR ↔ mandatory clauses §13.3 bijection

| MVR ([§0.5](../../standard/en/00-introduction.md#0.5)) | §13.3 clause | `mandatory-clauses-confirmed` field |
|---|---|---|
| MVR-1 Source-of-Truth inversion | §13.3.1 | `sot-inversion: true` |
| MVR-2 V1–V6 | §13.3.2 | `substrate-v1-v6: { v1..v6: true }` |
| MVR-3 ADAPT per TZ | §13.3.3 | `adapt-per-tz: true` |
| MVR-4 9 SPEC types | §13.3.4 | `spec-types-closed-list: true` |
| MVR-5 TC pos/neg | §13.3.5 | `tc-pos-neg-pairing: true` |
| MVR-6 QG — closed list | §13.3.6 | `quality-gates-closed-list: true` |
| MVR-7 conformance manifest | §13.4 (artifact) | manifest exists + signed |
| — (closed-list policy) | §13.3.7 | `closed-lists-backward-findings: true` |

All seven MVR + §13.3.7 are mandatory for **any** RENAR-1..5 level.

---

<a id="2-self-assessment-checklist-mandatory-clauses"></a>

## 2. Self-assessment checklist (mandatory clauses)

Check off after verifying the evidence in the substrate:

### §13.3.1 Source-of-Truth inversion

- [ ] The BR/SR/SPEC/TC hierarchy is the authoritative source of behavior
- [ ] No SR reconstructed from code without a defect-fix justification
- [ ] Drift-hooks / review policy block silent SR←code adaptation

### §13.3.2 V1–V6 capabilities (substrate)

- [ ] V1 immutable history — enabled
- [ ] V2 atomic change unit — enabled
- [ ] V3 diff & review — enabled
- [ ] V4 branching / change-set — enabled
- [ ] V5 end-to-end version pinning across substrates — enabled (`verifies[].requirement-version`)
- [ ] V6 author + timestamp — enabled

### §13.3.3 ADAPT

- [ ] Every active TZ has an approved ADAPT
- [ ] Every delta-TZ has a delta-ADAPT
- [ ] Dual signature (Architect + Client) is recorded

### §13.3.4 SPEC types

- [ ] All SPEC ∈ {ARCH, API, DATA, INT, PROC, UI, AI, SEC, OPS}
- [ ] No local `SPEC-CUSTOM-*`

### §13.3.5 TC pos/neg

- [ ] Every verifiable assertion has a pos + neg TC (or a negative-invariant exception)
- [ ] QG-2 blocks `verified` on violation

### §13.3.6 Quality Gates

- [ ] QG-0, QG-1, QG-2 implemented as `required`
- [ ] QG-3, QG-4 declared `required` | `declared` | `absent` in the manifest
- [ ] No local custom gates

### §13.3.7 Closed lists

- [ ] Backward finding types — closed list §7.4.4 only
- [ ] SPEC decomposition types — closed list §8 only

**Rule:** if at least one is unchecked → **do not release** the manifest ([§13.5.1](../../standard/en/13-conformance.md#13.5.1)).

---

## 3. Level checklist (choose the target RENAR-N)

The minimum for claiming a level is [standard/11 §11.4–12.8](../../standard/en/11-maturity-model.md). Brief summary:

| Level | Key additional criteria |
|---|---|
| RENAR-1 | Mandatory clauses only; frontmatter minimal |
| RENAR-2 | Canonical frontmatter + lifecycle-status enforcement |
| RENAR-3 | Full SPEC axis + hooks on all QG-0..QG-2 |
| RENAR-4 | ai-provenance mandatory; adversarial review for SPEC-SEC/AI |
| RENAR-5 | Multi-model consensus; continuous assessment; KG reconciliation |

- [ ] The chosen `level` in the manifest is **no higher** than the checklist actually passed
- [ ] `declared-stricter` (if present) is documented separately

---

## 4. Manifest template (minimal)

Save as `RENAR-CONFORMANCE.yaml` at the root of the requirements substrate:

```yaml
manifest-version: 1
manifest-id: "CFM-YYYY-NNN"
renar-version: "1.0-draft"
senar-version: "1.0"
level: RENAR-2
assessment-date: "2026-05-22"
assessment-type: self
next-assessment-due: "2026-08-22"

mandatory-clauses-confirmed:
  sot-inversion: true
  substrate-v1-v6: { v1: true, v2: true, v3: true, v4: true, v5: true, v6: true }
  adapt-per-tz: true
  spec-types-closed-list: true
  tc-pos-neg-pairing: true
  quality-gates-closed-list: true
  closed-lists-backward-findings: true

quality-gates:
  qg-0: required
  qg-1: required
  qg-2: required
  qg-3: declared
  qg-4: absent

external-claims:
  - standard: "ISO/IEC/IEEE 29148:2018"
    scope: "requirements classes, attributes, lifecycle, verification"
    evidence: "reference/07-iso29148-trace-matrix.md"

substrate:
  type: git
  capabilities-verified: "2026-05-22"
  project-req-ref: "<substrate-native pointer>"

signed-by:
  name: "<Architect / Tech Lead>"
  role: approver
  signed-at: "2026-05-22T12:00:00Z"
```

The full field list is [§13.4.2](../../standard/en/13-conformance.md#13.4.2).

---

## 5. Cadence

- Self-assessment: **quarterly** (default)
- After a delta-TZ that affects mandatory clauses — **out of cycle**
- Conformance-loss triggers — [§13.8](../../standard/en/13-conformance.md#13.8)

---

*Reference RENAR 1.0-draft — renar.tech*
