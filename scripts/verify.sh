#!/bin/sh
# Repository checks for the Opus Advisor Claude Code plugin.

set -eu

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

repo=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
plugin=$repo/plugins/opus-advisor
agents=$plugin/agents
skill=$plugin/skills/orchestration/SKILL.md

claude plugin validate "$plugin" >/dev/null || fail "plugin validation"
claude plugin validate "$repo" >/dev/null || fail "marketplace validation"
pass "plugin and marketplace validate"

field() { sed -n "s/^$2: //p" "$agents/$1.md" | head -n 1; }

check_agent() {
  [ "$(field "$1" model)" = "$2" ] || fail "$1 model is not $2"
  [ "$(field "$1" effort)" = "$3" ] || fail "$1 effort is not $3"
  grep -Fq "opus-advisor:$1" "$skill" || fail "skill does not name $1"
}

check_agent haiku-implementer claude-haiku-5-5 max
check_agent sonnet-implementer claude-sonnet-5-5 high
check_agent opus-reviewer claude-opus-5-5 high
[ "$(find "$agents" -type f | wc -l | tr -d ' ')" = 3 ] || fail "expected exactly three agents"
pass "agent model and effort pins"

[ "$(field opus-reviewer tools)" = "Read, Grep, Glob" ] || fail "reviewer tools are not read-only"
pass "reviewer tools are read-only"

for text in 'SELECTIVE ROUTE' 'mode: solo | delegate | audit | full' \
  'No task tool call may precede this declaration' 'Solo is the default' \
  'never silently downgrade'; do
  grep -Fq "$text" "$skill" || fail "skill omits: $text"
done
pass "skill keeps the routing contract"

if grep -RInEi 'codex|gpt-5|openai|fork_turns|agent_type' "$repo/plugins" "$repo/.claude-plugin"; then
  fail "Codex-specific text remains"
fi
pass "no Codex-specific text in the plugin"

sh -n "$0"
printf 'VERIFY PASSED\n'
