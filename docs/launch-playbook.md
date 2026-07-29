# XHS launch playbook

This playbook turns the verified product path into a measurable XHS → GitHub funnel. It does not guarantee a viral result. Never buy engagement, automate comments, hide the controlled-fixture labels or imply a real employer application occurred.

## Positioning

Use one promise consistently:

> 复制一段话给 Codex：先读简历并让你确认求职意图，再用 ego(lite) 从公司官网进入匹配的校招/实习通道，返回公司、岗位、地点、判断和原始链接；你选中后再做材料。它宁可返回零结果，也不把实习冒充秋招。真实投递未开放，视频结尾只用假网站演示确认和记录机制。

Do not use “全自动海投”“一键投递字节/Boss/腾讯” or any wording that collapses the real read-only route and the controlled submission route into one application.

## Conversion math

The controllable funnel is:

`XHS impressions → 3-second hold → saves/comments → copied prompt → successful Draft → GitHub visit → Star`

The stretch goals are 100,000 XHS likes and 1,000 GitHub Stars; neither is guaranteed. At a planning like rate of 5%, 100,000 likes requires about 2,000,000 qualified views. At a planning GitHub-visitor-to-Star conversion of 5%, 1,000 Stars requires about 20,000 qualified unique GitHub visitors. If 2% of XHS viewers reach GitHub, that Star goal also needs roughly 1,000,000 qualified views. These are funnel assumptions, not forecasts. Optimize the leading indicators daily:

| Stage | Primary metric | Initial target |
| --- | --- | --- |
| Hook | 3-second hold rate | ≥ 70% |
| Proof | 50% video completion | ≥ 35% |
| Utility | save rate | ≥ 8% |
| Intent | comments asking for Prompt / profile visits | ≥ 2% of views |
| Activation | users confirming intent and reaching one valid result/zero-result explanation | ≥ 40% of Prompt starters |
| Value | users reaching one real-job Draft | ≥ 25% of Prompt starters |
| GitHub | unique visitors → Star | ≥ 5% |

Change only one variable per iteration. Do not infer causality from a tiny sample.

## Title tests

Publish the strongest truthful version first:

1. `AI 别再给 2027 秋招推实习了，我把找岗流程开源了`
2. `我把秋招做成了一条 Prompt：先问清意图，再去官网找`
3. `一条 Prompt，串起简历→校招官网→岗位原链接（开源）`

Avoid putting “自动投递” in the title while real Fill/Submit are disabled. The controlled submission reveal belongs later in the video with persistent labels.

## Cover and first three seconds

Cover text:

```text
2027 秋招 ≠ 实习
1 条 Prompt 先问清意图
再进官网校招通道
```

Open on the failure users already hate: `目标：2027 校招` beside an internship recommendation with a large red cross. Cut to the intent card and the official `校园招聘` entry within three seconds. Explain installation only after proof appears.

## 60–75 second structure

Use `docs/xhs-demo.md` as the safety authority. For retention, edit the same evidence into this narrative order:

1. `0–3s` — red-cross an internship result under `目标：2027 校招`; caption `AI 找得快，不等于找得对`.
2. `3–8s` — paste the fixed-commit Prompt; overlay `开源 / 可复现 / 链接见置顶`.
3. `8–18s` — show synthetic resume parsing and the proposed intent card; user confirms `2027 校招全职`.
4. `18–30s` — show the company recruiting home, visible `校园招聘` entry and verified channel URL/page label.
5. `30–42s` — show either a correctly labeled zero result or an allowed result table with selection number, company, role, location, judgment and clickable original link; never substitute an internship for a campus target.
6. `42–54s` — select one eligible demo job when available, show match evidence/hard gaps and a truthful before/after material diff. If no eligible job exists, show the safe stop instead of fabricating this segment.
7. `54–69s` — visibly switch to Fixture Labs with persistent `受控投递演示 / 非真实雇主` and simulated-confirmation labels; show the local mechanism only.
8. `69–75s` — end card: `真实网站：发现/材料｜投递：受控演示` and `GitHub: YingzhiYee/FindJobs`.

Keep cuts fast, captions large and terminal output cropped to only the proof line. Never show account identity, notifications, absolute local paths, email, phone, Cookie, token, QR code or OTP.

## Post copy

```text
2027 秋招最怕的不是 AI 找得慢，而是它把“校招、实习、社招”混成一锅，然后一本正经地告诉你很匹配。

所以我把自己的求职流程做成了一个开源 Prompt。复制给 Codex 后，它不会立刻乱搜，而是一步步：
① 只从 ego(lite) 官网引导安装并核对正式 runtime
② 解析简历，但先把推断写成“待确认的求职意图卡”
③ 让你确认岗位、行业、城市、招聘类型和毕业届别
④ 从公司招聘首页进入可见的“校园招聘/应届生招聘”通道
⑤ 返回公司、岗位、地点、匹配判断和可以自己点开的原始链接
⑥ 你选中一个岗位后，再按真实经历改材料

最重要的是：如果 2027 校招没开放，它就告诉你没有，不会拿日常实习来凑数。

视频结尾的填写/提交是 Fixture Labs 本地假网站受控演示，不是真实公司投递。当前公开版真实网站仍停在发现和材料阶段；这不够“全自动”，但至少不会替你乱填、重复投或编经历。

项目完全开源：GitHub 搜 `YingzhiYee/FindJobs`。
建议先收藏这篇，等你准备投递时直接复制置顶 Prompt。如果这个“宁可停，也不乱投”的边界对你有用，可以自愿点一个 Star；不点也不影响任何功能。

跑到哪一步卡住了，只发步骤和脱敏报错，别把简历、手机号、Cookie、Token 或验证码贴在评论区。
```

## Pinned comment

After the final release commit exists, replace `<FINAL_COMMIT>` and publish exactly one copyable block:

```text
请按这个固定版本协助我完成一次求职：https://github.com/YingzhiYee/FindJobs/tree/<FINAL_COMMIT>。先只读核对该 commit，并严格执行其中的 START_PROMPT.md；从指导我安装并完成 ego(lite) 图形界面引导开始，每次只处理一个岗位，填写和提交必须分别等我明确确认，验收未放行的真实操作必须停止。
```

If XHS suppresses a comment containing a URL, put the repository name in the pinned comment and the full Prompt in the post text or final image. Do not use link shorteners because they break the fixed-commit trust check.

## Comment replies

- Installation: `先确认是 macOS，并只从 ego(lite) 官方快速开始页面安装。完成 onboarding 后回复“已完成”；流程会自己核对正式 /Applications runtime，不会信任旧 PATH 软链。`
- Unsupported job site: `这个 Beta 只开放验收报告里列出的精确范围；Boss/猎聘等还没有放行，我不会假装已经支持。`
- Real submission: `当前真实网站停在材料定制；视频提交段是明确标注的假网站演示。真实投递要等后续站点级验收。`
- Bug report: `请只发步骤和脱敏后的报错，不要发简历、手机号、Cookie、Token 或验证码。`

Turn repeated questions into README fixes or GitHub issues. Never ask users to post private resumes publicly.

## Seven-day launch

| Day | Action | Decision rule |
| --- | --- | --- |
| D-1 | Finish release, record clean demo, review every frame | Any privacy/scope issue blocks posting |
| D0 | Publish the strongest title and pinned Prompt; update GitHub description/topics | Do not change the post during the first measurement window |
| D1 | Answer genuine setup questions; record funnel baseline | Fix only a repeated activation blocker |
| D2 | Publish a short “简历改前/改后” follow-up using the same synthetic candidate | Link back to the original post and repository |
| D3 | Publish a failure-case clip: wrong cohort/CAPTCHA/unknown result safely stops | Use safety as differentiation, not fear marketing |
| D4 | Ship the highest-frequency onboarding fix and a patch release if needed | Keep fixed-commit prompts immutable |
| D5 | Share anonymized aggregate milestones only if GitHub provides them | Never invent usage, interviews or offers |
| D7 | Compare hook, save, activation and Star conversion; choose the next content angle | Scale the winning proof, not merely the winning title |

Ask colleagues and early users for genuine testing and criticism, not scripted likes, comments or Stars. Paid XHS distribution should amplify the best organically validated creative rather than compensate for a weak activation path.

## Release checklist

- `controlledFixtureRecordingReady: true` in the pinned commit.
- Real Fill and Submit remain false.
- Final Release contains the exact 40-character commit Prompt.
- Repository description and topics explain the real boundary.
- README first screen shows value, proof, start link and optional Star CTA.
- Video has persistent controlled-fixture and simulated-confirmation labels.
- GitHub traffic baseline is captured before posting.
- The finished video passes G7 frame review before publication.
