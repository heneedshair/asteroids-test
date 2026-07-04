---
title: "Working with the AI agent"
order: 11
lang: en
---
# 11. Working with the AI agent

> **This is not "manual mode."** A common misconception: since RENAR requires human approvals, everything must be done by hand. The opposite is true — the bulk of the work (drafts of `BR`/`SR`/`SPEC`/`TC`, the initial interpretation of the TZ, the search for contradictions) is done by the agent. The human does not type artifacts; the human **approves** them at a few fixed points. This chapter shows how to load the standard into the agent, what commands to give, and what you get as output.
>
> The normative delegation model — [standard/05 Roles](../../standard/en/05-roles.md) and the ADAPT approval points — [standard/07 §7](../../standard/en/07-adapt.md). The self-sufficient edition for the agent is `RENAR-AGENT-EN.md` (in the repository root and at [renar.tech](https://renar.tech)).

---

## 1. Who does what: the delegation map

The agent is an executor: it produces and maintains artifacts, but it does not own them and does not sign. The human is the owner and the one who approves. The boundary runs along fixed points:

| Step | The agent does | The human approves |
|---|---|---|
| TZ import | Registers the TZ as an immutable document, captures the client's signature | — (the client signs when delivering the TZ) |
| Adversarial review | A critic agent on a **different model** issues the verdict "findings present" / "no findings" | The Architect records the verdict as evidence |
| ADAPT | Prepares a draft: forward interpretation + backward findings | Dual signature: client + Architect |
| Decomposition | Creates `BR` → `SR` → `SPEC` → `TR` with provenance | The Architect approves the transition to `approved` (QG-0) |
| Tests | Writes `TC` pairs (positive + negative) | The automated run records the result (QG-2) |
| Delivery | Presents the business outcome | The stakeholder accepts it (QG-4) |

If human approval is not obtained, the artifact stays in `draft`, and the substrate blocks the transitions. The agent never declares itself the owner and never signs.

---

## 2. How to load the standard into the agent

The agent does not need the entire normative corpus — for everyday work a single file is enough.

1. Download `RENAR-AGENT-EN.md` — the self-sufficient operational edition (≈400 lines): the artifact map, the workflow, ADAPT, the closed lists, the hard rules, the recording forms (frontmatter + body sections).
2. Place the file beside the agent — in the project context, the system prompt, or as a session attachment (depends on your tool).
3. Give the setup command: "Study this file — it is the RENAR standard. From now on do requirements engineering strictly by it."
4. Optionally add project context: the registry of systems and subsystems, a link to your artifact substrate, the naming convention.

Attach the full corpus (`standard/`, `reference/`) only when a formal dispute over the exact wording of a norm arises — for most tasks the operational edition is enough.

---

## 3. How to give commands

Commands to the agent are ordinary natural-language statements tied to a workflow step. Below are typical examples; substitute your own identifiers.

**TZ import and review:**

```text
Here is the client TZ (file TZ-2026-001). Register it as an immutable document.
Then run an adversarial review: issue the verdict "findings present" or "no findings",
with reasoning across the 7 categories (contradiction, gap, hidden assumption,
feasibility, regulatory, terminology, scope).
```

**Creating an ADAPT (if there are findings):**

```text
The review found findings. Prepare an ADAPT draft: a forward interpretation by TZ
section plus backward findings as questions for the client. Do not fill in for the
client — turn whatever is unclear into a question.
```

**Decomposition:**

```text
The ADAPT is approved. Derive a BR (business goal) from it, then SR (system behavior),
then SPEC of the needed types. Set source and parent on every artifact. Show the
relationship graph before committing.
```

**Tests:**

```text
For every normative statement in SR-03, write a TC pair: positive and negative.
The Pass criterion must be binary and observable.
```

A good command names the **input** (which artifact), the **action** (what to produce), and the **expectation** (what to check). The agent handles the routine itself; step in where your decision is needed.

---

## 4. What you get as output

The agent returns not chat text but ready substrate artifacts — with machine-readable frontmatter and a body in fixed sections:

- **`BR`** — the business need: who, what, why; success criteria; context with a reference to an ADAPT.
- **`SR`** — system behavior: one requirement, behavior, constraints, link to `SPEC`.
- **`SPEC-<TYPE>`** — a specification of one of the nine types, linked to the `SR` via `constrained-by[]`.
- **`TC`** — positive/negative pairs with `verifies[]` pointing at the verified artifact.

Every artifact has its `source` set (origin from the TZ or an ADAPT) and, for AI-generated ones, an `ai-provenance` block (model, prompt template, the fact of a human edit). Ready copy-paste skeletons for all forms are in [reference/12 Document templates](../../reference/en/12-document-templates.md).

The mark of good output: from any artifact a chain traces upward — to the `SR`, to the `BR`, to a TZ section. If the chain breaks, the artifact is not ready.

---

## 5. Points of human approval

Delegation to the agent is broad, but it has hard boundaries. A human is required in four places (normatively — [standard/10 Lifecycle and quality gates](../../standard/en/10-lifecycle-qg.md)):

1. **TZ signature** — the client signs the contractual input; the agent only registers it.
2. **ADAPT dual signature (QG-3)** — the client confirms that the interpretation matches the intent; the Architect confirms that the findings are worked through and the interpretation is feasible. Until then the ADAPT is not approved.
3. **QG-0 approval** — the Architect moves `BR`/`SR`/`SPEC` from `draft` to `approved`. Only after this is further decomposition allowed.
4. **QG-4 acceptance** — the stakeholder accepts the business outcome.

Between these points the agent acts on its own. An attempt to make the agent sign, or to declare it `Accountable`, breaks the role model.

---

## 6. A full session end to end

To dispel the sense of "magic", here is an end-to-end scenario — what the agent does and where the human steps in:

1. You hand the agent the TZ and `RENAR-AGENT-EN.md`. The agent registers the TZ.
2. A critic agent (a different model) runs an adversarial review → verdict "findings present".
3. The agent prepares an ADAPT draft with questions for the client. The **Architect** relays the questions to the client, transcribes the answers, and signs together with the client → the ADAPT is approved.
4. The agent derives `BR` → `SR` → `SPEC`, shows the relationship graph. The **Architect** approves QG-0.
5. The agent writes `TC` pairs and runs them; the runner records the result (QG-2).
6. The agent assembles the business outcome. The **stakeholder** accepts it (QG-4).

Of the six steps the human joins in on three — and only to approve, not to type artifacts.

---

## 7. Common mistakes

| Mistake | Why it is bad | What to do instead |
|---|---|---|
| Asking the agent to "just write code" from the TZ | The source of truth is lost — code without requirements | Requirements first, then implementation derived from them |
| Skipping the adversarial review | "No ADAPT needed" becomes a silent assumption | The review is always mandatory; "no findings" is a recorded verdict of a different model |
| Letting the agent sign the ADAPT | The agent is not the owner or a signatory | The signature is always a human (client + Architect) |
| Reconstructing `SR` from finished code | Source-of-truth inversion | Change the requirement → then the code; the exception is a justified bug-fix |
| Using one model to both generate and check | No independence of review | The critic is on a different model than the generator |

---

[← Back to the guide overview](README.md)
