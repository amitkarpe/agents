---
type: Policy
title: Intent-Based SDLC for the Coordinator
description: The coordinator turns the owner's intent into a researched one-page plan, gets one click-approval, then threads execute alone.
status: candidate
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

## Where the lifecycle lives

The lifecycle (Intent, Spec, Plan, Code, Tests, Review, Deploy, Observe) is in
[repo-starter AI_NATIVE_SDLC.md](https://github.com/amitkarpe/repo-starter/blob/main/AI_NATIVE_SDLC.md).
This page only adds what the coordinator does around it.

## Coordinator duties

1. Take the owner's intent in a few words.
2. Run discovery before asking questions. Ask only what facts cannot answer.
3. Bring one page: goal and proof, scope and bound environment, measured facts,
   an inventory table (resource, owner, rebuild), risks and stops, steps with a
   proof each, and the choices only the owner can make.
4. Ask each choice as one click card with a recommendation.
5. After approval, hand one writer per goal to a thread under [AUTONOMY](AUTONOMY.md).
6. At close, update docs and save the learnings.

## Timers

A promise in text does not wake an agent. Set a timer in the same turn and
state the time; if there is no timer tool, say so and do not promise. The
coordinator may have no timer: a thread sets it and messages the coordinator.
Timers can fire a few minutes late; that is fine.
