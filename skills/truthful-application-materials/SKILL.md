---
name: truthful-application-materials
description: Prepare evidence-backed resume changes, cover letters, and answer drafts for one selected job, with claim-level diffs, contact isolation, local render/readback QA, and no submission or invented facts.
---

# Truthful Application Materials

Use this skill in `Draft` mode for one user-selected `JobPosting`, ready `CandidateProfile`, and `MatchReport`. It creates one `ApplicationDraft`; it does not operate the browser, fill a form, upload a file, or submit an application.

## Preconditions and output isolation

Require the exact job ID, company, title, canonical URL, source resume hash, and selected output format. In a real run, write only to the user-selected private output directory outside version control. Never overwrite the source or a previous draft. Synthetic repository fixtures are the only exception to the output-directory rule.

Start from the selected candidate's profile in the current run. Do not reuse contact details, headers, template placeholders, or claims from another candidate, a browser autofill profile, or a prior job package.

## Claim ledger before drafting

Build an internal allowlist with one row per usable claim:

| Claim ID | Exact fact | Allowed transformations | Candidate evidence | Risk |
| --- | --- | --- | --- | --- |

Critical values are immutable without explicit correction evidence: name, email, phone, employer, title, dates, degree, school, certification, metric, project ownership, and experience type (`academic`, `synthetic`, `internship`, or commercial). Preserve the source wording for all numeric values in the allowlist.

Any proposed sentence containing a new proper noun, skill, responsibility, date, duration, number, percentage, currency, team size, or ownership verb must map to the allowlist. Otherwise remove it and add a `riskFlag` or `missingRequiredField`; never ask the model to make it plausible.

## Resume tailoring

- Reorder or omit evidence-backed material to emphasize relevance.
- Use JD terminology only when it accurately describes existing evidence and does not change the experience type or scope.
- Preserve employers, titles, dates, degrees, certifications, metrics, and ownership exactly unless the user confirms a correction.
- Keep synthetic or academic work labeled as such; never present it as production or employer work.
- Use only transformations declared in the claim ledger, such as shortening, active-voice rewriting, or combining two claims that share evidence.
- Create a new version and a machine-readable before/after diff with evidence IDs for every changed bullet.

## Cover letters and answers

- Every factual sentence must trace to candidate evidence or a cited company/JD source.
- Tone-only language must be marked separately from factual claims.
- Company news, referrals, employee names, products, and impact claims require a source and user confirmation.
- Do not promise availability, compensation, work authorization, legal eligibility, or relocation without an explicit user-answer evidence ID.
- Metrics are optional. Never manufacture one because a template contains a placeholder or the JD uses metrics.

## Sensitive fields

Never infer or auto-answer salary expectations, visa/work authorization, citizenship, disability, health, criminal history, veteran status, ethnicity, gender, age, signature, consent, or other legal/self-identification fields. Add them to `missingRequiredFields` and leave them for the user at the point of use.

## Deterministic export QA

After generating the local document, keep `readyForReview: false` and run all of these checks with an already trusted local document capability:

1. Compute the output SHA-256 and record the exact source and output paths.
2. Parse the exported file back. Verify that all expected sections and every approved critical value are present.
3. Compare all extracted emails and phone numbers with the selected candidate contact allowlist. Any missing, altered, placeholder, or foreign contact blocks the draft.
4. Reconcile every changed factual sentence to the claim ledger and diff. Any unsupported number, skill, scope, ownership verb, or company-specific claim blocks the draft.
5. Render every page and inspect it at readable scale. Fail on clipping, overlap, corrupted glyphs, hidden/missing text, broken links, empty pages, orphan headings, unexpected page-count growth, or content beyond the intended page budget.
6. Check reading order for columns/tables and confirm that extraction of the exported document returns the same semantic order visible in the render.
7. Scan the artifact and QA outputs for another candidate's name, email, phone, or template placeholders.

If the original format is ambiguous, create a clean new layout rather than reproducing a broken two-column structure. If rendering or readback is unavailable, stop; do not mark the file ready or upload it.

## Output and approval gate

Return the `ApplicationDraft` contract from `find-my-dream-job` plus:

```json
{
  "claimLedger": [],
  "qa": {
    "sourceSha256": "<hash>",
    "outputSha256": "<hash>",
    "readbackPassed": false,
    "criticalValuesPassed": false,
    "contactIsolationPassed": false,
    "claimReconciliationPassed": false,
    "renderedPages": [],
    "layoutPassed": false,
    "issues": []
  }
}
```

Before setting `readyForReview`:

- show the machine-readable diff, exact job/company, output version/hash, unresolved fields, and risk flags;
- require every QA flag above to pass;
- keep `readyForReview: false` until the user reviews the rendered package;
- after explicit draft approval, record the approval against the exact output hash. A later edit changes the hash and invalidates approval.

Approval of a draft is not authorization to fill, upload, or submit it. This skill never changes the coordinator permission mode.
