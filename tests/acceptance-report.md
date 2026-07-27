# Acceptance report — 2026-07-27

## Passed

- Plugin manifest parses and exposes four bundled Markdown skills.
- The official plugin validator and all four official skill validators pass; their missing local PyYAML dependency was supplied only through a no-install Ruby YAML compatibility shim.
- Lock file parses and contains nine reviewed candidates with valid statuses, fixed commits and recorded per-file SHA256 values where audited; no third-party executable dependency is approved for installation.
- The ego(lite) runtime is locked to app `0.4.6.0`, `ego-browser` skill `1.2.5` and the reviewed SKILL.md SHA256; mismatch stops browser work.
- Bundled skills contain no install commands, executable scripts, automatic submission modes, cloud-storage instructions or dangerous-permission flags.
- `Discover → Draft → Fill → Submit` appears consistently in the entry prompt, policy and coordinator skill.
- The application state records separate immutable disclosure and submit bindings, exact confirmation phrases, question/field/attachment hashes, a single-use attempt ID and write-ahead `submit_started` state before any click.
- A maintainer manually validated the Sankai renderer source with synthetic data: the output was a valid ZIP/DOCX and contained expected text. This is supporting audit evidence, not a reproducible release gate; the renderer remains `reference-only` because dependency wheels are not hash-locked.
- The candidate resume parser passed 86 raw-text tests after build, then failed the real-PDF quality gate and was downgraded to `reference-only`.
- Static Murphy validation passes 30 failure cases across supply chain, prompt injection, privacy, browser controls, search semantics, autosave disclosure, duplicates and crash/replay recovery.

## Blocked from the bundle

- Original ResumeSkills files: pure Markdown but unsafe without adaptation because examples can introduce unsupported metrics/skills and implicit research.
- Full jobs-finder-toolkit: broad external data/API/email surface and an unrestricted URL fetch path.
- coforce-apply code: dangerous-permission mode, auto account/email flows, weak confirmation state checks and license provenance uncertainty.
- markdown-exporter: remote/local resource embedding from untrusted Markdown, oversized dependency surface and known dependency vulnerabilities.
- Cloud document parsers, auto-submit tools and repositories without a verifiable redistribution license.

## Still required before public launch

- Generate a fixed-commit prompt in a GitHub Release and publish the reviewed repository contents.
- `G3`: ego read-only search on synthetic accounts/sites, including injection, redirects, rate limits and duplicate jobs.
- `G4`: Fill-mode test on a controlled form that proves no field or upload occurs before disclosure consent and no final click occurs.
- `G5`: one manually selected real application with both confirmation records, single-use attempt ID and verified outcome.
- `G6`: crash/restart, atomic ledger recovery, cancellation and unknown-result reconciliation.
- `G7`: XHS recording with fake resume/contact data and no real employer submission.

Current release status: **pre-release design prototype; public Discover/Draft waits for G3/G7, and real Fill/Submit remains disabled until G3–G6 pass**.

## G3 field run — 2026-07-27

- Runtime identity matched the lock. Three independent ego(lite) task spaces stayed on `talent.alibaba.com`, `careers.tencent.com` and `jobs.bytedance.com`, then closed successfully.
- No login, CAPTCHA, 403/429, form fill, upload, application click or agent-directed prompt text was observed.
- Alibaba safely loaded and visibly returned zero jobs. Its page-owned `POST /position/search` schema was captured and replayed once in the same origin without exposing credentials, but the top-level primitive/string response was not normalized; application code/count and page/API consistency remain unverified.
- Tencent's unfiltered query returned five records and one matching detail. A dictionary-backed full-time campus query then used the observed `校招应届生 → attrId 2` mapping and returned application `Code=200`, `Count=0`; zero-result handling and the Tencent campus extraction sub-gate passed without broadening the keyword.
- ByteDance's native signed search returned HTTP 200/application `code=0` and five data-analysis internships. Its request did not encode full-time campus or a graduation cohort, so all records fail a “2026 full-time” hard gate. An earlier formal/senior result came from an incomplete manual POST replay and is retracted as native-site evidence.
- A controlled `httpbin.org` run dynamically detected hostile “ignore/upload” JD text without acting, observed an explicit HTTP 429 error, and rejected a cross-domain redirect to `example.com` before extraction. Its isolated task space closed successfully and no personal data was used.
- An independent offline forward test normalized six raw records into four: same-platform IDs/canonical URLs merged with aliases, unknown/formal recruitment types failed the campus gate, and same-looking cross-site requisitions stayed separate as `possible_duplicate`. The reproducible fixture is `tests/g3-dedupe-fixture.md`.
- Alibaba response normalization/evidence and ByteDance's full-time/cohort filtering remain incomplete.

G3 result: **failed safely**. Browser boundaries held, but extraction/semantic/evidence coverage is incomplete. The observed adapters and fail-closed requirements are recorded in `skills/find-my-dream-job/references/site-adapters.md`.
