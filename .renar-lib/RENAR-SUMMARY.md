# RENAR — Requirements Engineering & Normative Adaptive Regulation

AI-native standalone standard and methodology for requirements engineering. Complements SENAR; works independently.
Version 0.1-draft | 13.05.2026 | Authors: Vadim Soglaev, Andrey Yumashev | renar.tech

## In One Sentence

RENAR is a standalone normative standard defining how to manage requirements (BR/SR/TR), specifications (9 SPEC types), test cases, and adaptation artifacts (ADAPT) in projects where AI agents produce the implementation — substrate-agnostic across git / Mercurial / SVN / Raven; adopted independently or alongside SENAR.

## The Shift

In AI-native development the implementation is produced by agents from inputs. The Source of Truth shifts from code to requirements: requirements define behavior, agents emit implementation, tests verify against requirements — not the reverse. RENAR formalizes this Spec-Driven Development inversion as substrate-agnostic normative rules.

## 5 Values (inherited from SENAR)

1. **Context over Code** — AI output quality = input context quality
2. **Verification over Speed** — correctness is the constraint, not velocity
3. **Knowledge over Experience** — what's not documented doesn't exist for AI
4. **Enforcement over Agreement** — quality gates as automated code, not meetings
5. **Judgment over Keystrokes** — human attention on decisions, not typing

## RENAR Core Structure

15 normative chapters (00–14): introduction, scope, normative references, terms, roles, methodology positioning, requirements hierarchy, ADAPT artifact, specifications, test cases, lifecycle and quality gates, substrate versioning, maturity model, metrics, conformance.

## Core Structure (Standard)

- **3-level Hierarchy:** BR (Business — who, what, why) → SR (System — what the system does) → TR (Task — Goal + AC in tracker, not a file)
- **ADAPT artifact:** bidirectional adaptation between immutable TZ and BR/SR/SPEC; forward interpretation + backward findings (7 categories); client + architect double signature
- **9 SPEC types (closed list):** ARCH / API / DATA / INT / PROC / UI / AI / SEC / OPS — parallel axis to requirements via `constrained-by[]` graph edges
- **Test Cases (TC):** first-class artifact; pos/neg pair coverage; VLM-judge for UX; spec-specific TC types; `[test-spec-change]` tag protects against test tampering
- **4 Quality Gates:** QG-0 (Context) → QG-1 (Requirements) → QG-2 (Implementation) → QG-3 (Verification) → QG-4 (Acceptance) — RENAR adds requirements-specific state machine for each artifact
- **Substrate capabilities V1–V6:** versioned identity, atomic change unit, parent-link, content-diff, branch/merge, hooks — same normative rules across git, Mercurial, SVN, Raven
- **5 RENAR Maturity Levels:** RENAR-1 (Initial) → RENAR-2 (Managed) → RENAR-3 (Defined) → RENAR-4 (Measured) → RENAR-5 (Optimizing) — one axis of overall SENAR maturity

## Key Innovations (not in any other requirements standard)

- **ADAPT as mandatory intermediate artifact** — separates immutable client TZ from architect-interpreted BR/SR/SPEC; backward findings prevent silent reinterpretation
- **9 SPEC types as closed list** — adding a new SPEC type requires a standard amendment (prevents private artifact-type sprawl)
- **`constrained-by[]` graph edges** — specifications constrain requirements bidirectionally; not parent-child but parallel axis
- **Substrate-agnostic V1–V6** — normative language never mentions `git`, `commit`, `PR`; capabilities are abstracted
- **Test Case as first-class artifact** — not a derived attribute of a requirement; has independent lifecycle and source provenance
- **AI provenance for AI-generated artifacts** — every AI-emitted artifact records model, prompt-hash, generated-at; `[test-spec-change]` tag required for evaluator change

## Document Set

| Document | Purpose |
|----------|---------|
| RENAR Standard | Normative specification (SHALL/SHOULD/MAY), 15 chapters (00–14) |
| RENAR Guide | Practical guide: quickstart, walkthrough, transition, tool guides, SAFe comparison, compliance, failure modes, developer guide |
| RENAR Reference | Glossary, schemas, AI risk register, appendices |
| RENAR Core | Gentle single-document introduction |
| Standard for the agent | Self-sufficient operational edition in one file for an AI agent — [RENAR-AGENT-EN.md](RENAR-AGENT-EN.md) (EN) · [RENAR-AGENT-RU.md](RENAR-AGENT-RU.md) (RU) |
