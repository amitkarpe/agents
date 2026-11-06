# Agent identity

Status: canonical standard (Amit, 6 Nov 2026). Many agents work with Amit at the same time. A reader must know **who** writes, **where** it runs and **why**, without guessing.

## Rule

Start every Issue, Issue comment, PR description, review and handoff with one identity header. This is a must when the text goes to a repository that is not your own: for example, an agent of `aws-factory` asks a question in `nextflow-offline`.

```text
<Identity: ACTOR | Agent: AGENT | Surface: SURFACE | Host: HOST | Repo: OWNER/REPO | Role: ROLE>
Evidence: <link to the Issue, PR, run or log; omit when there is none>
```

| Field | Meaning | Values |
|---|---|---|
| ACTOR | Your shorthand in this repository | `G`, `X`, `Q`, `AA`, `HHC`, `MBC`, or your agent name |
| AGENT | Provider and product that writes the text | `Claude Code`, `Codex`, `ChatGPT`, `Kiro` |
| SURFACE | Where you run | `CLI`, `web`, `desktop`, `cloud task` |
| HOST | The kind of machine | `Mac`, `Windows`, `Linux`, `cloud`, `unknown` |
| Repo | The repository you work **for** (not the one that receives the text) | `OWNER/REPO` |
| ROLE | What you do now | `implementer`, `reviewer`, `controller`, `requester` |

Examples:

```text
<Identity: HHC | Agent: Claude Code | Surface: CLI | Host: Linux | Repo: amitkarpe/aws-factory | Role: requester>
<Identity: G | Agent: ChatGPT | Surface: web | Host: cloud | Repo: amitkarpe/agents | Role: reviewer>
```

The first four fields of the older header in `chatgpt/COLLABORATION.md` stay valid. Add `Surface` and `Host` when you can state them as facts.

## Ask in another repository

Right after the header, write four lines:

1. **From:** the repository and Issue you work for.
2. **Why:** the reason in one sentence.
3. **Need:** one exact answer or action.
4. **Evidence:** a link.

## Never

- Do not guess the environment, the model or the host. Write `unknown`.
- Do not write secrets, session IDs, machine names, user names or IP addresses.
- Do not use the identity of another agent. A reply uses the responder's own identity.
- Identity is attribution, not approval. It does not grant any permission.

## Adopt it

- New repository: `repo-starter` `INIT.md` points here. Do not copy this file into each repository.
- Existing repository: add one line to its `AGENTS.md`: "Follow `amitkarpe/agents` `IDENTITY.md` in every Issue, comment and PR."
- Do not add a framework, a registry or a workflow for this.
