# Golden path MVP

The target public promise is deliberately narrow: one macOS user can move from a pinned XHS prompt to one user-selected job, prepare truthful materials, confirm disclosure, confirm submission, and retain a local record. It is assisted single-job application, not unattended or bulk application. In `0.4.0-beta.2`, the real-site route stops after Draft; only the fixed fake-data loopback route may demonstrate Fill/Submit. A later pinned release must pass user-participated G5 plus exact-ATS G4/G6 evidence, including exclusive-lock contention, before making the complete real-employer promise for that tested scope.

## Entry contract

The XHS post contains one short bootstrap prompt generated after the release commit exists. It points to an immutable URL of the form:

```text
<fixed 40-character commit URL copied from the GitHub Release>
```

The commit cannot be embedded into the same commit's tracked `START_PROMPT.md`; doing so would be self-referential. The maintainer therefore commits first, then substitutes the resulting 40-character commit in the GitHub Release description and XHS copy. Never publish a `main`, `master`, `HEAD`, branch, or mutable tag URL as the bootstrap source.

## User journey

| Stage | Codex action | User action | Completion evidence |
|---|---|---|---|
| 1. Load | Verify the official repository plus full commit URL. If no matching checkout exists, fetch only that object into an owner-only temporary detached checkout; verify remote and HEAD, then read only allowlisted instructions and acceptance state. | Paste the XHS prompt. | Report the exact 40-character commit, official remote and currently allowed modes; no pre-existing local repository is required. |
| 2. Install | Open the official ego(lite) quick-start page if the runtime is unavailable. Do not source a binary elsewhere. Resolve the official latest stable skill and compare it with the signed `/Applications` runtime; invoke only the resolver-returned CLI through the verified runner, never a PATH activation link. | Install or update the macOS app, finish GUI onboarding, optionally import Chrome data, quit any old duplicate, launch the official `/Applications` copy, and reply that onboarding is complete. | The latest-stable resolver returns ready, the runner sees exactly one fixed `/Applications` process, and a minimal verified-runner call succeeds even when a stale or shadowed `ego-browser` exists on PATH. |
| 3. Login | Explain which allowed job sites will be visited and pause. | In ego(lite), log in to each selected site and handle any CAPTCHA or OTP, then explicitly reply to continue. | A read-only page observation confirms the expected site/account state without exposing credentials. |
| 4. Resume | Explain local/model data exposure, create a private output directory outside version control, and parse the resume into evidence-backed facts. | Upload a PDF/DOCX and confirm missing or ambiguous facts. | Candidate profile preserves unknowns and cites source evidence. |
| 5. Intent | Turn resume-derived possibilities into a compact proposed intent card; do not treat them as confirmed preferences. | Confirm or edit target roles, industries/domains, preferred and avoided work, locations/work mode, recruitment program and cohort. | `preferences.confirmedByUser` is true; autumn/spring/campus intent maps to cohort-matched campus full-time, not internship. |
| 6. Discover | From each official recruiting home, inspect the visible intent-matched channel entry and its disclosed official link; click it, or follow that exact verified same-domain link when new-tab behavior blocks observable navigation, then verify the destination before searching. | Confirm sites and search budget. | Reviewable job table with company, clickable source link, entry label/link, verified final channel URL/page label, hard-gate failures and uncertainty labels. |
| 7. Draft | Score selected jobs from evidence and create truthful, job-specific material drafts with a diff. | Select exactly one job and approve the material hash. | `批准草稿：<jobId>/<materialHash>` is recorded; no external disclosure has occurred. |
| 8. Fill | If the acceptance report enables real Fill, snapshot the exact employer, URL, fields, answers, files, hashes, and privacy effects. Fill only after exact authorization and stop before final submit. | Review the disclosure snapshot, reply `授权填写：<jobId>/<bindingHash>`, and personally handle sensitive/legal fields. | Filled values and attachments are read back; final submission has not occurred. |
| 9. Submit | If the acceptance report enables real Submit, revalidate the page, persist `submit_prepared`, request the exact second confirmation, persist `submit_started`, click once, and verify the result. | Reply `确认提交：<jobId>/<attemptId>/<bindingHash>` only after final review. | Local ledger records `submitted`, `failed`, `skipped`, or non-retryable `unknown`. |

## Mandatory pauses

- Wait after opening the official installation guide. Codex cannot complete ego(lite) GUI onboarding or Chrome data import for the user.
- Wait while the user logs in or handles CAPTCHA, OTP, identity checks, agreements, payment, or platform warnings. Never read or export passwords, cookies, tokens, or verification codes.
- Wait for a job selection, a draft approval, a disclosure authorization, and a separate final-submit confirmation. “可以”, “继续”, or approval of a draft cannot replace either binding confirmation.
- If the user takes control of an ego-browser task space, do not retry or take it back until the user explicitly says to continue.

## Runtime compatibility

Browser work is enabled only when `scripts/resolve-latest-ego-runtime.sh` resolves Citro Labs' official latest stable GitHub Release, verifies the published asset digest, validates the fixed `/Applications` bundle's Apple identity and notarization, confirms the active runtime is inside that bundle, and proves its `ego-browser/SKILL.md` exactly matches the Release. `scripts/run-verified-ego-browser.sh` then ignores every shell activation link, requires exactly one trusted main process, and executes only the resolver-returned absolute CLI. A successful smoke test alone is not an identity match.

`config/skills.lock.yaml` locks the vendor identity, official update and Release sources, fixed app path and required checks rather than one manually copied version. The acceptance report still records the exact tuple used for evidence, but an official stable update no longer requires editing an allowlist before the controlled harness can test it. Unknown, prerelease, partially observed or mismatched sources fail closed for browser work; offline parsing/drafting may continue only when the Codex host still has an already trusted document capability. A task that cached older skill metadata reads the fully verified active runtime skill as its call contract; it opens a new task only when the runtime executable remains unavailable.

## Acceptance gates

`tests/acceptance-report.md` is the release authority. Codex reads its current release status before every mode change and never infers a pass from the presence of implementation files.

- Discover/Draft on real sites is allowed only when the report explicitly allows it and its required gates have passed.
- Real Fill/Submit is allowed only when the report explicitly enables those modes for the pinned release. Missing, stale, ambiguous, or failed gates mean stop before the first external write/upload.
- When real Fill/Submit is disabled, the same journey may continue with local drafts and an explicitly controlled test form, but it must not be described as a real completed application.

## Demo-ready definition

The golden path is ready to record only when `controlledFixtureRecordingReady` is `true` and a clean macOS/Codex profile completes the path with synthetic resume/contact data, one designated demo job or controlled form, no private data in the recording, and a ledger that survives a restart without duplicate submission. The XHS video must label fixture confirmations as simulated and must not imply unattended batch application.

ByteDance posting `A106199` (Shanghai, daily internship, data analysis) was observed during the 2026-07-27 Discover validation and can be used as a rehearsal seed. It is not a bundled or guaranteed job: every recording/runtime must search again, verify the live official URL and current fields, and accept an expired/removed/zero-result outcome without substituting invented data or silently broadening the query.
