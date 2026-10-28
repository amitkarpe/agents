---
type: Playbook
title: Agent-Run Browser E2E and Screenshot Evidence
description: Automate a local application's startup, state setup, browser proof, negative-path check, evidence capture, and cleanup without manual clicking.
status: reviewed
scope: local web application development and browser evidence
confidence: high
timestamp: 2026-08-27T00:00:00+08:00
review_after: 2026-11-27
tags: [browser, e2e, screenshots, testing, automation, wsl]
---

# Agent-Run Browser E2E and Screenshot Evidence
> **Scope:** Specialist implementation reference, not permission to install,
> access a private host, deploy infrastructure or run a paid browser provider.
> Follow the active project's Goal and [canonical Core](../AGENTS.md),
> [Goals](../GOALS.md) and [Testing](../TESTING.md).
> Validate current tool capabilities on the actual execution host.


Use this playbook when an agent must prove a local web application end to end
and return screenshots without asking a human to start servers, click the UI,
or copy files manually.

The trusted result is a deterministic runner owned by the application repo,
such as `scripts/browser-e2e.sh`. A one-time command sequence is useful for
discovery, but it is not the finished workflow.

## Choose the Evidence Mode

| Mode | Use when | Required proof |
| --- | --- | --- |
| Interactive browser E2E (default) | The UI has buttons, forms, navigation, approvals, or another user journey | Drive the real UI with Playwright or the repository's browser framework; assert API responses and rendered DOM; capture console, page, request, and HTTP errors; take screenshots. |
| API-seeded rendering evidence (limited fallback) | The claim is only that the real frontend renders a state, or the UI cannot create a prerequisite | Create state through a documented application API, assert the returned state, open the real frontend in a clean browser, and capture the rendered result. |

If the UI can create the state under test, use interactive browser E2E by
default. Do not call API-seeded rendering proof a click-level or full
user-journey test. Record the selected mode in the compact result file.

For WSL applications using installed Windows Node.js and Chrome, follow
[Run Playwright Core with Windows Node and Chrome from WSL](PLAYWRIGHT.md).

## Agent Execution Contract

### Inputs

- The repo-owned command that starts the backend and frontend.
- A readiness URL for every local service.
- A deterministic way to create each state under test. Use browser actions when
  the UI exposes them; use a documented application API only for a prerequisite
  or explicitly limited rendering evidence.
- JSON assertions for the expected state and decision.
- Screenshot names and the required viewport.
- Exact cleanup commands for processes and any disposable resources created by
  the run.

### Outputs

- Service logs.
- Readiness and state JSON.
- One screenshot for the successful path.
- One screenshot for the important negative or bypass path.
- A compact result file containing pass/fail assertions and cleanup state.
- A nonzero exit status when any required assertion or cleanup check fails.

### Stop Conditions

Stop without widening scope when:

- the required port is occupied by an unrelated process;
- the app exposes private identifiers, credentials, or raw infrastructure data;
- the test needs an unapproved cloud write, billable resource, or public network
  exposure;
- the required state cannot be produced through a documented UI or API path;
- the screenshot exists but the underlying API assertion fails; or
- exact cleanup cannot be proven.

## Required Test Layers

| Layer | What it proves | Minimum evidence |
| --- | --- | --- |
| Unit and policy tests | Deterministic business and security logic | Repo test command and exit status |
| API contract | The running backend returns the expected state | Saved JSON plus `jq -e` assertions |
| Browser E2E | The real frontend renders and operates against that backend | Real UI actions, API and DOM assertions, browser-error capture, and screenshot |
| Rendering-only fallback | The real frontend renders an API-seeded state | Documented API assertion, clean browser load, screenshot, and explicit limited-proof label |
| Negative path | Bypass, denial, invalid approval, or drift remains blocked | Separate assertion and screenshot |
| Cleanup | The run did not leave processes or disposable resources behind | Process/resource inventory after cleanup |

A screenshot proves appearance at one moment. It does not by itself prove the
backend result, security decision, or cleanup. Pair it with machine-checkable
state evidence.

## End-to-End Workflow

### 1. Preflight

1. Read the repo instructions and test policy.
2. Review the working tree and preserve unrelated changes.
3. Run the fast deterministic tests before starting services.
4. Check required tools: Bash, `curl`, `jq`, and an approved browser or browser
   driver.
5. Create a run-specific evidence directory with restrictive permissions.
6. Resolve free loopback ports. Never kill an unknown listener to reclaim a
   preferred port.

Keep the development server bound to `localhost`. Do not bind to all interfaces
merely to make browser access easier.

Example preflight helpers:

```bash
set -Eeuo pipefail
umask 077

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'missing required command: %s\n' "$1" >&2
    exit 1
  }
}

port_is_free() {
  ! ss -ltnH "sport = :$1" | grep -q .
}

require_command curl
require_command jq
```

The owning repo should either select the next free port deterministically or
accept explicit backend and frontend ports. Log the actual URLs used by the
run. For Vite, use `--strictPort` when the runner must know the exact port;
otherwise capture the actual port Vite selected.

### 2. Start Services and Own Their Lifecycle

Start services through repo-owned commands, redirect their output to the
evidence directory, and record only the process IDs created by this run.

```bash
backend_pid=''
frontend_pid=''

cleanup() {
  local pid
  for pid in "$frontend_pid" "$backend_pid"; do
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      wait "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup EXIT INT TERM
```

Do not use broad process matches such as `pkill node` or `pkill python`.

### 3. Wait for Readiness

Use bounded polling. A sleeping process is not proof that the service is ready.

```bash
wait_for_url() {
  local url=$1
  local attempts=${2:-30}
  local attempt

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if curl --fail --silent --show-error "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  printf 'readiness check failed: %s\n' "$url" >&2
  return 1
}
```

Save service logs on failure, but sanitize them before publication.

### 4. Create and Assert the Positive State

Prefer driving the real UI with Playwright, Puppeteer, Selenium, or the
framework already owned by the repo. If the test must seed a prerequisite
through an application API, use only a documented endpoint that the production
frontend or trusted operator flow uses. Do not edit static HTML, browser local
storage, database rows, or saved JSON to manufacture the screenshot.

Save the live state and make the required properties executable assertions:

```bash
curl --fail --silent --show-error "$STATE_URL" >"$EVIDENCE_DIR/state.json"
jq -e '
  .mode == "LIVE READ ONLY" and
  .decision == "APPROVAL_REQUIRED" and
  .proposal.before == "COUNT" and
  .proposal.requested == "BLOCK"
' "$EVIDENCE_DIR/state.json" >/dev/null
```

Use product-specific values in the owning repo. Public evidence should use
aliases and must not expose account IDs, ARNs, hostnames, internal IP addresses,
tokens, or credentials.

### 5. Capture the Browser Screenshot

Use a fresh browser profile, fixed viewport, bounded page-settle time, and an
explicit output path. A unique profile prevents a previous browser session,
cache, or extension from changing the result.

For a native Chrome binary:

```bash
"$CHROME_BIN" \
  --headless \
  --disable-gpu \
  --hide-scrollbars \
  --no-first-run \
  "--user-data-dir=$BROWSER_PROFILE" \
  --window-size=1920,1080 \
  --virtual-time-budget=5000 \
  "--screenshot=$SCREENSHOT_FILE" \
  "$APP_URL"

test -s "$SCREENSHOT_FILE"
```

Prefer a browser automation framework when the proof requires clicking,
waiting for a selector, checking text, or capturing browser console errors.
The Chrome command-line route is suitable when the state is already created
through a documented application flow and the remaining proof is rendering.

### 6. WSL with Windows Chrome

When Chrome is installed on Windows but not inside WSL:

1. Discover the Windows Chrome executable; do not hardcode a username.
2. Put the screenshot and temporary browser profile on a Windows-mounted
   directory.
3. Convert paths with `wslpath -w`.
4. Invoke the Windows browser from Bash, directly or through PowerShell.
5. Copy the final screenshot into the repo's durable evidence location if the
   Windows path is only a review mirror.

Example path preparation:

```bash
chrome_wsl=${CHROME_WSL:?set CHROME_WSL to the Windows Chrome executable}
windows_output_wsl=${WINDOWS_OUTPUT_WSL:?set a Windows-mounted output directory}
mkdir -p "$windows_output_wsl"

browser_profile_wsl=$(mktemp -d "$windows_output_wsl/browser-profile.XXXXXX")
screenshot_wsl="$windows_output_wsl/e2e-positive.png"
screenshot_windows=$(wslpath -w "$screenshot_wsl")
browser_profile_windows=$(wslpath -w "$browser_profile_wsl")

"$chrome_wsl" \
  --headless \
  --disable-gpu \
  --hide-scrollbars \
  --no-first-run \
  "--user-data-dir=$browser_profile_windows" \
  --window-size=1920,1080 \
  --virtual-time-budget=5000 \
  "--screenshot=$screenshot_windows" \
  "$APP_URL"

test -s "$screenshot_wsl"
```

Delete only the run-specific browser profile after Chrome exits. Preserve the
validated screenshot and compact result evidence.

#### Playwright Core Across the WSL/Windows Boundary

For a small POC that already has Windows Chrome and Windows Node.js, the owning
repo can use `playwright-core` without downloading another browser:

Use the focused
[Windows/WSL Playwright Core guide](PLAYWRIGHT.md) for the
tested direct-launch route, UI/API/DOM assertion pattern, browser-error gates,
and exact cleanup. The CDP outline below remains an attachment fallback when
the Bash runner must launch Chrome separately.

```bash
npm install --save-dev playwright-core
```

Launch Chrome with a unique Windows temporary profile, keep CDP on loopback,
let Chrome select an unused debugging port, and read the selected port from
`DevToolsActivePort`:

```bash
loopback_host=localhost

"$chrome_wsl" \
  --headless=new \
  --remote-debugging-address="$loopback_host" \
  --remote-debugging-port=0 \
  "--user-data-dir=$browser_profile_windows" \
  about:blank &

debug_port=$(sed -n '1p' "$browser_profile_wsl/DevToolsActivePort" | tr -d '\r')
cdp_url="http://$loopback_host:$debug_port"
```

Do not assume a WSL Node.js process can reach the Windows browser's loopback
CDP endpoint. Run the Playwright script with Windows Node.js when that boundary
fails. Convert script and evidence paths with `wslpath -w`, and pass values as
explicit arguments. Inline WSL environment assignments are not guaranteed to
become Windows process environment variables unless `WSLENV` was deliberately
configured.

```bash
script_windows=$(wslpath -w "$REPO_DIR/e2e/browser-e2e.mjs")
evidence_windows=$(wslpath -w "$EVIDENCE_DIR")
"$windows_node" "$script_windows" "$APP_URL" "$cdp_url" "$evidence_windows"
```

The Node.js script can attach to the existing Chromium browser:

```javascript
import { chromium } from 'playwright-core';

const [, , appUrl, cdpUrl] = process.argv;
const browser = await chromium.connectOverCDP(cdpUrl);
const context = browser.contexts()[0];
const page = context.pages()[0];
await page.goto(appUrl);
```

This CDP route is appropriate for basic POC actions, assertions, console and
network capture, and screenshots. Playwright documents it as lower fidelity
than its native Playwright protocol, so use the normal Playwright-managed
browser route if advanced features become necessary.

For cleanup, do not treat the WSL launcher PID as proof that the Windows Chrome
process tree stopped. The repo-owned cleanup helper must validate that the
profile is a run-specific child of the Windows temporary directory, stop only
`chrome.exe` processes whose command line contains that exact profile, remove
only that profile, and verify both the CDP listener and profile are gone. One
bounded second cleanup pass is acceptable for a late-exiting Chrome child;
broad commands such as `taskkill /IM chrome.exe` are not.

### 7. Exercise the Negative Path

Reset through the real application flow, attempt the bypass or invalid action,
and assert the denial before taking a second screenshot.

```bash
curl --fail --silent --show-error "$NEGATIVE_STATE_URL" \
  >"$EVIDENCE_DIR/negative-state.json"

jq -e '
  .decision == "DENY" and
  .mutation_performed == false
' "$EVIDENCE_DIR/negative-state.json" >/dev/null
```

Capture the negative screenshot with a separate clean filename. Never reuse a
positive screenshot as evidence for a negative test.

### 8. Inspect, Sanitize, and Close

The agent must visually inspect every screenshot, not only check that the PNG
is nonempty. Confirm:

- the expected page and mode banner are visible;
- the decision, requested change, and result agree with the saved JSON;
- loading indicators and error overlays are absent;
- no secrets or private identifiers are visible;
- the viewport includes all required evidence; and
- positive and negative screenshots are distinct.

Then run the full relevant test suite, stop only the processes created by the
runner, remove the temporary browser profile, and verify that the selected
ports are no longer owned by those processes.

If the workflow used an explicitly approved disposable cloud resource, cleanup
must be repo-owned and exact-targeted. Save the post-cleanup zero inventory.
Browser evidence never authorizes cloud mutation.

## Owning-Repo Runner Shape

Keep the repo-owned runner small and deterministic:

```text
preflight
  -> fast tests
  -> choose explicit free ports
  -> start backend and frontend
  -> bounded readiness checks
  -> create positive state
  -> assert API state
  -> run browser action or capture positive screenshot
  -> create bypass or negative state
  -> assert denial and no mutation
  -> capture negative screenshot
  -> visually inspect screenshots
  -> full relevant tests
  -> exact cleanup
  -> write result summary and exit
```

The runner should accept configuration through documented arguments or
environment variables, validate every required input, and avoid embedding
credentials. Run `bash -n` on edited Bash and execute the smallest meaningful
local E2E proof before treating the automation as trusted.

## Common Failure Modes

- **Address already in use:** choose another explicit free port or stop with a
  clear message; do not kill the existing listener.
- **Screenshot taken too early:** assert backend state first, then wait for a
  specific DOM selector when using browser automation. A larger arbitrary sleep
  is weaker evidence.
- **Wrong Vite URL:** use `--strictPort` or parse and record the actual URL; Vite
  can otherwise advance to the next available port.
- **Stale browser state:** use a unique profile for every run.
- **Pretty screenshot with fake state:** reject any proof created by editing
  HTML, local storage, fixtures, or API response files after startup.
- **Screenshot-only testing:** require API assertions and the repo test command.
- **API-driven proof mislabeled as UI E2E:** label it rendering-only unless the
  browser actually performed the user actions and asserted the rendered DOM.
- **Hidden browser hygiene failure:** capture console errors, page errors,
  request failures, and HTTP error responses. A missing favicon can otherwise
  create an unnoticed browser-console 404.
- **Leaked identifiers:** keep real resource identifiers server-side and show
  only stable aliases in the browser.
- **Orphaned processes:** trap exit signals and terminate only recorded child
  process IDs.
- **Unproven cleanup:** a cleanup command without a post-cleanup check is not a
  pass.

## Acceptance Checklist

- [ ] The application repo owns one repeatable E2E runner.
- [ ] The runner binds only to loopback unless wider exposure was explicitly
      approved.
- [ ] Port conflicts fail safely or select a logged free port.
- [ ] Readiness uses bounded checks.
- [ ] The selected evidence mode is written into the result summary.
- [ ] Interactive UI state is created through real browser actions.
- [ ] Any API-seeded state is labeled as limited rendering evidence.
- [ ] Saved JSON passes executable `jq -e` assertions.
- [ ] Interactive mode asserts the rendered DOM after each important action.
- [ ] Console errors, page errors, request failures, and HTTP errors are zero or
      retained as an explicit failed/warning result.
- [ ] The positive screenshot is nonempty and visually inspected.
- [ ] The negative or bypass path proves denial and no mutation.
- [ ] The negative screenshot is nonempty, distinct, and visually inspected.
- [ ] Full relevant tests pass.
- [ ] Temporary profiles and owned processes are cleaned up.
- [ ] Public artifacts contain no secrets or private identifiers.
- [ ] Any approved disposable external resource has zero-inventory cleanup
      evidence.

## Citations

- [Chrome Headless mode](https://developer.chrome.com/docs/automation-and-testing/headless)
- [Vite command-line interface](https://vite.dev/guide/cli)
- [Vite server options](https://vite.dev/config/server-options)
- [curl command-line manual](https://curl.se/docs/manpage.html)
- [jq manual](https://jqlang.org/manual/)
- [Playwright library](https://playwright.dev/docs/library)
- [Playwright `connectOverCDP`](https://playwright.dev/docs/api/class-browsertype#browser-type-connect-over-cdp)
