#!/usr/bin/env bash
# End-to-end evals: builds throwaway repos, runs doc-upkeep headless, checks the results.
# Usage: evals/run.sh [claude] [codex] [opencode]   (default: all three)
# Tests the doc-upkeep skill each agent has *installed*, so install from this checkout first.
set -u

SKILL_DIR="$(cd "$(dirname "$0")/../skills/doc-upkeep" && pwd)"
OUT="${TMPDIR:-/tmp}/doc-upkeep-evals-$(date +%Y%m%d-%H%M%S)"
MUST_READ="$(grep -o '> Before finishing[^`]*' "$SKILL_DIR/SKILL.md")"
SCENARIOS="${SCENARIOS:-fresh existing-claude audit-drift protected normal-task}"
TASK="Make add() in src/math.js throw a TypeError when either argument is not a number."
mkdir -p "$OUT"
total_fails=0
summary=""

g() { git -c user.name=eval -c user.email=eval@example.com "$@"; }

check() { # check "<description>" '<shell test>'
  if eval "$2" >/dev/null 2>&1; then echo "    ok   $1"; else echo "    FAIL $1"; fails=$((fails + 1)); fi
}

base_repo() {
  mkdir -p "$1/src" && cd "$1" && git init -q
  printf '{"name":"demo","scripts":{"dev":"vite","test":"vitest"}}\n' > package.json
  echo "export const add = (a, b) => a + b" > src/math.js
  printf '# Demo\n\nA tiny demo app.\n' > README.md
}

set_up_docs() { # what a finished setup looks like, written by hand
  cp "$SKILL_DIR/rules.md" doc-upkeep.md
  printf '%s\n\n# demo\n\nSource is in `src/math.js` (exports `add`).\n' "$MUST_READ" > AGENTS.md
  echo "@AGENTS.md" > CLAUDE.md
}

build() { # build <scenario> <dir>
  base_repo "$2"
  case $1 in
    existing-claude) printf '# Notes\n\n- Use pnpm, not npm: the lockfile is pnpm-lock.yaml.\n' > CLAUDE.md ;;
    normal-task) set_up_docs; printf "\n## Gotchas\n- \`add\` does no type checking, so \`add('1', 2)\` returns \`'12'\`.\n" >> AGENTS.md ;;
    audit-drift) set_up_docs; g add -A; g commit -qm docs; mkdir -p src/lib; git mv src/math.js src/lib/calc.js ;;
    protected)
      set_up_docs
      printf '\nProtected docs: README.md\n' >> AGENTS.md
      printf '\n## Architecture\n\nThe entry point is `src/old.js`.\n' >> README.md ;;
  esac
  g add -A && g commit -qm fixture
}

run() { # run <agent> <setup|audit> <dir> <log>
  local slash="/doc-upkeep" words="Use the doc-upkeep skill to set up doc-upkeep in this repo."
  if [ "$2" = audit ]; then slash="/doc-upkeep-audit"; words="Use the doc-upkeep-audit skill to audit the docs in this repo."; fi
  if [ "$2" = task ]; then slash="$TASK"; words="$TASK"; fi  # an ordinary task that never mentions docs
  case $1 in
    claude) (cd "$3" && claude -p --model sonnet --allowedTools "Bash(git:*)" "Bash(cp:*)" "Bash(cmp:*)" \
              "Bash(diff:*)" "Bash(date:*)" "Bash(ls:*)" "Bash(head:*)" "Bash(grep:*)" "Bash(wc:*)" \
              Read Write Edit Glob Grep -- "$slash") ;;
    codex) codex exec -C "$3" -s workspace-write --skip-git-repo-check "$words" ;;
    opencode) opencode run --dir "$3" --auto "$words" ;;
  esac > "$4" 2>&1
}

for agent in ${*:-claude codex opencode}; do
  for s in $SCENARIOS; do
    d="$OUT/$agent-$s"; log="$OUT/$agent-$s.log"; fails=0
    (build "$s" "$d") || { echo "fixture $s failed"; exit 1; }
    cp "$d/README.md" "$OUT/$agent-$s.README.before"
    [ -f "$d/doc-upkeep.md" ] && cp "$d/doc-upkeep.md" "$OUT/$agent-$s.rules.before"
    commits="$(git -C "$d" rev-list --count HEAD)"
    mode=setup; case $s in audit-drift|protected) mode=audit ;; normal-task) mode=task ;; esac
    echo "== $agent / $s ($mode)"
    run "$agent" "$mode" "$d" "$log"

    check "nothing committed" "[ \"\$(git -C '$d' rev-list --count HEAD)\" = $commits ]"
    case $s in
      fresh|existing-claude)
        check "rules copied verbatim" "cmp -s '$SKILL_DIR/rules.md' '$d/doc-upkeep.md'"
        check "must-read line exactly once" "[ \"\$(grep -cF -- '$MUST_READ' '$d/AGENTS.md')\" = 1 ]"
        check "CLAUDE.md is a regular file" "[ -f '$d/CLAUDE.md' ] && [ ! -L '$d/CLAUDE.md' ]"
        check "CLAUDE.md imports @AGENTS.md once" "[ \"\$(grep -cx '@AGENTS.md' '$d/CLAUDE.md')\" = 1 ]" ;;
    esac
    case $s in
      existing-claude)
        check "@AGENTS.md is the first line" "[ \"\$(head -1 '$d/CLAUDE.md')\" = '@AGENTS.md' ]"
        check "existing pnpm note kept or moved" "grep -q pnpm '$d/CLAUDE.md' '$d/AGENTS.md'" ;;
      audit-drift)
        check "dead path src/math.js removed" "! grep -q 'src/math.js' '$d/AGENTS.md'"
        check "new path calc.js documented" "grep -q 'calc.js' '$d/AGENTS.md'"
        check "rules copy untouched" "cmp -s '$OUT/$agent-$s.rules.before' '$d/doc-upkeep.md'" ;;
      protected)
        check "protected README untouched" "cmp -s '$OUT/$agent-$s.README.before' '$d/README.md'"
        check "Protected docs line kept" "grep -q '^Protected docs:.*README.md' '$d/AGENTS.md'"
        check "report mentions the README problem" "grep -qi readme '$log'"
        check "rules copy untouched" "cmp -s '$OUT/$agent-$s.rules.before' '$d/doc-upkeep.md'" ;;
      normal-task)
        check "task done (add throws TypeError)" "grep -q TypeError '$d/src/math.js'"
        check "outdated gotcha fixed or removed" "! grep -q \"returns .'12'\" '$d/AGENTS.md'"
        check "report lists the AGENTS.md change" "grep -q AGENTS.md '$log'"
        check "rules copy untouched" "cmp -s '$OUT/$agent-$s.rules.before' '$d/doc-upkeep.md'" ;;
    esac
    [ $fails = 0 ] && r=PASS || r="FAIL ($fails)"
    summary="$summary$(printf '%-9s %-16s %s' "$agent" "$s" "$r")\n"
    total_fails=$((total_fails + fails))
  done
done

printf '\n%b' "$summary"
echo "Repos and agent logs: $OUT"
[ $total_fails = 0 ]
