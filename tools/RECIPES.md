---
type: Policy
title: Tracked Repository Search and Tool Recipes
description: Choose tracked source searches and focused CLI helpers, with direct evidence verification.
status: reviewed
confidence: high
scope: Reusable public-safe agent guidance
review_after: 2027-04-23
tags: [tools, search, git, source]
---

# Tracked Repository Search and Tool Recipes

Search output narrows candidates; it does not prove tracked ownership or current
behavior. Start at a verified repository root and open the exact source before
editing. The default tracked inventory is `git ls-files`, not `fd` or `rg`.

| Question | Preferred command |
| --- | --- |
| Tracked filenames | `git ls-files src/` |
| Dirty or untracked work | `git status --short` |
| Tracked exact literal | `git grep -n -F 'ConfigValue' -- src/` |
| Discover filename in working tree | `fd -g '*.py' src/` |
| Broad content discovery | `rg -nF 'ConfigValue' src/` |

`fd` and `rg` may intentionally omit ignored/hidden files and include
untracked work; they are useful discovery tools but not Git ownership evidence.
Use unrestricted searches only when the task explicitly requires them.
Inspect the source, scope and changed diff before a bulk replacement.

## CLI recipe reference

The following concrete command recipes are preserved from the existing
specialist reference, with tracked-search priority established above.


Confirm command and file scope before trusting its output.

## `rg`: Search File Contents

Find a literal value with line numbers:

```bash
rg -nF 'ConfigValue' src/
```

Failure mode: regex metacharacters change a search when `-F` is omitted.
Unrestricted flags also include ignored or hidden data that is normally noise.

## `fd`: Discover Filenames

List Python files under a source directory:

```bash
fd -g '*.py' src/
```

Failure mode: `fd` is ignore-aware working-tree discovery, not proof that Git
tracks a result. Use `git ls-files` for tracked inventory.

## `ast-grep`: Inspect Code Structure

Find JavaScript logging calls without rewriting them:

```bash
ast-grep -p 'console.log($$$)' src/
```

Failure mode: the pattern must be valid syntax for the target language. Keep
inspection read-only by omitting rewrite or fix options.

## `sd`: Replace Known Literal Text

Verify the scope, replace the literal, then inspect the diff:

```bash
rg -nF 'OldValue' src/config.py
sd -F 'OldValue' 'NewValue' src/config.py
git diff -- src/config.py
```

Failure mode: without literal mode, punctuation may act as regular-expression
syntax. `sd` replaces every matching occurrence in the named scope.

## `jq` or `jaq`: Validate JSON Shape

Require `items` to be an array:

```bash
jq -e '.items | type == "array"' data.json >/dev/null
```

Failure mode: printing a missing field can yield `null` without proving the
required shape. Use an assertion and check its exit status. A compatible
`jaq` installation can run the same basic filter.

## `hyperfine`: Compare Commands

Measure repeated runs with warmup:

```bash
hyperfine --warmup 3 "rg -nF 'ConfigValue' src/" \
  "git grep -nF 'ConfigValue' -- src/"
```

Failure mode: timing commands with different file sets or outputs does not
support a fair performance claim. Prove equivalent scope first.

## `tokei`: Estimate Repository Size

Summarize languages and code size under a source directory:

```bash
tokei src/
```

Failure mode: line count is a scope hint, not a measure of complexity, risk, or
required effort.

## QMD: Search an Existing Index

Use QMD only after proving that the required collection is fresh and contains
at least one document:

```bash
qmd status
qmd search "configuration loading" -c docs
```

Failure mode: a configured, empty, or stale collection can omit current
evidence. Fall back to the Git-aware search hierarchy when freshness or
nonzero content is not proven, and always read the selected source directly.

## Definition searches, parser traps and transformations

Use multiple `-e` patterns or grouping for alternatives. In ripgrep, `-E`
selects **encoding**, unlike grep's extended-regex option. A scoped JavaScript
definition search, including several export styles:

```bash
rg -n -e '^export (async )?(function|const|class) acquireLock\b|^(async )?function acquireLock\b|^const acquireLock\b' scripts/ -g '*.mjs'
fd -g '*.mjs' scripts/
ast-grep -p 'try { $$$ } catch { }' scripts/
ast-grep -p 'export function $NAME($$$) { $$$ }' scripts/
```

`fd -g '*.mjs' . scripts/` supplies an extra path argument; in the dated
source it returned 324 files instead of the intended 187. Use
`fd -g '*.mjs' scripts/` for that single-directory scope. Hidden/ignored flags
also change the file set; enable them deliberately. AST patterns must match
the language/version and syntax variant:
the swallowed-catch example does not cover every catch binding or function
form. Regex can match comments/strings or miss multiline structures; inspect
the matched source before claiming exhaustive structural coverage.

For replacement, punctuation is meaningful in regex mode. Prefer `sd -F` for
an exact literal, name specific files, check preconditions and inspect the diff.
Do not build a bulk rewrite from an approximate search count.

Printing a JSON field is not an assertion. Check presence **and** shape when
both matter:

```bash
jq -e 'has("scripts") and (.scripts | type == "object")' package.json >/dev/null
jq -e '.items | type == "array"' result.json >/dev/null
```

An empty array can still satisfy a type assertion; add a nonzero/count condition
only when the contract requires it. `yq` variants have different syntax; verify
the implementation before reusing a command. Parsing YAML/JSON successfully
does not lint its semantics or prove downstream configuration acceptance.

## Fair benchmarks and empty indexes

Before measuring, compare file lists, ignore/hidden/generated-file handling,
case sensitivity, match semantics and output. Export repeated measurements:

```bash
hyperfine --warmup 3 --export-json benchmark.json \
  "rg -nF 'ConfigValue' src/" \
  "git grep -nF 'ConfigValue' -- src/"
```

This compares meaningful behavior only after tracked and working-tree scopes
are known to agree. Cache warmth and tiny-directory overhead can reverse the
result. Preserve command/version, input revision and sample conditions with
numbers; line counts from `tokei` are only a scope hint.

**Dated 2026-07-28 observations from the pinned source:** one broad grep saw
102 files in about 2841 ms while rg saw 47 in about 23 ms. Those are unequal
sets, not a supported speedup. An fd/find comparison reported about 19.8/361.1 ms
and an 18.23 ratio, while discovery inventories differed (185/187 versus 337);
find won another tiny-directory sample by about 15 ms. Regex catch searches
reported 12/109 versus 15 AST results with differing match scope. These examples
show why elapsed time/counts alone cannot select a tool or establish coverage.

The same source observed QMD with zero files/vectors and no configured
collections. An empty result there proved nothing about repository content.
Check collection, nonzero content and freshness before search, and read the
selected source. Local wrapper names, indexing schedules and collection paths
remain local. Do not create/rebuild an index without owning authority merely
to satisfy a search.

## Other helpers and bounded events

| Need | Boundary |
| --- | --- |
| PDF/archive/office-document discovery with `rga` | Search only approved artifacts; inspect extracted source and provenance |
| HTTP with `curl`/`xh` | Confirm status, service identity and content contract; protect auth/body output |
| DNS with `dig`/`dog` | Resolution is not TLS/auth/object access; see [Private Artifacts](PRIVATE_ARTIFACTS.md) |
| Display with `bat`/`eza` or diff viewers | Convenience, not validation or tracked ownership proof |
| Filesystem event with `inotifywait`/`watchexec` | Bounded authorized local watch, followed by content/version readback |

A single authorized event wait might be:

```bash
inotifywait --timeout 30 --event close_write,moved_to "$approved_artifact_dir"
```

Check the wait status, then inspect the exact expected artifact. An unrelated
write, partial file, atomic rename or stale output can satisfy a directory
event without producing the required result. A timeout means no matching event
was observed within that bound, not that a remote workload failed. A watched
command loop is not cloud/provider health proof and does not authorize a daemon.

## Interpreter and host boundaries

The outer launcher parses a command before an inner interpreter sees it.
`bash -lc` cannot protect shell syntax that the outer POSIX shell, JSON layer
or PowerShell already expanded. Prefer structured tool arguments, small
reviewable scripts and explicit interpreter selection.

For generated shell, quote a heredoc delimiter to prevent expansion while
writing, then parse-check the exact generated file:

```bash
cat > candidate.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$1"
SH
bash -n candidate.sh
```

This is a standalone recipe, not permission to overwrite an existing file.
Choose an approved new path and preserve a preimage before a material
replacement. A parse check proves syntax only; inspect content/diff and use the
owning validator before executing. Test each parser boundary separately rather
than embedding several layers of quoting until an error disappears.

On WSL, distinguish Linux paths/interpreters/config from Windows paths/native
executables/config. A Linux CLI's configuration does not establish a Windows
binary's identity or availability. Convert paths at the boundary, use the
verified active host profile and export only the scoped approved artifacts;
do not mirror private directories. A viewer URI is not a CLI filesystem path.
A single slow interop call does not establish measured CPU/memory pressure.
Do not infer current shell, address or tool availability from an old profile,
invent a missing host pointer or publish that profile.

For major policy replacement, preserve exact old content and a recoverable
rollback before overwriting; a summary or remembered link is not an equivalent
preimage. [Knowledge](../KNOWLEDGE.md) owns retention/disposition, and the project
owns exact backup and approval requirements.

## Citations

- [`ripgrep` project documentation](https://github.com/BurntSushi/ripgrep)
- [`fd` project documentation](https://github.com/sharkdp/fd)
- [`ast-grep` pattern syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
- [`sd` project documentation](https://github.com/chmln/sd)
- [`jq` manual](https://jqlang.org/manual/)
- [`jaq` project documentation](https://github.com/01mf02/jaq)
- [`hyperfine` project documentation](https://github.com/sharkdp/hyperfine)
- [`tokei` project documentation](https://github.com/XAMPPRocky/tokei)
- [QMD project documentation](https://github.com/tobi/qmd)
- [Pinned detailed recipes and dated observations](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/TOOLS-AGENT-RECIPES.md)
- [Pinned tool and event routing](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/TOOLS.md)
- [Pinned parser-boundary learning](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/CORE.md)
- [Pinned optional shell practices](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/OPTIONAL_CONTEXT.md)
- [Pinned public host-boundary observations](https://github.com/amitkarpe/dotfiles/blob/5685eea054e1fbd4499ea4631e86014654f774d0/config/.config/agent/hosts/office/HOST.md)


