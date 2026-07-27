#!/bin/bash
set -euo pipefail

TRUSTED_APP_BUNDLE="/Applications/AI product Builder/ego.app"
TRUSTED_APP_EXECUTABLE="$TRUSTED_APP_BUNDLE/Contents/MacOS/ego"
TRUSTED_BUNDLE_IDENTIFIER="com.citrolabs.ego"
TRUSTED_TEAM_IDENTIFIER="JGQLC6YQYJ"
TRUSTED_DESIGNATED_REQUIREMENT='identifier "com.citrolabs.ego" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = JGQLC6YQYJ'
TRUSTED_UPDATE_URL="https://update.citrolabs.ai/service/update2"
TRUSTED_SKILL_REPOSITORY="https://github.com/citrolabs/ego-lite"
TRUSTED_LATEST_RELEASE="$TRUSTED_SKILL_REPOSITORY/releases/latest"
OUTPUT_MODE="human"
RUNTIME_TMP_DIR=""

fail() {
  echo "Latest ego runtime verification failed: $1" >&2
  exit 1
}

cleanup() {
  if [ -n "$RUNTIME_TMP_DIR" ] && [ -d "$RUNTIME_TMP_DIR" ]; then
    if [ -f "$RUNTIME_TMP_DIR/ego-browser.zip" ]; then
      /bin/rm "$RUNTIME_TMP_DIR/ego-browser.zip"
    fi
    /bin/rmdir "$RUNTIME_TMP_DIR" 2>/dev/null || true
  fi
}

trap cleanup EXIT

case "$#" in
  0) ;;
  1)
    if [ "$1" != "--tsv" ]; then
      fail "the only supported option is --tsv"
    fi
    OUTPUT_MODE="tsv"
    ;;
  *) fail "unexpected arguments" ;;
esac

if [ "$(uname -s)" != "Darwin" ]; then
  fail "macOS is required"
fi

for RUNTIME_COMMAND in curl unzip shasum awk grep sed; do
  if ! command -v "$RUNTIME_COMMAND" >/dev/null 2>&1; then
    fail "missing required command: $RUNTIME_COMMAND"
  fi
done

if [ ! -x "$TRUSTED_APP_EXECUTABLE" ]; then
  fail "the trusted /Applications executable is missing"
fi
RUNTIME_INFO_PLIST="$TRUSTED_APP_BUNDLE/Contents/Info.plist"
RUNTIME_BUNDLE_IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$RUNTIME_INFO_PLIST")"
RUNTIME_APP_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$RUNTIME_INFO_PLIST")"
RUNTIME_BUNDLE_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$RUNTIME_INFO_PLIST")"
RUNTIME_UPDATE_PRODUCT="$(/usr/libexec/PlistBuddy -c 'Print :KSProductID' "$RUNTIME_INFO_PLIST")"
RUNTIME_UPDATE_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :KSVersion' "$RUNTIME_INFO_PLIST")"
RUNTIME_UPDATE_URL="$(/usr/libexec/PlistBuddy -c 'Print :KSUpdateURL' "$RUNTIME_INFO_PLIST")"

if [ "$RUNTIME_BUNDLE_IDENTIFIER" != "$TRUSTED_BUNDLE_IDENTIFIER" ] ||
   [ "$RUNTIME_UPDATE_PRODUCT" != "$TRUSTED_BUNDLE_IDENTIFIER" ] ||
   [ "$RUNTIME_UPDATE_VERSION" != "$RUNTIME_APP_VERSION" ] ||
   [ "$RUNTIME_UPDATE_URL" != "$TRUSTED_UPDATE_URL" ]; then
  fail "bundle metadata or the official updater identity changed"
fi
if ! printf '%s\n' "$RUNTIME_APP_VERSION" | grep -Eq '^[0-9]+([.][0-9]+){2,3}$' ||
   ! printf '%s\n' "$RUNTIME_BUNDLE_VERSION" | grep -Eq '^[0-9]+([.][0-9]+){2,3}$'; then
  fail "bundle versions are not strict numeric versions"
fi

RUNTIME_ACTIVE_VERSION_DIR="$TRUSTED_APP_BUNDLE/Contents/Frameworks/ego Framework.framework/Versions/$RUNTIME_APP_VERSION"
if [ ! -d "$RUNTIME_ACTIVE_VERSION_DIR" ]; then
  fail "the version declared by the /Applications bundle is missing from its framework"
fi

RUNTIME_CODESIGN_DETAIL="$(/usr/bin/codesign -dv --verbose=6 "$TRUSTED_APP_BUNDLE" 2>&1)"
if ! printf '%s\n' "$RUNTIME_CODESIGN_DETAIL" | grep -Fqx "Identifier=$TRUSTED_BUNDLE_IDENTIFIER" ||
   ! printf '%s\n' "$RUNTIME_CODESIGN_DETAIL" | grep -Fqx "TeamIdentifier=$TRUSTED_TEAM_IDENTIFIER"; then
  fail "the Apple signing identity changed"
fi
RUNTIME_CODE_DIRECTORY_SHA256="$(printf '%s\n' "$RUNTIME_CODESIGN_DETAIL" | sed -n 's/^CandidateCDHashFull sha256=//p' | tail -1)"
if ! printf '%s\n' "$RUNTIME_CODE_DIRECTORY_SHA256" | grep -Eq '^[0-9a-f]{64}$'; then
  fail "the full code-directory SHA-256 is unavailable"
fi
if ! /usr/bin/codesign --verify -R "=$TRUSTED_DESIGNATED_REQUIREMENT" "$TRUSTED_APP_BUNDLE" >/dev/null 2>&1; then
  fail "the app does not satisfy the trusted designated requirement"
fi

RUNTIME_GATEKEEPER="$(/usr/sbin/spctl -a -vv -t execute "$TRUSTED_APP_BUNDLE" 2>&1)"
if ! printf '%s\n' "$RUNTIME_GATEKEEPER" | grep -Fqx "$TRUSTED_APP_BUNDLE: accepted" ||
   ! printf '%s\n' "$RUNTIME_GATEKEEPER" | grep -Fqx 'source=Notarized Developer ID'; then
  fail "Gatekeeper did not accept a notarized Developer ID build"
fi

RUNTIME_EXECUTABLE_SHA256="$(shasum -a 256 "$TRUSTED_APP_EXECUTABLE" | awk '{print $1}')"
RUNTIME_SKILL="$RUNTIME_ACTIVE_VERSION_DIR/Resources/ego-skills/ego-browser/SKILL.md"
RUNTIME_EGO_BROWSER="$RUNTIME_ACTIVE_VERSION_DIR/Helpers/ego-browser"
if [ ! -f "$RUNTIME_SKILL" ]; then
  fail "the active runtime does not contain ego-browser/SKILL.md"
fi
if [ ! -x "$RUNTIME_EGO_BROWSER" ]; then
  fail "the /Applications runtime does not contain an executable ego-browser CLI"
fi

read_skill_metadata() {
  awk '
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && /^[[:space:]]+version:[[:space:]]*/ {
      line = $0
      sub(/^[[:space:]]+version:[[:space:]]*/, "", line)
      gsub(/^"|"$/, "", line)
      version = line
    }
    in_frontmatter && /^[[:space:]]+date:[[:space:]]*/ {
      line = $0
      sub(/^[[:space:]]+date:[[:space:]]*/, "", line)
      gsub(/^"|"$/, "", line)
      date = line
    }
    END {
      if (version == "" || date == "") exit 1
      print version "\t" date
    }
  '
}

RUNTIME_SKILL_METADATA="$(read_skill_metadata < "$RUNTIME_SKILL")" || fail "installed skill metadata is invalid"
IFS=$'\t' read -r RUNTIME_SKILL_VERSION RUNTIME_SKILL_DATE <<< "$RUNTIME_SKILL_METADATA"
RUNTIME_SKILL_SHA256="$(shasum -a 256 "$RUNTIME_SKILL" | awk '{print $1}')"

RUNTIME_LATEST_URL="$(curl -fsSL --retry 3 --retry-all-errors --retry-delay 1 --max-time 30 -o /dev/null -w '%{url_effective}' "$TRUSTED_LATEST_RELEASE")" ||
  fail "the official latest stable release could not be resolved"
RUNTIME_LATEST_URL="${RUNTIME_LATEST_URL%%\?*}"
RUNTIME_LATEST_URL="${RUNTIME_LATEST_URL%/}"
case "$RUNTIME_LATEST_URL" in
  "$TRUSTED_SKILL_REPOSITORY"/releases/tag/v*) ;;
  *) fail "the latest release redirected outside the trusted repository" ;;
esac
RUNTIME_RELEASE_TAG="${RUNTIME_LATEST_URL##*/}"
RUNTIME_RELEASE_VERSION="${RUNTIME_RELEASE_TAG#v}"
if ! printf '%s\n' "$RUNTIME_RELEASE_TAG" | grep -Eq '^v[0-9]+([.][0-9]+){2}$'; then
  fail "the latest GitHub release is not a stable semantic version"
fi
if [ "$RUNTIME_SKILL_VERSION" != "$RUNTIME_RELEASE_VERSION" ]; then
  fail "the installed skill is $RUNTIME_SKILL_VERSION but the official stable release is $RUNTIME_RELEASE_VERSION; let ego finish updating"
fi

RUNTIME_ASSET_NAME="ego-browser-$RUNTIME_RELEASE_TAG.zip"
RUNTIME_ASSET_PATH="/citrolabs/ego-lite/releases/download/$RUNTIME_RELEASE_TAG/$RUNTIME_ASSET_NAME"
RUNTIME_ASSETS_HTML="$(curl -fsSL --retry 3 --retry-all-errors --retry-delay 1 --max-time 30 "$TRUSTED_SKILL_REPOSITORY/releases/expanded_assets/$RUNTIME_RELEASE_TAG")" ||
  fail "the official release assets could not be read"
if [ "$(printf '%s\n' "$RUNTIME_ASSETS_HTML" | grep -Fc "$RUNTIME_ASSET_PATH")" -ne 1 ]; then
  fail "the official release does not contain exactly one expected ego-browser asset"
fi
RUNTIME_ASSET_SHA256="$(printf '%s\n' "$RUNTIME_ASSETS_HTML" | awk -v asset="$RUNTIME_ASSET_NAME" '
  index($0, ">" asset "<") { in_asset = 1; next }
  in_asset && match($0, /sha256:[0-9a-f]+/) {
    digest = substr($0, RSTART + 7, RLENGTH - 7)
    print digest
    exit
  }
')"
if ! printf '%s\n' "$RUNTIME_ASSET_SHA256" | grep -Eq '^[0-9a-f]{64}$'; then
  fail "the official release asset SHA-256 is missing or malformed"
fi

RUNTIME_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/findjobs-ego-runtime.XXXXXX")"
RUNTIME_ASSET_FILE="$RUNTIME_TMP_DIR/ego-browser.zip"
curl -fsSL --retry 3 --retry-all-errors --retry-delay 1 --max-time 60 -o "$RUNTIME_ASSET_FILE" \
  "https://github.com$RUNTIME_ASSET_PATH" || fail "the official release asset download failed"
if [ "$(shasum -a 256 "$RUNTIME_ASSET_FILE" | awk '{print $1}')" != "$RUNTIME_ASSET_SHA256" ]; then
  fail "the downloaded release asset digest does not match GitHub's digest"
fi
if [ "$(unzip -Z1 "$RUNTIME_ASSET_FILE" | grep -Fxc 'ego-browser/SKILL.md')" -ne 1 ]; then
  fail "the release asset does not contain exactly one ego-browser/SKILL.md"
fi

RUNTIME_RELEASE_SKILL_METADATA="$(unzip -p "$RUNTIME_ASSET_FILE" 'ego-browser/SKILL.md' | read_skill_metadata)" ||
  fail "release skill metadata is invalid"
IFS=$'\t' read -r RUNTIME_RELEASE_SKILL_VERSION RUNTIME_RELEASE_SKILL_DATE <<< "$RUNTIME_RELEASE_SKILL_METADATA"
RUNTIME_RELEASE_SKILL_SHA256="$(unzip -p "$RUNTIME_ASSET_FILE" 'ego-browser/SKILL.md' | shasum -a 256 | awk '{print $1}')"
if [ "$RUNTIME_RELEASE_SKILL_VERSION" != "$RUNTIME_SKILL_VERSION" ] ||
   [ "$RUNTIME_RELEASE_SKILL_DATE" != "$RUNTIME_SKILL_DATE" ] ||
   [ "$RUNTIME_RELEASE_SKILL_SHA256" != "$RUNTIME_SKILL_SHA256" ]; then
  fail "the signed app's skill does not exactly match the official latest release"
fi

if [ "$OUTPUT_MODE" = "tsv" ]; then
  printf 'ready\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$RUNTIME_APP_VERSION" \
    "$RUNTIME_BUNDLE_VERSION" \
    "$RUNTIME_CODE_DIRECTORY_SHA256" \
    "$RUNTIME_EXECUTABLE_SHA256" \
    "$RUNTIME_SKILL_VERSION" \
    "$RUNTIME_SKILL_DATE" \
    "$RUNTIME_SKILL_SHA256" \
    "$RUNTIME_ASSET_SHA256" \
    "$RUNTIME_RELEASE_TAG"
else
  printf '%s\n' \
    'status: ready' \
    "appVersion: $RUNTIME_APP_VERSION" \
    "bundleVersion: $RUNTIME_BUNDLE_VERSION" \
    "skillRelease: $RUNTIME_RELEASE_TAG" \
    "skillVersion: $RUNTIME_SKILL_VERSION" \
    "skillDate: $RUNTIME_SKILL_DATE" \
    "skillSha256: $RUNTIME_SKILL_SHA256" \
    "runtimeSkillPath: $RUNTIME_SKILL" \
    "egoBrowserExecutable: $RUNTIME_EGO_BROWSER" \
    'realFillEnabled: false' \
    'realSubmitEnabled: false'
fi
