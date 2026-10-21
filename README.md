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
Without Node, copy both folders in `skills/` into your agent's skills folder, e.g. `~/.claude/skills/`
for Claude Code or `~/.agents/skills/` for Codex.
</details>

Each command installs two skills: `doc-upkeep` and `doc-upkeep-audit`.

## Use
- `/doc-upkeep`, or "set up doc-upkeep": run once per repo.
- `/doc-upkeep-audit`, or "audit the docs": checks every doc against the current code and fixes drift
  from edits that skipped an agent. Run it when you come back to a project.

After setup there is nothing to run. Agents update the docs as part of normal tasks and list every
doc change at the end of their reply:
```
- `AGENTS.md`: `src/math.js` → `src/lib/calc.js`
- `src/payments/AGENTS.md`: added webhook retry gotcha
```

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
Tell an agent "don't touch README.md" and it records that in `AGENTS.md`; "you can edit it again"
removes it. `CHANGELOG*` and `LICENSE*` are always protected. Revert an agent's doc change and it
asks whether to protect that file.

## Compatibility
Tested with Claude Code, Codex and OpenCode (see `evals/`). It should work in any agent that supports
[Agent Skills](https://agentskills.io) and reads `AGENTS.md`, but those aren't tested.

## Update and remove
- Update: `npx skills update doc-upkeep doc-upkeep-audit`, then rerun `/doc-upkeep` in each repo to
  refresh its `doc-upkeep.md`. `/doc-upkeep-audit` tells you when a repo's copy is outdated.
- Remove the skills: `npx skills remove doc-upkeep doc-upkeep-audit`.
- Stop using it in one repo: delete `doc-upkeep.md` and the first line of `AGENTS.md`. The docs stay yours.

## Evals
`evals/run.sh [claude] [codex] [opencode]` builds five throwaway repos (fresh, existing `CLAUDE.md`,
audit after drift, protected doc, and an ordinary coding task that makes a doc wrong), runs the
installed skill headless in each agent, and checks the results. A full run uses a few hundred thousand
tokens. Run a subset with e.g. `SCENARIOS=normal-task evals/run.sh codex`.

## Maintenance
Maintained as part of my own daily use. Issues and pull requests are welcome; no promises on response time.
