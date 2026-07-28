# Acceptance report - 2026-07-28

## Authoritative release status

This block is the release gate. A consumer must use the exact booleans and scopes below, not infer broader permission from prose or implementation files. A missing, unknown, or changed scope is disabled.

```yaml
schemaVersion: 1
release: 0.4.0-beta.1
publicBetaEnabled: true
offlineResumeEnabled: true
trustedDocumentCapabilityRequired: true
localDraftEnabled: true
realDiscoverEnabled: true
realDiscoverScopes:
  - site: jobs.bytedance.com
    recruitmentType: internship
    siteProgram: daily-internship
    query: 数据分析
    evidence: native-list-plus-visible-detail
  - site: careers.tencent.com
    recruitmentType: campus-full-time
    query: 数据分析
    evidence: exact-query-zero-result
controlledFixtureFillEnabled: true
controlledFixtureSubmitEnabled: true
controlledFixtureRecordingReady: true
realFillEnabled: false
realSubmitEnabled: false
gates:
  G0: passed-for-listed-read-only-scopes-with-no-blanket-permission-claim
  G1: passed
  G2: passed
  G3: passed-for-listed-scopes-only
  G4: passed-controlled-fixture-only
  G5: not-run
  G6: partial-controlled-single-writer-fixture
  G7: pending-video-review
```

The highest real-site mode is `Draft`, and only after a posting is found inside an allowed Discover scope. The controlled fixture may exercise `Fill` and `Submit` with `application-fake-*` data. No real employer or ATS page may receive a field value, attachment, checkbox change, autosave trigger, or final click in this release.

## Passed

- Plugin manifest parses and exposes four bundled Markdown skills.
- The official plugin validator and all four official skill validators pass; their missing local PyYAML dependency was supplied only through a no-install Ruby YAML compatibility shim.
- The lock file contains nine reviewed candidates with fixed commits and recorded per-file SHA-256 values where audited. No third-party executable dependency is approved for installation.
- Browser validation used the exact acceptance-tested tuple ego(lite) `0.4.6.1`, `ego-browser` `1.2.5`, date `2026-07-16`, and SKILL.md SHA-256 `3d2d43ba61ace9977827f0343d333c597ac6f3d1a0a207a4a62b16468c3292c7`. Runtime admission resolves the official latest stable Release dynamically; this line records the runtime used by the passing rerun rather than a manual allowlist.
- G0 documents the threat model, exact query scopes, unknown/variable terms risk and fail-closed re-review triggers in `g0-threat-model.md`; it does not claim blanket site permission.
- The PDF/DOCX resume-to-profile-to-match-to-material path passed deterministic build, parse/readback, render, contact-isolation, truthfulness and layout gates. See `golden-resume-report.md`.
- ByteDance daily-internship discovery passed a native list plus visible official detail check for posting `A106199`. Tencent campus-full-time exact-query semantics passed with a verified zero-result response. Separate navigation observations confirmed that both official recruiting homes expose visible campus entries and that the destination URL/page label can be verified before searching; those observations do not add a query, cohort or recruitment-program scope. These are narrow adapter scopes, not whole-site approval.
- Hostile JD text, HTTP 429, cross-domain redirect, recruitment-semantic mismatch and conservative deduplication all failed safely.
- The current controlled `Fill -> Submit -> ledger -> restart/replay` harness passed dynamically against the fixed loopback fixture. It wrote and replayed 23 fsynced, hash-chained events, maintained two owner-only HMAC sidecars, recovered a byte-preserved partial tail into a new generation, rejected attempt replay, and completed a fresh-confirmation retry cycle without a second browser click. This enables fake-data recording, so `controlledFixtureRecordingReady` is true. Operating-system exclusive-lock contention between concurrent writers has not been dynamically exercised, so G6 remains partial. See `golden-submit-report.md`.
- Static Murphy validation covers 39 failure cases across supply chain, prompt injection, privacy, browser controls, intent confirmation, recruitment-channel selection, search semantics, autosave disclosure, duplicates and crash/replay recovery.

## Explicitly disabled

- Alibaba Discover remains disabled because its top-level response was not normalized and cross-checked.
- Boss Zhipin, Liepin, and all unlisted sites/scopes remain disabled because this release has no dynamic adapter evidence for them.
- ByteDance full-time/cohort-specific Discover remains disabled. A campus route or search keyword does not prove recruitment type or graduation cohort.
- Tencent scopes other than the exact reviewed campus-full-time query remain disabled.
- The visible ByteDance/Tencent campus-entry checks are navigation evidence only. The absence of an observed 2027 full-time opening cannot be replaced with an internship, a social-recruiting result or a guessed campus route.
- Real `Fill` and `Submit` remain disabled. G4 and the tested portion of G6 used only the loopback fixture for fictional company `Fixture Labs`; no real employer/ATS page was opened or mutated.
- Unattended, batch, CAPTCHA-bypassing, OTP-handling and blind-retry behavior remains forbidden.

## Gate evidence

### G2 - resume and material path

`tests/golden-resume-report.md` records the passing one-page DOCX/PDF path and safe stops for conflicting dates, a fabricated metric, wrong contact data, two-column layout, scanned PDF and page overflow. Image-only PDFs intentionally stop at `needs_ocr`; ambiguous layouts require human review.

### G3 - scoped real discovery

- ByteDance: the native search rendered five data-analysis results. Official detail `A106199` confirmed title, ID, Shanghai, `日常实习`, responsibilities and requirements. Every run must re-search and revalidate the live page; removed, expired, zero-result or changed-schema outcomes stop safely.
- Tencent: the observed dictionary mapped `校招应届生` to `attrId=2`; the exact `数据分析` campus-full-time query returned application `Code=200`, `Count=0` and was not broadened.
- Alibaba: the campus page visibly returned zero jobs, but application code/count and page/API consistency remain unverified. It is not an allowed scope.
- Controlled fixtures detected hostile instructions without acting, surfaced 429, rejected a cross-domain redirect, and preserved conservative duplicate handling.

### G4 and partial controlled G6 - form and persistence

`tests/golden-submit-report.md` records zero mutation before authorization, exact disclosure and submit phrases, approved-field-only filling, attachment readback, write-ahead `submit_started`, one semantic click, receipt verification, replay rejection, mutation/cross-origin/CAPTCHA stops, sensitive-field handoff, ambiguous-result handling, restart recovery, HMAC sidecars, generation switching and a no-click retry cycle. This evidence enables only the repository's controlled fixture and its clearly labeled recording. It does not prove that the exclusive operating-system lock rejects a competing writer.

## Still required for real application submission

`G5` is the main real end-to-end gate: one user-selected real application must be exercised with real materials, both exact confirmations, durable ledger evidence, one final click, and a verified or explicitly `unknown` outcome. It is not the only remaining evidence. The same later pinned release must also record exact-ATS G4/G6 behavior, including dynamic exclusive-lock contention and recovery, for the scope it enables. These tests require a consenting user and must not be simulated or claimed from the controlled fixture.

After G5 and the matching exact-ATS G4/G6 evidence pass, publish a new pinned commit and release that changes `realFillEnabled` and `realSubmitEnabled` only for the exact tested site/ATS scope. G7 passes after the finished XHS video is reviewed frame by frame for private data, scope labels and overclaiming; it does not unlock real submission.
