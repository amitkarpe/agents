---
type: Playbook
title: ChatGPT Project Context and File Surfaces
description: Distinguish ChatGPT Project instructions, Project files, Library files, chat attachments, runtime copies, and Skills without inventing shared identity or lifecycle semantics.
status: reviewed
scope: ChatGPT Projects, files, Library, and Skills
confidence: medium
timestamp: 2026-09-17T01:58:00+08:00
last_verified: 2026-09-17
review_after: 2026-12-17
tags: [chatgpt, projects, files, library, skills, context]
---

# ChatGPT Project Context and File Surfaces
> **Ownership:** This specialist guide documents one bounded topic. The
> canonical [Core](../AGENTS.md), [Goals](../GOALS.md),
> [Context](../CONTEXT.md) and [Safety](../SAFETY.md)
> rules govern reusable authority and evidence. Project rules and local
> provider/host configuration still take precedence. A documented command or
> reference is not proof of current runtime support.


ChatGPT Projects can keep chats, files, instructions, and related context together.
Treat those product surfaces as distinct unless official documentation explicitly
states that they share identity or lifecycle semantics.

## Documented Product Model

- **Project instructions** apply inside that Project and override global custom
  instructions for chats in the Project.
- **Project files** are reference material attached to the Project. They can be
  previewed, downloaded, or deleted from the Project sources list.
- Uploading a Project file with the same name as an existing one can produce an
  explicit choice to upload it anyway or skip it; same display name therefore
  does not imply replacement.
- **Library** stores uploaded and created ChatGPT files for later reuse when the
  feature is available. Library files and chats are managed separately.
- Files uploaded to a Project are retained with the Project until the Project is
  deleted, subject to OpenAI retention and legal/security exceptions.
- **Skills** are reusable workflows for repeatable tasks. Projects provide shared
  context, files, instructions, and conversations around an ongoing body of work.

## Safe Operating Rules

1. Keep one clearly named canonical instruction source when a Project also uses
   instruction files as reference material. Remove stale duplicates through the
   product surface that owns them.
2. Remove source files that belong to another repository/project or that carry a
   conflicting operating model. An unrelated `AGENTS.md`, bootstrap file, or
   project instruction file can silently contaminate future answers even when it
   was added only as a temporary reference.
3. When two Project source files contain the same instruction text, keep the
   clearly named/current one and remove the duplicate rather than relying on
   filename order or upload date to imply precedence.
4. Do not infer overwrite, replacement, or object identity from display-name
   equality alone.
5. When freshness matters, explicitly request the current instruction/source file
   rather than assuming every Project file has already been read in the current
   chat.
6. Keep volatile repository state in repository truth, not in reusable Project
   instructions:

   ```text
   Project instructions
     -> shared Project-wide behavior

   repo/AGENTS.md
     -> durable repository rules

   repo/CONTEXT.md
     -> current-only restart state

   Issue / PR / Git
     -> active task, evidence, and durable history
   ```

7. Prefer **Project instructions** for behavior that should apply throughout one
   Project. Prefer a **Skill** when the behavior is a reusable workflow that
   benefits from explicit packaging and reuse across chats or surfaces.
8. Keep repository-specific authority in the repository even when Project
   instructions or Skills provide higher-level workflow guidance.
9. Do not turn Project source files into mandatory rereads for every agent
   handoff. When repository/objective context is already usable, continue from
   the owning PR/comment. Reload broader context only when it changed, became
   stale/ambiguous, or a new authority/safety domain requires it. See
   [Context Loading Economy for Agent Handoffs](../CONTEXT.md).

## Recommended Project Source Hygiene

Keep the Project Sources list small enough that every source has an obvious job.
A useful review asks of each source:

- Is this file about this Project?
- Is it current?
- Is it unique, or a duplicate of another source?
- Is it stable reference material rather than volatile task state?
- Would loading it together with the other sources create conflicting operating
  instructions?

Prefer one canonical Project-instructions source plus a small number of durable
reference files. Active Issue/PR state should normally remain in GitHub instead
of being copied into Project Sources.

## Empirical Observations, Not Product Guarantees

The following observations motivated this playbook but are not established by the
cited product documentation and should remain dated observations until OpenAI
publishes stronger guarantees:

- a tool-visible or runtime-mounted copy may be separate from the Project Source
  object shown in the UI;
- renaming or deleting a runtime copy may not mutate the Project Source card;
- internal file identity may differ from the display filename;
- recreating a runtime file with the same filename does not prove that a Project
  Source or Library object was replaced;
- source retrieval may be selective rather than equivalent to injecting every
  complete Project file into every prompt.

Operational consequence: **do not use a runtime filename or local working copy as
lifecycle authority for a Project Source or Library object.** Manage the product
object through the product surface that owns it unless a documented tool/API says
otherwise.

## Validation Checklist

Before relying on a Project/file behavior:

- identify the exact surface: Project instructions, Project file, Library file,
  chat attachment, Skill resource, or runtime/tool-visible copy;
- check current OpenAI documentation for retention and deletion semantics;
- verify same-name behavior instead of assuming overwrite;
- distinguish documented behavior from local observation;
- keep product-specific claims dated because ChatGPT behavior can change.

For source-list hygiene, also verify:

- no duplicate instruction files remain;
- no unrelated repository/project instruction file remains;
- one clearly named current source owns Project-wide behavior;
- active task state is not being maintained redundantly in both Project Sources
  and GitHub.

## Related playbooks

- [Context Loading Economy for Agent Handoffs](../CONTEXT.md)
- [ChatGPT and Codex Collaboration Protocol](COLLABORATION.md)

## Citations

- https://help.openai.com/en/articles/10169521-using-projects-in-chatgpt
- https://help.openai.com/en/articles/20001052
- https://help.openai.com/en/articles/8983778
- https://help.openai.com/en/articles/8983762
- https://help.openai.com/en/articles/20001066
- https://openai.com/academy/skills/
