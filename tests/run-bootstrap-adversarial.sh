#!/bin/bash
set -euo pipefail

BOOTSTRAP_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BOOTSTRAP_REPO_DIR="$(cd "$BOOTSTRAP_SCRIPT_DIR/.." && pwd -P)"
BOOTSTRAP_REMOTE="https://github.com/YingzhiYee/FindJobs.git"
BOOTSTRAP_COMMIT="$(git -C "$BOOTSTRAP_REPO_DIR" rev-parse --verify HEAD)"
BOOTSTRAP_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/findjobs-bootstrap.XXXXXX")"

cleanup() {
  chmod -R u+w "$BOOTSTRAP_TMP_DIR" 2>/dev/null || true
  /bin/rm -rf "$BOOTSTRAP_TMP_DIR"
}
trap cleanup EXIT

if ! printf '%s\n' "$BOOTSTRAP_COMMIT" | grep -Eq '^[0-9a-f]{40}$'; then
  echo "Bootstrap source commit is not a full SHA-1." >&2
  exit 1
fi

chmod 700 "$BOOTSTRAP_TMP_DIR"
git -C "$BOOTSTRAP_TMP_DIR" init --quiet
git -C "$BOOTSTRAP_TMP_DIR" remote add origin "$BOOTSTRAP_REMOTE"
git -C "$BOOTSTRAP_TMP_DIR" fetch --quiet --depth=1 origin "$BOOTSTRAP_COMMIT"
git -C "$BOOTSTRAP_TMP_DIR" checkout --quiet --detach FETCH_HEAD

BOOTSTRAP_OBSERVED_HEAD="$(git -C "$BOOTSTRAP_TMP_DIR" rev-parse HEAD)"
BOOTSTRAP_OBSERVED_REMOTE="$(git -C "$BOOTSTRAP_TMP_DIR" remote get-url origin)"
if [ "$BOOTSTRAP_OBSERVED_HEAD" != "$BOOTSTRAP_COMMIT" ] ||
   [ "$BOOTSTRAP_OBSERVED_REMOTE" != "$BOOTSTRAP_REMOTE" ]; then
  echo "Bootstrap remote or commit mismatch." >&2
  exit 1
fi
if git -C "$BOOTSTRAP_TMP_DIR" symbolic-ref -q HEAD >/dev/null; then
  echo "Bootstrap checkout unexpectedly follows a branch." >&2
  exit 1
fi
if [ "$(git -C "$BOOTSTRAP_TMP_DIR" remote | wc -l | tr -d ' ')" != "1" ]; then
  echo "Bootstrap checkout contains an unexpected remote." >&2
  exit 1
fi
for BOOTSTRAP_REQUIRED in README.md START_PROMPT.md tests/acceptance-report.md skills/find-my-dream-job/SKILL.md; do
  if [ ! -f "$BOOTSTRAP_TMP_DIR/$BOOTSTRAP_REQUIRED" ]; then
    echo "Bootstrap checkout is missing $BOOTSTRAP_REQUIRED" >&2
    exit 1
  fi
done

printf '{\n  "status": "passed",\n  "officialRemote": true,\n  "fullCommitMatched": true,\n  "detachedHead": true,\n  "blankWorkspace": true\n}\n'
