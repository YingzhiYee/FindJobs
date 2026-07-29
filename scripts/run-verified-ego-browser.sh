#!/bin/bash
set -euo pipefail

RUNNER_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
RUNNER_RESOLVER="$RUNNER_SCRIPT_DIR/resolve-latest-ego-runtime.sh"
RUNNER_TRUSTED_APP_BUNDLE="/Applications/AI product Builder/ego.app"
RUNNER_TRUSTED_APP_EXECUTABLE="$RUNNER_TRUSTED_APP_BUNDLE/Contents/MacOS/ego"

fail() {
  echo "Verified ego-browser launch failed: $1" >&2
  exit 1
}

if [ "$#" -eq 0 ]; then
  fail "provide ego-browser arguments, for example: nodejs"
fi
if [ ! -x "$RUNNER_RESOLVER" ]; then
  fail "the latest-stable runtime resolver is unavailable"
fi

RUNNER_EGO_BROWSER="$($RUNNER_RESOLVER --ego-browser-executable)" ||
  fail "the official latest-stable runtime could not be verified"
case "$RUNNER_EGO_BROWSER" in
  "$RUNNER_TRUSTED_APP_BUNDLE"/Contents/Frameworks/ego\ Framework.framework/Versions/*/Helpers/ego-browser) ;;
  *) fail "the resolver returned an executable outside the trusted app bundle" ;;
esac
if [ ! -x "$RUNNER_EGO_BROWSER" ]; then
  fail "the verified ego-browser executable is unavailable"
fi

collect_ego_main_processes() {
  /bin/ps -axo pid=,command= | awk '
    {
      pid = $1
      $1 = ""
      sub(/^[[:space:]]+/, "")
      command = $0
      lower = tolower(command)
      if (lower ~ /\/ego( lite)?[.]app\/contents\/macos\//) {
        print pid "\t" command
      }
    }
  '
}

RUNNER_EGO_MAIN_PROCESSES="$(collect_ego_main_processes)"
RUNNER_EGO_MAIN_COUNT="$(printf '%s\n' "$RUNNER_EGO_MAIN_PROCESSES" | awk 'NF { count++ } END { print count + 0 }')"
RUNNER_TRUSTED_MAIN_COUNT="$(printf '%s\n' "$RUNNER_EGO_MAIN_PROCESSES" | awk -F '\t' -v expected="$RUNNER_TRUSTED_APP_EXECUTABLE" '
  {
    command = $2
    if (command == expected || index(command, expected " ") == 1) count++
  }
  END { print count + 0 }
')"
if [ "$RUNNER_EGO_MAIN_COUNT" -ne 1 ] || [ "$RUNNER_TRUSTED_MAIN_COUNT" -ne 1 ]; then
  echo "Exactly one ego main process from the trusted /Applications bundle must be running." >&2
  if [ -n "$RUNNER_EGO_MAIN_PROCESSES" ]; then
    printf '%s\n' "$RUNNER_EGO_MAIN_PROCESSES" >&2
  fi
  exit 1
fi

exec "$RUNNER_EGO_BROWSER" "$@"
