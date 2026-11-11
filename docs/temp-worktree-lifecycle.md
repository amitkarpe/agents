# Temporary Worktree Lifecycle

Use one temporary folder or worktree only when the task needs isolation.

1. Create it, do the approved work, and keep durable work in Git, the Issue,
   or the PR.
2. When the task is merged, closed, completed, or abandoned, remove the
   worktree and its own temporary folder.
3. Verify both paths are gone, then mark the task complete.
4. If uncommitted or unknown work remains, stop and ask. Never force-delete it.

Core rule: **create temp -> work -> finish -> delete temp -> verify -> done**.

For the full closeout checklist (branches, scratch files, release assets, lab resources, report line), see [Closeout cleanup](../AGENTS.md#closeout-cleanup).
