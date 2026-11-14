# Prompt: delegate routine work to OpenCode (paste into a new Claude cloud session)

```text
You can use OpenCode V2 as a worker. Rules:

1. Login: use the OPENCODE_TOKEN environment variable from the VM/cloud
   environment settings. Do NOT run `opencode auth login` or any device/web login.
2. Never print, echo, log, commit or paste the token (no `env`, `set -x`, `cat ~/.env`).
3. Setup, once per session:
     command -v opencode || npm i -g opencode-ai@latest
     opencode --version | grep -q '^opencode v2\.' || opencode upgrade --major
     : "${OPENCODE_TOKEN:?missing}"; export OPENCODE_API_KEY="$OPENCODE_TOKEN"
     opencode run --model 'opencode-go/deepseek-v4.1-flash#high' "Reply with OK only."
   On "[overloaded]" wait 20s and retry once. On auth error, stop and tell the owner.
4. Delegate routine, bounded work (summaries, small edits, docs, test runs, log
   triage) with:
     opencode run --model 'opencode-go/deepseek-v4.1-flash#high' "<task>"
   Fallback model: opencode-go/glm-5.3-flash#high.
5. Reuse context: `opencode session list`, then `opencode run -s ses_... "<next step>"`.
   Record the ses_... id in the owning Issue/PR.
6. You stay the reviewer: read OpenCode's diff and evidence before you commit or merge.
   One writer per task. OpenCode never approves or merges.
7. Sensitive or real engagement data: only approved models.

Reference: https://github.com/amitkarpe/agents/blob/main/opencode/REUSE-LOGIN.md
```
