# Agent OS

**One canonical home per reusable rule.** Agent OS stores public-safe operating
knowledge. Projects own implementation, permissions, Goal approval and results;
dotfiles or native provider homes own host-specific setup and private data.

Knowledge is at the root or **one subject directory**. There is no active
`kb/`, `observations/`, `playbooks/`, `policies/` or `principles/`.

## Core and platform topics

| Need | Canonical file |
| --- | --- |
| Authority, evidence and core principles | [AGENTS.md](AGENTS.md) |
| One Goal, Fast/Deep plan, delegation | [GOALS.md](GOALS.md) |
| Cold/warm context and handoffs | [CONTEXT.md](CONTEXT.md) |
| Knowledge promotion and evidence cleanup | [KNOWLEDGE.md](KNOWLEDGE.md) |
| Connector safety | [SAFETY.md](SAFETY.md) |
| Git workflow | [GIT.md](GIT.md) |
| GitLab runners | [GITLAB.md](GITLAB.md) |
| Validation economy | [TESTING.md](TESTING.md) |
| Tool selection | [TOOLS.md](TOOLS.md) |
| Terraform change and drift | [TERRAFORM.md](TERRAFORM.md) |
| AWS identity, sources, lifecycle and cost | [AWS.md](AWS.md) |
| Repository foundation/runtime decisions | [REPOSITORIES.md](REPOSITORIES.md) |
| Cloudflare demo deployment | [CLOUDFLARE.md](CLOUDFLARE.md) |

## Provider and task topics

| Area | Topics |
| --- | --- |
| AWS | [Inspector/CIS](aws/INSPECTOR_CIS.md), [SSM and NoReboot](aws/SSM.md), [Images and sharing](aws/IMAGES.md), [Toolkit](aws/TOOLKIT.md), [AgentCore](aws/AGENTCORE.md), [OIDC and durable control](aws/OIDC.md) |
| Codex | [Sessions and Goals](codex/SESSIONS.md), [Native delegation](codex/DELEGATION.md), [Worker control](codex/CONTROL.md), [Skills](codex/SKILLS.md) |
| ChatGPT | [Collaboration](chatgpt/COLLABORATION.md), [Projects](chatgpt/PROJECTS.md), [Automations](chatgpt/AUTOMATIONS.md) |
| Tools | [Recipes and Git-aware search](tools/RECIPES.md), [Browser evidence](tools/BROWSER.md), [Playwright/WSL](tools/PLAYWRIGHT.md), [X/Grok research](tools/RESEARCH.md), [RTK/raw output](tools/RTK.md), [Private artifacts](tools/PRIVATE_ARTIFACTS.md), [Presentations](tools/PRESENTATIONS.md), [Email](tools/EMAIL.md) |
| Kiro | [Worker scope, artifacts and recovery](kiro/WORKERS.md) |
| OpenCode | [Worker JSONL, liveness and recovery](opencode/WORKERS.md) |

Local installed versions, account settings and provider-specific secrets belong
in dotfiles/native configuration.

## Task-scoped loading

[AGENTS.md](AGENTS.md) is the shared instruction entrypoint. When editing this
knowledge repository itself, also read [CONTRIBUTING.md](CONTRIBUTING.md).
Consumers keep their project instructions and approvals; they do not inherit
this repository's publication rules.

The standard filename does not guarantee discovery at every global path.
Use the provider's supported native adapter to select a verified checkout.
For Codex, a sibling shared directory needs explicit routing from its discovered
instructions. Source checks, an explicit read and an automatic provider read
are separate evidence; installing this draft is a later host decision.

Start from the active project's `AGENTS.md`, approved Goal/Issue and current
HEAD; read **one to three** matching Agent OS topics. Reuse valid warm context.
A link, checkout or native adapter is not proof that a provider automatically
loaded instructions. A public Git merge is not proof of Office/Home installation.

```text
Goal: <approved outcome>; Project: <owning repo>
Agent OS: <verified Git source>
Use the project rules and approvals first. Read only task-relevant topics.
Execute within authority and report exact, observable acceptance evidence.
```

Use [CONTRIBUTING.md](CONTRIBUTING.md) for safe knowledge changes.
Validate with `scripts/validate.sh --self-test` and `scripts/validate.sh`.
Superseded content remains in Git history, not active copies.

Keep long-term instructions short and stable. Load specialist topics only for
the current task. Store changing plans, decisions and results in the owning
project's Issue or current-state files; do not append chat logs to AGENTS.md.
Keep private host exceptions and skill implementations in their existing
owners. Review shared changes once in Git instead of copying rules to every
project and letting those copies drift.

[Issue #62](https://github.com/amitkarpe/agents/issues/62) separately tracks
the live Home cutover and provider-loading acceptance.

## License

[Apache-2.0](LICENSE).

## Citations

- [AGENTS.md open format](https://agents.md/)
- [Codex instruction discovery and scope](https://developers.openai.com/codex/guides/agents-md)
