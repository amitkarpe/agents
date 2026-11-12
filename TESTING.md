---
type: Policy
title: Proportional Testing and Validation
description: Prove changed behavior with the smallest sufficient checks, adding tests only for meaningful uncovered risk.
status: reviewed
scope: Reusable testing and validation guidance for agent-managed repositories
confidence: high
timestamp: 2026-10-21T16:30:00+08:00
review_after: 2027-04-21
tags: [testing, validation, regression, economy]
---

# Testing and Validation

The default for an approved change is **zero new tests**, not zero validation.
Use the smallest existing check or runtime evidence that can prove or disprove
the changed behavior. Repository-mandated CI and safety checks still apply.

**End to end, on the local machine, first.** The main proof is one repeatable
script that runs the real flow end to end on the developer's machine (real
browser, real lab read-back where it applies) and cleans up after itself.
Hosted CI is slow; it is not the proof path. Write unit tests only for small,
pure safety logic, such as the rule that decides whether a result is an
all-clear. Do not add many small unit tests to show coverage.

## Decide whether a new test is needed

Before adding or modifying a test, establish:

1. The concrete regression or failure it would catch.
2. Whether the observable behavior is stable enough to assert.
3. Whether an existing test covers the same boundary.
4. Whether a smaller syntax, type, build, smoke or provider readback suffices.

A test is valuable for a real recurring bug, stable parser/branch/error logic,
an uncovered security or authorization boundary, a reused component with
multiple callers, or an isolated external contract. Avoid artificial cloud
mocks, shallow duplicate coverage, or a new test framework for one small fix.

## Validation proportional to the change

- Documentation: verify edited links, examples and any required repository
  document validation; do not invent functional tests.
- Config/shell: run the parser or smallest syntax check. For Bash changes,
  `bash -n` is useful; ShellCheck is conditional on meaningful quoting,
  credentials, destructive paths or complex error handling.
- Code: use focused existing tests and required CI, not an entire unrelated
  test matrix unless the changed risk justifies it.
- Cloud or stateful operations: distinguish deterministic code checks from
  exact-target live readback, identity, rollback and approval evidence.

Once required checks pass and the changed behavior is proven, **stop**.
Repeat or broaden testing only for a new change, failed check or unresolved
risk. A passing unit test alone never proves that an external system changed.

## Security evidence versus promotion

Keep result validity, runtime success and promotion acceptance separate. A scan
that completes without evaluating controls cannot prove security acceptance;
an unavailable or unusable optional scan does not itself prove runtime failure.
The owning specification decides required scanners, thresholds and closure
authority. A pending optional result never waives a mandatory gate.

Preserve the evaluated scope, coverage and complete result before reducing it
to actionable findings. A filtered failure subset is not the total scan scope.
Finding counts alone do not authorize promotion, rejection, resource deletion
or termination; apply the project's acceptance and cleanup decisions. Preserve
required evidence before cleanup, and bound any diagnostic retention.

## Test cleanup

Remove or consolidate tests only after demonstrating that their behavior is
covered elsewhere or that the governing contract was intentionally retired.
Do not delete a useful regression guard just to shorten a test suite.

The owning repository's `AGENTS.md`, `SPEC.md`, Issue and mandatory gates
override this public reusable guidance. Host-specific lint/CI switches belong
in the owning repository or local setup, not here.

## Citations

- [Public source learning: security evidence and promotion gates](https://github.com/amitkarpe/dotfiles/blob/815f31b7995dcfe023f10c041cc5416b412b4ed5/config/.config/agent/AWS_INSPECTOR_CIS.md#evidence-gate-versus-promotion-gate)
- [ShellCheck guidance](https://www.shellcheck.net/wiki/SC2086)
- [ShellCheck array/quoting guidance](https://www.shellcheck.net/wiki/SC2048)
