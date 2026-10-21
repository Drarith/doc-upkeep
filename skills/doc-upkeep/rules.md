# Doc Upkeep Rules

Version: 2026-10-21.19
Source: https://github.com/Drarith/doc-upkeep (install: `npx skills add Drarith/doc-upkeep`)
Don't edit this copy; rerunning the skill's setup overwrites it. Change the rules in the skill instead.

## Purpose
Project docs let a fresh session understand the project fast: where things are, how to run it,
what to watch out for, and why it is built this way. They supplement reading the code, never replace it.
Read code whenever you need to.

## When docs and code disagree
- Docs that describe the code (maps, commands, gotchas): the code wins, so fix the doc.
- Docs that describe intent (requirements, specs, design docs, roadmaps, plans): a mismatch is not
  a doc error. Never edit them to match the code or delete them as stale; report the mismatch instead.
- If a mismatch looks like a bug in the code rather than an outdated doc, change nothing and flag it.

## Where docs live
- `AGENTS.md` at the repo root: the project map. Layout, key decisions, gotchas.
- `<folder>/AGENTS.md`: details for one area, placed next to the code it describes. The root
  `AGENTS.md` points to each one by plain path, since some agents only load the root.
- `DECISIONS.md` at the repo root: the decision history (see Decisions).
- Every `AGENTS.md` has a sibling `CLAUDE.md` so Claude Code loads it. A new `CLAUDE.md` contains
  only the line `@AGENTS.md`. If one already exists, add `@AGENTS.md` as its first line; never rename,
  move, or delete it. Write project facts in `AGENTS.md`, not `CLAUDE.md`.
- When you touch project facts in an existing `CLAUDE.md`, move them into its `AGENTS.md`.
  Leave Claude-specific instructions in `CLAUDE.md`. Move facts as you touch them, not all at once.
- Never put docs in ignored or generated folders (check with `git check-ignore <path>`).
- Project facts go in project docs, not personal memory, so every agent can see them.

## Protected docs
- Agents never edit protected docs. If one looks wrong, say so in your report instead.
- Always protected: `CHANGELOG*` and `LICENSE*`.
- Others are listed on a `Protected docs:` line in the root `AGENTS.md` (paths or globs, comma-separated).
  You maintain that line so the user doesn't have to, and respect entries the user adds:
  - The user says not to touch a doc: add it.
  - The user allows edits again: remove it. Delete the line when it is empty.
  - The user reverts one of your doc changes: ask once whether to protect that file. Add it only on yes.
- Every other `.md` file is yours to maintain under these rules, including deleting stale content.
  Never rename, move, or delete a file itself; if a whole doc is stale, list it under Needs you.

## When to create or extend a doc
- Only for an area you worked in or had to investigate this session. Never document ahead of time.
- Only when something there was non-obvious and would cost the next agent time to rediscover.

## What goes in
- Map: where things live, entry points, what is generated or vendored.
- Commands: only non-obvious ones and their prerequisites (e.g. "tests need Docker running",
  "run `db:migrate` before `dev`"). Leave out scripts an agent can read from the build files.
- Why: the current reasons for decisions, constraints, and trade-offs the code cannot show.
- Gotchas: traps, ordering requirements, things that look wrong but are intentional.

## What stays out
- Anything obvious from the code, file names, or config.
- Line-by-line descriptions of functions.
- Current task state, plans, or progress notes.
- Anything you have not verified against the code or confirmed with the user.
- Secrets: never write keys, tokens, passwords, or private URLs. Name the env var instead.

## Decisions
- Reasons often exist only in the user's head. If the area you are working on has a non-obvious
  decision with no recorded reason, ask the user one short question and record the answer.
  At most one such question per task. If nobody can answer (CI, scripts, headless runs), don't ask:
  append `YYYY-MM-DD <area>: <decision>, reason unknown.` to `DECISIONS.md` instead.
- When a decision changes, update the doc to the current state and append to `DECISIONS.md`:
  `YYYY-MM-DD <area>: <old> -> <new>, because <reason>.` Get the date from `date +%F`.
- `DECISIONS.md` is append-only and exempt from the size limits. Never edit or delete its entries,
  except to replace `reason unknown` with a reason the user gives.
- When you create `DECISIONS.md`, add a one-line pointer to it in the root `AGENTS.md`.

## Keeping docs small
- Limits: repo root `AGENTS.md` ≤ 100 lines, folder docs ≤ 150 lines.
  This file and `DECISIONS.md` don't count.
- Over the limit: split by area into a folder doc next to that code, and leave a one-line
  pointer by plain path (e.g. `Payments: see src/payments/AGENTS.md`).
- Point to other docs by plain path. `@path` imports load every session and defeat the split;
  the only allowed import is `@AGENTS.md` in its sibling `CLAUDE.md`.
- When splitting, also cut anything outdated or obvious. Splitting is not only moving.
- Each fact lives in exactly one doc. Point to it; never copy it.

## Keeping docs accurate
- If your change makes a doc wrong, fix the doc in the same change.
- If your change alters behavior elsewhere (a shared function, API, data shape, config,
  or default), even in code you did not edit, search the project's `.md` files for the
  affected names and check each doc that mentions them.
- Update a doc only when it is now wrong or misleading. Don't add to a doc that is
  merely incomplete.
- Delete stale content you come across, even if your change did not cause it (never in intent docs).
  A stale reason goes into `DECISIONS.md` before it is deleted.

## Audit
When asked to audit the docs (e.g. `/doc-upkeep-audit`):
1. Scope. If the root `AGENTS.md` has a `Last audit:` date, list the files changed since then
   (`git log --since="<date> 00:00" --no-renames --name-only --format=` plus `git status --short`;
   `00:00` because git otherwise starts at the current time of day, `--no-renames` to keep a moved
   file's old path). Audit only every changed doc, the docs in or above the changed non-Markdown
   files' folders, and docs that mention those files by name. Skip the rest and say how many you
   skipped. With no `Last audit:` date, or when this run created the root `AGENTS.md`, every doc is in scope.
2. Do the audit yourself. Use helper agents only when more than 5 docs are in scope and your agent
   supports them: one read-only helper per area, reporting problems back. You make every edit.
   Before starting helpers, ask the user which model and effort level they should use, listing the
   choices your agent offers, with no recommendation. If your agent can't set these, or nobody can
   answer, use its defaults.
3. Check that every path, command, and script named in each in-scope doc still exists, and check
   its claims against the current code.
4. Fix what is wrong, delete what is stale (reasons go to `DECISIONS.md` first), and enforce
   the size limits. Leave protected docs and this file unchanged. Mismatches in intent docs
   and possible code bugs go in the report, not into edits.
5. Set `Last audit: YYYY-MM-DD` (today, from `date +%F`) in the root `AGENTS.md`: update the line
   if it exists, otherwise add it as the last line. Only audits change this line.
6. Report in the format below, then ask: "Keep all of these, or revert any?" Revert the ones
   the user names (see Protected docs). If nobody can answer, skip the question.

## Reporting
At the end of any reply where you changed docs, add this block and write nothing else about the
docs. An audit's whole reply is this block, with no intro line. Leave out lines that don't apply.
```
**✓ Doc upkeep is on.** Agents now update these docs as they work. There's nothing for you to run.
**✓ Docs audited** · <N> checked · <N> skipped · <N> fixes · nothing committed

| Doc | Was | Now |
|---|---|---|
| `<file>` | <old> | <new> |

**Needs you:** `<file>`: <intent-doc mismatch, possible code bug, or protected doc that looks wrong>
**Next:** <e.g. commit these with the earlier uncommitted doc changes · outdated rules: run `/doc-upkeep`>
```
- The first line only when this run set up the repo. The second only in audits, including the one
  setup runs; elsewhere write `**Docs updated**`.
- Rows only for docs you changed; leave out the `Last audit:` line. A few words per cell, so the
  table fits a narrow terminal. Use `—` for an empty side: an added gotcha is `—` → `<gotcha>`,
  a removed section `<section>` → `—`, a new doc `—` → `created`.
- Needs you: one line per doc, a few words, not sentences. Next: only things the user must do,
  on one line, separated by `·`.
Outside audits, don't ask whether to keep the changes.

Then, outside audits, end with one reminder line when it applies:
- The root `AGENTS.md` has no `Last audit:` line: `Docs never audited: run /doc-upkeep-audit.`
- Its date is more than 30 days before today (`date +%F`):
  `Docs not audited since <date>: run /doc-upkeep-audit.`
