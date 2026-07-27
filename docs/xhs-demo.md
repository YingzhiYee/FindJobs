# XHS demo script

Current target: a 60-75 second public-Beta demo using synthetic data. Show one reviewed real-site Discover slice and local Draft, then switch visibly to the controlled loopback form for the two-confirmation Fill/Submit/ledger ending. Never enter a real application form or imply that controlled submission is a real employer application.

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
| 0-5s | Open Codex and paste the short fixed-commit XHS prompt | “我只复制一段话，让 Codex 自己加载求职流程。” |
| 5-12s | Show the fixed GitHub commit check and ego-browser version check | “它会先核对固定版本和浏览器能力，不会直接安装陌生脚本。” |
| 12-20s | Select the synthetic resume and the private output folder | “这里用假简历；解析内容会进入 Codex，会话外文件留在本地私有目录。” |
| 20-31s | Show a read-only ByteDance daily-internship search and one verified detail | “它按已验收的范围找真实岗位，岗位失效或范围不符就停。” |
| 31-41s | Show the deduplicated job table, select one job, and show the evidence-based match result | “我先选一个岗位；它会标出硬条件、证据和未知项，而不是只数关键词。” |
| 41-51s | Show a before/after resume diff, material hash and explicit draft approval | “改写只能用已有事实；我确认这个版本后，才会进入下一步。” |
| 51-64s | Put persistent `以下不是字节投递`, `受控投递演示 / 非真实雇主`, and `确认短语由测试脚本模拟` labels on screen; show the Rowan fake form, simulated exact Fill authorization, and stop before submit | “现在切到假网站。为了演示状态机，确认短语由测试脚本模拟；真实使用必须由用户单独确认。” |
| 64-75s | Keep all controlled-demo labels visible; show the simulated Submit phrase, one controlled click, receipt, and local ledger status | “真实提交还要再确认一次，只点一次，结果和异常都会留在本地。” |

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
- End on `受控演示成功 / 真实投递未开放`, not on an unqualified “投递成功” claim.

## Publication gate

Before recording, require `controlledFixtureRecordingReady: true`, publish the reviewed commit and generate the concrete fixed-commit prompt in its GitHub Release. G7 passes only after the finished video is reviewed frame by frame for personal data, the persistent controlled-demo labels and overclaiming.
