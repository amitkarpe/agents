---
type: Practice
title: Curated Skill Exposure Without Source Deletion
description: Retain reusable skill source while enabling only a small, reversible task-fit set.
status: candidate
scope: local Codex skill discovery and enablement
confidence: medium
timestamp: 2026-09-17T00:00:00+08:00
review_after: 2026-12-17
tags: [codex, skills, configuration, context, rollback]
---

# Curated Skill Exposure Without Source Deletion
> **Ownership:** This specialist guide documents one bounded topic. The
> canonical [Core](../AGENTS.md), [Goals](../GOALS.md),
> [Context](../CONTEXT.md) and [Safety](../SAFETY.md)
> rules govern reusable authority and evidence. Project rules and local
> provider/host configuration still take precedence. A documented command or
> reference is not proof of current runtime support.


Skill source, installation, enablement, and invocation are separate states.
Keep useful source versioned without making every skill part of every session's
available catalog.

## Use a small profile

Start with the smallest always-on set that protects common work. Add a bounded
task profile only when the current repository or mission needs it. Enable a
specialist skill by exact name for an exceptional task, then return to the
smaller profile.

Low observed use is evidence for task-scoped exposure, not source deletion.
Likewise, a skill read during a difficult task does not prove that the skill
caused either success or failure.

## Keep the layers separate

| Layer | Decision |
| --- | --- |
| Source | Is the reusable capability worth retaining and improving? |
| Discovery installation | Can the runtime find the skill directory? |
| Enablement | Should this skill be available in the current profile? |
| Invocation | Should the current task select it implicitly or explicitly? |

Bundled system skills and plugin-provided skills are separate governance
layers. A source-repository profile controller must not silently modify them.

## Controller contract

A local profile controller should:

1. default to a read-only preview;
2. use an explicit allowlist rather than inferred popularity;
3. touch only source-owned entries;
4. preserve unrelated configuration and external skills;
5. reject conflicting manual overrides;
6. validate the complete generated configuration before replacement;
7. write a protected backup and reversal record before mutation;
8. replace configuration atomically;
9. make repeated application idempotent;
10. refuse restoration after unrecognized configuration drift; and
11. never restart an active runtime automatically.

Use the runtime's supported per-skill enablement mechanism when available.
Unlinking a verified source-owned discovery link is a fallback, not source
deletion. Never remove a real skill directory to change exposure.

## Adoption flow

1. Inventory source-owned, bundled, plugin-provided, and externally installed
   skills separately.
2. Define the minimal core and each task profile as reviewable allowlists.
3. Preview the exact enable, disable, install, and unchanged sets.
4. Validate the controller against an isolated configuration and discovery
   root.
5. Apply only the approved profile and retain its reversal record.
6. Restart at an approved idle boundary when the runtime requires it.
7. Verify the effective available-skill catalog in a fresh session.
8. Restore if protected capabilities are missing or unrelated entries changed.

## Evidence and limitations

Record profile name, source revision, enabled and disabled names, configuration
hashes, validation status, and restoration pointer. Do not record credentials,
authentication state, or the complete unrelated runtime configuration.

A smaller catalog can improve routing clarity, but do not claim token or
quality savings without a controlled before-and-after measurement. Existing
sessions can retain old context after a configuration change. Runtime discovery
verification must therefore use a fresh session after any required restart.

## Citations

- [OpenAI skill guide](https://developers.openai.com/codex/skills)
- [OpenAI Codex configuration reference](https://developers.openai.com/codex/config-reference)
