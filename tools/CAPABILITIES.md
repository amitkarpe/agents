---
type: Playbook
title: Agent Capability Cards and the "Can't" Preflight
description: What each agent surface (Claude app/CLI, Codex app/CLI, Kiro CLI) can do natively on a Mac, with proof, and the 1-minute probe before any agent says "I can't".
status: reviewed
scope: local agent work on macOS — computer use, browser, headless Chrome, screen recording, video checks
confidence: medium
timestamp: 2026-11-13T14:00:00+08:00
review_after: 2027-02-13
tags: [agents, capabilities, computer-use, browser, recording, ffmpeg, preflight]
---

# Agent Capability Cards and the "Can't" Preflight

**Load this when** a task needs screen control, a browser, a recording or a video check, or when an agent is about to say a tool is "unavailable".

## The rule: preflight before any "can't"

An agent does not know its tools until it looks. Tools change by surface (app or CLI), by sandbox and by permission. Before an agent answers "not possible":

1. **List** the tools in this session (the tool list, `codex mcp list`, `kiro-cli mcp list`).
2. **Probe** for one minute. Take one screenshot, run one `ffprobe`, or open one headless Chrome page.
3. **Name the cause:** *ability* (the surface has no such tool) or *permission* (a sandbox, an approval or a safety rule blocked it). A blocked permission is not a missing skill. Report it with the exact error.
4. If a different surface or agent has the ability, say which one.

A brief that gives tool work to an agent says this in one line.

## Cards (macOS, checked 13 Nov 2026)

"Proven" means a real test produced the output. "Not checked" means nobody tested it here yet.

| Surface | Computer use (other apps) | Browser | Headless Chrome / Playwright | Screen recording | Video checks (ffmpeg) |
|---|---|---|---|---|---|
| **Claude Desktop app (Code tab)** | Yes: `app_*` tools drive a granted app in the background; full-screen tools need extra approval. Browsers are read-only in computer use | Built-in browser pane, plus Claude in Chrome (the user's real Chrome) | Yes, through the shell if Chrome is installed | Yes, through `screencapture` in the shell | **Proven**: full decode and frame checks of 3 private clips |
| **Claude CLI** | Not checked | Claude in Chrome when connected; no built-in pane | Yes, through the shell | Yes, through the shell | Yes **unless sandboxed**: a sandboxed reviewer was denied `ffprobe`/`ffmpeg` (a permission, not an ability) |
| **Codex app (ChatGPT desktop)** | Yes: `cua_repl` | ChatGPT browser access to Chrome. With **full CDP access on**, Chrome shows a yellow "debugging this browser" bar in every frame | Proven | Proven | Proven |
| **Codex CLI** | **Yes**: the same `cua_repl` and `node_repl` servers load from the ChatGPT app. An agent once wrongly said this was unavailable | The browser-access host can be "unavailable" here; native app control still works | **Proven**: Playwright `recordVideo`, 25 s WebM | **Proven**: `screencapture -l <window-id> -V 20` recorded a background Chrome window while the user typed elsewhere | Proven |
| **Kiro CLI** | Not checked | Not checked | Through its shell tool, if trusted | Through its shell tool, if trusted | Through its shell tool, if trusted |

## Recording facts that cause most failures

- `screencapture -V` films a **display** and shows only what is on it. A plain screen recording catches the front window, often the terminal.
- `screencapture -l <window-id>` films **one window**, even behind other windows. It films that window's **selected tab**. Get the window ID in the current session, and restore the user's tab afterwards.
- `screencapture -D 2` films the second display. A Space that is not active cannot be filmed (not checked further).
- **Headless Playwright** with `recordVideo` films a page with no window at all. This is best for local or synthetic pages. Never copy a signed-in profile to get round a login.
- Keep **full CDP access off** for films. Turn it on only for a task that needs deep browser control, then off again.
- **Verify every clip:** run a full `ffmpeg -i f -f null -` decode, sample frames, and find state changes with `freezedetect`. A contact sheet alone is not proof that the video is good.

## Keep it current

When a test proves or disproves a cell, update that cell with the date in one line. Add a surface (for example Grok or Devin) only after a real round-trip test.
