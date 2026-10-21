# doc-upkeep

An agent skill that keeps `AGENTS.md` project docs up to date as you work, for Claude Code, Codex,
OpenCode, Cursor and other coding agents. A fresh session, or you years later, can understand a repo
without rediscovering it from the code.

## Install
Pick your agent. Use more than one? Run the command for each.

<details>
<summary><strong>Claude Code</strong></summary>

All your projects:
```bash
npx skills add Drarith/doc-upkeep -g -a claude-code -y
```
This project only (run it in the project folder):
```bash
npx skills add Drarith/doc-upkeep -a claude-code -y
```
</details>

<details>
<summary><strong>Codex</strong></summary>

All your projects:
```bash
npx skills add Drarith/doc-upkeep -g -a codex -y
```
This project only (run it in the project folder):
```bash
npx skills add Drarith/doc-upkeep -a codex -y
```
</details>

<details>
<summary><strong>Cursor</strong></summary>

All your projects:
```bash
npx skills add Drarith/doc-upkeep -g -a cursor -y
```
This project only (run it in the project folder):
```bash
npx skills add Drarith/doc-upkeep -a cursor -y
```
</details>

<details>
<summary><strong>OpenCode</strong></summary>

All your projects:
```bash
npx skills add Drarith/doc-upkeep -g -a opencode -y
```
This project only (run it in the project folder):
```bash
npx skills add Drarith/doc-upkeep -a opencode -y
```
</details>

<details>
<summary><strong>Gemini CLI</strong></summary>

All your projects:
```bash
npx skills add Drarith/doc-upkeep -g -a gemini-cli -y
```
This project only (run it in the project folder):
```bash
npx skills add Drarith/doc-upkeep -a gemini-cli -y
```
</details>

<details>
<summary><strong>GitHub Copilot</strong></summary>

All your projects:
```bash
npx skills add Drarith/doc-upkeep -g -a github-copilot -y
```
This project only (run it in the project folder):
```bash
npx skills add Drarith/doc-upkeep -a github-copilot -y
```
</details>

<details>
<summary><strong>Another agent, or no Node</strong></summary>

Pick from the full list of supported agents:
```bash
npx skills add Drarith/doc-upkeep
```
Without Node, copy every folder in `skills/` into your agent's skills folder, e.g. `~/.claude/skills/`
for Claude Code or `~/.agents/skills/` for Codex.
</details>

Each command installs three skills: `doc-upkeep`, `doc-upkeep-audit` and `doc-upkeep-protect`.

## Use
**Run `/doc-upkeep` once in any project, new or existing.** If the project already has docs, it checks
them against the code in the same run.

| Command | When |
|---|---|
| `/doc-upkeep` | Once per project, to start |
| `/doc-upkeep-audit` | When an agent reminds you (after 30 days), or after big changes made without an agent. Works as a first command too: it sets up the project if needed. When more than 5 docs need checking, it first asks which model and effort its helper agents should use |
| `/doc-upkeep-protect README.md docs/legal/**` | To stop agents editing those docs. On its own, it lists what's protected |

After that there is nothing to run. Agents update the docs as part of normal tasks and list every
doc change at the end of their reply:

> **Docs updated**
>
> | Doc | Was | Now |
> |---|---|---|
> | `AGENTS.md` | `src/math.js` | `src/lib/calc.js` |
> | `src/payments/AGENTS.md` | — | webhook retry gotcha |
>
> Docs not audited since 2026-09-12: run /doc-upkeep-audit.

That last line appears when the docs haven't been audited in over 30 days, so you don't have to
remember. The audit records its date as a `Last audit:` line in `AGENTS.md`.

## What it adds to a repo
| File | What it is |
|---|---|
| `doc-upkeep.md` | The rules agents follow. Overwritten when you rerun setup, so don't edit it. |
| `AGENTS.md` | The project map. Its first line tells agents to read `doc-upkeep.md`. |
| `CLAUDE.md` | One line, `@AGENTS.md`, so Claude Code loads the map. An existing `CLAUDE.md` gets that line added at the top. |
| `DECISIONS.md` | Added the first time a decision changes: an append-only log of what changed and why. |
| `<folder>/AGENTS.md` + `CLAUDE.md` | Added when an area needs its own doc. |

It never commits, and never renames or deletes your files. Commit what it adds like any other change.

## Protecting docs
Agents never edit a protected doc; if it looks wrong, they tell you instead. To protect one:

- **Run** `/doc-upkeep-protect README.md` (paths or globs, as many as you like). It adds them to a
  `Protected docs:` line in the root `AGENTS.md`.
- **Or tell an agent:** "don't touch README.md". Same result.
- **Or add it yourself** to the root `AGENTS.md` (paths or globs, comma-separated):
  ```
  Protected docs: README.md, docs/legal/**
  ```

To unprotect, tell an agent "you can edit README.md again", or delete it from the line.
`CHANGELOG*` and `LICENSE*` are always protected. Revert an agent's doc change and it asks whether
to protect that file. Docs about intent (specs, requirements, design docs, roadmaps) are never edited
to match the code: a mismatch gets reported, since the code might be the thing that's wrong.

## Extra checks between audits (optional)
Docs only get checked while an agent works on that area, or when you audit. If you want more, add one
of these to a repo. Both are recipes, not part of the skill, and haven't been tested end to end.

<details>
<summary><strong>Free dead-path check on every push</strong> (no AI, no tokens)</summary>

Uses [agents-doctor](https://github.com/ItsHege/agents-md-doctor), a third-party linter that fails when
an `AGENTS.md` names a file or command that no longer exists. It can't tell whether a description is
still true; that's what the audit is for. Save as `.github/workflows/docs-check.yml`:
```yaml
name: docs-check
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npx -y agents-doctor@0.10.1 lint .
```
</details>

<details>
<summary><strong>Weekly audit that opens a pull request</strong> (uses API tokens)</summary>

Runs `/doc-upkeep-audit` every Monday and opens a pull request with the fixes for you to review. Needs
an `ANTHROPIC_API_KEY` repo secret, and "Allow GitHub Actions to create and approve pull requests"
turned on under Settings → Actions → General. Save as `.github/workflows/doc-audit.yml`:
```yaml
name: doc-audit
on:
  schedule: [{ cron: "0 6 * * 1" }]   # Mondays 06:00 UTC
  workflow_dispatch:
permissions:
  contents: write
  pull-requests: write
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }      # the audit reads git history
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npm install -g @anthropic-ai/claude-code
      - run: npx -y skills add Drarith/doc-upkeep -g -a claude-code -y
      - run: >
          claude -p "/doc-upkeep-audit" --allowedTools "Bash(git:*)" "Bash(date:*)" "Bash(ls:*)"
          Read Write Edit Glob Grep
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      - uses: peter-evans/create-pull-request@v7
        with:
          branch: doc-upkeep/audit
          title: "docs: doc-upkeep audit"
          commit-message: "docs: doc-upkeep audit"
          body: "Automated /doc-upkeep-audit. Review the doc changes before merging."
```
</details>

## Compatibility
Tested with Claude Code, Codex and OpenCode (see `evals/`). It should work in any agent that supports
[Agent Skills](https://agentskills.io) and reads `AGENTS.md`, but those aren't tested.

## Update and remove
- Update: `npx skills update doc-upkeep doc-upkeep-audit doc-upkeep-protect`, then rerun `/doc-upkeep`
  in each repo to refresh its `doc-upkeep.md`. `/doc-upkeep-audit` tells you when a repo's copy is outdated.
- Remove the skills: `npx skills remove doc-upkeep doc-upkeep-audit doc-upkeep-protect`.
- Stop using it in one repo: delete `doc-upkeep.md` and the first line of `AGENTS.md`. The docs stay yours.

## Evals
`evals/run.sh [claude] [codex] [opencode]` builds ten throwaway repos (fresh, existing `CLAUDE.md`, existing outdated docs, audit run first,
audit after drift, a file moved since the last audit, protected doc, an ordinary coding task that makes a doc wrong, a spec the code
doesn't meet yet, and protecting a doc with `/doc-upkeep-protect`), runs the installed skills headless
in each agent, and checks the results. A full run uses a few hundred thousand
tokens. Run a subset with e.g. `SCENARIOS=normal-task evals/run.sh codex`.

## Maintenance
Maintained as part of my own daily use. Issues and pull requests are welcome; no promises on response time.
