---
name: doc-upkeep-audit
description: Audits a repo's agent-maintained docs against the current code and fixes drift, setting up doc-upkeep first if the repo doesn't have it yet. Use only when the user explicitly asks to audit the docs, e.g. "/doc-upkeep-audit".
disable-model-invocation: true
license: MIT
metadata:
  author: Drarith
  repository: https://github.com/Drarith/doc-upkeep
---

# doc-upkeep-audit

1. **Find the repo root.** Run `git rev-parse --show-toplevel`. If it fails, ask the user which folder is the project root; if nobody can answer, stop and report.

2. **Set up first if needed.** If `<root>/doc-upkeep.md` is missing, the repo isn't set up yet: do steps 1–4 of the [doc-upkeep setup](../doc-upkeep/SKILL.md) (installed next to this skill), then continue here.

3. **Check the rules version.** Compare the `Version:` line of [rules.md](../doc-upkeep/rules.md) with `<root>/doc-upkeep.md`. If they differ, say the repo's copy is outdated and suggest rerunning `/doc-upkeep`. Don't change `doc-upkeep.md`.

4. **Audit.** Follow the **Audit** section of `<root>/doc-upkeep.md`. Don't commit.
