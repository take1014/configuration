# Global settings (`~/.claude/CLAUDE.md`)

## Language and responses
- Reply to the user in Japanese. Write code, identifiers, comments, logs, and in-code documentation in English; preserve the language of existing project docs.
- Be concise and lead with the outcome; prioritize code in code-generation tasks. Explain material decisions and report changed files, checks, and remaining risks without hiding failures or caveats.

## Working rules
- Read only relevant code and conventions. Make the smallest correct change within scope; avoid unrelated refactors and dependencies.
- Use only the relevant sections of task specifications; keep long specifications out of global instructions.
- When versions or APIs matter, check the current documentation instead of assuming from memory.
- Run the smallest relevant verification. Claim success only with evidence: the commands run and their key output. State skipped checks and unresolved issues.
- After two failed attempts at the same fix, stop and suggest `/rewind` or `/clear` with a sharper prompt instead of piling on more attempts.
- Match existing shell-script conventions (`set -euo pipefail`, quote variables, idempotency). Ask only when ambiguity would materially change the work.

## Safety
- Do not read, write, print, or commit secrets.
- Commit, push, delete files, or send data externally only when asked. Confirm targets before destructive operations.

## Planning and delegation
- Plan multi-file work in the main session (Plan mode) so the plan keeps the conversation's context. Work directly on small, obvious changes.
- For hard tasks (materially different approaches, changes across 3+ modules or a public API, data migration, security, or compatibility), suggest that the user raise `/effort high` or `xhigh`, or add `ultrathink`, before planning.
- Delegate only self-contained or parallel work, verbose output, or tool isolation; do not delegate what you can finish in a few tool calls. Give a narrow goal, restate constraints from the conversation, and request concise findings with file references. Use `isolation: "worktree"` for parallel agents that edit files.
- Run `reviewer` before reporting or committing high-risk changes, and give it the request or spec to check against; inspect small, low-risk changes directly. Resolve review findings before completion.
- When a skill or plugin (e.g. superpowers) says to dispatch a `general-purpose` subagent, use the matching custom agent below instead, and keep the skill's prompt template as the prompt. Use `general-purpose` only when no row fits.

| Dispatched for | Use |
| --- | --- |
| Code review, task review, re-review, final review | `reviewer` |
| Implementing a task, fixing failures in parallel | `developer` (`isolation: "worktree"` when parallel) |
| Builder check or an independent plan from a written design | `planner` |
| Finding the root cause of a bug or failure | `debugger` |
| Locating code or surveying the codebase | `Explore` |
| Looking up docs, release notes, or known issues on the web | `researcher` |
| Mechanical edits, running commands, summarizing logs | `worker` |

## Context
- Suggest `/clear` before unrelated topics, and `/compact <focus>` (naming what to keep: decisions, affected files, remaining work) during long related work.
- Keep project-specific rules in the project's `CLAUDE.md`.
