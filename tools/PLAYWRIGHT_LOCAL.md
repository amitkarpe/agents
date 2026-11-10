---
type: Playbook
title: Run Playwright with the Installed Chrome on macOS or Linux
description: Run repeatable browser E2E tests from the owning repository with the Chrome that is already installed, with no browser download, and with real-effect runs kept behind an explicit switch.
status: reviewed
scope: local web application browser E2E on a macOS or Linux host that already has Google Chrome
confidence: medium
timestamp: 2026-11-10T00:00:00+08:00
review_after: 2027-02-10
tags: [browser, e2e, playwright, macos, linux, chrome, screenshots]
---

# Run Playwright with the Installed Chrome on macOS or Linux
> **Scope:** Specialist implementation reference, not permission to install,
> download a browser, access a private host or change cloud resources.
> Follow the active project's Goal and [canonical Core](../AGENTS.md),
> [Goals](../GOALS.md) and [Testing](../TESTING.md).
> Validate current tool capabilities on the actual execution host.

Use this page with [Agent-Run Browser E2E and Screenshot Evidence](BROWSER.md),
which owns the test layers, stop conditions and evidence rules. For WSL with
Windows Chrome, use [Playwright Core from WSL](PLAYWRIGHT.md) instead.

Observed on macOS with Playwright Test and installed Google Chrome. The Linux
notes follow the Playwright documentation and were not run for this page.

## Default decision

1. Add `@playwright/test` to the application repository as an **exact**
   development dependency.
2. Point the tests at the installed browser with `channel: "chrome"`.
3. Keep the tests as files in the repository, so any agent or person can run
   them again.

```ts
// playwright.config.ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "e2e",
  workers: 1,
  use: {
    channel: process.env.E2E_CHANNEL ?? "chrome", // the installed Google Chrome
    baseURL: "http://127.0.0.1:4400",
    screenshot: "only-on-failure",
  },
});
```

## Why not the bundled browser

Each Playwright version expects one exact build of its own bundled browsers. A
browser cache left by another Playwright version is **not** used, and the run
stops with `Executable doesn't exist ... Please run: npx playwright install`.

Do not hunt for the Playwright version that matches an old cache, and do not
download a browser as a reflex. A browser download is a download: it needs the
project's permission. The installed-Chrome channel needs none.

| Host | Route |
| --- | --- |
| macOS with Google Chrome | `channel: "chrome"` |
| Linux with Google Chrome stable installed | `channel: "chrome"` |
| Linux with no Chrome | Ask before `npx playwright install chromium`; it downloads a browser and may need system libraries |

## Test shape that held up

- **One worker, loopback only.** Start the dev server with a strict port so the
  URL cannot move.
- **Role and label locators** (`getByRole`, `getByTestId` for status areas), not
  CSS paths.
- **Upload without a file dialog:** `setInputFiles({ name, mimeType, buffer })`
  on the file input.
- **Assert content, not only arrival.** "The page loaded and a button was
  clickable" passed while half of the expected rows were missing. Name the
  expected items and assert each one.
- **Wait like a person.** When the page says a source is not ready, wait, do
  the same user action again and re-check, with an upper limit. Do not hide the
  state with a longer fixed sleep.
- **One screenshot per step**, written to an evidence directory outside Git.
- **Long real work gets a long, explicit timeout** on that one assertion, not a
  global one.

## Real effects stay behind a switch

A test that changes real resources must not run by accident.

```ts
test.skip(!process.env.E2E_REAL, "Set E2E_REAL=1 to run against the real environment.");
```

- The mock or sample flow runs by default and needs no cloud access.
- The real flow runs only with the switch, in the environment the project's
  policy names.
- If the test presses an **approval** control, the server process must record
  it as a test approval. Decide this when the server starts (for example an
  environment variable read once), not from anything the page sends. A test
  approval is never reported as a human approval.

## One command for the whole loop

The trusted result is one runner script in the repository:

```text
create disposable resources -> start services -> wait until ready
  -> browser test -> read the result back outside the application
  -> delete the resources -> prove they are gone
```

- Start a service only if it is not already running, and stop only what the
  runner started.
- Refuse to continue when a running service is in the wrong mode (for example
  human approvals instead of test approvals).
- Read the result back through a path that does not use the application under
  test.
- Do not edit a shell script while it runs, or source files that a hot-reload
  dev server is serving to the browser under test.

## macOS shell differences that cost time

| Trap | What to do |
| --- | --- |
| `/bin/bash` is 3.2: no associative arrays (`declare -A`), no `mapfile` | Check `bash --version` before running a repository script that needs Bash 4 or later; report the gap, do not rewrite the script silently |
| BSD `sed` has no `\b` or `\w` | Use explicit character classes, and test the expression on a sample line before trusting a redaction |
| `zsh` does not split an unquoted variable into words | Use arrays, or `while read` over lines |
| `date -d` is GNU only | macOS uses `date -v`; support both or use a small script |
| `lsof -ti tcp:PORT` takes one port per call | Loop over ports |

## Acceptance checklist

- [ ] Exact Playwright version in the repository; no global install.
- [ ] No browser download, or an explicit permission for one.
- [ ] Sample flow passes with the real backend unreachable.
- [ ] Real flow is skipped without the switch.
- [ ] Expected items are asserted by name.
- [ ] Approvals pressed by a test are recorded as test approvals.
- [ ] Screenshots and logs are outside Git and hold no private identifiers.
- [ ] Disposable resources are deleted and the deletion is checked.

## Citations

- [Playwright: Browsers and channels](https://playwright.dev/docs/browsers)
- [Playwright: Test configuration](https://playwright.dev/docs/test-configuration)
- [Playwright: Locators](https://playwright.dev/docs/locators)
- [Playwright: Annotations (`test.skip`)](https://playwright.dev/docs/test-annotations)
