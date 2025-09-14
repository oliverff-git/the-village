<<<SCRIPT
#!/usr/bin/env bash
set -euo pipefail

# Inputs via env (provide sane defaults for dry runs)

OBJECTIVE="${OBJECTIVE:-Add pagination + tests to /api/orders}"
BASE\_REF="${BASE\_REF:-origin/main}"
TEST\_CMD="${TEST\_CMD:-pytest -q}"
CLAUDE\_AGENTS="${CLAUDE\_AGENTS:-Planner,Backend,QA}"
CODEX\_AGENTS="${CODEX\_AGENTS:-Docs,Refactor,CI}"

# Binaries

CLAUDE\_BIN="${CLAUDE\_BIN:-claude}"
CODEX\_BIN="${CODEX\_BIN:-codex}"

# Folders

mkdir -p worktrees agents/tickets agents/logs

# Helper: slugify

slug() { echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g;s/^-|-$//g'; }

# Helper: create one agent worktree + ticket

create\_wt\_and\_ticket () {
local tool="$1" ; local name="$2"
local sname="$(echo "$name" | xargs)"
local slugified="$(slug "$sname")"
local branch="agent/${tool}/${slugified}"
local wtdir="worktrees/${tool}/${slugified}"
git worktree add -B "$branch" "$wtdir" "$BASE\_REF"
mkdir -p "agents/${slugified}"
printf "Agent: %s (%s)\nObjective: %s\nScope: (fill by orchestrator)\nTests: (list of tests to add/adjust)\nConstraints: edit only inside %s\n" 
"$sname" "$tool" "$OBJECTIVE" "$wtdir" > "agents/tickets/${slugified}.md"
echo "$branch|$wtdir|$slugified"
}

# 1) Create worktrees for Claude agents

declare -a WT\_INFO=()
IFS=',' read -r -a C\_ARR <<< "$CLAUDE\_AGENTS"
for NAME in "${C\_ARR[@]}"; do
mapfile -t out < <(create\_wt\_and\_ticket "claude" "$NAME")
WT\_INFO+=("${out[0]}")
done

# 2) Create worktrees for Codex agents

IFS=',' read -r -a X\_ARR <<< "$CODEX\_AGENTS"
for NAME in "${X\_ARR[@]}"; do
mapfile -t out < <(create\_wt\_and\_ticket "codex" "$NAME")
WT\_INFO+=("${out[0]}")
done

# 3) Launch workers in parallel

pids=()

for entry in "${WT\_INFO[@]}"; do
IFS='|' read -r BR WTDIR SLUG <<< "$entry"
TOOL="$(echo "$BR" | cut -d'/' -f2)"  # claude|codex

# Build the worker prompt (self-contained)

read -r -d '' PROMPT <<EOF
[AGENT ROLE: ${SLUG}]
Objective: ${OBJECTIVE}
Constraints: Only edit inside this worktree (${WTDIR}); add/adjust tests first; run: ${TEST\_CMD}; keep diffs small.
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
Claude Code headless mode with permissive edits; network prompts still require confirmation unless configured
See Anthropic docs for -p (print/headless) and permission modes.
${CLAUDE_BIN} -p "$PROMPT" --permission-mode acceptEdits > "$LOG" 2>&1
else
Codex non-interactive exec mode
${CODEX_BIN} exec "$PROMPT" > "$LOG" 2>&1
fi

) & pids+=($!)
done

# 4) Join all workers

for pid in "${pids[@]}"; do wait "$pid"; done

# 5) Aggregate minimal report

{
echo "# Aggregate Report"
echo
for entry in "${WT\_INFO[@]}"; do
IFS='|' read -r BR WTDIR SLUG <<< "$entry"
echo "## ${BR}"
echo ""
if [[ -f "worktrees/${BR#agent/*/}/agents/${SLUG}/RESULT.md" ]]; then
sed -n '1,120p' "worktrees/${BR#agent/*/}/agents/${SLUG}/RESULT.md"
else
echo "*No RESULT.md found*"
fi
echo ""
done
} > agents/AGGREGATE.md

echo "All agents completed. See agents/logs/*.log, per-branch diffs, and agents/AGGREGATE.md."
echo "Suggested next step: create a merge branch and integrate agents one-by-one."
SCRIPT>>>


