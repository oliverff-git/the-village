#!/usr/bin/env bash
set -euo pipefail

# Inputs via env (provide sane defaults for dry runs)
OBJECTIVE="${OBJECTIVE:-Add pagination + tests to /api/orders}"
BASE_REF="${BASE_REF:-main}"
TEST_CMD="${TEST_CMD:-pytest -q}"
CLAUDE_AGENTS="${CLAUDE_AGENTS:-Planner,Backend,QA}"
CODEX_AGENTS="${CODEX_AGENTS:-Docs,Refactor,CI}"

# Binaries
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CODEX_BIN="${CODEX_BIN:-codex}"

# Folders
mkdir -p worktrees agents/tickets agents/logs

# Helper: slugify
slug() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g;s/^-|-$//g'; }

# Helper: create one agent worktree + ticket
create_wt_and_ticket () {
  local tool="$1" ; local name="$2"
  local sname="$(echo "$name" | xargs)"
  local slugified="$(slug "$sname")"
  local branch="agent/${tool}/${slugified}"
  local wtdir="worktrees/${tool}/${slugified}"
  git worktree add -B "$branch" "$wtdir" "$BASE_REF" >/dev/null 2>&1
  mkdir -p "agents/${slugified}"
  # Don't overwrite existing tickets
  if [[ ! -f "agents/tickets/${slugified}.md" ]]; then
    printf "Agent: %s (%s)\nObjective: %s\nScope: (fill by orchestrator)\nTests: (list of tests to add/adjust)\nConstraints: edit only inside %s\n" \
      "$sname" "$tool" "$OBJECTIVE" "$wtdir" > "agents/tickets/${slugified}.md"
  fi
  echo "$branch|$wtdir|$slugified"
}

declare -a WT_INFO=()

# 1) Create worktrees for Claude agents
IFS=',' read -r -a C_ARR <<< "$CLAUDE_AGENTS"
for NAME in "${C_ARR[@]}"; do
  WT_INFO+=("$(create_wt_and_ticket "claude" "$NAME")")
done

# 2) Create worktrees for Codex agents
IFS=',' read -r -a X_ARR <<< "$CODEX_AGENTS"
for NAME in "${X_ARR[@]}"; do
  WT_INFO+=("$(create_wt_and_ticket "codex" "$NAME")")
done

# 3) Launch workers in parallel
pids=()

for entry in "${WT_INFO[@]}"; do
  IFS='|' read -r BR WTDIR SLUG <<< "$entry"
  TOOL="$(echo "$BR" | cut -d'/' -f2)"  # claude|codex

  read -r -d '' PROMPT <<EOF || true
[AGENT ROLE: ${SLUG}]
Objective: ${OBJECTIVE}
Constraints: Only edit inside this worktree (${WTDIR}); add/adjust tests first; run: ${TEST_CMD}; keep diffs small.
Steps:

1. Read agents/tickets/${SLUG}.md
2. Implement tests → make them pass
3. Write agents/${SLUG}/RESULT.md (summary, commands run, files changed, short test log)
4. Commit with message "[${BR}] ${SLUG}: summary"
   Output: leave branch ${BR} ready for PR.
EOF

(
  cd "$WTDIR"
  mkdir -p "agents/${SLUG}"
  LOG="../../agents/logs/${TOOL}-${SLUG}.log"

  if [[ "$TOOL" == "claude" ]]; then
    ${CLAUDE_BIN} -p "$PROMPT" --permission-mode acceptEdits > "$LOG" 2>&1 || true
  else
    ${CODEX_BIN} exec "$PROMPT" > "$LOG" 2>&1 || true
  fi
) & pids+=($!)
done

# 4) Join all workers
for pid in "${pids[@]}"; do wait "$pid"; done

# 5) Aggregate minimal report
{
  echo "# Aggregate Report"
  echo
  for entry in "${WT_INFO[@]}"; do
    IFS='|' read -r BR WTDIR SLUG <<< "$entry"
    echo "## ${BR}"
    echo ""
    if [[ -f "${WTDIR}/agents/${SLUG}/RESULT.md" ]]; then
      sed -n '1,120p' "${WTDIR}/agents/${SLUG}/RESULT.md"
    else
      echo "*No RESULT.md found*"
    fi
    echo ""
  done
} > agents/AGGREGATE.md

echo "All agents completed. See agents/logs/*.log, per-branch diffs, and agents/AGGREGATE.md."
echo "Suggested next step: create a merge branch and integrate agents one-by-one."