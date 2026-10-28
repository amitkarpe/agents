# Agent OS

**One canonical home per reusable rule.** Agent OS stores public-safe operating
knowledge. Projects own implementation, permissions, Goal approval and results;
dotfiles or native provider homes own host-specific setup and private data.

Knowledge is at the root or **one subject directory**. There is no active
`kb/`, `observations/`, `playbooks/`, `policies/` or `principles/`.

## Core and platform topics

| Need | Canonical file |
| --- | --- |
| Authority, evidence and core principles | [CORE.md](CORE.md) |
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
| Tools | [Recipes and Git-aware search](tools/RECIPES.md), [Browser evidence](tools/BROWSER.md), [Playwright/WSL](tools/PLAYWRIGHT.md), [X/Grok research](tools/RESEARCH.md) |

Create `kiro/` and `opencode/` only for genuinely reusable public-safe
instructions, not placeholder directories. Local installed versions, account
settings and provider-specific secrets belong in dotfiles/native configuration.

## Task-scoped loading

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

[Issue #62](https://github.com/amitkarpe/agents/issues/62) separately tracks
the live Home cutover and provider-loading acceptance.

## License

[Apache-2.0](LICENSE).
