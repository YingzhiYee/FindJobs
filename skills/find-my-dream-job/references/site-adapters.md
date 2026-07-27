# Reviewed site adapter observations

Use this reference only for read-only `Discover` work on the listed official domains. These are observed behaviors from 2026-07-27, not stable APIs or permission to bypass site controls. Stop on domain drift, bot warnings, login requirements, response-shape drift or terms that prohibit the requested automation.

## Common contract

1. Verify the final hostname against the exact allowlist before extracting or following a link.
2. Prefer the site's already-observed same-origin request semantics over guessing undocumented parameters. Never replay credentials outside the page origin.
3. Cap a validation query at five records and one detail page unless the user approves a larger read-only budget.
4. Record the query intent separately from the returned facts. A search term does not prove recruitment type, graduation cohort, location or seniority.
5. Require stable job ID, title, company, location, recruitment type, original URL and capture time. Mark missing values `unknown`.
6. Verify one list record against its same-origin detail page before trusting an adapter revision.
7. Treat a parsed JSON object as application data, not proof of HTTP status. Record transport status/content type when the runtime exposes them; otherwise require an observed application success field or a visible list/detail cross-check and label transport evidence unavailable.
8. Do not promote a job to the shortlist when a requested hard constraint is `unknown` or contradicted. In particular, campus/internship searches must reject experienced/formal roles unless the user changes scope.

## Alibaba

- Allowlist: `talent.alibaba.com`.
- The observed campus page redirected to `?campusType=freshman` and visibly reported zero open jobs.
- The empty page rendered no anchors, so broadening DOM link selectors is not a valid fix.
- Observed same-origin XHR paths included `/searchCondition/list` for filter metadata and `/position/search` for job search.
- The page's own search was observed as `POST /position/search` with `_csrf` in the query and body keys `batchId`, `categoryType`, `channel`, `corpCode`, `customDeptCode`, `key`, `language`, `pageIndex`, `pageSize`, `regions`, and `subCategories`.
- One same-origin replay preserved the captured URL/body and only non-credential `accept`/`content-type` headers. `fetch.browser` returned a top-level primitive/string shape that the validation normalizer did not parse, so application code/count remain unverified; this is not evidence that the API failed.
- A future adapter must safely normalize one top-level string/primitive before requiring an object, while preserving the exact page-observed request. Do not guess CSRF values or parameters, and do not claim success until application code/count and zero-result or one-detail consistency are verified.

## Tencent

- Allowlist: `careers.tencent.com`.
- Job cards use surrounding `.recruit` containers; anchors can be textless `/search.html?query=<opaque-id>` links rather than traditional detail paths.
- The public list URL's `query` value did not reliably apply the intended keyword and may show the default first page.
- The observed same-origin job endpoint is `/tencentcareer/api/post/Query`. Select it by exact pathname, not a broad regex over query values.
- The observed dictionary application response (`Code=200`) mapped `校招应届生 → PostAttr Code 2`, `校招实习生 → Code 3`, and `校招青云计划 → Code 5`. Map full-time graduating students to 2, internship only to 3, and Qingyun only after the user names that program. A graduation year alone never authorizes internship or a special program.
- A validation request with `keyword=数据分析` and `pageSize=5` returned stable post IDs and fields. A constructed same-origin `/jobdesc.html?postId=<id>` detail matched title, company and location for the first result.
- The unfiltered observed `attrId` was empty and must not be labeled campus. A later dictionary-backed full-time campus query used `attrId=2`, returned application `Code=200` and `Count=0`, and correctly stopped without broadening the keyword. This passes the Tencent campus extraction/zero-result sub-gate.
- `fetch.browser` may expose a parsed object or a top-level JSON string and may omit transport status/content type. Normalize one top-level JSON string safely, require the application `Code` when available, and retain the visible list/detail cross-check for non-empty results.

## ByteDance

- Allowlist: `jobs.bytedance.com`.
- The page's native search request was a signed same-origin `POST /api/v1/search/job/posts`. Its native response was HTTP 200, application `code=0`, count 3313; the first five records were data-analysis internships.
- The observed request had a non-empty keyword, but `recruitment_id_list` and `subject_id_list` were empty and no graduation-cohort field was present. The campus route alone does not prove “2026 full-time campus”.
- A later visible golden-path query for `数据分析` observed the native search transport at HTTP 200 and rendered five job-card links, but the response body could not be reread after the network event (`No resource with given identifier found`). Treat this as transport plus visible-DOM evidence, not application-body evidence. The rendered set was semantically mixed: some cards matched only JD body text and included daily internships, ByteIntern and 2027 full-time roles. Filter on the card's first-line title and explicit recruitment metadata; never treat the query match as title, program or cohort evidence.
- The daily-internship card `风险策略数据分析实习生 - TikTok Shop` (`A106199`, Shanghai) was opened at its canonical same-origin detail URL. The visible detail confirmed title, ID, location, `日常实习`, responsibilities and requirements. This passes one ByteDance daily-internship list/detail discovery slice; it does not pass a full-time or graduation-cohort slice, and the posting may expire.
- On that detail page, `投递` was a same-page `BUTTON` with no static `href`. Read-only discovery must not click it. After per-job disclosure authorization, a Fill implementation must click once, then freshly classify the resulting login, handoff, form, redirect or error state before any field action.
- An earlier manually reconstructed POST returned formal/senior roles, but it omitted the page's signature and complete query shape. That result is invalid as evidence of native site semantics and must not be used by the adapter.
- Require explicit observed recruitment program and graduation cohort before matching. Internship results fail a full-time campus target; an unknown cohort fails a cohort-specific target.
- Observe the page's native signed request/response. Do not manually construct, modify or replay a partial search request; retain DOM extraction only as a read-only fallback with the same semantic gate.

## Current gate result

The technical read-only boundary held on all three domains: no login, form fill, upload, application click, CAPTCHA, 403/429 or agent-directed prompt text was observed. Separate controlled fixtures detected hostile JD instructions without acting, surfaced an HTTP 429 as a stop signal, and rejected a cross-domain redirect before extraction. An offline six-record forward test passed confirmed/possible duplicate handling and recruitment hard gates.

Release `0.4.0-beta.1` enables only two G3 scopes, with every field matched exactly: Tencent `recruitmentType=campus-full-time`, `query=数据分析` for exact-query/zero-result handling; and ByteDance `recruitmentType=internship`, `siteProgram=daily-internship`, `query=数据分析` for native-list/visible-detail discovery. A synonym, omitted field, broader keyword, changed program or different recruitment type is outside the evidence. Alibaba, ByteDance full-time or cohort-specific search, Tencent scopes not named by the acceptance report, and every unlisted site remain disabled. A narrow pass never implies a whole-site adapter pass.
