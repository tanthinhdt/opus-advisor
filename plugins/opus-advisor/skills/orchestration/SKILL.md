---
name: orchestration
description: "Risk-gated selective routing for software delivery in Claude Code: default solo delivery, targeted subagent delegation or audit, and exceptional full review. Use when the user asks for Opus Advisor or a declared delivery route."
---

# Opus Advisor Orchestration

Act as the architect. Own the user's intent, architecture, route choice, decomposition,
implementation or delegation, verification, escalation, and final acceptance.

## Confirm the primary session

Run the primary session on Claude Opus 5.5 at high effort. If the session's model is
different, tell the user to switch with `/model` and stop before delegating. A skill
cannot read or change effort, so unless the user has stated it, ask them to confirm
high effort (`/effort high`) and stop until they do.

## Declare the route before task tools

Before the first task tool call, emit:

~~~text
SELECTIVE ROUTE
mode: solo | delegate | audit | full
risk: <concise, task-specific rationale>
~~~

No task tool call may precede this declaration. Solo is the default. One auxiliary
agent is the default maximum. A later declaration may only escalate the route, with
the newly observed risk recorded; never silently downgrade.

| Mode | Delivery |
|---|---|
| `solo` | Root plans, implements, tests, and self-reviews. No subagent. |
| `delegate` | One selected implementer executes the complete spec; root verifies. No fresh review. |
| `audit` | Root implements and verifies; a fresh `opus-reviewer` reviews. No implementer. |
| `full` | Explicit broad or high-risk exception: one implementer, root verification, then a fresh `opus-reviewer`. |

## Select and spawn subagents

Use the Agent tool with these exact types:

- `opus-advisor:haiku-implementer` for bounded, fully specified work.
- `opus-advisor:sonnet-implementer` for judgment-heavy, high-risk, context-heavy, or
  wide-blast-radius work.
- `opus-advisor:opus-reviewer` for audit and full review.

Do not pass a `model` or `effort` override, and do not use `fork`: each lane starts
fresh with its pinned model. If a required agent type is unavailable, stop that lane
and tell the user; never substitute another agent, model, or reviewer. If a subagent's
report opens with a notice that it switched models, treat that lane as failed and tell
the user.

Auxiliary work must substitute for root work, not duplicate it. A Haiku result may
justify a declared escalation to Sonnet only when it reveals new complexity, risk, wide
blast radius, or misclassification. One corrected Haiku attempt is reserved for a
specification error and is not a prerequisite for Sonnet.

## Implementer prompt

~~~text
OBJECTIVE
<Observable outcome and why it matters.>

FILES AND OWNERSHIP
You own only:
- <exact file or module>
Others may be editing concurrently. Preserve their edits, do not revert unrelated work,
and do not modify files outside your ownership.

INTERFACES
- <Signatures, types, schemas, commands, or behavior that must remain compatible.>

CONSTRAINTS
- <Repository conventions, safety boundaries, excluded scope, settled decisions.>

VERIFICATION
- Run: <exact command>
  Success: <concrete expected result>
- Inspect: <exact file, diff, or artifact>
  Success: <concrete expected evidence>

RETURN
IMPLEMENTATION REPORT
STATUS: complete | partial | blocked
OBJECTIVE: <one-line restatement>
CHANGES: <file-by-file summary from the actual diff>
VERIFIED: <exact commands plus concrete output evidence>
JUDGMENT CALLS: <decisions the specification left open, or none>
GAPS: <unfinished work, ambiguity, or none>
~~~

Treat worker reports as claims. Inspect the complete diff and changed-file scope, and
rerun the requested checks in the primary session.

## Review only when the route includes it

For `audit` and `full`, after root verification, spawn a new `opus-reviewer` with the
stated goal, exact allowed files, the complete accumulated diff pasted into the prompt,
interfaces and constraints, and actual verification output. The reviewer can only read
and search files, so it cannot run `git` or tests itself.

- ship: report completion with the verification evidence.
- fix-first, audit: root makes the correction, re-verifies, and obtains a new reviewer.
- fix-first, full: the selected implementer makes the correction, root re-verifies, and
  a new reviewer reviews.
- rethink: revise the architecture and do not report completion.

Any implementation correction invalidates the prior verdict. A reviewer never
implements its own findings. Opus reviewing Opus gives a clean context, not
cross-model independence.
