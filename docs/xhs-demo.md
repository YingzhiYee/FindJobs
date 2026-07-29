# XHS demo script

Current target: a 60-75 second public-Beta demo using synthetic data. Lead with the semantic failure candidates hate—campus intent contaminated by internships—then show the confirmed intent card, official recruitment-channel entry and evidence table. Use a reviewed real-site slice only when it exactly matches the acceptance report. Switch visibly to the controlled loopback form for the confirmation/ledger ending. Never enter a real application form or imply that controlled submission is a real employer application.

## Synthetic candidate

- Name: Rowan Example (synthetic fixture)
- Email: `rowan@example.invalid`
- Graduation: 2027, statistics bachelor
- Experience: one analytics internship; one academic logistic-regression risk-screening prototype; one local LLM retrieval/evaluation prototype
- Evidence boundary: use only the facts and caveats in `tests/fixtures/candidate_profile.json`; never claim production deployment, commercial deployment, leadership or invented business metrics
- Target: Shanghai data-analysis internship
- Search query: `数据分析`

Build or use only the tracked Rowan synthetic fixture and its generated documents. Keep the desktop, browser profile, account name, notifications, local paths and real contact information out of frame. Mask the synthetic email/phone too: the recording should demonstrate the workflow, not display contact fields.

## Shot list

| Time | Screen | Voiceover / caption |
| --- | --- | --- |
| 0-3s | Show `目标：2027 校招全职` beside an internship result and add a large red cross | “AI 找得快，不等于找得对。秋招最怕它把实习塞进来。” |
| 3-8s | Paste the short fixed-commit XHS prompt | “我只复制一段话，让 Codex 自己加载开源求职流程。” |
| 8-14s | Show the fixed commit, official runtime and verified-runner ready lines | “它先锁定版本和正式 ego，不会跟着旧 CLI 跑。” |
| 14-23s | Select the synthetic resume and show the proposed intent card | “读完简历也不直接搜；岗位、行业、城市、校招还是实习，先让我确认。” |
| 23-33s | Confirm one primary route, then show a company recruiting home and the visible `校园招聘`/matching channel entry | “确认后才联网，而且必须从官网对应招聘通道进去。” |
| 33-44s | Show a safe zero result for a cohort-mismatched campus target, or an acceptance-allowed result table with number, company, role, location, judgment and original link | “没有就是没有。它不会拿日常实习冒充校招；有结果也一定给原链接。” |
| 44-54s | When an eligible reviewed demo posting exists, show one evidence-based match and truthful material diff; otherwise show the explicit safe-stop card | “匹配看硬条件和证据，不是只数关键词；改材料也不能编经历。” |
| 54-66s | Put persistent `受控投递演示 / 非真实雇主` and `确认短语由测试脚本模拟` labels on screen; show the Fixture Labs fake form and simulated Fill authorization | “后面切到本地假网站，只演示填写前确认和状态记录，不是公司投递。” |
| 66-75s | Keep controlled-demo labels visible; show one simulated fixture click, receipt, ledger, then the GitHub end card | “真实提交现在没开放。项目开源，Prompt 和边界都在 GitHub。” |

## Recording checks

- Use a fresh disposable ego(lite) task space, synthetic search terms and the repository's fictional candidate.
- Keep every real site read-only and cap results so the recording is repeatable.
- Blur or crop browser profile names, avatars, bookmarks, notifications and account identifiers.
- Do not show a real resume, phone number, email address, local absolute path, Cookie, token, OTP or QR code.
- Do not click Apply, upload a file, fill a field or open an application form on any real employer site.
- Keep `受控投递演示 / 非真实雇主` visible from the first loopback-form frame through the receipt/ledger frame.
- Keep `以下不是字节投递` visible at the real-site-to-fixture transition; do not edit around the transition in a way that implies continuity of the destination.
- Keep `确认短语由测试脚本模拟` visible throughout the controlled route. Do not present harness-assigned phrases as user-entered approvals.
- The controlled form may use only the fixed loopback fixture and `application-fake-*` data. Never substitute a real resume, phone, email, job URL or employer name.
- The controlled route keeps the same synthetic Rowan identity but deliberately switches to a separate fake attachment and fictional Fixture Labs job. Keep that target and attachment discontinuity visible.
- Show the fixed commit URL long enough to establish that the prompt is reproducible.
- Show `建议意图卡（待确认）` before any real-site frame, and show the user's explicit intent confirmation before the channel entry.
- For a campus target, show the visible campus entry and channel evidence. Never edit a default/social search page to look like a campus search.
- Every visible shortlist row must include company and original link; crop or blur tracking parameters only if the canonical destination remains clear.
- End on `受控演示成功 / 真实投递未开放`, not on an unqualified “投递成功” claim.

## Publication gate

Before recording, require `controlledFixtureRecordingReady: true`, publish the reviewed commit and generate the concrete fixed-commit prompt in its GitHub Release. G7 passes only after the finished video is reviewed frame by frame for personal data, the persistent controlled-demo labels and overclaiming.
