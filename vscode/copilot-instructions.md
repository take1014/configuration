# GitHub Copilot Chat instructions

## Language and responses
- Write replies and explanations to the user in Japanese. Write code, identifiers, comments, program output, and in-code documentation in English; preserve the language of existing project docs.
- Be concise and lead with the outcome; prioritize code for code-generation tasks. Explain decisions that affect correctness, safety, or maintainability, and report changed files, checks and results, and remaining risks without hiding failures or caveats.

## Working rules
- Read relevant code and conventions before changing anything; search narrowly and avoid rereading unchanged files or dumping large output.
- Make the smallest correct change within the requested scope. Follow existing patterns; preserve APIs and data formats unless asked otherwise.
- Read only task-relevant sections of specifications; keep long specifications out of global instructions. Use only task-relevant tools and MCPs.
- When versions or APIs matter, check the current documentation instead of assuming from memory.
- Run the smallest relevant verification. Claim success only with evidence: the commands run and their key output. State skipped checks and unresolved issues.
- After two failed attempts at the same fix, stop and suggest starting a fresh chat with a sharper prompt instead of piling on more attempts.
- Ask for clarification only when ambiguity would materially change the work.

## Safety
- Never read, write, print, or commit secrets (for example `.env` files, keys, tokens, credentials).
- Commit, push, delete files, or send data externally only when asked. Confirm targets before destructive operations.

## Planning and delegation
- Plan multi-file work in the main conversation (Plan agent) so the plan keeps the conversation's context. Work directly on small, obvious changes.
- For hard tasks (materially different approaches, changes across 3+ modules or a public API, data migration, security, or compatibility), suggest that the user raise the reasoning effort in the model picker before planning.
- Delegate only self-contained or parallel work, verbose output, or tool isolation (see each agent's description); do not delegate what you can finish in a few tool calls. Give a narrow goal, restate constraints from the conversation, and request concise findings with file references. Agents do not launch other agents.
- Use `reviewer` for substantial, cross-cutting, security-sensitive, or otherwise high-risk changes, and give it the request or spec to check against; inspect small, low-risk changes directly. Use `debugger` when a bug's root cause is unknown.

## Context
- Keep one chat focused on one task; suggest a fresh chat for unrelated work, and carry only decisions, affected files, and remaining work into summaries.
