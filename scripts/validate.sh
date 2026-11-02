#!/usr/bin/env bash
set -euo pipefail

SELF="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/$(basename -- "${BASH_SOURCE[0]}")"
readonly SELF

errors=0
warnings=0

error() {
  printf 'ERROR: %s\n' "$*" >&2
  errors=$((errors + 1))
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
  warnings=$((warnings + 1))
}

strip_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  value="${value#\'}"
  value="${value%\'}"
  printf '%s' "$value"
}

validate_yaml_block() {
  local file="$1"
  local require_type="$2"
  local end line key value
  local type_value='' status_value='' confidence_value=''
  local review_after_value='' last_verified_value=''
  local line_number=0
  declare -A seen=()

  if [[ "$(sed -n '1p' "$file")" != '---' ]]; then
    error "$file: missing opening YAML frontmatter delimiter"
    return
  fi

  end="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$file")"
  if [[ -z "$end" ]]; then
    error "$file: missing closing YAML frontmatter delimiter"
    return
  fi

  while IFS= read -r line; do
    line_number=$((line_number + 1))
    [[ -z "$line" || "$line" == \#* ]] && continue

    if [[ "$line" == *$'\t'* ]]; then
      error "$file:$((line_number + 1)): tabs are not allowed in frontmatter"
      continue
    fi
    if [[ ! "$line" =~ ^([A-Za-z_][A-Za-z0-9_-]*):[[:space:]]*(.*)$ ]]; then
      error "$file:$((line_number + 1)): unsupported or malformed YAML"
      continue
    fi

    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"
    if [[ -n "${seen[$key]:-}" ]]; then
      error "$file:$((line_number + 1)): duplicate frontmatter key '$key'"
    fi
    seen[$key]=1

    if [[ "${value:0:1}" == '[' && "${value: -1}" != ']' ]]; then
      error "$file:$((line_number + 1)): unterminated YAML list"
    elif [[ "${value:0:1}" == '"' && "${value: -1}" != '"' ]]; then
      error "$file:$((line_number + 1)): unterminated double-quoted value"
    elif [[ "${value:0:1}" == "'" && "${value: -1}" != "'" ]]; then
      error "$file:$((line_number + 1)): unterminated single-quoted value"
    fi

    [[ "$key" == 'type' ]] && type_value="$(strip_quotes "$value")"
    [[ "$key" == 'status' ]] && status_value="$(strip_quotes "$value")"
    [[ "$key" == 'confidence' ]] && confidence_value="$(strip_quotes "$value")"
    [[ "$key" == 'review_after' ]] && review_after_value="$(strip_quotes "$value")"
    [[ "$key" == 'last_verified' ]] && last_verified_value="$(strip_quotes "$value")"
  done < <(sed -n "2,$((end - 1))p" "$file")

  if [[ "$require_type" == 'yes' && -z "${type_value//[[:space:]]/}" ]]; then
    error "$file: missing or empty required 'type'"
  fi

  if [[ "$require_type" == 'yes' ]]; then
    if [[ -z "$status_value" ]]; then
      error "$file: missing required 'status'"
    elif [[ ! "$status_value" =~ ^(candidate|reviewed|verified|deprecated)$ ]]; then
      error "$file: unsupported lifecycle status '$status_value'"
    fi

    if [[ -z "$confidence_value" ]]; then
      error "$file: missing required 'confidence'"
    elif [[ ! "$confidence_value" =~ ^(low|medium|high)$ ]]; then
      error "$file: unsupported confidence '$confidence_value'"
    fi

    if [[ ! "$review_after_value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      error "$file: missing or invalid required 'review_after'"
    fi

    if [[ "$status_value" == 'verified' &&
      ! "$last_verified_value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      error "$file: verified concept requires a valid 'last_verified'"
    fi
  elif [[ -n "$status_value" &&
    ! "$status_value" =~ ^(candidate|reviewed|verified|deprecated)$ ]]; then
    error "$file: unsupported lifecycle status '$status_value'"
  fi
}

validate_links() {
  local root="$1" file match target clean resolved

  while IFS= read -r -d '' file; do
    while IFS= read -r match; do
      [[ -z "$match" ]] && continue
      target="${match#*(}"
      target="${target%)}"
      case "$target" in
        http://* | https://* | mailto:* | \#*) continue ;;
        /*)
          error "$file: repository links must be relative: $target"
          continue
          ;;
      esac
      clean="${target%%#*}"
      clean="${clean%%\?*}"
      clean="${clean//%20/ }"
      [[ -z "$clean" ]] && continue
      resolved="$(dirname -- "$file")/$clean"
      [[ -e "$resolved" ]] || error "$file: broken relative link: $target"
    done < <(grep -oE '\[[^][]+\]\([^()]+\)' "$file" || true)
  done < <(find "$root" -path "$root/.git" -prune -o -type f -name '*.md' -print0)
}

scan_public_safety() {
  local root="$1" file status review_after today
  local -a files=()

  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(find "$root" -path "$root/.git" -prune -o -type f -print0)

  if ((${#files[@]} == 0)); then
    error "$root: no files to validate"
    return
  fi

  if grep -nHE --binary-files=without-match -e \
    '-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{30,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|(password|passwd|api[_-]?key|access[_-]?token)[[:space:]]*[:=][[:space:]]*[^ <{][^[:space:]]{7,}' \
    "${files[@]}" >/dev/null; then
    error 'high-confidence credential or private-key pattern found'
  fi

  if grep -nHE --binary-files=without-match \
    '/home/(dev|hermes)(/|$)|/opt/agent-share(/|$)' "${files[@]}" >/dev/null; then
    error 'forbidden private absolute path found'
  fi

  if grep -nHE --binary-files=without-match \
    '(^|[^0-9])(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})([^0-9]|$)' \
    "${files[@]}" >/dev/null; then
    error 'private IPv4 literal found'
  fi

  if grep -nHE --binary-files=without-match '/(etc|var|usr|tmp|srv|root|mnt)/[A-Za-z0-9._/-]+' \
    "${files[@]}" | grep -v ':1:#!' >/dev/null; then
    warn 'suspicious unsupported absolute path found'
  fi

  today="$(date -u +%F)"
  while IFS= read -r -d '' file; do
    status="$(sed -nE 's/^status:[[:space:]]*([^[:space:]]+)[[:space:]]*$/\1/p' "$file" | head -1)"
    review_after="$(sed -nE 's/^review_after:[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]*$/\1/p' "$file" | head -1)"
    if [[ -n "$review_after" && "$review_after" < "$today" ]]; then
      warn "$file: review_after expired on $review_after"
    fi
    if [[ "$status" == 'verified' ]] && ! grep -q '^## Citations$' "$file"; then
      warn "$file: verified concept has no Citations section"
    fi
  done < <(find "$root" -maxdepth 2 -type f -name '*.md' \
    ! -name 'README.md' ! -name 'CONTRIBUTING.md' \
    ! -name 'index.md' -print0)
}

validate_repo() {
  local root="$1" file

  errors=0
  warnings=0

  # The former knowledge taxonomy was retired; fail even on dangling links.
  if [[ -e "$root/kb" || -L "$root/kb" ]]; then
    error "$root/kb: retired taxonomy path must not exist"
  fi

  # AGENTS.md is the shared policy topic; source-only rules live in CONTRIBUTING.
  if [[ ! -f "$root/AGENTS.md" || -L "$root/AGENTS.md" ]]; then
    error "$root/AGENTS.md: canonical instructions must be a regular file"
  fi
  if [[ -e "$root/CORE.md" || -L "$root/CORE.md" ]]; then
    error "$root/CORE.md: retired duplicate shared policy must not exist"
  fi
  while IFS= read -r -d '' file; do
    validate_yaml_block "$file" yes
  done < <(find "$root" -maxdepth 1 -type f -name '*.md' \
    ! -name 'README.md' ! -name 'CONTRIBUTING.md' \
    ! -name 'index.md' -print0)

  # Canonical shallow topics are validated without reintroducing a hierarchy.
  local topic
  for topic in aws codex kiro opencode chatgpt tools; do
    [[ -d "$root/$topic" ]] || continue
    if find "$root/$topic" -mindepth 2 -type f -name '*.md' -print -quit | grep -q .; then
      error "$root/$topic: nested topic documents are not allowed"
    fi
    while IFS= read -r -d '' file; do
      validate_yaml_block "$file" yes
    done < <(find "$root/$topic" -maxdepth 1 -type f -name '*.md' -print0)
  done

  # Canonical topics live at the root; retired compatibility paths stay absent.
  if [[ -e "$root/agents" || -L "$root/agents" ]]; then
    error "$root/agents: retired compatibility path must not exist"
  fi

  validate_links "$root"
  scan_public_safety "$root"

  if ((errors > 0)); then
    printf 'FAIL: %d error(s), %d warning(s)\n' "$errors" "$warnings" >&2
    return 1
  fi

  printf 'PASS: 0 errors, %d warning(s)\n' "$warnings"
}

write_fixture() {
  local root="$1" body="$2"
  mkdir -p "$root"
  printf '%s\n' '---' 'type: Policy' 'status: reviewed' 'confidence: high' \
    'review_after: 2999-01-01' '---' '' '# Shared instructions' >"$root/AGENTS.md"
  printf '%s\n' "$body" >"$root/CONTEXT.md"
}

expect_failure() {
  local name="$1" root="$2"
  if "$SELF" "$root" >/dev/null 2>&1; then
    printf 'SELF-TEST FAIL: %s unexpectedly passed\n' "$name" >&2
    return 1
  fi
  printf 'SELF-TEST PASS: %s rejected\n' "$name"
}

self_test() {
  local temp pass case_dir secret_value private_path private_ip
  temp="$(mktemp -d)"
  trap 'if [[ -n "${temp:-}" ]]; then rm -rf -- "$temp"; fi' RETURN
  pass="$temp/pass"

  write_fixture "$pass" $'---\ntype: Practice\ntitle: Valid fixture\nstatus: reviewed\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Valid fixture'
  "$SELF" "$pass" >/dev/null
  printf 'SELF-TEST PASS: valid repository accepted\n'

  case_dir="$temp/missing-agents"
  write_fixture "$case_dir" $'---\ntype: Practice\nstatus: reviewed\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Valid topic'
  rm -- "$case_dir/AGENTS.md"
  expect_failure missing-canonical-agents "$case_dir"

  case_dir="$temp/retired-core"
  write_fixture "$case_dir" $'---\ntype: Practice\nstatus: reviewed\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Valid topic'
  cp -- "$case_dir/AGENTS.md" "$case_dir/CORE.md"
  expect_failure retired-core-policy "$case_dir"

  case_dir="$temp/retired-agents"
  write_fixture "$case_dir" $'---\ntype: Practice\nstatus: reviewed\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Valid concept'
  mkdir "$case_dir/agents"
  expect_failure retired-agents-compatibility "$case_dir"

  case_dir="$temp/warning"
  write_fixture "$case_dir" $'---\ntype: Practice\ntitle: Warning fixture\nstatus: verified\nconfidence: high\nlast_verified: 2000-01-01\nreview_after: 2000-01-01\n---\n\n# Warning fixture'
  "$SELF" "$case_dir" >/dev/null 2>&1
  printf 'SELF-TEST PASS: warnings remain non-fatal\n'

  case_dir="$temp/malformed"
  write_fixture "$case_dir" $'---\ntype Practice\n---\n\n# Bad YAML'
  expect_failure malformed-frontmatter "$case_dir"

  case_dir="$temp/missing-type"
  write_fixture "$case_dir" $'---\ntitle: Missing type\n---\n\n# Missing type'
  expect_failure missing-type "$case_dir"

  case_dir="$temp/broken-link"
  write_fixture "$case_dir" $'---\ntype: Practice\nstatus: reviewed\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Broken\n\n[Missing](missing.md)'
  expect_failure broken-link "$case_dir"

  case_dir="$temp/missing-status"
  write_fixture "$case_dir" $'---\ntype: Practice\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Missing status'
  expect_failure missing-status "$case_dir"

  case_dir="$temp/missing-review-after"
  write_fixture "$case_dir" $'---\ntype: Practice\nstatus: reviewed\nconfidence: high\n---\n\n# Missing review date'
  expect_failure missing-review-after "$case_dir"

  case_dir="$temp/verified-without-last-verified"
  write_fixture "$case_dir" $'---\ntype: Practice\nstatus: verified\nconfidence: high\nreview_after: 2999-01-01\n---\n\n# Missing verification date'
  expect_failure verified-without-last-verified "$case_dir"

  case_dir="$temp/secret"
  secret_value='AKIA'
  secret_value+='ABCDEFGHIJKLMNOP'
  write_fixture "$case_dir" "$(printf '%s\n' '---' 'type: Practice' 'status: reviewed' 'confidence: high' 'review_after: 2999-01-01' '---' '' '# Secret' '' "$secret_value")"
  expect_failure credential-pattern "$case_dir"

  case_dir="$temp/private-path"
  private_path='/home'
  private_path+='/dev/example'
  write_fixture "$case_dir" "$(printf '%s\n' '---' 'type: Practice' 'status: reviewed' 'confidence: high' 'review_after: 2999-01-01' '---' '' '# Path' '' "$private_path")"
  expect_failure private-path "$case_dir"

  case_dir="$temp/private-ip"
  private_ip='192.168'
  private_ip+='.10.20'
  write_fixture "$case_dir" "$(printf '%s\n' '---' 'type: Practice' 'status: reviewed' 'confidence: high' 'review_after: 2999-01-01' '---' '' '# Address' '' "$private_ip")"
  expect_failure private-ip "$case_dir"

  printf 'SELF-TEST PASS: all validator checks behaved as expected\n'
  trap - RETURN
  rm -rf -- "$temp"
}

main() {
  case "${1:-}" in
    --self-test)
      self_test
      ;;
    -h | --help)
      printf 'Usage: %s [--self-test] [repository-root]\n' "${0##*/}"
      ;;
    *)
      validate_repo "${1:-$(cd -- "$(dirname -- "$SELF")/.." && pwd)}"
      ;;
  esac
}

main "$@"
