# Third-party notices

本仓库当前只记录经过初筛的第三方 skill 来源，不会在安装阶段自动执行其脚本，也不会把未完成审查的代码复制进来。

## 初筛候选

- [Paramchoudhary/ResumeSkills](https://github.com/Paramchoudhary/ResumeSkills) — MIT，审计 commit `74ae19e7c62b0516d1c298328e5544976c12da5d`；方法经安全改写后进入 bundled skills，未复制原 skill。
- [SankaiAI/ats-optimized-resume-agent-skill](https://github.com/SankaiAI/ats-optimized-resume-agent-skill) — MIT，审计 commit `153209b510e6ca168ab50a6b0d4f19e380979d73`；本地 DOCX renderer 源码已通过测试，但运行依赖未做 wheel 哈希锁定，因此仅作参考、不安装。
- [QuentinMeow/jobs-finder-toolkit](https://github.com/QuentinMeow/jobs-finder-toolkit) — Apache-2.0，审计 commit `070324a06584648964e9aa8ddc8f90cdbe4cd2cd`；只参考岗位规范化、证据链和追加式记录设计。
- [Miracle-Aligner/job-search-hq](https://github.com/Miracle-Aligner/job-search-hq) — MIT；参考本地 JSON CRM、求职信和追加式状态记录。
- [OriginalDopey/job-search-agent-skills](https://github.com/OriginalDopey/job-search-agent-skills) — MIT；参考岗位证据、匹配评级和追踪器结构。
- [couragec/LLMInternSkill](https://github.com/couragec/LLMInternSkill) — MIT，审计 commit `11db44f57b3d78ae3f83072b3959cd7a5d85df0b`；参考中文场景的 evidence contract 和 truth boundary，未复制字体/LaTeX/脚本目录。
- [dhanushk-offl/resume-parser](https://github.com/dhanushk-offl/resume-parser) — MIT，审计 commit `050d7e851d7a97393980cad250d5d0f771cfff2c`；raw-text 测试通过但真实 PDF 失败处理不可靠，仅参考 schema。
- [bowenliang123/markdown-exporter](https://github.com/bowenliang123/markdown-exporter) — Apache-2.0，审计 commit `bc216faa6dc490208c4e229c973c81acde85a430`；因远程/本地资源嵌入和依赖漏洞排除。
- [Sma1lboy/coforce-apply](https://github.com/Sma1lboy/coforce-apply) — MIT，审计 commit `44aa91ac519aebe9a07b0ee33f91bb393d04d9b4`；仅参考流程设计，因危险权限模式、自动账号/邮件流程、状态校验缺陷和许可证来源疑点，不复制或安装代码。

## 不纳入公开 bundle 的候选

- 无许可证、许可证声明与仓库文件不一致、或要求付费 SaaS/API 的项目。
- 包含自动注册、自动提交、验证码处理、Cookie/Token 读取或未知外发域名的实现。
- 默认把简历上传到云端的解析服务；除非用户明确同意并完成单独的数据处理审查。

发布前必须将每个实际纳入的依赖固定到 commit 和内容哈希，并保留对应许可证、来源和变更记录。
