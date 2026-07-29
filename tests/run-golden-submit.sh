#!/bin/bash
set -euo pipefail

EXPECTED_APP_BUNDLE="/Applications/AI product Builder/ego.app"
EXPECTED_APP_EXECUTABLE="/Applications/AI product Builder/ego.app/Contents/MacOS/ego"
EXPECTED_BUNDLE_IDENTIFIER="com.citrolabs.ego"
EXPECTED_TEAM_IDENTIFIER="JGQLC6YQYJ"
EXPECTED_DESIGNATED_REQUIREMENT='identifier "com.citrolabs.ego" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = JGQLC6YQYJ'
EXPECTED_RELEASE="0.4.0-beta.2"
EXPECTED_FORM_SHA256="c6274b6b8ad23e07f8ce375ab15620dcf7312afd2bbe97668cd4ba16892ef237"
EXPECTED_FIELDS_SHA256="715dd35a13276af55b6a9f178378876e8a3c5929568912be145ad9e9e1e4b2da"
EXPECTED_RESUME_SHA256="7757555e6d835dd0636ec4064fbecdef881a65e4ab3209ccd670f02d483c3f0e"
HARNESS_PORT="18765"
HARNESS_HOST="127.0.0.1"

if [ "$#" -ne 0 ]; then
  echo "This maintainer harness accepts no URLs, paths, field values, or other arguments." >&2
  exit 2
fi

HARNESS_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
HARNESS_REPO_DIR="$(cd "$HARNESS_SCRIPT_DIR/.." && pwd -P)"
HARNESS_FIXTURE_DIR="$HARNESS_REPO_DIR/tests/fixtures"
HARNESS_FORM="$HARNESS_FIXTURE_DIR/application-form.html"
HARNESS_FIELDS="$HARNESS_FIXTURE_DIR/application-fake-fields.json"
HARNESS_RESUME="$HARNESS_FIXTURE_DIR/application-fake-resume.txt"
HARNESS_LOCK="$HARNESS_REPO_DIR/config/skills.lock.yaml"
HARNESS_ACCEPTANCE_REPORT="$HARNESS_REPO_DIR/tests/acceptance-report.md"
HARNESS_RUNTIME_RESOLVER="$HARNESS_REPO_DIR/scripts/resolve-latest-ego-runtime.sh"
if [ ! -x "$HARNESS_RUNTIME_RESOLVER" ]; then
  echo "The latest stable ego runtime resolver is missing or not executable." >&2
  exit 1
fi
HARNESS_RUNTIME_IDENTITY="$($HARNESS_RUNTIME_RESOLVER --tsv)"
IFS=$'\t' read -r HARNESS_RUNTIME_READY \
  EXPECTED_EGO_LITE_VERSION \
  EXPECTED_BUNDLE_VERSION \
  EXPECTED_CODE_DIRECTORY_SHA256 \
  EXPECTED_EXECUTABLE_SHA256 \
  EXPECTED_SKILL_VERSION \
  EXPECTED_SKILL_DATE \
  EXPECTED_SKILL_SHA256 \
  EXPECTED_SKILL_ASSET_SHA256 \
  EXPECTED_SKILL_RELEASE_TAG <<< "$HARNESS_RUNTIME_IDENTITY"
if [ "$HARNESS_RUNTIME_READY" != "ready" ]; then
  echo "The latest stable ego runtime resolver did not return ready." >&2
  exit 1
fi

HARNESS_TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/findjobs-golden-submit.XXXXXX")"
HARNESS_LEDGER_DIR="$HARNESS_TMP_DIR/ledger"
HARNESS_SERVER_LOG="$HARNESS_TMP_DIR/server.log"
HARNESS_RESULT="$HARNESS_TMP_DIR/result.json"
HARNESS_SERVER_PID=""

stop_server() {
  if [ -n "$HARNESS_SERVER_PID" ] && kill -0 "$HARNESS_SERVER_PID" 2>/dev/null; then
    kill "$HARNESS_SERVER_PID" 2>/dev/null || true
    wait "$HARNESS_SERVER_PID" 2>/dev/null || true
  fi
  HARNESS_SERVER_PID=""
}

on_exit() {
  HARNESS_EXIT_STATUS=$?
  stop_server
  if [ "$HARNESS_EXIT_STATUS" -ne 0 ]; then
    echo "Golden submit harness failed. Diagnostic files: $HARNESS_TMP_DIR" >&2
  fi
  exit "$HARNESS_EXIT_STATUS"
}

trap on_exit EXIT
trap 'exit 130' INT TERM

for HARNESS_REQUIRED_FILE in "$HARNESS_FORM" "$HARNESS_FIELDS" "$HARNESS_RESUME" "$HARNESS_LOCK" "$HARNESS_ACCEPTANCE_REPORT" "$HARNESS_RUNTIME_RESOLVER"; do
  if [ ! -f "$HARNESS_REQUIRED_FILE" ]; then
    echo "Missing controlled harness file: $HARNESS_REQUIRED_FILE" >&2
    exit 1
  fi
done

HARNESS_PINNED_FILES=(
  "tests/run-golden-submit.sh"
  "tests/fixtures/application-form.html"
  "tests/fixtures/application-fake-fields.json"
  "tests/fixtures/application-fake-resume.txt"
  "tests/acceptance-report.md"
  "tests/golden-submit-runbook.md"
  "config/skills.lock.yaml"
  "scripts/resolve-latest-ego-runtime.sh"
  "policies/security.md"
  "skills/find-my-dream-job/references/application-ledger.md"
)
if ! command -v git >/dev/null 2>&1 || ! git -C "$HARNESS_REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "The controlled harness must run from a Git checkout." >&2
  exit 1
fi
HARNESS_SOURCE_COMMIT="$(git -C "$HARNESS_REPO_DIR" rev-parse --verify HEAD)"
if ! printf '%s\n' "$HARNESS_SOURCE_COMMIT" | grep -Eq '^[0-9a-f]{40}$'; then
  echo "The controlled harness could not resolve a full source commit." >&2
  exit 1
fi
for HARNESS_PINNED_FILE in "${HARNESS_PINNED_FILES[@]}"; do
  if ! git -C "$HARNESS_REPO_DIR" ls-files --error-unmatch -- "$HARNESS_PINNED_FILE" >/dev/null 2>&1; then
    echo "Controlled harness input is not tracked by the source commit: $HARNESS_PINNED_FILE" >&2
    exit 1
  fi
done
if ! git -C "$HARNESS_REPO_DIR" diff --quiet -- "${HARNESS_PINNED_FILES[@]}" ||
   ! git -C "$HARNESS_REPO_DIR" diff --cached --quiet -- "${HARNESS_PINNED_FILES[@]}"; then
  echo "Controlled harness inputs differ from source commit $HARNESS_SOURCE_COMMIT." >&2
  exit 1
fi

if ! awk -v expected_release="$EXPECTED_RELEASE" '
  /^## Authoritative release status[[:space:]]*$/ { in_authority = 1; next }
  in_authority && /^## / { in_authority = 0; in_yaml = 0 }
  in_authority && /^\`\`\`yaml[[:space:]]*$/ { yaml_blocks++; in_yaml = 1; next }
  in_yaml && /^\`\`\`[[:space:]]*$/ { in_yaml = 0; next }
  in_yaml && /^[[:space:]]*release:/ {
    release_total++
    line = $0
    sub(/^[[:space:]]*release:[[:space:]]*/, "", line)
    if (line == expected_release) release_exact++
  }
  in_yaml && /^[[:space:]]*controlledFixtureFillEnabled:/ {
    controlled_fill_total++
    if ($0 ~ /^[[:space:]]*controlledFixtureFillEnabled:[[:space:]]*true[[:space:]]*$/) controlled_fill_true++
  }
  in_yaml && /^[[:space:]]*controlledFixtureSubmitEnabled:/ {
    controlled_submit_total++
    if ($0 ~ /^[[:space:]]*controlledFixtureSubmitEnabled:[[:space:]]*true[[:space:]]*$/) controlled_submit_true++
  }
  in_yaml && /^[[:space:]]*realFillEnabled:/ {
    real_fill_total++
    if ($0 ~ /^[[:space:]]*realFillEnabled:[[:space:]]*false[[:space:]]*$/) real_fill_false++
  }
  in_yaml && /^[[:space:]]*realSubmitEnabled:/ {
    real_submit_total++
    if ($0 ~ /^[[:space:]]*realSubmitEnabled:[[:space:]]*false[[:space:]]*$/) real_submit_false++
  }
  END {
    allowed = yaml_blocks == 1 && release_total == 1 && release_exact == 1 &&
              controlled_fill_total == 1 && controlled_fill_true == 1 &&
              controlled_submit_total == 1 && controlled_submit_true == 1 &&
              real_fill_total == 1 && real_fill_false == 1 &&
              real_submit_total == 1 && real_submit_false == 1
    exit(allowed ? 0 : 1)
  }
' "$HARNESS_ACCEPTANCE_REPORT"; then
  echo "Acceptance report does not enable controlled fixture Fill/Submit while disabling real Fill/Submit." >&2
  exit 1
fi

case "$HARNESS_FORM" in
  "$HARNESS_REPO_DIR"/tests/fixtures/application-form.html) ;;
  *) echo "Fixture path escaped the fixed repository target." >&2; exit 1 ;;
esac
case "$HARNESS_FIELDS" in
  "$HARNESS_FIXTURE_DIR"/application-fake-*) ;;
  *) echo "Harness field data must use only application-fake-* fixtures." >&2; exit 1 ;;
esac
case "$HARNESS_RESUME" in
  "$HARNESS_FIXTURE_DIR"/application-fake-*) ;;
  *) echo "Harness resume must use only application-fake-* fixtures." >&2; exit 1 ;;
esac

if [ ! -x /usr/bin/python3 ] || [ ! -x /usr/bin/curl ] || ! command -v shasum >/dev/null 2>&1; then
  echo "The harness requires only macOS system tools: python3, curl, and shasum." >&2
  exit 1
fi
if [ "$(shasum -a 256 "$HARNESS_FORM" | awk '{print $1}')" != "$EXPECTED_FORM_SHA256" ] ||
   [ "$(shasum -a 256 "$HARNESS_FIELDS" | awk '{print $1}')" != "$EXPECTED_FIELDS_SHA256" ] ||
   [ "$(shasum -a 256 "$HARNESS_RESUME" | awk '{print $1}')" != "$EXPECTED_RESUME_SHA256" ]; then
  echo "Controlled fixture hashes do not match the reviewed commit-pinned inputs." >&2
  exit 1
fi

HARNESS_ACTIVE_VERSION_DIR="$EXPECTED_APP_BUNDLE/Contents/Frameworks/ego Framework.framework/Versions/$EXPECTED_EGO_LITE_VERSION"
if [ ! -d "$HARNESS_ACTIVE_VERSION_DIR" ]; then
  echo "The latest /Applications runtime is missing from the reviewed app bundle." >&2
  exit 1
fi

if [ ! -x "$EXPECTED_APP_EXECUTABLE" ]; then
  echo "Reviewed ego(lite) executable is missing." >&2
  exit 1
fi
if [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$EXPECTED_APP_BUNDLE/Contents/Info.plist")" != "$EXPECTED_BUNDLE_IDENTIFIER" ] || \
   [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$EXPECTED_APP_BUNDLE/Contents/Info.plist")" != "$EXPECTED_EGO_LITE_VERSION" ] || \
   [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$EXPECTED_APP_BUNDLE/Contents/Info.plist")" != "$EXPECTED_BUNDLE_VERSION" ]; then
  echo "ego(lite) bundle metadata does not match the reviewed tuple." >&2
  exit 1
fi
HARNESS_CODESIGN_DETAIL="$(/usr/bin/codesign -dv --verbose=6 "$EXPECTED_APP_BUNDLE" 2>&1)"
if ! printf '%s\n' "$HARNESS_CODESIGN_DETAIL" | grep -Fqx "Identifier=$EXPECTED_BUNDLE_IDENTIFIER" || \
   ! printf '%s\n' "$HARNESS_CODESIGN_DETAIL" | grep -Fqx "TeamIdentifier=$EXPECTED_TEAM_IDENTIFIER" || \
   ! printf '%s\n' "$HARNESS_CODESIGN_DETAIL" | grep -Fqx "CandidateCDHashFull sha256=$EXPECTED_CODE_DIRECTORY_SHA256"; then
  echo "ego(lite) signing identity does not match the reviewed tuple." >&2
  exit 1
fi
if ! /usr/bin/codesign --verify -R "=$EXPECTED_DESIGNATED_REQUIREMENT" "$EXPECTED_APP_BUNDLE" >/dev/null 2>&1; then
  echo "ego(lite) is not valid on disk or does not satisfy the reviewed designated requirement." >&2
  exit 1
fi
if [ "$(shasum -a 256 "$EXPECTED_APP_EXECUTABLE" | awk '{print $1}')" != "$EXPECTED_EXECUTABLE_SHA256" ]; then
  echo "ego(lite) executable hash does not match the reviewed tuple." >&2
  exit 1
fi
HARNESS_GATEKEEPER="$(/usr/sbin/spctl -a -vv -t execute "$EXPECTED_APP_BUNDLE" 2>&1)"
if ! printf '%s\n' "$HARNESS_GATEKEEPER" | grep -Fqx "$EXPECTED_APP_BUNDLE: accepted" || \
   ! printf '%s\n' "$HARNESS_GATEKEEPER" | grep -Fqx 'source=Notarized Developer ID'; then
  echo "ego(lite) Gatekeeper result does not match the reviewed tuple." >&2
  exit 1
fi
HARNESS_SKILL="$HARNESS_ACTIVE_VERSION_DIR/Resources/ego-skills/ego-browser/SKILL.md"
if [ ! -f "$HARNESS_SKILL" ]; then
  echo "Reviewed ego-browser skill is missing from the active runtime." >&2
  exit 1
fi
HARNESS_SKILL_SHA256="$(shasum -a 256 "$HARNESS_SKILL" | awk '{print $1}')"
if [ "$HARNESS_SKILL_SHA256" != "$EXPECTED_SKILL_SHA256" ]; then
  echo "ego-browser skill hash mismatch; browser work is blocked." >&2
  exit 1
fi
if ! grep -Fqx "  version: \"$EXPECTED_SKILL_VERSION\"" "$HARNESS_SKILL" || \
   ! grep -Fqx "  date: \"$EXPECTED_SKILL_DATE\"" "$HARNESS_SKILL"; then
  echo "ego-browser skill metadata does not match the reviewed tuple." >&2
  exit 1
fi

if ! awk '
  /^[[:space:]]+match:[[:space:]]+latest-official-stable-signed-runtime[[:space:]]*$/ { match_policy++ }
  /^[[:space:]]+update:[[:space:]]+resolve-official-latest-at-runtime[[:space:]]*$/ { update_policy++ }
  /^[[:space:]]+resolver:[[:space:]]+scripts\/resolve-latest-ego-runtime[.]sh[[:space:]]*$/ { resolver++ }
  /^[[:space:]]+appBundlePath:[[:space:]]+\/Applications\/AI product Builder\/ego[.]app[[:space:]]*$/ { app_path++ }
  /^[[:space:]]+bundleIdentifier:[[:space:]]+com[.]citrolabs[.]ego[[:space:]]*$/ { bundle_id++ }
  /^[[:space:]]+teamIdentifier:[[:space:]]+JGQLC6YQYJ[[:space:]]*$/ { team_id++ }
  /^[[:space:]]+skillLatestRelease:[[:space:]]+https:\/\/github[.]com\/citrolabs\/ego-lite\/releases\/latest[[:space:]]*$/ { latest_release++ }
  END {
    ok = match_policy == 1 && update_policy == 1 && resolver == 1 &&
         app_path >= 1 && bundle_id >= 1 && team_id >= 1 && latest_release == 1
    exit(ok ? 0 : 1)
  }
' "$HARNESS_LOCK"; then
  echo "The latest stable runtime policy is absent from config/skills.lock.yaml." >&2
  exit 1
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

count_ego_main_processes() {
  printf '%s\n' "$HARNESS_EGO_MAIN_PROCESSES" | awk 'NF { count++ } END { print count + 0 }'
}

count_reviewed_main_processes() {
  printf '%s\n' "$HARNESS_EGO_MAIN_PROCESSES" | awk -F '\t' -v expected="$EXPECTED_APP_EXECUTABLE" '
    {
      command = $2
      if (command == expected || index(command, expected " ") == 1) count++
    }
    END { print count + 0 }
  '
}

HARNESS_EGO_MAIN_PROCESSES="$(collect_ego_main_processes)"
HARNESS_EGO_MAIN_COUNT="$(count_ego_main_processes)"
if [ "$HARNESS_EGO_MAIN_COUNT" -eq 0 ]; then
  /usr/bin/open "$EXPECTED_APP_BUNDLE"
  HARNESS_START_ATTEMPT=0
  while [ "$HARNESS_START_ATTEMPT" -lt 80 ]; do
    HARNESS_EGO_MAIN_PROCESSES="$(collect_ego_main_processes)"
    HARNESS_EGO_MAIN_COUNT="$(count_ego_main_processes)"
    if [ "$HARNESS_EGO_MAIN_COUNT" -gt 0 ]; then
      break
    fi
    sleep 0.25
    HARNESS_START_ATTEMPT=$((HARNESS_START_ATTEMPT + 1))
  done
fi
HARNESS_REVIEWED_MAIN_COUNT="$(count_reviewed_main_processes)"
if [ "$HARNESS_EGO_MAIN_COUNT" -ne 1 ] || [ "$HARNESS_REVIEWED_MAIN_COUNT" -ne 1 ]; then
  echo "Exactly one ego main process, from the reviewed app bundle, must be running before the fixture server starts." >&2
  if [ -n "$HARNESS_EGO_MAIN_PROCESSES" ]; then
    printf '%s\n' "$HARNESS_EGO_MAIN_PROCESSES" >&2
  fi
  exit 1
fi

HARNESS_EGO_BROWSER="$HARNESS_ACTIVE_VERSION_DIR/Helpers/ego-browser"
if [ ! -x "$HARNESS_EGO_BROWSER" ]; then
  echo "The latest /Applications runtime does not contain ego-browser." >&2
  exit 1
fi

/usr/bin/python3 - "$HARNESS_FORM" "$HARNESS_HOST" "$HARNESS_PORT" \
  >"$HARNESS_SERVER_LOG" 2>&1 <<'PY' &
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
import sys

form_path = Path(sys.argv[1])
host = sys.argv[2]
port = int(sys.argv[3])
expected_authority = f"{host}:{port}"
form_bytes = form_path.read_bytes()
csp = (
    "default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; "
    "connect-src 'none'; img-src 'none'; font-src 'none'; media-src 'none'; "
    "object-src 'none'; frame-src 'none'; worker-src 'none'; base-uri 'none'; "
    "form-action 'none'"
)


class FixtureHandler(BaseHTTPRequestHandler):
    server_version = "FindJobsFixture/1"

    def _headers(self, status, content_length=0):
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(content_length))
        self.send_header("Content-Security-Policy", csp)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()

    def _serve(self, include_body):
        if self.headers.get("Host") != expected_authority:
            self._headers(421)
            return
        if urlsplit(self.path).path != "/application-form.html":
            self._headers(404)
            return
        self._headers(200, len(form_bytes))
        if include_body:
            self.wfile.write(form_bytes)

    def do_GET(self):
        self._serve(True)

    def do_HEAD(self):
        self._serve(False)

    def do_POST(self):
        self._headers(405)

    def log_message(self, format, *args):
        sys.stderr.write("fixture-server: " + format % args + "\n")


ThreadingHTTPServer((host, port), FixtureHandler).serve_forever()
PY
HARNESS_SERVER_PID=$!

HARNESS_SERVER_READY="false"
HARNESS_READY_ATTEMPT=0
while [ "$HARNESS_READY_ATTEMPT" -lt 50 ]; do
  if ! kill -0 "$HARNESS_SERVER_PID" 2>/dev/null; then
    echo "Loopback fixture server exited before becoming ready." >&2
    sed -n '1,80p' "$HARNESS_SERVER_LOG" >&2
    exit 1
  fi
  if /usr/bin/curl --fail --silent --show-error \
      "http://$HARNESS_HOST:$HARNESS_PORT/application-form.html?scenario=success&case=readiness" \
      >/dev/null; then
    HARNESS_SERVER_READY="true"
    break
  fi
  HARNESS_READY_ATTEMPT=$((HARNESS_READY_ATTEMPT + 1))
  sleep 0.1
done
if [ "$HARNESS_SERVER_READY" != "true" ]; then
  echo "Loopback fixture server did not become ready." >&2
  exit 1
fi

HARNESS_CONFIG_JSON="$(/usr/bin/python3 - \
  "$HARNESS_REPO_DIR" \
  "$HARNESS_FIELDS" \
  "$HARNESS_RESUME" \
  "$HARNESS_LEDGER_DIR" \
  "http://$HARNESS_HOST:$HARNESS_PORT/application-form.html?scenario=success&case=maintainer-harness" \
  "$EXPECTED_EGO_LITE_VERSION" \
  "$EXPECTED_SKILL_VERSION" \
  "$EXPECTED_SKILL_SHA256" \
  "$HARNESS_SOURCE_COMMIT" <<'PY'
import json
import sys

keys = (
    "repoDir",
    "fieldsPath",
    "resumePath",
    "ledgerDir",
    "expectedUrl",
    "expectedEgoVersion",
    "expectedSkillVersion",
    "expectedSkillSha",
    "sourceCommit",
)
print(json.dumps(dict(zip(keys, sys.argv[1:])), separators=(",", ":")))
PY
)"

{
  printf 'const harnessConfig = Object.freeze(%s)\n' "$HARNESS_CONFIG_JSON"
  /bin/cat <<'EOF'
import fs from 'node:fs'
import path from 'node:path'
import crypto from 'node:crypto'

const expectedUrl = new URL(harnessConfig.expectedUrl)
const repoDir = fs.realpathSync(harnessConfig.repoDir)
const fixturesDir = fs.realpathSync(path.join(repoDir, 'tests', 'fixtures'))
const fieldsPath = fs.realpathSync(harnessConfig.fieldsPath)
const resumePath = fs.realpathSync(harnessConfig.resumePath)
const ledgerDir = harnessConfig.ledgerDir
const generationsDir = path.join(ledgerDir, 'generations')
const quarantineDir = path.join(ledgerDir, 'quarantine')
const secretsDir = path.join(ledgerDir, 'secrets')
const currentPointer = path.join(ledgerDir, 'CURRENT')
const fakeData = JSON.parse(fs.readFileSync(fieldsPath, 'utf8'))
const expectedEgoVersion = harnessConfig.expectedEgoVersion
const expectedSkillVersion = harnessConfig.expectedSkillVersion
const expectedSkillSha = harnessConfig.expectedSkillSha
const sourceCommit = harnessConfig.sourceCommit

function assert(condition, message) {
  if (!condition) throw new Error(message)
}
function canonical(value) {
  if (Array.isArray(value)) return '[' + value.map(canonical).join(',') + ']'
  if (value && typeof value === 'object') {
    return '{' + Object.keys(value).sort().map((key) => JSON.stringify(key) + ':' + canonical(value[key])).join(',') + '}'
  }
  return JSON.stringify(value)
}
function sha(value) {
  return crypto.createHash('sha256').update(value).digest('hex')
}
function bindingWithHash(binding) {
  return { ...binding, bindingHash: sha(canonical(binding)) }
}
function exactConfirmation(reply, expected) {
  return typeof reply === 'string' && reply.trim() === expected
}

assert(expectedUrl.protocol === 'http:', 'fixture protocol must be http')
assert(expectedUrl.hostname === '127.0.0.1', 'fixture host must be fixed loopback')
assert(expectedUrl.port === '18765', 'fixture port changed')
assert(expectedUrl.pathname === '/application-form.html', 'fixture path changed')
assert(expectedUrl.searchParams.get('scenario') === 'success', 'only the success fixture scenario is allowed')
assert(path.dirname(fieldsPath) === fixturesDir && path.basename(fieldsPath).startsWith('application-fake-'), 'fake field data escaped fixtures')
assert(path.dirname(resumePath) === fixturesDir && path.basename(resumePath).startsWith('application-fake-'), 'fake resume escaped fixtures')
assert(fakeData.fixtureOnly === true, 'fixtureOnly marker missing')
assert(fakeData.fields.resume === path.basename(resumePath), 'fake resume binding mismatch')

fs.mkdirSync(generationsDir, { recursive: true, mode: 0o700 })
fs.mkdirSync(quarantineDir, { recursive: true, mode: 0o700 })
fs.mkdirSync(secretsDir, { recursive: true, mode: 0o700 })
for (const directory of [ledgerDir, generationsDir, quarantineDir, secretsDir]) {
  assert((fs.statSync(directory).mode & 0o077) === 0, 'ledger directory permissions are not owner-only')
}
let sequence = 0
let previousEventHash = '0'.repeat(64)

function fsyncDirectory(directory) {
  const fd = fs.openSync(directory, 'r')
  try { fs.fsyncSync(fd) } finally { fs.closeSync(fd) }
}
function durableWrite(file, bytes, mode = 0o600) {
  const fd = fs.openSync(file, 'wx', mode)
  try {
    const written = fs.writeSync(fd, bytes)
    assert(written === Buffer.byteLength(bytes), 'short durable write')
    fs.fsyncSync(fd)
  } finally {
    fs.closeSync(fd)
  }
  fsyncDirectory(path.dirname(file))
}
function switchCurrent(generationName) {
  const temporary = path.join(ledgerDir, `.CURRENT-${crypto.randomBytes(6).toString('hex')}.tmp`)
  durableWrite(temporary, generationName + '\n')
  fs.renameSync(temporary, currentPointer)
  fsyncDirectory(ledgerDir)
}
function currentGenerationName() {
  const name = fs.readFileSync(currentPointer, 'utf8')
  assert(name.endsWith('\n'), 'CURRENT pointer is partial')
  const trimmed = name.trim()
  assert(/^generation-[0-9]{6}\.ndjson$/.test(trimmed), 'CURRENT generation name is invalid')
  return trimmed
}
function currentGenerationPath() {
  return path.join(generationsDir, currentGenerationName())
}
const firstGeneration = 'generation-000001.ndjson'
durableWrite(path.join(generationsDir, firstGeneration), '')
switchCurrent(firstGeneration)

function createApplicationSecret(applicationId) {
  const key = crypto.randomBytes(32)
  const keyId = 'hmac-key-' + sha(key).slice(0, 16)
  const sidecar = path.join(secretsDir, `${applicationId}.json`)
  durableWrite(sidecar, canonical({
    schemaVersion: '1.0',
    applicationId,
    keyId,
    algorithm: 'HMAC-SHA-256',
    key: key.toString('base64'),
  }) + '\n')
  assert((fs.statSync(sidecar).mode & 0o077) === 0, 'HMAC sidecar permissions are not owner-only')
  return { key, keyId }
}
function hmacCommit(secret, label, value) {
  return crypto.createHmac('sha256', secret.key).update(canonical({ label, value })).digest('hex')
}

function replayLedger() {
  const generationPath = currentGenerationPath()
  const raw = fs.readFileSync(generationPath, 'utf8')
  assert(raw === '' || raw.endsWith('\n'), 'ledger has a partial final line')
  const events = raw === '' ? [] : raw.trimEnd().split('\n').map(JSON.parse)
  let prior = '0'.repeat(64)
  const states = new Map()
  const attempts = new Set()
  events.forEach((event, index) => {
    assert(event.sequence === index + 1, 'ledger sequence gap')
    assert(event.previousEventHash === prior, 'ledger hash chain mismatch')
    const unhashed = { ...event }
    delete unhashed.eventHash
    assert(sha(canonical(unhashed)) === event.eventHash, 'ledger event hash mismatch')
    if (event.attemptId) attempts.add(event.attemptId)
    if (event.type !== 'ledger_recovered') states.set(event.applicationId, event.type)
    prior = event.eventHash
  })
  return { events, states, attempts }
}

function appendEvent(applicationId, attemptId, type, payload) {
  const event = {
    schemaVersion: '1.0',
    sequence: ++sequence,
    eventId: 'event-' + crypto.randomBytes(8).toString('hex'),
    applicationId,
    attemptId,
    type,
    occurredAt: new Date().toISOString(),
    previousEventHash,
    payload,
  }
  event.eventHash = sha(canonical(event))
  const line = canonical(event) + '\n'
  const generationPath = currentGenerationPath()
  const fd = fs.openSync(generationPath, 'a', 0o600)
  try {
    const bytes = fs.writeSync(fd, line)
    assert(bytes === Buffer.byteLength(line), 'short ledger write')
    fs.fsyncSync(fd)
  } finally {
    fs.closeSync(fd)
  }
  fsyncDirectory(path.dirname(generationPath))
  const replayed = replayLedger()
  assert(replayed.events[replayed.events.length - 1].eventHash === event.eventHash, 'durable ledger readback mismatch')
  previousEventHash = event.eventHash
  return event
}

function recoverPartialTail(applicationId) {
  const oldGeneration = currentGenerationName()
  const oldPath = currentGenerationPath()
  const raw = fs.readFileSync(oldPath)
  assert(raw.length > 0 && raw[raw.length - 1] !== 0x0a, 'partial-tail fixture was not present')
  const lastNewline = raw.lastIndexOf(0x0a)
  assert(lastNewline >= 0, 'partial tail has no valid prefix')
  const validPrefix = raw.subarray(0, lastNewline + 1)
  const damagedSegment = raw.subarray(lastNewline + 1)
  const damagedHash = sha(damagedSegment)
  const quarantineName = `${oldGeneration}.partial-${damagedHash.slice(0, 16)}.bin`
  const quarantinePath = path.join(quarantineDir, quarantineName)
  durableWrite(quarantinePath, damagedSegment)

  const nextNumber = Number(oldGeneration.slice('generation-'.length, 'generation-'.length + 6)) + 1
  const newGeneration = `generation-${String(nextNumber).padStart(6, '0')}.ndjson`
  const recoveryEvent = {
    schemaVersion: '1.0',
    sequence: ++sequence,
    eventId: 'event-' + crypto.randomBytes(8).toString('hex'),
    applicationId,
    attemptId: null,
    type: 'ledger_recovered',
    occurredAt: new Date().toISOString(),
    previousEventHash,
    payload: {
      oldGeneration,
      damagedSegmentSha256: damagedHash,
      damagedSegmentBytes: damagedSegment.length,
      quarantineName,
    },
  }
  recoveryEvent.eventHash = sha(canonical(recoveryEvent))
  const newBytes = Buffer.concat([validPrefix, Buffer.from(canonical(recoveryEvent) + '\n')])
  const temporary = path.join(generationsDir, `.${newGeneration}-${crypto.randomBytes(6).toString('hex')}.tmp`)
  durableWrite(temporary, newBytes)
  const newPath = path.join(generationsDir, newGeneration)
  fs.renameSync(temporary, newPath)
  fsyncDirectory(generationsDir)
  switchCurrent(newGeneration)
  previousEventHash = recoveryEvent.eventHash
  const replayed = replayLedger()
  assert(replayed.events[replayed.events.length - 1].type === 'ledger_recovered', 'recovery event missing from new generation')
  assert(fs.readFileSync(quarantinePath).equals(damagedSegment), 'damaged tail was not preserved exactly')
  assert(fs.readFileSync(oldPath).equals(raw), 'old damaged generation was not retained byte-for-byte')
  return { oldGeneration, newGeneration, quarantineName, damagedHash }
}

async function inspectPage() {
  return await page.evaluate(() => {
    const form = document.querySelector('#application-form')
    const fields = Array.from(form.elements).map((element) => ({
      formId: form.id,
      id: element.id || null,
      name: element.name || null,
      type: element.type || element.tagName.toLowerCase(),
      label: Array.from(element.labels || []).map((label) => label.textContent.replace(/\s+/g, ' ').trim()).join(' '),
      required: Boolean(element.required),
      options: element.tagName === 'SELECT' ? Array.from(element.options).map((option) => option.value) : [],
    }))
    return {
      url: location.href,
      company: document.querySelector('#company')?.dataset.company || null,
      title: document.querySelector('h1')?.textContent.trim() || null,
      jobId: document.querySelector('#job-id')?.dataset.jobId || null,
      form: {
        id: form.id,
        action: form.action,
        method: form.method,
        schemaVersion: form.dataset.schemaVersion,
        fields,
      },
      caseId: document.body.dataset.caseId || null,
      submitCount: Number(document.body.dataset.submitCount || '0'),
      applicationStatus: document.body.dataset.applicationStatus || document.querySelector('#result')?.dataset.applicationStatus || null,
      statusText: document.querySelector('#result')?.textContent.trim() || '',
      receipt: document.querySelector('#result')?.dataset.receipt || null,
      formHidden: form.hidden,
    }
  })
}

const taskName = 'findjobs maintainer golden submit ' + crypto.randomBytes(4).toString('hex')
const task = await taskSpaces.useOrCreate(taskName)
let result
let taskFailure = null
try {
  await browser.openOrReuseTab(expectedUrl.href, { wait: true, timeout: 20000 })
  const actualUrl = await page.url()
  assert(actualUrl === expectedUrl.href, 'fixture navigation changed')

  const initial = await inspectPage()
  assert(initial.company === fakeData.job.company, 'fixture company mismatch')
  assert(initial.title === fakeData.job.title, 'fixture title mismatch')
  assert(initial.jobId === fakeData.job.jobId, 'fixture job ID mismatch')
  assert(new URL(initial.form.action).origin === expectedUrl.origin, 'fixture form action is cross-origin')
  assert(initial.submitCount === 0, 'fixture submit counter was not clean')

  const resumeHash = sha(fs.readFileSync(resumePath))
  const formSchemaHash = sha(canonical(initial.form))
  const applicationId = 'application-' + sha(`v1\0${fakeData.profileId}\0${fakeData.job.jobId}`)
  const applicationSecret = createApplicationSecret(applicationId)
  const approvedAnswers = ['fullName', 'email', 'city', 'coverLetter'].map((fieldId) => ({
    fieldId,
    value: fakeData.fields[fieldId],
  }))
  const answersCommitment = {
    keyId: applicationSecret.keyId,
    hmac: hmacCommit(applicationSecret, 'approved-answers', approvedAnswers),
  }
  const disclosureBinding = bindingWithHash({
    bindingType: 'disclosure',
    jobId: fakeData.job.jobId,
    observedCompany: initial.company,
    observedTitle: initial.title,
    finalUrl: initial.url,
    domain: expectedUrl.hostname,
    resumeVersion: resumeHash,
    answersCommitment,
    attachmentHashes: [resumeHash],
    formSchemaHash,
    approvedFields: fakeData.approvedFields,
    manualFields: fakeData.manualFields,
    autosaveDestinations: [new URL(initial.form.action).origin],
  })

  appendEvent(applicationId, null, 'awaiting_disclosure_confirmation', {
    bindingHash: disclosureBinding.bindingHash,
    answersCommitment,
  })
  const disclosurePhrase = `授权填写：${fakeData.job.jobId}/${disclosureBinding.bindingHash}`
  const simulatedDisclosureReply = disclosurePhrase
  assert(exactConfirmation(simulatedDisclosureReply, disclosurePhrase), 'exact disclosure confirmation failed')
  assert(!exactConfirmation('继续', disclosurePhrase), 'ambiguous disclosure confirmation was accepted')
  assert(exactConfirmation(` \n${disclosurePhrase}\t`, disclosurePhrase), 'trimmed disclosure confirmation was rejected')
  assert(!exactConfirmation(`${disclosurePhrase} extra`, disclosurePhrase), 'disclosure confirmation accepted extra prose')
  appendEvent(applicationId, null, 'disclosure_confirmed', {
    bindingHash: disclosureBinding.bindingHash,
    confirmationRef: sha(simulatedDisclosureReply),
  })

  await page.getByLabel('Full name').fill(fakeData.fields.fullName)
  await page.getByLabel('Email').fill(fakeData.fields.email)
  await page.getByLabel('Current city').fill(fakeData.fields.city)
  await page.getByLabel('Cover letter').fill(fakeData.fields.coverLetter)
  await page.getByLabel('Resume').setInputFiles(resumePath)

  const readback = await page.evaluate(() => {
    const form = document.querySelector('#application-form')
    return {
      fullName: form.elements.fullName.value,
      email: form.elements.email.value,
      city: form.elements.city.value,
      coverLetter: form.elements.coverLetter.value,
      resumeName: form.elements.resume.files[0]?.name || null,
      expectedSalary: form.elements.expectedSalary.value,
      workAuthorization: form.elements.workAuthorization.value,
      legalConsent: form.elements.legalConsent.checked,
      submitCount: Number(document.body.dataset.submitCount || '0'),
    }
  })
  assert(readback.fullName === fakeData.fields.fullName, 'full name readback failed')
  assert(readback.email === fakeData.fields.email, 'email readback failed')
  assert(readback.city === fakeData.fields.city, 'city readback failed')
  assert(readback.coverLetter === fakeData.fields.coverLetter, 'cover letter readback failed')
  assert(readback.resumeName === fakeData.fields.resume, 'resume readback failed')
  assert(!readback.expectedSalary && !readback.workAuthorization && !readback.legalConsent, 'sensitive field changed')
  assert(readback.submitCount === 0, 'Fill crossed the submit boundary')

  const afterFill = await inspectPage()
  assert(sha(canonical(afterFill.form)) === formSchemaHash, 'form schema changed after Fill')
  appendEvent(applicationId, null, 'filled', { bindingHash: disclosureBinding.bindingHash, readbackVerified: true })

  const finalControl = page.getByRole('button', { name: 'Submit test application' })
  assert((await finalControl.count()) === 1, 'final submit control is not unique')
  assert(await finalControl.isEnabled(), 'final submit control is disabled')
  const submitControl = await page.locator('#final-submit').evaluate((element) => ({
    formId: element.form?.id || null,
    fieldId: element.id || element.name || null,
    role: 'button',
    accessibleName: element.textContent.trim(),
    destinationOrigin: new URL(element.form.action).origin,
  }))
  const { bindingHash: ignoredDisclosureHash, ...disclosureCore } = disclosureBinding
  const submitBinding = bindingWithHash({
    ...disclosureCore,
    bindingType: 'submit',
    applicationId,
    submitControl,
  })
  appendEvent(applicationId, null, 'awaiting_submit_confirmation', {
    disclosureBindingHash: disclosureBinding.bindingHash,
    submitBindingHash: submitBinding.bindingHash,
  })
  const attemptId = 'attempt-' + crypto.randomBytes(16).toString('hex')
  appendEvent(applicationId, attemptId, 'submit_prepared', {
    disclosureBindingHash: disclosureBinding.bindingHash,
    submitBindingHash: submitBinding.bindingHash,
    submitControl,
  })

  const submitPhrase = `确认提交：${fakeData.job.jobId}/${attemptId}/${submitBinding.bindingHash}`
  const simulatedSubmitReply = submitPhrase
  assert(exactConfirmation(simulatedSubmitReply, submitPhrase), 'exact submit confirmation failed')
  assert(!exactConfirmation('确认提交', submitPhrase), 'ambiguous submit confirmation was accepted')
  assert(exactConfirmation(`\n${submitPhrase} `, submitPhrase), 'trimmed submit confirmation was rejected')
  assert(!exactConfirmation(`${submitPhrase}\nextra`, submitPhrase), 'submit confirmation accepted extra prose')
  appendEvent(applicationId, attemptId, 'submit_started', {
    submitBindingHash: submitBinding.bindingHash,
    finalSubmitConfirmationRef: sha(simulatedSubmitReply),
  })
  const beforeClickReplay = replayLedger()
  assert(beforeClickReplay.states.get(applicationId) === 'submit_started', 'submit_started was not durable before click')
  assert(beforeClickReplay.attempts.has(attemptId), 'attempt ID was not persisted before click')

  const receiptWait = page.locator('#result[data-receipt]').waitFor({ state: 'visible', timeout: 5000 })
  await finalControl.click()
  assert(await receiptWait, 'receipt did not become visible')
  const submitted = await page.evaluate(() => ({
    receipt: document.querySelector('#result')?.dataset.receipt || null,
    submitCount: Number(document.body.dataset.submitCount || '0'),
    formHidden: document.querySelector('#application-form')?.hidden || false,
  }))
  assert(/^FIXTURE-[0-9]{3}$/.test(submitted.receipt || ''), 'verified fixture receipt missing')
  assert(submitted.submitCount === 1, 'final control was not clicked exactly once')
  assert(submitted.formHidden, 'fixture form did not enter its submitted state')

  appendEvent(applicationId, attemptId, 'submitted', {
    submitBindingHash: submitBinding.bindingHash,
    evidence: {
      kind: 'fixture_receipt',
      keyId: applicationSecret.keyId,
      receiptHmac: hmacCommit(applicationSecret, 'fixture-receipt', submitted.receipt),
    },
  })
  let finalReplay = replayLedger()
  assert(finalReplay.states.get(applicationId) === 'submitted', 'ledger replay did not materialize submitted')
  assert(finalReplay.events.length === 7, 'unexpected pre-recovery ledger event count')

  // Inject a partial physical tail, preserve it byte-for-byte, and atomically switch generations.
  const partialTail = Buffer.from('{"partial":"controlled-damaged-tail"')
  const damagedFd = fs.openSync(currentGenerationPath(), 'a')
  try {
    fs.writeSync(damagedFd, partialTail)
    fs.fsyncSync(damagedFd)
  } finally {
    fs.closeSync(damagedFd)
  }
  const recovery = recoverPartialTail(applicationId)
  finalReplay = replayLedger()
  assert(finalReplay.states.get(applicationId) === 'submitted', 'recovery changed submitted application state')
  assert(finalReplay.events.length === 8, 'recovery generation did not add exactly one event')

  // Use a distinct fixture page for unknown reconciliation and a fresh retry cycle.
  const retryUrl = new URL(expectedUrl.href)
  retryUrl.searchParams.set('case', 'retry-cycle')
  await browser.openOrReuseTab(retryUrl.href, { wait: true, timeout: 20000 })
  assert(await page.url() === retryUrl.href, 'retry fixture navigation changed')
  const retryInitial = await inspectPage()
  assert(retryInitial.caseId === 'retry-cycle', 'retry fixture case mismatch')
  assert(retryInitial.url !== initial.url, 'retry fixture reused the main application URL')
  assert(retryInitial.jobId === fakeData.retryJob.jobId, 'retry fixture job ID mismatch')
  assert(retryInitial.jobId !== initial.jobId, 'retry fixture reused the main application job')
  assert(retryInitial.company === fakeData.retryJob.company, 'retry fixture company mismatch')
  assert(retryInitial.title === fakeData.retryJob.title, 'retry fixture title mismatch')
  assert(new URL(retryInitial.form.action).origin === retryUrl.origin, 'retry fixture form action is cross-origin')
  assert(retryInitial.submitCount === 0, 'retry fixture submit counter was not independent')
  assert(retryInitial.receipt === null, 'retry fixture reused the main application receipt')
  assert(retryInitial.applicationStatus === fakeData.retryJob.authoritativeStatus, 'retry fixture lacks authoritative non-submission status')
  assert(retryInitial.statusText.includes(fakeData.retryJob.jobId), 'retry fixture status does not identify its job')
  assert(!retryInitial.formHidden, 'retry fixture unexpectedly hid its form')

  const retryFormSchemaHash = sha(canonical(retryInitial.form))
  assert(retryFormSchemaHash !== formSchemaHash, 'retry fixture reused the main application schema')
  const retryFinalControl = page.getByRole('button', { name: 'Submit test application' })
  assert((await retryFinalControl.count()) === 1, 'retry final submit control is not unique')
  assert(await retryFinalControl.isEnabled(), 'retry final submit control is disabled')
  const retrySubmitControl = await page.locator('#final-submit').evaluate((element) => ({
    formId: element.form?.id || null,
    fieldId: element.id || element.name || null,
    role: 'button',
    accessibleName: element.textContent.trim(),
    destinationOrigin: new URL(element.form.action).origin,
  }))

  const retryJobId = retryInitial.jobId
  const retryApplicationId = 'application-' + sha(`v1\0${fakeData.profileId}\0${retryJobId}`)
  const retrySecret = createApplicationSecret(retryApplicationId)
  const lowEntropyAnswers = { expectedSalary: '10000', workAuthorization: 'yes' }
  const retryAnswersCommitment = {
    keyId: retrySecret.keyId,
    hmac: hmacCommit(retrySecret, 'retry-low-entropy-answers', lowEntropyAnswers),
  }
  const firstRetryDisclosure = bindingWithHash({
    bindingType: 'disclosure',
    bindingCycle: 1,
    bindingNonce: crypto.randomBytes(16).toString('hex'),
    jobId: retryJobId,
    observedCompany: retryInitial.company,
    observedTitle: retryInitial.title,
    finalUrl: retryInitial.url,
    domain: new URL(retryInitial.url).hostname,
    resumeVersion: resumeHash,
    answersCommitment: retryAnswersCommitment,
    attachmentHashes: [resumeHash],
    formSchemaHash: retryFormSchemaHash,
    approvedFields: fakeData.approvedFields,
    manualFields: fakeData.manualFields,
    autosaveDestinations: [new URL(retryInitial.form.action).origin],
  })
  appendEvent(retryApplicationId, null, 'awaiting_disclosure_confirmation', {
    bindingHash: firstRetryDisclosure.bindingHash,
    answersCommitment: retryAnswersCommitment,
  })
  const firstRetryFillPhrase = `授权填写：${retryJobId}/${firstRetryDisclosure.bindingHash}`
  assert(exactConfirmation(firstRetryFillPhrase, firstRetryFillPhrase), 'first retry disclosure confirmation failed')
  assert(exactConfirmation(` ${firstRetryFillPhrase}\n`, firstRetryFillPhrase), 'trimmed first retry disclosure confirmation failed')
  appendEvent(retryApplicationId, null, 'disclosure_confirmed', {
    bindingHash: firstRetryDisclosure.bindingHash,
    confirmationRef: sha(firstRetryFillPhrase),
  })
  appendEvent(retryApplicationId, null, 'filled', { bindingHash: firstRetryDisclosure.bindingHash, fixtureStateOnly: true })
  const { bindingHash: ignoredFirstRetryHash, ...firstRetryCore } = firstRetryDisclosure
  const firstRetrySubmit = bindingWithHash({
    ...firstRetryCore,
    bindingType: 'submit',
    applicationId: retryApplicationId,
    submitControl: retrySubmitControl,
  })
  appendEvent(retryApplicationId, null, 'awaiting_submit_confirmation', {
    disclosureBindingHash: firstRetryDisclosure.bindingHash,
    submitBindingHash: firstRetrySubmit.bindingHash,
  })
  const firstRetryAttempt = 'attempt-' + crypto.randomBytes(16).toString('hex')
  appendEvent(retryApplicationId, firstRetryAttempt, 'submit_prepared', { submitBindingHash: firstRetrySubmit.bindingHash })
  const firstRetrySubmitPhrase = `确认提交：${retryJobId}/${firstRetryAttempt}/${firstRetrySubmit.bindingHash}`
  assert(exactConfirmation(firstRetrySubmitPhrase, firstRetrySubmitPhrase), 'first retry submit confirmation failed')
  assert(exactConfirmation(`\t${firstRetrySubmitPhrase} `, firstRetrySubmitPhrase), 'trimmed first retry submit confirmation failed')
  appendEvent(retryApplicationId, firstRetryAttempt, 'submit_started', {
    submitBindingHash: firstRetrySubmit.bindingHash,
    finalSubmitConfirmationRef: sha(firstRetrySubmitPhrase),
  })
  appendEvent(retryApplicationId, firstRetryAttempt, 'unknown', { reason: 'controlled_state_fixture_unknown' })
  const authoritativeNonSubmission = await inspectPage()
  assert(authoritativeNonSubmission.jobId === retryJobId, 'reconciliation page no longer identifies the retry job')
  assert(authoritativeNonSubmission.url === retryInitial.url, 'reconciliation URL changed')
  assert(authoritativeNonSubmission.submitCount === 0, 'retry fixture observed a browser submit click')
  assert(authoritativeNonSubmission.receipt === null, 'retry fixture exposed an unrelated receipt')
  assert(authoritativeNonSubmission.applicationStatus === fakeData.retryJob.authoritativeStatus, 'non-submission status is not authoritative')
  assert(authoritativeNonSubmission.statusText.includes(retryJobId), 'non-submission status does not identify the retry job')
  assert(!authoritativeNonSubmission.formHidden, 'reconciliation unexpectedly hid the retry form')
  assert(sha(canonical(authoritativeNonSubmission.form)) === retryFormSchemaHash, 'retry form schema changed during reconciliation')
  appendEvent(retryApplicationId, firstRetryAttempt, 'not_submitted_verified', {
    evidence: {
      kind: 'authoritative_fixture_non_submission',
      keyId: retrySecret.keyId,
      evidenceHmac: hmacCommit(retrySecret, 'not-submitted-evidence', {
        attemptId: firstRetryAttempt,
        fixtureSubmitCount: authoritativeNonSubmission.submitCount,
        fixtureStatus: authoritativeNonSubmission.applicationStatus,
        fixtureJobId: authoritativeNonSubmission.jobId,
        retryClickObserved: false,
      }),
    },
  })

  const freshRetryPage = await inspectPage()
  assert(freshRetryPage.url === retryInitial.url, 'fresh retry URL changed')
  assert(freshRetryPage.jobId === retryJobId && freshRetryPage.title === retryInitial.title, 'fresh retry page identity changed')
  assert(sha(canonical(freshRetryPage.form)) === retryFormSchemaHash, 'fresh retry form schema changed')
  const freshRetrySubmitControl = await page.locator('#final-submit').evaluate((element) => ({
    formId: element.form?.id || null,
    fieldId: element.id || element.name || null,
    role: 'button',
    accessibleName: element.textContent.trim(),
    destinationOrigin: new URL(element.form.action).origin,
  }))
  const freshRetryDisclosure = bindingWithHash({
    ...firstRetryCore,
    bindingType: 'disclosure',
    bindingCycle: 2,
    bindingNonce: crypto.randomBytes(16).toString('hex'),
    priorAttemptId: firstRetryAttempt,
    jobId: freshRetryPage.jobId,
    observedCompany: freshRetryPage.company,
    observedTitle: freshRetryPage.title,
    finalUrl: freshRetryPage.url,
    domain: new URL(freshRetryPage.url).hostname,
    formSchemaHash: sha(canonical(freshRetryPage.form)),
    autosaveDestinations: [new URL(freshRetryPage.form.action).origin],
  })
  assert(freshRetryDisclosure.bindingHash !== firstRetryDisclosure.bindingHash, 'retry reused its disclosure binding')
  appendEvent(retryApplicationId, null, 'awaiting_disclosure_confirmation', {
    bindingHash: freshRetryDisclosure.bindingHash,
    answersCommitment: retryAnswersCommitment,
    priorAttemptId: firstRetryAttempt,
  })
  const freshRetryFillPhrase = `授权填写：${retryJobId}/${freshRetryDisclosure.bindingHash}`
  assert(exactConfirmation(freshRetryFillPhrase, freshRetryFillPhrase), 'fresh retry disclosure confirmation failed')
  assert(exactConfirmation(`\n${freshRetryFillPhrase}\t`, freshRetryFillPhrase), 'trimmed fresh retry disclosure confirmation failed')
  assert(freshRetryFillPhrase !== firstRetryFillPhrase, 'retry disclosure phrase was reused')
  appendEvent(retryApplicationId, null, 'disclosure_confirmed', {
    bindingHash: freshRetryDisclosure.bindingHash,
    confirmationRef: sha(freshRetryFillPhrase),
  })
  appendEvent(retryApplicationId, null, 'filled', { bindingHash: freshRetryDisclosure.bindingHash, fixtureStateOnly: true })
  const { bindingHash: ignoredFreshRetryHash, ...freshRetryCore } = freshRetryDisclosure
  const freshRetrySubmit = bindingWithHash({
    ...freshRetryCore,
    bindingType: 'submit',
    applicationId: retryApplicationId,
    submitControl: freshRetrySubmitControl,
  })
  assert(freshRetrySubmit.bindingHash !== firstRetrySubmit.bindingHash, 'retry reused its submit binding')
  appendEvent(retryApplicationId, null, 'awaiting_submit_confirmation', {
    disclosureBindingHash: freshRetryDisclosure.bindingHash,
    submitBindingHash: freshRetrySubmit.bindingHash,
  })
  const freshRetryAttempt = 'attempt-' + crypto.randomBytes(16).toString('hex')
  assert(freshRetryAttempt !== firstRetryAttempt, 'retry reused an attempt ID')
  appendEvent(retryApplicationId, freshRetryAttempt, 'submit_prepared', { submitBindingHash: freshRetrySubmit.bindingHash })
  const freshRetrySubmitPhrase = `确认提交：${retryJobId}/${freshRetryAttempt}/${freshRetrySubmit.bindingHash}`
  assert(exactConfirmation(freshRetrySubmitPhrase, freshRetrySubmitPhrase), 'fresh retry submit confirmation failed')
  assert(exactConfirmation(` ${freshRetrySubmitPhrase}\n`, freshRetrySubmitPhrase), 'trimmed fresh retry submit confirmation failed')
  assert(freshRetrySubmitPhrase !== firstRetrySubmitPhrase, 'retry submit phrase was reused')
  appendEvent(retryApplicationId, freshRetryAttempt, 'submit_started', {
    submitBindingHash: freshRetrySubmit.bindingHash,
    finalSubmitConfirmationRef: sha(freshRetrySubmitPhrase),
  })
  appendEvent(retryApplicationId, freshRetryAttempt, 'unknown', { reason: 'controlled_state_fixture_no_second_browser_click' })

  const postRetryFixture = await inspectPage()
  assert(postRetryFixture.jobId === retryJobId, 'post-retry fixture job changed')
  assert(postRetryFixture.submitCount === 0, 'retry state audit caused a browser submit click')
  assert(postRetryFixture.receipt === null, 'post-retry fixture exposed a receipt')
  assert(postRetryFixture.applicationStatus === fakeData.retryJob.authoritativeStatus, 'post-retry authoritative status changed')
  assert(postRetryFixture.statusText.includes(retryJobId), 'post-retry status no longer identifies the retry job')
  assert(!postRetryFixture.formHidden, 'post-retry fixture form was hidden')
  finalReplay = replayLedger()
  assert(finalReplay.states.get(applicationId) === 'submitted', 'main application changed during retry audit')
  assert(finalReplay.states.get(retryApplicationId) === 'unknown', 'fresh retry attempt did not materialize independently')
  assert(finalReplay.attempts.has(firstRetryAttempt) && finalReplay.attempts.has(freshRetryAttempt), 'retry attempts were not replayed')

  const ledgerText = fs.readdirSync(generationsDir)
    .filter((name) => name.endsWith('.ndjson'))
    .map((name) => fs.readFileSync(path.join(generationsDir, name), 'utf8'))
    .join('\n')
  for (const value of [fakeData.fields.fullName, fakeData.fields.email, fakeData.fields.city, fakeData.fields.coverLetter, '10000', 'yes']) {
    assert(!ledgerText.includes(JSON.stringify(value)), 'ledger leaked a field value instead of an HMAC')
  }
  assert(fs.readdirSync(secretsDir).length === 2, 'per-application HMAC sidecars were not created')

  result = {
    status: 'passed',
    runtime: {
      egoLiteVersion: expectedEgoVersion,
      egoBrowserSkillVersion: expectedSkillVersion,
      egoBrowserSkillSha256: expectedSkillSha,
    },
    target: {
      sourceCommit,
      origin: expectedUrl.origin,
      path: expectedUrl.pathname,
      company: fakeData.job.company,
      jobId: fakeData.job.jobId,
      realEmployerTouched: false,
    },
    taskSpaceId: task.id,
    disclosure: { bindingHash: disclosureBinding.bindingHash, exactConfirmation: disclosurePhrase },
    submit: { bindingHash: submitBinding.bindingHash, attemptId, exactConfirmation: submitPhrase },
    receipt: submitted.receipt,
    submitCount: submitted.submitCount,
    ledger: {
      directory: 'redacted-local-ledger',
      currentGeneration: currentGenerationName(),
      events: finalReplay.events.length,
      replayState: finalReplay.states.get(applicationId),
      privacySafe: true,
      hmacSidecars: 2,
      partialTailRecovery: recovery,
      retryAudit: {
        firstAttemptId: firstRetryAttempt,
        firstTerminalState: 'not_submitted_verified',
        freshAttemptId: freshRetryAttempt,
        freshBinding: true,
        exactConfirmationsRepeated: true,
        retryFixtureSubmitCount: postRetryFixture.submitCount,
        retryFixtureReceipt: postRetryFixture.receipt,
        authoritativeStatus: postRetryFixture.applicationStatus,
        secondBrowserClick: false,
      },
    },
  }
} catch (error) {
  taskFailure = error
} finally {
  const completion = await taskSpaces.complete(task.id, { keep: false })
  if (!completion.done && !taskFailure) taskFailure = new Error('Task space cleanup failed: ' + JSON.stringify(completion))
}
if (taskFailure) throw taskFailure
console.log(JSON.stringify(result, null, 2))
EOF
} | "$HARNESS_EGO_BROWSER" nodejs | tee "$HARNESS_RESULT"

stop_server
trap - EXIT INT TERM
echo "Loopback server stopped. Harness artifact ID: $(basename "$HARNESS_TMP_DIR")"
