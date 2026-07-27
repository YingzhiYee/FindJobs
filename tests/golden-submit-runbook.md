# Maintainer runbook: controlled golden submit

This harness is only for maintainers recording or checking the fake-data golden demo. It cannot accept a URL, resume path, field override or command-line argument. Its dedicated loopback handler serves only `GET`/`HEAD /application-form.html` (query strings allowed) on `127.0.0.1:18765`, rejects other paths/methods and hostname substitution, and sends a CSP that blocks connections, external subresources and form actions. It reads only `tests/fixtures/application-fake-*` data. Those files reuse the synthetic Rowan profile identity, but the attachment and Fixture Labs job are deliberately separate from the ByteDance Draft shown earlier.

## Prerequisites

- macOS with ego(lite) onboarding complete.
- The active runtime must exactly match the reviewed tuple: ego(lite) `0.4.6.0`, ego-browser skill `1.2.5`, skill SHA-256 `3d2d43ba61ace9977827f0343d333c597ac6f3d1a0a207a4a62b16468c3292c7`.
- Exactly one ego main process must be running, and it must be the reviewed app bundle. Quit other ego/ego(lite) installations yourself before a maintainer run; the harness never terminates them.
- Port `18765` must be free.
- Run from a Git checkout whose harness, controlled fixtures, acceptance block, runtime lock and controlled-test policies are tracked and unchanged from the current 40-character `HEAD` commit.
- No package installation is needed. The harness uses the ego(lite) CLI and macOS `python3`, `curl`, `shasum`, and shell tools.

## Single command

From a fresh clone root, run:

```bash
./tests/run-golden-submit.sh
```

Do not pass arguments. The script rejects them so a copied command cannot redirect the browser or substitute real data.

## Expected result

The command prints one JSON result with:

- `status: "passed"`;
- target `Fixture Labs` / `golden-demo-001` and `realEmployerTouched: false`;
- the generated disclosure binding and exact fixture confirmation;
- the generated submit binding, single-use attempt ID and exact fixture confirmation;
- a `FIXTURE-001` receipt and `submitCount: 1`;
- a generation-based, hash-chained ledger whose main application replay state is `submitted`;
- two owner-only per-application HMAC sidecars, with no raw low-entropy answers in any generation;
- byte-preserving partial-tail recovery to a new generation and an atomic `CURRENT` switch;
- an independent `case=retry-cycle` page for job `golden-demo-retry-001`, with authoritative `not_submitted`, submit count `0` and no receipt;
- an `unknown -> not_submitted_verified` audit followed by fresh page-derived disclosure/submit bindings, both fresh confirmations and a new attempt ID, without any click on the retry page;
- only a redacted artifact label or basename, never an absolute private temporary path.

It then prints `Loopback server stopped`. The script owns the server process and stops it on success, failure, interrupt or termination. ego-browser task-space cleanup also runs on success or browser-test failure.

The two confirmations are deterministically simulated only inside this fixture harness by setting the simulated reply to the phrase generated from the just-computed binding. Leading/trailing whitespace is trimmed, then the whole reply must match byte-for-byte; extra prose still fails. Keep `确认短语由测试脚本模拟` visible in any recording of this route. The production skill is unchanged: a real user must still send each phrase in a separate confirmation step.

## Failure behavior

The harness stops before starting the loopback server when the four acceptance flags, pinned fixture hashes, runtime tuple, lock entry, CLI target or running ego process set differs. Once browser work starts, any origin/path change, form/schema mismatch, non-unique submit control, failed readback, sensitive-field mutation, missing write-ahead state, missing receipt, second click, bad replay or ledger value leak fails the run. On failure only, stderr prints an absolute diagnostic path. Do not include a failed-run terminal in an XHS recording because that path may identify the local machine. No real website fallback exists.
