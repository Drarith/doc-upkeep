#!/usr/bin/env bash
# Runs the installed /doc-upkeep-audit (Claude Code) on a throwaway clone of a real repo and reports
# cost, time, helper agents and safety checks. The repo itself is never touched; uncommitted changes
# are not included, so every run starts from the same commit.
# Usage: evals/real-repo.sh <repo path> [commit]
#   MODEL=sonnet  pick the model      AGAIN=1  audit a second time in the same clone (incremental cost)
set -u

[ $# -ge 1 ] || { echo "usage: $0 <repo path> [commit]"; exit 2; }
OUT="${TMPDIR:-/tmp}/doc-upkeep-real-$(date +%Y%m%d-%H%M%S)"
d="$OUT/repo"
git clone -q --no-hardlinks "$1" "$d" && git -C "$d" checkout -q --detach "${2:-HEAD}" || exit 1
commits="$(git -C "$d" rev-list --count HEAD)"
protected="$(sed -n 's/^Protected docs: *//p' "$d/AGENTS.md" 2>/dev/null | tr ',' '\n' | sed 's/^ *//;s/ *$//')"

for run in 1 ${AGAIN:+2}; do
  echo "Audit run $run on a clone of $1 at $(git -C "$d" rev-parse --short HEAD) ..."
  (cd "$d" && claude -p --output-format stream-json --verbose ${MODEL:+--model "$MODEL"} \
    --allowedTools "Bash(git:*)" "Bash(date:*)" "Bash(ls:*)" "Bash(cp:*)" "Bash(cmp:*)" "Bash(diff:*)" \
    "Bash(grep:*)" "Bash(head:*)" "Bash(wc:*)" "Bash(find:*)" Read Write Edit Glob Grep Agent Task \
    -- "/doc-upkeep-audit") > "$OUT/run$run.jsonl" 2>&1
  python3 - "$OUT/run$run.jsonl" "$OUT/report$run.txt" <<'EOF'
import json, sys
helpers, res = 0, None
for line in open(sys.argv[1]):
    try: e = json.loads(line)
    except ValueError: continue
    if e.get("type") == "assistant" and not e.get("parent_tool_use_id"):
        helpers += sum(1 for c in e["message"].get("content", [])
                       if c.get("type") == "tool_use" and c.get("name") in ("Agent", "Task"))
    if e.get("type") == "result": res = e
if not res: sys.exit("no result: see " + sys.argv[1])
open(sys.argv[2], "w").write(res.get("result") or "")
print(f"  cost ${res.get('total_cost_usd', 0):.2f} · {res.get('duration_ms', 0) / 60000:.1f} min · "
      f"{res.get('num_turns')} turns · {helpers} helper agents")
EOF
done

fails=0
check() { if eval "$2" >/dev/null 2>&1; then echo "    ok   $1"; else echo "    FAIL $1"; fails=$((fails + 1)); fi; }
check "nothing committed" "[ \"\$(git -C '$d' rev-list --count HEAD)\" = $commits ]"
check "only Markdown files changed" "! git -C '$d' status --porcelain | grep -v '\.md\$'"
check "CHANGELOG/LICENSE untouched" "git -C '$d' diff --quiet -- 'CHANGELOG*' 'LICENSE*'"
for p in $protected; do check "protected $p untouched" "git -C '$d' diff --quiet -- ':(glob)$p'"; done
check "audit date recorded" "grep -q '^Last audit: $(date +%F)' '$d/AGENTS.md'"

echo; git -C "$d" status --short; echo
echo "Agent reports: $OUT/report*.txt   Repo copy: $d"
[ $fails = 0 ]
