# Find My Dream Job

> 复制一段 Prompt 给 Codex，让它引导你安装 ego(lite)、读取简历、在已验收范围内找真实岗位、做证据匹配并生成定制材料。真实招聘网站的填写与提交默认关闭；仓库另提供明确标注的假网站受控演示。

**你只需要做四件事：**复制 Prompt、完成 ego(lite) 图形界面引导、上传简历、在关键节点确认。Codex 每次只问一个问题。

- [从 `v0.4.0-beta.2` Release 获取一键 Prompt](https://github.com/YingzhiYee/FindJobs/releases/tag/v0.4.0-beta.2)
- [查看 60–75 秒演示脚本](docs/xhs-demo.md)
- [查看当前真实能力与未开放边界](tests/acceptance-report.md)

## 直接复制给 Codex

```text
请使用这个开源求职流程协助我：https://github.com/YingzhiYee/FindJobs 。使用 GitHub Release v0.4.0-beta.2，先核对该 Release 指向的固定 commit 和验收报告，再严格执行其中的 START_PROMPT.md。从 ego(lite) 官方安装引导开始，读取简历后先和我确认求职意图，每次只处理一个岗位；填写和提交必须分别获得我的明确确认，未通过验收的真实操作必须停止。
```

如果它确实帮你完成了一次岗位搜索或材料定制，欢迎给仓库点一个 Star，方便秋招时回来继续用。Star 完全可选，不影响任何功能。

这是一个面向 Codex + ego(lite) 的求职流程启动包。它把简历理解、岗位发现、匹配分析、材料准备和投递状态设计串成一条可暂停、可复核的流程。目标黄金路径是在用户逐步确认后辅助完成**一个岗位**：安装与登录交接、简历解析、搜岗、岗位选择、材料定制、填写前确认、提交前再次确认和本地记录；不做无人值守或批量投递。当前候选版实际开放范围以下一段为准。

当前候选版本是 `0.4.0-beta.2`。它已放行在宿主具备可信文档能力时进行本地 PDF/DOCX 简历解析和材料定制、字节日常实习与腾讯校招全职的窄范围真实搜岗，以及维护者使用假数据受控表单进行的双确认填写/提交演示。真实招聘网站的 Fill/Submit 仍关闭；仓库中出现实现文件不等于验收通过。

本仓库只负责流程编排和使用说明，不打包 ego(lite) 桌面应用，也不在默认情况下自动安装第三方脚本。第三方 skill 会先经过来源、许可证和行为检查；只有在你明确同意后，才考虑安装其必要依赖。

本项目与 ego(lite)、Boss 直聘、猎聘、阿里、腾讯、字节或其他招聘平台没有官方合作、背书或投递保证。

## 最简单的用法

1. 复制 README 顶部的短提示词给 Codex。用户只需看到仓库地址和 Release 版本；Codex 会在内部核对该 Release 指向的完整 commit，不要求你预先下载仓库或理解 40 位 hash。
2. Codex 会先读取该固定版本的入口和验收状态；如果没有 ego(lite)，它只会引导你从[官方快速开始页面](https://lite.ego.app/document/zh/docs/quick-start)安装。
3. 按提示在 ego(lite) 的图形界面中完成首次引导、按需导入 Chrome 数据，并亲自登录你允许访问的招聘网站。完成后明确回复 Codex，Codex 才会验证浏览器连接并继续。
4. 上传最新简历（PDF 或 DOCX），确认求职偏好，依次完成已放行范围内的搜岗、单岗位选择、材料定制和确认。当前 Beta 会在真实招聘网站填写前停下；只有验收报告中的 `controlledFixtureRecordingReady` 为 `true` 时，录屏才可用仓库受控表单演示两次模拟确认、单次提交和本地记录。

Codex 每次只会让用户做一个动作。私有产物默认建议放到用户 Documents 目录下的 `FindMyDreamJob-private`。简历解析后，Codex 会先给出一张待确认的求职意图卡，包含目标岗位、行业/业务方向、偏好与排除的工作内容、城市/远程、招聘类型和毕业届别；用户确认或修改后才开始搜岗，其他条件确实需要时再补充。秋招/春招默认只进入对应届别的校招全职主列表，实习岗位不会混入。

首次安装或升级 ego(lite) 后，Codex 当前任务可能仍显示旧 skill 元数据，`~/.local/bin/ego-browser` 也可能仍指向旧 onboarding runtime。仓库不再信任这个缓存或 PATH 软链：先运行 `scripts/resolve-latest-ego-runtime.sh`，从 Citro Labs 官方 GitHub Release 解析最新稳定 skill，并与 `/Applications/AI product Builder/ego.app` 内经过 Apple 签名和公证验证的 skill 逐字比对；通过后完整读取该活动 runtime 的 `SKILL.md`，并只通过 `scripts/run-verified-ego-browser.sh` 调用 resolver 返回的官方 CLI。runner 不重写用户软链，不混用 Desktop/下载目录副本，也不自动删除或结束应用；发现重复进程时会停下让用户亲自处理。

> XHS 和 README 使用同一段“仓库地址 + 固定 Release 版本”提示词。用户不需要复制 40 位 hash；Codex 必须先解析该 Release 的目标 commit，再以完整 hash 核对和加载 [`START_PROMPT.md`](START_PROMPT.md)。Release 只负责让用户发现版本，底层仍不得直接跟随会漂移的 main/master/HEAD 或分支。

成品提示词应尽量短，形式如下：

```text
请使用这个开源求职流程协助我：https://github.com/YingzhiYee/FindJobs 。使用 GitHub Release v0.4.0-beta.2，先核对该 Release 指向的固定 commit 和验收报告，再严格执行其中的 START_PROMPT.md。从 ego(lite) 官方安装引导开始，读取简历后先和我确认求职意图，每次只处理一个岗位；填写和提交必须分别获得我的明确确认，未通过验收的真实操作必须停止。
```

完整流程和录屏完成标准见 [`docs/golden-path.md`](docs/golden-path.md)。

维护者的小红书标题、正文、置顶评论、7 天发布节奏和转化指标见 [`docs/launch-playbook.md`](docs/launch-playbook.md)。

## 前置条件

- 支持联网和读取 GitHub 仓库的 Codex 环境。
- macOS；尚未安装 ego(lite) 时，Codex 会在流程内打开官方说明并等待你完成安装和首次 onboarding。
- Codex 宿主已有经过信任的 PDF/DOCX 读取与导出能力；本仓库不携带通用解析器，也不会为此自动安装第三方依赖。能力缺失时会安全停止简历解析和材料导出。
- 用户自己在 ego(lite) 中完成网站登录；不要把密码、Cookie、Token 或验证码发送给 Codex。
- 一份由用户确认真实有效的简历，以及可公开用于求职的联系方式。
- 用户了解目标网站的服务条款，并愿意逐条确认最终投递。

ego(lite) 是外部桌面依赖。若未安装，Codex 只应引导你打开官方安装页面并等待你完成安装，不应下载来路不明的二进制或修改浏览器登录资料。

浏览器兼容性使用 `config/skills.lock.yaml` 中的“官方最新稳定版”解析策略，而不是手工维护的单版本白名单。每次首次网页调用和维护者黄金测试都会运行 `scripts/resolve-latest-ego-runtime.sh`：只接受 Citro Labs GitHub 的最新稳定 Release，核对 GitHub 资产 SHA-256，并要求 `/Applications/AI product Builder/ego.app` 的固定路径、bundle id、Apple Team、designated requirement、Gatekeeper 公证、bundle 当前 runtime 路径以及内置 `SKILL.md` 与 Release 完全一致。普通流程随后通过 `scripts/run-verified-ego-browser.sh` 启动该绝对路径，并在启动前要求系统只运行这一个正式主进程；shell 中同名旧命令不会被执行。任一来源未知、预发布、部分匹配或校验失败都停止网页工作；宿主文档能力仍可信时可继续离线解析和起草。验收报告继续记录实际测试过的精确元组，但不再用它阻止已通过上述检查的官方稳定更新。

## 四种模式

### Discover（发现）

读取简历和已确认的求职意图后，通过 ego(lite) 从每家公司的官方招聘首页进入对应的“校园招聘/应届生招聘/社会招聘”等可见通道，核验通道页面后再搜索岗位，统一整理岗位名称、公司、地点、要求、薪资（如有）、原始链接、通道证据和抓取时间。此模式只读，不修改简历，也不填写或提交申请。

### Draft（起草）

对岗位去重并进行人岗匹配，说明匹配证据、硬性缺口和不确定项；再针对用户选中的岗位生成简历修改稿、求职信或申请问答草稿。所有新增或改写内容必须能回溯到原简历或用户确认的信息，不能编造经历、数字、技能或证书。导出文件前先让用户查看差异。

### Fill（填写，是否可用由验收报告决定）

填写、上传或触发表单自动保存前，先展示目标公司、域名、岗位、材料版本和将披露的字段。用户明确授权向该岗位披露这些数据后，才使用 ego(lite) 填写或上传，并停在最终提交按钮之前。

### Submit（提交，是否可用由验收报告决定）

重新核对当前页面、附件哈希和最终答案，在用户第二次明确确认后只提交一次。遇到验证码、登录失效、付款、协议勾选或异常页面时暂停并交还用户处理。成功、失败、跳过或结果不确定都要记录；结果不确定时禁止自动重试。

## 如何加载本仓库流程

首版采用固定 Release 指向固定 commit 的 GitHub 启动包：短提示词让 Codex 先解析指定 Release 的目标 commit，再在 owner-only 临时目录获取并 detached checkout 同一 commit，核对官方 remote 与完整 HEAD，最后读取 `START_PROMPT.md` 和四个 bundled skill。用户不需要预装仓库、理解 hash 或手动运行命令；该 Prompt 只放行 runtime resolver 与 verified runner，其他仓库脚本、依赖和第三方候选仍不得执行。不得因为找不到某个依赖文件就自行猜测或运行未知代码。

高级用户希望长期复用时，可以明确要求 Codex 使用内置 `skill-installer` 从固定的 GitHub commit 安装本仓库四个 skill。安装前仍要查看 `config/skills.lock.yaml` 和 `policies/`；不要把第三方依赖和安装脚本当成可信代码。

`0.4.0-beta.2` 不发布 marketplace 安装入口。首版 XHS 演示只走固定版本的 GitHub 提示词；所有能力是否可用始终以该固定 commit 内 `tests/acceptance-report.md` 的机器可读状态块为准。

录屏前按 [`docs/xhs-demo.md`](docs/xhs-demo.md) 使用虚构简历和假联系方式；当前 G3 站点实测结论记录在 [`tests/acceptance-report.md`](tests/acceptance-report.md)，旧 CLI/PATH 劫持对抗结果记录在 [`tests/runtime-activation-report.md`](tests/runtime-activation-report.md)。

第三方 skill 只作为受控依赖。Codex 应先记录其 GitHub 地址、固定版本或 commit、许可证、所需权限和联网行为，展示审查结果并征得同意。默认不执行第三方仓库中的安装脚本、二进制、MCP 或会上传简历的程序。

## 隐私与平台边界

- 简历、联系方式和投递记录优先保存在本机；除非用户明确同意，不上传到陌生服务或第三方 API。
- 不读取、导出或转发密码、Cookie、Token、验证码和私人聊天内容。
- 只访问用户指定且有权访问的网站，遵守网站服务条款、频率限制、robots 规则和隐私政策。
- 不绕过验证码、登录保护、反自动化措施、付费墙或访问控制，不进行无人值守的批量投递。
- 发现网站明确禁止自动化、页面要求付款或请求敏感信息时立即暂停，由用户决定是否继续。
- 最终提交由用户负责；自动化填写不等于平台允许自动化提交。

## 产物和记录

每次运行都应保留可复核的结果：岗位原始链接和时间、匹配理由、使用的简历版本、用户确认记录、表单结果和失败原因。真实产物必须写入用户选定且位于仓库外的私有目录；若用户坚持放在 clone 内，只能写入已忽略的 `private/`。记录可以先采用本地 CSV 或 Markdown；公开输出要脱敏本地路径，不要把个人信息提交到公开 issue、日志或遥测服务。

## 第三方声明

引入任何外部 skill 前，请核对其许可证和再分发条件，并在 `THIRD_PARTY_NOTICES.md` 中保留原项目地址、版本、许可证和修改说明。许可证不清晰、来源不可信或行为超出求职流程所需范围的项目不纳入默认包。

## License

本项目采用 [MIT License](LICENSE)。第三方项目仍分别受其原许可证约束，具体审计来源和使用方式见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

## 当前限制

网站字段、登录状态和反自动化策略会变化；岗位信息可能过期或重复；生成的材料必须由用户自行核验。这个项目的目标是减少重复操作和提高复核效率，不承诺自动获得面试或绕过任何平台规则。

## 后续真实投递门槛

- 提交候选版本后发布固定 Release，并在 README/XHS 提示词中写明该 Release 版本；Codex 负责把它解析为完整目标 commit。完整 commit 仍是底层信任锚点，用户无需手动复制 hash。
- 真实投递仍需一名同意参与的用户完成 G5：选择一个真实岗位，用真实材料完成两次精确确认、一次真实提交和结果记录；同一个目标站点/ATS 还必须补齐对应的 G4/G6 证据，包括独占锁竞争和恢复。全部通过后也只能在新的固定 commit 中放行实际验收过的精确范围；在此之前只能把受控表单称为投递演示。
