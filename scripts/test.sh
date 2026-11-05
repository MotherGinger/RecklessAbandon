#!/usr/bin/env bash
# Runs the busted suite, then luacheck. Run from the repository root (on Windows, inside WSL:
# `wsl -e bash scripts/test.sh`). Full output goes to log files; only a summary is printed.
cd "$(dirname "$0")/.." || exit 1
log=${TMPDIR:-/tmp}/recklessabandon-busted.log
lint=${TMPDIR:-/tmp}/recklessabandon-luacheck.log
status=0

busted -o utfTerminal > "$log" 2>&1 || status=1
grep -E '[0-9]+ successes' "$log" | sed 's/\x1b\[[0-9;]*m//g'
grep -A8 'Failure →\|Error →' "$log" | sed 's/\x1b\[[0-9;]*m//g' | head -60

luacheck RecklessAbandon spec > "$lint" 2>&1 || status=1
grep -B1 -E '^\s+\S+:[0-9]+:[0-9]+:' "$lint" | sed 's/\x1b\[[0-9;]*m//g' | head -40
tail -1 "$lint" | sed 's/\x1b\[[0-9;]*m//g'

exit $status
