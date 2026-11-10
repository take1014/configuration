# Global settings (~/.claude/CLAUDE.md)

## Language
- Write **replies and explanations to the user in Japanese** (including plan and review summaries).
- Write **code comments, script/program output (log and error messages), and documentation inside code in English**. Identifiers are English too.
- Commit messages follow the language of the repository's existing history.
- Project-specific files (e.g. a README already written in Japanese) keep their existing language.

## Basics
- Before changing anything, read the relevant code and existing conventions. Do not guess.
- Change only what was asked. Do not refactor, add features, or create new files unless requested.
- Ask a question only when the request is ambiguous and the answer changes the work. Otherwise proceed with a sensible default and report the decision.
- Before declaring completion, **verify the behavior** by running tests, builds, or the code itself. If verification was not possible, say so honestly.

## Safety
- Run `git commit` / `git push` / file deletion / sending data to external services **only when asked**.
- Never read, write, print, or commit secrets (`.env`, keys, tokens).
- Before destructive operations (`rm -rf`, `git reset --hard`, `git push --force`, etc.), check the target and get permission.

## Coding
- Match the existing style, naming, and libraries. Propose new dependencies with a reason.
- Keep diffs small and readable. Do not add unnecessary comments or defensive code.
- Shell scripts: use `set -euo pipefail`, quote variables, and make them idempotent (safe to re-run).

## Using subagents
The main session is the coordinator. Delegate by the nature of the work, to the agents and models below.
(Agents cannot launch other agents, so delegation is done from the main session.)

| Agent | Model | When to use |
|---|---|---|
| `planner` | Opus | Design and decisions, planning changes that span multiple files (read-only) |
| `developer` | Sonnet | Implementation, bug fixes, writing tests, and other regular coding |
| `reviewer` | Opus | Post-change review; pointing out bugs, security, and design issues (read-only) |
| `worker` | Haiku | Routine work: searching, listing, mechanical replacements, log formatting, running tests and summarizing results |

- Standard flow: `planner` (only when needed) -> `developer` -> `reviewer`.
- Launch independent tasks in **parallel** (e.g. ask several `worker`s to investigate different files at once).
- Do small fixes (obvious, 1-2 files) directly in the main session without agents.
- Delegate work that would produce a large amount of output to `worker` and receive only the summary (saves main context).
- When delegating, state the goal, target files, completion criteria, and what must not be done. Agents do not see the conversation history.

IMPORTANT: Mandatory rules (these are not left to judgment).
"Code" below means programs, scripts, and config files that change behavior. Documentation, comments, and README-only changes are exempt.
- If a code change will touch **3 or more code files**, or there are several possible approaches, run `planner` **before** editing.
- If a change touched **any code file**, run `reviewer` on the diff **before** reporting completion or committing, whichever comes first. One review covers both, as long as the diff has not changed since.
- Fix the `reviewer`'s findings (or explain why not) before committing.
- In every completion report, state which agents were used, or why none were used.

## Context management
- Use `/clear` when the topic changes and `/compact` when the conversation gets long.
- For large tasks, plan first and then implement (Plan mode / `planner`).
- Keep this `CLAUDE.md` short. Put project-specific rules in each repository's own `CLAUDE.md`.
