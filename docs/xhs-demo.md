# XHS demo script

Current target: a 45-60 second Discover/Draft demo using synthetic data. Do not enter a real application form or imply that real Fill/Submit has passed acceptance.

## Synthetic candidate

- Name: 林遥（虚构）
- Email: `demo@example.invalid`
- Graduation: 2026, information management bachelor
- Experience: one data-analysis internship; one three-person Python/pandas course project
- Evidence boundary: participated in recommendation logic; never claim ownership, leadership, SQL work years or business metrics
- Target: Shanghai/Hangzhou data analysis or product roles
- Search salary: 18-25K, `filter_only`

Prepare the synthetic resume outside the public repository. Keep the desktop, browser profile, account name, notifications, local paths and real contact information out of frame.

## Shot list

| Time | Screen | Voiceover / caption |
| --- | --- | --- |
| 0-5s | Open Codex and paste the complete `START_PROMPT.md` text | “我只复制一段话，让 Codex 自己加载求职流程。” |
| 5-12s | Show the fixed GitHub commit check and ego-browser version check | “它会先核对固定版本和浏览器能力，不会直接安装陌生脚本。” |
| 12-20s | Select the synthetic resume and the private output folder | “简历用假数据演示，真实材料只放本地私有目录。” |
| 20-32s | Show three read-only search workers on allowed official career sites | “多个 agent 可以并行找岗位，但只读取，不填表、不投递。” |
| 32-42s | Show the deduplicated job table and evidence-based match result | “它会标出硬条件、证据和未知项，而不是只数关键词。” |
| 42-52s | Show a before/after resume diff | “改写只能使用简历里已经存在的事实，不能编经历和数字。” |
| 52-60s | Show the local output summary and release status | “当前版本先开放找岗位和改材料；真实填写和投递通过验收后再开放。” |

## Recording checks

- Use a fresh disposable ego(lite) task space and synthetic search terms.
- Keep every site read-only and cap results so the recording is repeatable.
- Blur or crop browser profile names, avatars, bookmarks, notifications and account identifiers.
- Do not show a real resume, phone number, email address, local absolute path, Cookie, token, OTP or QR code.
- Do not click Apply, upload a file, fill a field or open a real employer application form.
- Show the fixed commit URL long enough to establish that the prompt is reproducible.
- End on the generated shortlist/diff, not on a marketing promise or a submission success claim.

## Publication gate

Before recording, publish the reviewed commit, generate the concrete fixed-commit prompt in its GitHub Release, and complete G3. G7 passes only after the finished video is reviewed frame by frame for personal data and overclaiming.
