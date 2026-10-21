---
name: doc-upkeep-audit
description: Audits a repo's agent-maintained docs (set up by doc-upkeep) against the current code and fixes drift. Use only when the user explicitly asks to audit the docs, e.g. "/doc-upkeep-audit".
disable-model-invocation: true
license: MIT
metadata:
  author: Drarith
  repository: https://github.com/Drarith/doc-upkeep
---

# doc-upkeep-audit

1. **Find the repo root.** Run `git rev-parse --show-toplevel`. If it fails, ask the user which folder is the project root; if nobody can answer, stop and report.

2. **Check the setup.** If `<root>/doc-upkeep.md` is missing, stop and suggest running `/doc-upkeep` first.

3. **Check the rules version.** If the doc-upkeep skill is installed next to this one ([rules.md](../doc-upkeep/rules.md)), compare its `Version:` line with `<root>/doc-upkeep.md`. If they differ, say the repo's copy is outdated and suggest rerunning `/doc-upkeep`. Don't change `doc-upkeep.md`.

4. **Audit.** Follow the **Audit** section of `<root>/doc-upkeep.md`. Don't commit.
