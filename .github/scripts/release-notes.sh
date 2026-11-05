#!/usr/bin/env bash
# Prints the CHANGELOG.txt section for a tag as Markdown release notes.
#
# Usage: release-notes.sh <tag> [changelog]
#   e.g. release-notes.sh v3.2.0 > .release-notes.md

set -euo pipefail

tag="${1:?usage: release-notes.sh <tag> [changelog]}"
changelog="${2:-CHANGELOG.txt}"

prerelease=
[[ ${tag,,} == *alpha* || ${tag,,} == *beta* ]] && prerelease=1

# Betas and alphas ship what is under "- Unreleased"; full releases have their own heading
heading="- $tag"
[[ -n $prerelease ]] && heading="- Unreleased"

# CHANGELOG.txt layout:
#   - v3.2.0              <- version heading (older ones may end in " - <date>")
#     - Fixed             <- group, becomes "## Fixed"
#       - Some fix        <- entry, becomes "- Some fix"
notes=$(tr -d '\r' < "$changelog" | awk -v heading="$heading" '
    $0 == heading || index($0, heading " ") == 1 { found = 1; next }
    found && /^- / { exit }
    found && /^  - / { sub(/^  - /, "## "); print; next }
    found && /^    / { sub(/^    /, ""); print; next }
')

if [[ -z "$notes" ]]; then
    echo "No entries for $tag in $changelog. Add them under \"$heading\" before releasing." >&2
    exit 1
fi

printf '%s\n' "$notes"

# Link the commits since the previous release, skipping betas when this is a full release
if [[ -n $prerelease ]]; then
    exclude=(--exclude='*[Aa][Ll][Pp][Hh][Aa]*')
else
    exclude=(--exclude='*[Aa][Ll][Pp][Hh][Aa]*' --exclude='*[Bb][Ee][Tt][Aa]*')
fi
previous=$(git describe --tags --abbrev=0 "${exclude[@]}" "$tag~" 2>/dev/null || true)

if [[ -n "$previous" && -n "${GITHUB_REPOSITORY:-}" ]]; then
    printf '\n**Full Changelog**: %s/%s/compare/%s...%s\n' \
        "${GITHUB_SERVER_URL:-https://github.com}" "$GITHUB_REPOSITORY" "$previous" "$tag"
fi
