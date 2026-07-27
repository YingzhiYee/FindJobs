---
name: truthful-application-materials
description: Prepare evidence-backed resume changes, cover letters, and application-answer drafts for one selected job, with diffs and sensitive-field handoff; never submit or invent facts.
---

# Truthful Application Materials

Use this skill in `Draft` mode for one selected `JobPosting`, `CandidateProfile`, and `MatchReport`. It creates an `ApplicationDraft`; it does not operate the browser, fill a form, upload a file, or submit an application.

## Resume tailoring

- Reorder or omit evidence-backed material to emphasize relevance.
- Use JD terminology only when it accurately describes existing evidence.
- Preserve employers, titles, dates, degrees, certifications, metrics and project ownership exactly unless the user confirms a correction.
- New numbers, skills, responsibilities or claims go to `missingRequiredFields`/`riskFlags`; they never enter the final draft automatically.
- Keep the source resume immutable and create a new version with a content hash.
- Produce a machine-readable before/after diff with evidence IDs.

## Cover letter and free-text answers

- Every factual sentence must trace to candidate evidence or a cited company/JD source.
- Metrics are optional. Never manufacture one to make the writing stronger.
- Company news, referrals, employee names and product claims require a source and user confirmation.
- Mark tone-only language separately from factual claims.
- Do not promise availability, compensation, work authorization or legal eligibility without user-provided values.

## Sensitive fields

Never infer or auto-answer salary expectations, visa/work authorization, citizenship, disability, health, criminal history, veteran status, ethnicity, gender, age, signature, consent or other legal/self-identification fields. Add them to `missingRequiredFields` and ask the user at the point of use.

## Quality gate

Before setting `readyForReview`:

1. Check every changed claim against evidence.
2. Show the diff, job/company names, document version and unresolved fields.
3. Render and re-read the output when a trusted local document tool is available; fail on missing text, wrong contact details, page overflow or corrupted characters.
4. Keep `readyForReview: false` until the user approves the material.

This skill never uploads a file, fills a website, clicks a button or changes the permission mode.
