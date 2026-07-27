# Controlled golden Fill/Submit report — 2026-07-27

## Result

An earlier synthetic `Fill → Submit → local ledger → restart/replay` slice passed its controlled dynamic gate. The current generation/HMAC/retry harness has not yet completed its reproducible dynamic rerun, so `controlledFixtureRecordingReady` remains false. This is not a real-employer submission gate: `realFillEnabled` and `realSubmitEnabled` remain false.

A separate read-only Discover run observed ByteDance official posting `A106199`. That evidence proves only real-site discovery. Every fill, upload and click in this report targeted the loopback fixture for fictional company `Fixture Labs`, job `golden-demo-001`; no real employer or ATS form was opened or mutated.

## Runtime and fixture

- Reviewed ego(lite): `0.4.6.0`.
- Reviewed `ego-browser`: skill `1.2.5`, dated `2026-07-16`.
- Executed skill SHA-256: `3d2d43ba61ace9977827f0343d333c597ac6f3d1a0a207a4a62b16468c3292c7`, the acceptance-tested tuple recorded in `config/skills.lock.yaml` before the latest-stable resolver replaced the manual runtime allowlist.
- Browser target: `tests/fixtures/application-form.html`, served only on `127.0.0.1:8765` for the run.
- Upload: `tests/fixtures/application-fake-resume.txt`, containing synthetic `example.invalid` data.
- Final passing ego task space: ID `44`; `taskSpaces.complete(..., { keep: false })` returned done and closed it.
- Durable test ledger: 19 hash-chained NDJSON events in a private system temporary directory. Every append was followed by file `fsync`, readback and full replay validation before the allowed click.

The first harness attempt was rejected by Node's module-format check before task-space selection or page access. A later harness attempt reached only the controlled fixture but had an incorrect assertion about a hidden form; task space `43` was explicitly closed. The corrected full run below is the acceptance evidence.

## Reproducible harness rerun

`./tests/run-golden-submit.sh` now packages the controlled route as a no-argument maintainer command on fixed `127.0.0.1:18765`. Bash syntax, embedded JavaScript syntax, pinned fixture hashes and the scoped diff check passed.

The 2026-07-27 rerun correctly exited before starting the loopback server because two ego main processes were present: the reviewed `0.4.6.0` app and an older Desktop `0.4.5.5` app. Port `18765` had no listener before or after the command. The harness did not create a browser task space, touch a website or terminate either process.

This is positive fail-closed evidence, not a passing end-to-end rerun. The generation switch, HMAC sidecars, partial-tail recovery and fresh retry-cycle assertions in the new harness have passed static syntax/review only; they were not dynamically executed in this rerun. The task-space `44` evidence below remains the prior controlled browser evidence and must not be represented as if it exercised those newer assertions.

## Dynamic Murphy checks

| Check | Observed result |
| --- | --- |
| No disclosure authorization | Empty text/select/checkbox/file controls; submit count `0`. |
| Exact first authorization then Fill | Only five approved non-sensitive controls were populated; fake attachment name read back. |
| Fill boundary | Form remained visible and submit count stayed `0`. |
| Ambiguous second confirmation | `确认提交` did not match the bound phrase; submit count stayed `0`. |
| Write-ahead and success | `submit_started` was durable and replayed before the single semantic click; fixture returned a receipt; submit count was exactly `1`. |
| Attempt replay | The consumed attempt ID was rejected; count remained `1`. |
| Form mutation | A newly required `portfolioUrl` changed the schema hash after fill; state paused with no click. |
| Cross-origin action | An `https://cross-origin.invalid/collect` form destination was detected before fill/upload; no click. |
| Cross-domain redirect | Redirect from `127.0.0.1` to `localhost` changed the bound hostname; no fill/upload/click. |
| CAPTCHA | Visible challenge caused a stop with every control untouched. |
| Sensitive fields | Salary, work authorization and legal consent stayed blank/unchecked and control stayed with the user. |
| Duplicate final control | Two equally named submit buttons invalidated the control fingerprint; no click. |
| Ambiguous submit result | One click produced only `Processing`; ledger recorded `unknown`; the attempt remained consumed and non-retryable. |
| Crash/restart | Replaying a durable `submit_started` tail appended `unknown` before browser action; submit count remained `0`. |
| Handoff side effect | An existing fixture receipt with the form hidden was reconciled without a click. |
| Ledger integrity/privacy | All 19 event sequence/hash links validated; candidate name, email and cover-letter text were absent from the ledger. |

All 16 checks returned `true`. The local HTTP service was stopped after the run.

## Implemented contract

The one-off task-space run above predates the generation/HMAC hardening below. `skills/find-my-dream-job/references/application-ledger.md` now defines:

- a private, coordinator-owned `CURRENT` generation with retired damaged generations retained unchanged;
- canonical hashes for application, form, attachments and bindings plus per-application HMAC commitments for answers;
- owner-only HMAC key sidecars so low-entropy salary or authorization answers are not exposed to offline guessing from ledger data alone;
- an exclusive-writer, append + `fsync` + readback protocol;
- byte-exact disclosure and final-submit phrases;
- single-use cryptographic attempt IDs and exact semantic final-control fingerprints;
- recovery of `submit_started` to non-retryable `unknown`;
- byte-preserving partial-tail quarantine, recovery into a new generation and atomic `CURRENT` switching;
- authoritative non-submission reconciliation followed by fresh bindings, both exact confirmations and a new attempt ID before a later attempt.

## Remaining risk and release boundary

- This proves G4 and only the exercised controlled portion of G6 against a deterministic fixture, not G5 or exact-ATS G4/G6 on a real employer/ATS.
- Actual ATS autosave, multi-page navigation, attachment widgets, status endpoints and employer-specific agreements still require site-by-site evidence.
- The dynamic run had one writer; the protocol requires an operating-system exclusive lock, but concurrent-process lock contention was not dynamically stress-tested here. G6 is therefore `partial-controlled-single-writer-fixture`, not passed.
- CAPTCHA, OTP, login expiry, signatures, consent and sensitive questions require user handoff. The agent must reconcile first when control returns.
- A generic HTTP success, redirect, toast or click return remains insufficient evidence of submission.

Therefore this report supports a fake-data XHS golden-path recording. Real Fill/Submit require G5 plus matching exact-ATS G4/G6 evidence, including exclusive-lock contention, in a later pinned release. They remain disabled here.
