# Opus Advisor

**Opus / High runs the show. It declares a risk-gated route before task tools, keeps
solo as the default, and uses a single subagent only when that improves delivery.**

Opus Advisor is a Claude Code plugin for capability-routed software delivery. You
bring the goal and constraints; Opus owns the plan, implementation or delegation,
verification, and acceptance. It is a Claude Code port of
[Sol Advisor](https://github.com/DannyMac180/sol-advisor) by Daniel McAteer.

## Go deeper

Daniel McAteer, the original author, writes [**Attention Heads**](https://attentionheads.substack.com/?utm_source=github&utm_medium=readme&utm_campaign=sol-advisor) — deep, evidence-backed writing on AI, cognition, and agentic engineering. The **Agentic Engineering Field Notes** series covers practical advice on the craft of using AI. [Subscribe](https://attentionheads.substack.com/subscribe?utm_source=github&utm_medium=readme&utm_campaign=sol-advisor) to get new posts to your inbox.

## Quick start

You need a current Claude Code with access to Claude Opus 5.5. Sonnet 5.5 or Haiku 5.5
access is needed only when the selected route delegates to them.

~~~sh
claude plugin marketplace add tanthinhdt/opus-advisor
claude plugin install opus-advisor@opus-advisor
~~~

Start a new session on Opus at high effort (`/model opus`, then `/effort high`) and run:

~~~text
/opus-advisor:orchestration Build this feature and verify it.
~~~

## Routes

| Mode | Use it when | Delivery |
|---|---|---|
| `solo` | Default; risk is contained. | Opus plans, implements, tests, and self-reviews. |
| `delegate` | A complete spec is better executed by one implementer. | Haiku / Max for bounded work, or Sonnet / High for judgment-heavy or high-risk work; Opus verifies. |
| `audit` | Independent final scrutiny matters more than delegation. | Opus implements; a fresh read-only Opus / High reviews. |
| `full` | Explicit broad or high-risk exception. | One selected implementer, Opus verification, and a fresh Opus / High review. |

Solo is the default, and one subagent is the default maximum. Opus emits a
`SELECTIVE ROUTE` declaration with the mode and a short risk rationale before its first
task tool call. It can escalate only when newly observed risk justifies it, and it
never silently downgrades.

## What happens automatically

Opus keeps architecture, decomposition, route selection, verification, escalation, and
acceptance in the main session. Subagent work replaces main-session work rather than
duplicating it. Opus inspects the complete diff and reruns the requested checks. When
the route includes a review, a fresh reviewer returns ship, fix-first, or rethink, and
any fix requires a new review. The reviewer can only read and search files.

## Model pins

Each subagent pins its model and effort in `plugins/opus-advisor/agents/`. While a
subagent runs, `/tasks` shows the model it is using. These settings override the pins:

- `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` with `CLAUDE_CODE_SUBAGENT_MODEL` forces one model.
- `CLAUDE_CODE_EFFORT_LEVEL` forces one effort level.
- An organization `availableModels` allowlist can make a subagent fall back to another
  model. The skill treats that fallback as a failed lane.

## Updating

~~~sh
claude plugin marketplace update opus-advisor
claude plugin update opus-advisor@opus-advisor
~~~

Then start a new session.

## Development

Load this checkout directly, and run the repository checks before committing:

~~~sh
claude --plugin-dir ./plugins/opus-advisor
sh scripts/verify.sh
~~~
