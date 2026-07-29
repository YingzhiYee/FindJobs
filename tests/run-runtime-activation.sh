#!/bin/bash
set -euo pipefail

TEST_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TEST_REPO_DIR="$(cd "$TEST_SCRIPT_DIR/.." && pwd -P)"
TEST_RESOLVER="$TEST_REPO_DIR/scripts/resolve-latest-ego-runtime.sh"
TEST_RUNNER="$TEST_REPO_DIR/scripts/run-verified-ego-browser.sh"
TEST_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/findjobs-runtime-activation.XXXXXX")"

cleanup() {
  if [ -L "$TEST_TMP_DIR/ego-browser" ]; then
    /bin/rm "$TEST_TMP_DIR/ego-browser"
  fi
  /bin/rmdir "$TEST_TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

for TEST_REQUIRED in "$TEST_RESOLVER" "$TEST_RUNNER"; do
  if [ ! -x "$TEST_REQUIRED" ]; then
    echo "Runtime activation test requires an executable: $TEST_REQUIRED" >&2
    exit 1
  fi
done

TEST_VERIFIED_CLI="$($TEST_RESOLVER --ego-browser-executable)"
case "$TEST_VERIFIED_CLI" in
  /Applications/AI\ product\ Builder/ego.app/Contents/Frameworks/ego\ Framework.framework/Versions/*/Helpers/ego-browser) ;;
  *) echo "Resolver returned an unexpected CLI path: $TEST_VERIFIED_CLI" >&2; exit 1 ;;
esac

/bin/ln -s /usr/bin/false "$TEST_TMP_DIR/ego-browser"
if [ "$(PATH="$TEST_TMP_DIR:$PATH" command -v ego-browser)" != "$TEST_TMP_DIR/ego-browser" ]; then
  echo "The adversarial PATH shadow was not activated." >&2
  exit 1
fi

PATH="$TEST_TMP_DIR:$PATH" "$TEST_RUNNER" nodejs <<'EOF'
const task = await taskSpaces.useOrCreate('findjobs verified runtime activation')
const tabs = await browser.listTabs({ includeChrome: false })
const completion = await taskSpaces.complete(task.id, { keep: false })
if (!completion.done) throw new Error('Task space cleanup failed: ' + JSON.stringify(completion))
console.log(JSON.stringify({
  status: 'passed',
  pathShadowIgnored: true,
  taskSpacesAvailable: true,
  taskSpaceId: task.id,
  openTabCount: tabs.length,
  noWebsiteOpened: true,
}, null, 2))
EOF
