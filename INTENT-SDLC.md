---
type: Policy
title: Intent-Based SDLC for the Coordinator
description: The coordinator turns the owner's intent into a researched one-page plan, gets one click-approval, then threads execute alone.
status: draft
scope: Reusable public-safe coordinator playbook; does not grant cloud, production or credential authority
confidence: medium
timestamp: 2026-11-07T11:30:00+08:00
review_after: 2027-05-07
tags: [coordinator, intent, planning, sdlc, kiss, timers]
---

# Intent-Based SDLC (coordinator playbook)

The owner gives an intent in a few words. The coordinator does the discovery
and brings a plan. The owner approves by clicking options, not by typing
instructions. Then threads execute under [AUTONOMY](AUTONOMY.md).

## Flow

| Step | Who | Output |
|---|---|---|
| 1. Intent | owner | one sentence: the outcome wanted |
| 2. Discover | coordinator | inventory, owners, constraints, what already exists, feasibility checks run for real |
| 3. Plan | coordinator | the one-page plan below |
| 4. Confirm | owner | click cards for each open choice, one question per card |
| 5. Execute | threads | one writer per goal; proof per step; stop only at real limits |
| 6. Close | thread, coordinator | docs updated, learnings saved, thread resolved |

## One-page plan (plus inventory)

1. **Goal** and what "done" proves (one command or result).
2. **Scope**: in, out, and the environment or account it is bound to.
3. **Facts found**: measured, not guessed (for example, size a host by measuring peak use).
4. **Inventory**: table of existing resources, owner, and how each is rebuilt.
5. **Risks and stops**: production, destructive actions, missing credentials.
6. **Steps**, each with its own proof.
7. **Choices for the owner**: only what changes the goal, each as a click card with a recommendation.

## Rules learned

- Do discovery before asking. Ask only what facts cannot answer.
- Work already in the approved plan needs no new "go".
- Infrastructure goes in code with remote, locked state from day one.
- Prove each lane end to end; theory review finds fewer bugs than one real run.
- A time promise needs a timer set in the same turn (see below); otherwise say you cannot wake yourself.

## Timers

A promise in text does not wake an agent. Set a timer in the same turn and
state the time. Where the agent has no timer tool, say so and do not promise.
The coordinator may have no timer: a thread sets it and messages the
coordinator. Timers can fire several minutes late; do not rely on exact timing.

## Starter-repo checklist (what a new project should have)

Must: AGENTS.md with the account and authority binding; SPEC (what) and POLICY (who may do what) split; a bootstrap runbook listing each part, owner and rebuild step; remote Terraform state.
Should: an intake template (the plan above); a definition of done; a cold-start test by a fresh agent.
Nice: a list of which decisions need an owner click.
