# Golden resume-to-materials dynamic report

Date: 2026-07-27

## Scope and safety

This report covers the local resume -> evidence profile -> job match -> tailored resume segment only. All candidate data is synthetic. The only email domain is `example.invalid`; the phone uses the fictional North American `555-01xx` range. No personal resume, login state, form fill, upload, or submission was used.

The fixture builder is test-only and was run with the already trusted Codex document runtime. The repository does not install or declare a third-party parser dependency.

## Target job

- Company/title: ByteDance, Risk Strategy Data Analysis Intern - TikTok Shop
- Platform job ID: `A106199`
- Official URL: <https://jobs.bytedance.com/campus/position/7665368414857726261/detail>
- Captured: `2026-07-27T15:15:58Z`
- Bounded facts used: current bachelor-or-higher students; at least three months; international e-commerce merchant risk analysis/monitoring; risk profiles/models/strategies; analysis and iteration recommendations; independent model development/implementation; cross-functional collaboration; complex-data risk/anomaly analysis; AI/LLM practice; communication/rigor; working English; statistics-related education and risk-control experience preferred.

No other company or job facts were added.

## Happy-path result

1. A real DOCX source fixture was generated and parsed back locally.
2. The source and tailored SHA-256 values are recorded in the generated contracts and are checked against the exact files after every build; the report does not freeze one run's hash.
3. The profile retained the exact August/September 2025 conflict instead of choosing a date. A synthetic explicit user answer (`USER-A1`) resolves it to August only for the tailored document.
4. Matching applied two hard gates and the documented score formula. Both hard gates passed. The result is `possible_match`, score `65/100`, confidence `medium`.
5. Academic/synthetic risk work remained labeled as such. Production deployment and commercial risk-control experience were recorded as gaps, not invented qualifications.
6. Repeated builds produce byte-identical DOCX/PDF fixtures, so hash-bound approvals can be reproduced instead of drifting because of container timestamps.
7. Source and tailored DOCX/PDF each rendered to one Letter page. Visual review found no clipping, overlap, corrupted glyph, orphan heading, broken reading order, or unexpected page growth.
8. DOCX and text-layer PDF readback recovered the expected facts and exact candidate email. `ApplicationDraft.readyForReview` remains `false` because no user has approved the rendered draft.

The generated contracts are `candidate_profile.json`, `candidate_job_posting.json`, `candidate_match_report.json`, and `candidate_application_draft.json` under `tests/fixtures/`.

## Commands and observed results

Fixture build and structural verification:

```text
<trusted-runtime-python> tests/fixtures/candidate_fixture_builder.py build
```

Observed: all eleven structural checks passed, including DOCX and text-layer PDF readback, conflicting-date capture, exact contact isolation, wrong-contact rejection, two-column detection, image-only PDF detection, and absence of the fabricated metric.

DOCX render/readback gate:

```text
<trusted-runtime-python> <documents-skill>/render_docx.py tests/fixtures/<fixture>.docx --output_dir <temporary-qa-dir> --emit_pdf
```

Observed page counts:

| Fixture | Pages | Expected gate |
| --- | ---: | --- |
| `resume_candidate_source.docx` | 1 | pass |
| `resume_candidate_tailored.docx` | 1 | pass |
| `resume_candidate_source.pdf` | 1 | pass text-layer parsing |
| `resume_candidate_tailored.pdf` | 1 | pass export readback |
| `resume_candidate_wrong_contact.docx` | 1 | reject before upload |
| `resume_candidate_two_column.docx` | 1 | `needs_layout_review` |
| `resume_candidate_overflow.docx` | 6 | reject unexpected growth |
| `resume_candidate_scanned.pdf` | 1 visible image, zero extracted text | `needs_ocr` |

Every rendered page was visually inspected. QA render files remained in a temporary directory and are not repository artifacts.

## Murphy-law cases

| Case | Injected failure | Observed result | Status |
| --- | --- | --- | --- |
| Conflicting dates | Heading says August; bullet says September | Both evidence refs retained in `conflicts`; synthetic user correction required for draft | pass |
| Fabricated metric | Proposed `31%` production fraud-loss claim | No allowlisted evidence; mutation rejected and absent from output | pass |
| Wrong contact | Output uses `other.candidate@example.invalid` | Extracted-contact set differs from profile allowlist; upload gate fails | pass |
| Two-column resume | Native two-column section with cross-column flow | Section column count detected; visible reading-order ambiguity requires review | pass-safe |
| Scanned PDF | Visible text embedded only as a page image | Text extraction is empty; status must be `needs_ocr`, with no matching/tailoring | pass-safe |
| Page overflow | Tailored fixture padded to 74 extra bullets | Render grows from intended one page to six; layout gate fails | pass |
| Synthetic/commercial confusion | Academic synthetic risk project resembles JD | Output preserves both `academic` and `synthetic`; no commercial or production claim | pass |

## Skill hardening

- `resume-evidence-profile`: deterministic file selection, hash, DOCX/PDF diagnostics, stable evidence locators, two-column/text-layer checks, conflict/contact gates.
- `evidence-job-match`: source-evidenced requirement normalization, hard-gate semantics, fixed 70/30 scoring, status multipliers, confidence and decision mapping.
- `truthful-application-materials`: claim allowlist, immutable critical values, other-candidate isolation, changed-claim reconciliation, hash-bound approval, render and export readback blockers.

## Remaining gaps

- OCR is intentionally not implemented. Image-only resumes stop safely and need separate user consent plus low-confidence review.
- Ambiguous two-column/text-box reading order is detected but not automatically repaired; a simpler source or human confirmation is still required.
- A real user's private output directory, model-disclosure consent, and final rendered-document approval were not exercised with personal data.
- Browser Fill/Submit and ledger persistence are outside this report. Passing this report does not enable real upload or submission.

Within this segment, the one-page DOCX/PDF golden path is dynamically usable with explicit review. The safe-stop branches are also observable and deterministic.
