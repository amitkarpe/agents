---
type: Playbook
title: Run Playwright Core with Windows Node and Chrome from WSL
description: Run deterministic browser E2E evidence from a WSL-owned repository by launching installed Windows Chrome with Playwright Core, with CDP attachment as a fallback.
status: reviewed
scope: local web application browser E2E evidence from WSL using Windows Node and Chrome
confidence: high
timestamp: 2026-09-22T00:00:00+08:00
review_after: 2026-12-22
tags: [browser, e2e, playwright, playwright-core, wsl, screenshots]
---

# Run Playwright Core with Windows Node and Chrome from WSL
> **Scope:** Specialist implementation reference, not permission to install,
> access a private host, deploy infrastructure or run a paid browser provider.
> Follow the active project's Goal and [canonical Core](../AGENTS.md),
> [Goals](../GOALS.md) and [Testing](../TESTING.md).
> Validate current tool capabilities on the actual execution host.


This playbook records the small POC pattern used when the application lives in
WSL, Chrome and Node.js live on Windows, and the repository must capture
repeatable browser evidence. Use it with [Agent-Run Browser E2E and Screenshot
Evidence](BROWSER.md); that playbook remains
the source for test layers, stop conditions, and evidence rules.

## Default decision

Use Playwright Core for interactive browser E2E when the UI exposes the action
being proved. The preferred route is:

1. Stage a repo-owned `.mjs` test and an exact Playwright Core version in a
   unique Windows temporary directory.
2. Run the test with Windows Node.
3. Let Playwright launch the installed Windows Chrome executable directly.
4. Click the real UI, assert both the network response and rendered DOM, capture
   screenshots, and close the browser in `finally` cleanup.

Use CDP attachment only when Bash must own Chrome startup or the test must
attach to an already-running isolated browser. Direct Chrome CLI screenshots
are a rendering-only fallback, not interactive E2E proof.

## Why this route

`playwright-core` supplies the automation API without downloading a bundled
browser. It can launch the already-installed Windows Chrome executable while
owning its lifecycle. This keeps a small POC fast and avoids a second browser
installation.

For a stable repo-owned runner, pin an exact development dependency and audit
it:

```bash
npm install --save-dev --save-exact playwright-core@<approved-version>
npm audit --audit-level=high
```

A unique Windows temporary install is acceptable for one bounded discovery or
smoke test. The trusted repeatable result should move the exact version and the
test script into the owning repository. Do not silently install a global
package or use an implicit `latest` version.

Do not put credentials, cloud identifiers, raw logs, or private screenshots in
the knowledge base or public evidence.

## Boundary contract

The repo-owned Bash runner must:

1. Start the local application on loopback and poll a health endpoint.
2. Refuse a busy port instead of killing an unknown process.
3. Create unique run and Windows temporary directories.
4. Convert WSL paths with `wslpath -w` before passing them to Windows tools.
5. Run the repo-owned `.mjs` script with Windows Node and explicit arguments.
6. Launch installed Chrome through Playwright with a private context and fixed
   viewport.
7. Perform real UI actions and assert the corresponding API response and DOM.
8. Capture console errors, page errors, failed requests, and unexpected HTTP
   error responses.
9. Write machine-checkable JSON and screenshots to a run-specific directory.
10. Close the Playwright browser, stop only the app process created by the run,
    remove temporary dependencies, and prove that allocated ports are free.

The runner must not use `pkill`, `taskkill /IM chrome.exe`, a shared browser
profile, a public bind address, or a cloud mutation.

## Preferred tested route: direct launch

Pass values as explicit arguments across the WSL-to-Windows boundary. Do not
depend on inline WSL environment assignments reaching a Windows executable.
The repo-owned JavaScript can follow this pattern:

```javascript
import assert from 'node:assert/strict';
import { chromium } from 'playwright-core';

const [, , appUrl, chromePath, evidenceDir] = process.argv;
assert(appUrl && chromePath && evidenceDir, 'missing required argument');

const problems = [];
let browser;

try {
  browser = await chromium.launch({
    executablePath: chromePath,
    headless: true,
  });
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 },
  });
  const page = await context.newPage();

  page.on('console', message => {
    if (message.type() === 'error') problems.push(`console: ${message.text()}`);
  });
  page.on('pageerror', error => problems.push(`page: ${error.message}`));
  page.on('requestfailed', request => {
    problems.push(`request: ${request.method()} ${request.url()}`);
  });
  page.on('response', response => {
    if (response.status() >= 400) {
      problems.push(`http: ${response.status()} ${response.url()}`);
    }
  });

  await page.goto(appUrl, { waitUntil: 'networkidle' });
  const apiResult = page.waitForResponse(response =>
    response.url().includes('/api/') && response.request().method() === 'POST'
  );
  await page.getByRole('button', { name: '<action label>' }).click();

  const response = await apiResult;
  assert(response.ok(), `API returned ${response.status()}`);
  const payload = await response.json();
  assert.equal(payload['<stable field>'], '<expected value>');
  await page.getByText('<expected visible result>', { exact: true }).waitFor();

  await page.screenshot({
    path: `${evidenceDir}/result.png`,
    fullPage: true,
  });
  assert.deepEqual(problems, [], `browser problems: ${problems.join('; ')}`);
} finally {
  await browser?.close();
}
```

Replace the placeholders with stable selectors and fields owned by the app.
Do not use a timeout as the primary assertion. Wait for a meaningful response
or visible state instead.

When Windows Node needs a temporary dependency, use a staged PowerShell script
or equivalent deterministic wrapper. Give it explicit paths and an exact
version, and remove its unique temporary directory during cleanup. Do not ask
Bash to parse `npm.cmd` or PowerShell syntax.

A discovery-only staging wrapper can use this shape:

```powershell
param(
  [Parameter(Mandatory = $true)][string]$WorkDir,
  [Parameter(Mandatory = $true)][string]$Runner,
  [Parameter(Mandatory = $true)][string]$NpmPath,
  [Parameter(Mandatory = $true)][string]$NodePath,
  [Parameter(Mandatory = $true)][string]$Version,
  [Parameter(Mandatory = $true)][string]$AppUrl,
  [Parameter(Mandatory = $true)][string]$ChromePath,
  [Parameter(Mandatory = $true)][string]$EvidenceDir
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null
& $NpmPath install --prefix $WorkDir --ignore-scripts --no-audit --no-fund "playwright-core@$Version"
if ($LASTEXITCODE -ne 0) { throw 'Playwright Core install failed' }

$stagedRunner = Join-Path $WorkDir 'browser-e2e.mjs'
Copy-Item -LiteralPath $Runner -Destination $stagedRunner
& $NodePath $stagedRunner $AppUrl $ChromePath $EvidenceDir
if ($LASTEXITCODE -ne 0) { throw 'Browser E2E failed' }
```

The calling Bash runner should create `WorkDir`, convert every path with
`wslpath -w`, invoke the staged PowerShell file with explicit named arguments,
and remove only that exact unique directory in its cleanup trap. A repository
that runs this regularly should use its checked-in package manifest and lock
file instead of installing a temporary package on every run.

## Critical WSL/Windows boundary

A WSL Codex or Bash session **can still own the full browser workflow** when
Chrome runs on Windows. Do not equate a failed Linux-side probe of
`localhost:<cdp-port>` with "Playwright from WSL is impossible."

The tested cross-boundary pattern is:

```text
WSL Codex/Bash
  -> launch Windows chrome.exe
  -> read DevToolsActivePort through the shared Windows filesystem
  -> launch Windows node.exe from WSL
  -> playwright-core connects to Windows localhost CDP
  -> drive/assert/capture
```

The important distinction is **who owns the TCP connection**. A Linux
`curl`/Node process may not reach the Windows browser's loopback endpoint in a
given WSL/network configuration, while `node.exe` launched from that same WSL
shell can connect because it runs as a Windows process. WSL remains the
orchestrator; moving the whole Codex session to Windows is not automatically
required.

### Do not misdiagnose a refused localhost probe

If `http://localhost:<port>/json/version` is refused from Linux:

1. Confirm whether the probe ran as a Linux process or a Windows process.
2. Do not probe arbitrary Windows interfaces or widen the CDP bind address.
3. Prefer a unique debugging profile and `--remote-debugging-port=0`; read the
   actual port from that profile's `DevToolsActivePort` file instead of assuming
   port 9222.
4. Convert the runner/module/evidence paths with `wslpath -w`.
5. Invoke **Windows Node.js** from WSL and let that process call
   `chromium.connectOverCDP("http://localhost:<port>")`.
6. Declare a real access gate only if the Windows executable route is itself
   unavailable or the Windows-side attach fails.

This prevents a common false blocker: "Linux localhost cannot see Chrome, so
Codex/Playwright must run natively on Windows."

## Authenticated browser sessions

For a flow that needs an already authenticated web session, keep the same
boundary instead of exporting browser state:

1. Launch a **dedicated debugging Chrome profile** from WSL using Windows
   `chrome.exe`, localhost CDP, and a unique user-data directory.
2. Let the human authenticate normally in that dedicated Chrome window.
3. Keep that exact Chrome/profile alive for the bounded E2E run.
4. From the WSL-owned workflow, invoke Windows `node.exe` and attach
   Playwright Core to the profile's localhost CDP endpoint.
5. Drive only the approved UI path and retain sanitized evidence.
6. Remove only the run-specific profile when it is explicitly disposable.

Do not copy cookies, tokens, passwords, browser databases, or a normal shared
Chrome profile into WSL. Do not try to retrofit automation onto an unrelated
Chrome process that was not launched with the intended debugging boundary.

## Tested reference implementation

The SecCop public learning repository exercised this pattern successfully with
one repo-owned Bash runner and one Playwright Core script:

- WSL starts the local application;
- WSL launches Windows Chrome with a unique Windows temporary profile;
- the runner reads `DevToolsActivePort` from that profile;
- WSL invokes Windows Node.js;
- Windows Node attaches over localhost CDP and drives the UI;
- screenshots, console/network evidence, and exact cleanup are verified.

Use that implementation as a concrete example of the boundary, not as a file to
copy blindly. Keep each owning repository's selectors, auth rules, and safety
contract local to that repository.

## Optional CDP attachment route

Use placeholders owned by the runner rather than hard-coded user directories:

```bash
chrome_wsl=${CHROME_WSL:?set the Windows Chrome executable}
windows_node=${WINDOWS_NODE:?set the Windows Node executable}
profile_wsl=$(mktemp -d "$windows_temp_wsl/browser-e2e.XXXXXX")
profile_windows=$(wslpath -w "$profile_wsl")

"$chrome_wsl" \
  --headless=new \
  --disable-background-networking \
  --remote-debugging-address=localhost \
  --remote-debugging-port=0 \
  "--user-data-dir=$profile_windows" \
  about:blank &
chrome_launcher_pid=$!

debug_port=$(sed -n '1p' "$profile_wsl/DevToolsActivePort" | tr -d '\r')
cdp_url="http://localhost:$debug_port"
runner_windows=$(wslpath -w "$repo_dir/scripts/browser-e2e.mjs")
core_windows=$(wslpath -w "$playwright_core")

"$windows_node" "$runner_windows" "$app_url" "$cdp_url" "$core_windows"
```

The real runner must use bounded polling for `DevToolsActivePort`; the snippet
shows the boundary, not an excuse to wait forever.

### Minimal attachment pattern

The Windows Node script imports the explicit module path and attaches to the
existing browser:

```javascript
import { pathToFileURL } from 'node:url';

const [, , appUrl, cdpUrl, modulePath] = process.argv;
const { chromium } = await import(pathToFileURL(modulePath).href);
const browser = await chromium.connectOverCDP(cdpUrl);
const context = browser.contexts()[0] ?? await browser.newContext();
const page = context.pages()[0] ?? await context.newPage();
await page.setViewportSize({ width: 1920, height: 1080 });
```

Drive the real UI, assert the API result, and then take the screenshot. A
screenshot alone is not proof of policy, tool execution, or cleanup.

## Evidence checks for a local POC

- Health JSON confirms the expected local mode before the browser starts.
- The browser performs the real user action when the UI exposes it.
- The matching API response asserts stable machine-readable fields.
- The rendered DOM asserts the visible decision and reason.
- Positive and negative paths are both covered when policy is part of the POC.
- Every request is observed; external request count must remain zero unless an
  exact allowlist is part of the test contract.
- Browser console errors, page errors, failed requests, and unexpected HTTP
  error responses must remain zero or be reported as explicit warnings or
  failures.
- Screenshots are written both to the restricted run directory and to the
  operator's review mirror only when that mirror is explicitly requested.

## Observed smoke-test lesson

This direct-launch pattern was smoke-tested with Windows Node, installed
Windows Chrome, and a temporary exact Playwright Core package. Real UI clicks,
API assertions, DOM assertions, full-page screenshots, browser closure, and
port cleanup completed successfully. The error collector also surfaced a
missing favicon response. That did not invalidate the feature assertions, but
the run was correctly labeled as passing with a browser warning rather than a
fully clean pass.

Do not hide browser hygiene warnings. Fix the application asset or record the
warning explicitly in the result.

## Failure handling

Stop and retain the run evidence if the port is busy, Chrome does not expose a
CDP endpoint, the module cannot be imported, an assertion fails, an external
request appears, or cleanup cannot be proven. Do not retry by killing unrelated
processes or by widening network access. Fix the runner or application and
start a new unique run.

## Acceptance checklist

- [ ] The repo owns the test script and pins the Playwright Core version.
- [ ] The app binds to loopback and readiness is bounded.
- [ ] Playwright performs real UI actions when available.
- [ ] Both API payload and rendered DOM are asserted.
- [ ] Screenshots use a fixed viewport and run-specific filenames.
- [ ] Console, page, request, HTTP, and external-network observations are saved.
- [ ] Warnings are visible in the result rather than silently ignored.
- [ ] Browser, temporary package, app process, and ports are clean after exit.

## References

- [Agent-Run Browser E2E and Screenshot Evidence](BROWSER.md)
- [Playwright library documentation](https://playwright.dev/docs/library)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)

## Citations

- Playwright library documentation: https://playwright.dev/docs/library
- Chrome DevTools Protocol: https://chromedevtools.github.io/devtools-protocol/
- SecCop Issue #27 (WSL/Windows Chrome CDP requirement): https://github.com/mytestlab123/agentic-ai-cybersecurity-lab/issues/27
- SecCop PR #28 (validated browser evidence): https://github.com/mytestlab123/agentic-ai-cybersecurity-lab/pull/28
- SecCop WSL browser runner: https://github.com/mytestlab123/agentic-ai-cybersecurity-lab/blob/main/scripts/browser-e2e.sh
- SecCop Playwright Core runner: https://github.com/mytestlab123/agentic-ai-cybersecurity-lab/blob/main/scripts/browser-e2e.mjs
