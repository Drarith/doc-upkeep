---
name: doc-upkeep-protect
description: Protects docs from agent edits in a repo set up with doc-upkeep, or lists what is protected. Use only when the user explicitly asks, e.g. "/doc-upkeep-protect README.md docs/legal/**" or "/doc-upkeep-protect".
disable-model-invocation: true
argument-hint: "[paths or globs]"
license: MIT
metadata:
  author: Drarith
  repository: https://github.com/Drarith/doc-upkeep
---

# doc-upkeep-protect

1. **Find the repo root.** Run `git rev-parse --show-toplevel`. If it fails, ask the user which folder is the project root; if nobody can answer, stop and report.

2. **Check the setup.** If `<root>/AGENTS.md` is missing, stop and suggest running `/doc-upkeep` first.

3. **No paths given: list.** Reply with what is protected: the built-in `CHANGELOG*` and `LICENSE*`, plus every entry on the `Protected docs:` line of `<root>/AGENTS.md`, or "nothing else" if there is no such line. Change nothing.

4. **Paths given: protect them.** Paths are relative to the repo root; globs are fine. Keep each entry exactly as given.
   - If `<root>/AGENTS.md` has a `Protected docs:` line, append the new entries, comma-separated, skipping any already listed.
   - Otherwise add `Protected docs: <entries>` as the last line of `<root>/AGENTS.md`.
   - If an entry matches no existing file, still add it, and say so in case it's a typo.
   - Check: exactly one `Protected docs:` line exists and it contains every entry.

5. **Don't commit.** Report the entries you added, then the full protected list. End with: `To unprotect, tell an agent "you can edit <file> again".`
