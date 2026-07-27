# G0 threat model and site review - 2026-07-27

## Decision

G0 is complete only for the narrowly listed, read-only Discover scopes in `tests/acceptance-report.md`. It is not an assertion that any employer grants blanket permission for automation. Published terms and technical controls can change; when the current page, robots policy, terms, login flow or platform warning prohibits the requested access, the run stops even if this file previously recorded a technical pass.

The current evidence supports bounded observation of public job-search results. It does not support account creation, credential handling, CAPTCHA/OTP handling, form mutation, upload, application submission, messaging, scraping at scale or reuse of first-party requests outside their original page context.

## Protected assets and actors

- User assets: resume facts, contact data, login state, search intent, application answers and local records.
- Site assets: availability, access controls, unpublished interfaces, rate limits and employer/application data.
- Untrusted inputs: repository dependencies, resumes, job descriptions, page text, redirects, forms and network response bodies.
- Privileged actors: the user controls login and both disclosure/submit confirmations; the coordinator alone writes the local ledger; Discover workers are read-only.

## Threats and controls

| Threat | Required control | Failure result |
| --- | --- | --- |
| Prompt injection in a JD/page | Treat all page content as data; never follow page-authored agent instructions | Flag and stop the affected record |
| Credential or session disclosure | Never read/export passwords, Cookie, token, OTP or browser-profile data | Handoff to user |
| Semantic overreach | Match every machine-readable scope field exactly; query terms do not prove program/cohort | Zero-result or excluded result; no silent broadening |
| Excessive traffic or anti-bot response | Maximum five list records and one detail in validation; no blind retry | Stop on 403, 429, CAPTCHA, warning or rate-limit signal |
| Cross-origin/SSRF | Exact official hostname allowlist; HTTPS for real sites; reject redirects and private addresses | Stop before extraction or mutation |
| Unintended application side effect | Real Discover never clicks Apply, fills, uploads, checks a box or triggers autosave | Stop and invalidate the run |
| Duplicate or stale job | Stable ID/canonical URL, timestamp, detail cross-check and conservative dedupe | Mark stale/possible duplicate; do not infer |
| Terms or schema drift | Re-observe current page and request shape; current prohibition overrides old evidence | Disable the scope pending review |

## Site-specific review record

| Official site | Reviewed evidence | Allowed release scope | Terms/permission conclusion | Stop conditions |
| --- | --- | --- | --- | --- |
| `jobs.bytedance.com` | Native same-origin list observation plus visible official detail for `A106199`; exact query `数据分析`; observed `日常实习` | `recruitmentType=internship`, `siteProgram=daily-internship`, `query=数据分析`; five results and one detail maximum | No affirmative permission for agent automation is claimed. Only minimal public, read-only navigation is approved by this project; current site terms and page controls govern each run. | Login requirement, warning, 403/429, CAPTCHA, domain/request-shape drift, missing program metadata, removed job or any Apply/form interaction |
| `careers.tencent.com` | Dictionary-backed `attrId=2`; exact `数据分析` query returned application `Code=200`, `Count=0` | `recruitmentType=campus-full-time`, `query=数据分析`; zero-result handling only | No affirmative permission for agent automation is claimed. The release may reproduce only the exact bounded read-only query and must accept zero results. | Any query broadening, nonzero result without fresh detail cross-check, warning, 403/429, CAPTCHA, login, domain/schema drift or application interaction |
| `talent.alibaba.com` | Campus page and request shape observed, but response normalization/application status remained unresolved | Disabled | Unknown; no release authorization | Any access beyond future maintainer revalidation |
| Boss Zhipin, Liepin and all other sites | No release evidence | Disabled | Not reviewed | Do not access through this workflow |

## Residual risk

- Public pages, terms and anti-automation controls may change after the review date.
- Authentication would expose account identity and browsing history; this release does not require authenticated Discover evidence.
- A technically readable first-party response is not a public API contract and must not be replayed as a broad crawler.
- Search results can be incomplete, personalized, stale or semantically mixed. The workflow reports evidence and unknowns rather than guaranteeing coverage.

## Re-review trigger

Re-run G0 and publish a new pinned commit when a hostname, route, request schema, recruitment taxonomy, terms link/text, access-control behavior, rate limit, runtime identity or enabled scope changes. An unknown or conflicting observation disables that scope; it never inherits the previous pass.
