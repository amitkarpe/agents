---
type: Playbook
title: Evidence-led POC Presentations
status: candidate
confidence: medium
scope: Management story, faithful proof, export and visual acceptance
review_after: 2027-01-28
tags: [presentations, evidence, screenshots, marp, pptx]
---

# Evidence-led POC Presentations

Start with the audience's problem and requested decision. A management POC
presentation explains why the problem matters, what the bounded solution does,
what was proved, the remaining limitation and the next decision. Detailed
technical requirements and design belong in separate artifacts when requested.

## Establish the story

Before creating slides, determine the audience, decision, presentation time,
business problem, available proof and target display/delivery format. If a
fact is unavailable, mark the limitation instead of inventing business impact.

Use one repository/problem/story where practical. A seven-to-nine-slide outline
is a useful starting point; the pinned source targeted fewer than ten. These
are editorial constraints for a concise POC, not universal deck requirements.
Keep one message per slide and separate the problem from the proposed solution.
Two to four feature panels often work better than a dense architecture diagram.

| Slide | Content and proof boundary |
| --- | --- |
| Promise | A few memorable words and a short subtitle; no unsupported enterprise claim |
| Problem | Who repeats what activity, what limitation appears at what scale, and what impact follows |
| Gap | Explain the work between finding an issue and investigating, coordinating, approving and verifying resolution |
| Proposed solution | A narrow governed workflow, with actual controls and bounded tools |
| Workflow | Find → Explain → Recommend → Approve → Remediate → Verify, only where implemented; label missing stages |
| Proof | One positive path and the important denial/bypass case where relevant |
| Controls | The few controls that matter to this decision, with honest evidence |
| Value | Management benefit supported by current proof; distinguish estimates from measured results |
| Next decision | One bounded request, stated limitation and next validation step |

First form a generic problem/solution foundation, then replace generic examples
with project-specific, authoritative evidence. An incident or cost claim needs
a source; a plausible narrative is not a measured outcome. Avoid function names,
raw logs, long test lists, account IDs, ARNs, internal hosts and unsupported
“100% compliant” or unrestricted-autonomy promises in the management story.

## Label evidence honestly

| Label | Meaning |
| --- | --- |
| DEMO-PROVEN | Current real UI workflow exercised end to end with supporting assertions |
| TEST-PROVEN | Logic/contract checked; does not establish the real UI workflow |
| READ-ONLY | Real external state inspected; no mutation or remediation proved |
| PLANNED | Selected direction, not implemented behavior |
| NOT PROVEN | Required evidence absent or inconclusive |

Keep labels identical in Markdown, exported deck and spoken claims. A source
merge, screenshot, API success or unit test must not be silently promoted to a
stronger label. [Browser Evidence](BROWSER.md) owns real-UI/API/DOM assertions,
error capture and positive/negative paths; [Playwright](PLAYWRIGHT.md) supplies
the specialist workflow. Do not fabricate HTML, database state or API responses
to make a proof screenshot look convincing.

## Build a reviewable source and faithful images

A practical source layout is `docs/demo.md` with relative assets beneath
`docs/demo-proof/`. Keep originals and focused slide images separately. Capture
the actual approved application at a fixed viewport; 1920×1080 was the source
example, not a mandatory device size.

For each proof image:

1. Establish the claimed state through the real application and machine
   assertions. Record the important before/requested/actual outcome.
2. Capture the full evidence image. Check it for private information before
   sharing; retain raw sensitive evidence only in approved private storage.
3. Use a locator capture or deterministic crop to make the decision and result
   readable. Retain enough context to show what happened. Do not edit status,
   text, identity or outcome into an image.
4. Keep distinct positive/negative proof filenames and accurate labels.
5. Inspect the final image at normal presentation size, not only zoomed in.

One short takeaway above one large focused image is often clearer than several
small screenshots. The source suggested roughly 70–85% of the canvas for a
proof image. Preserve text sharpness; lowering resolution or enlarging the
entire application does not repair unreadable evidence. A crop must not conceal
a denial, qualification or contradictory result.

## Theme, layout and viewer differences

Choose light slides for an unknown/bright room; dark can work for a known dim
venue. A dark application screenshot does not require a dark deck. Use the
actual target viewer to decide whether the choice is readable.

A portable Marp starting point:

```yaml
---
marp: true
theme: default
paginate: true
backgroundColor: '#f7f9fc'
color: '#132238'
style: |
  section { font-family: Arial, Helvetica, sans-serif; padding: 54px 64px; }
  h1, h2 { color: #0f766e; }
  strong { color: #0369a1; }
  img { display: block; max-width: 86%; max-height: 520px;
        object-fit: contain; margin: 12px auto 0; }
---
```

Use normal Markdown headings, short lists and relative image links so source
remains useful outside Marp. Markdown viewers may ignore frontmatter CSS.
Inspect critical tables/images in every requested delivery viewer; use simple
panels or trusted inline styling only when supported. Check that arrows render:
plain arrows or `->` can be safer than an entity displayed literally.

Leave a bottom safe area for controls/pagination. At a 1920×1080 reference
canvas, the source used 80–100 pixels. Put the takeaway before the large image,
keep tables compact, and shorten/split text when the final line is clipped.
Speaker notes can live in short HTML comments; explain the management takeaway,
rather than repeating the slide.

## Select and export the requested artifact

- **Story draft:** review Markdown, proof labels, links and companion images.
- **Executive delivery:** use the approved editable presentation workflow and
  requested native artifact, commonly PPTX. Design it for the actual 16:9
  canvas rather than preserving a Markdown layout mechanically.
- **Reproducible fallback:** Marp HTML/PDF/draft PPTX can be useful when requested.
  A successful conversion is not proof of executive design quality.

Use an approved existing renderer; do not install a global tool or add an
application dependency merely for an export. From the directory containing
the trusted source and relative assets, a supported Marp CLI can use:

```bash
marp --version
marp demo.md --preview
marp demo.md --watch --preview
marp demo.md --html --allow-local-files --output demo.html
marp demo.md --html --allow-local-files --pptx --output demo.pptx
```

Run only the requested modes. Check each command's status, output existence
and nonzero size. Local-file access is for a trusted deck and known assets;
never enable it for untrusted content. HTML may still require its companion
image directory; PPTX packaging does not excuse inspecting embedded images.
The filesystem path passed to a CLI differs from the viewer's `file:` URI.

### Optional Windows/WSL boundary

Only when the active host profile selects a Windows mirror and an existing
PowerShell/Marp installation, export from that mirror so relative assets match
the intended viewing location. Host-specific mirror paths stay local. A generic
PowerShell example using already-approved locations:

```powershell
$deckDir = "<approved-deck-directory>"
$marp = "<verified-marp-command>"
$deck = Join-Path $deckDir "demo.md"
if (-not (Test-Path $marp)) { throw "Renderer unavailable" }
if (-not (Test-Path $deck)) { throw "Deck unavailable" }
Set-Location $deckDir
& $marp --version
& $marp ".\demo.md" --html --allow-local-files --output ".\demo.html"
if ($LASTEXITCODE -ne 0) { throw "HTML export failed" }
& $marp ".\demo.md" --html --allow-local-files --pptx --output ".\demo.pptx"
if ($LASTEXITCODE -ne 0) { throw "PPTX export failed" }
Get-Item ".\demo.html", ".\demo.pptx" |
  Select-Object Name, Length, LastWriteTime
$htmlUri = [System.Uri]::new((Resolve-Path ".\demo.html").Path).AbsoluteUri
```

Use the approved viewer to open that URI; browser paths, fullscreen choices and
output mirrors belong to local setup. For Bash invoking PowerShell, protect
PowerShell dollar expressions from Bash expansion, preferably through an
approved script file. Do not pass a WSL viewer URI where a Windows filesystem
path is required. Do not silently install missing Marp or Chrome.

## Final acceptance

Inspect the longest text slide, every proof slide and the last slide in the
target viewer. For final PPTX, inspect **every slide** after export.

- Can the audience state the problem after the opening slides?
- Are problem, solution, limits and one requested decision distinct?
- Does every material feature have a supported evidence label?
- Do full/focused images match asserted real states and remain readable?
- Do all relative assets work in the actual delivery copy?
- Are text, arrows, tables, theme, notes and safe areas rendered correctly?
- Are private information and unsupported claims absent?
- Does the next decision concern direction, validation or deployment exactly
  as authorized, rather than implying those are interchangeable?

After direction is accepted, technical requirements/design may document users,
integrations, controls, architecture, identity, failure handling, evidence,
cost and rollout as separate requested artifacts. Do not hide a deployment
approval inside a POC direction decision.

Stop once the requested audience can understand problem, controlled workflow,
proof, value, limitation and next decision. Add animation, branding or formats
only when they materially serve that request.

## Citations

- [Pinned presentation procedure and examples](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/presentation-POC.md)
- [Marp](https://marp.app/)
- [Marp CLI export and security documentation](https://github.com/marp-team/marp-cli)
