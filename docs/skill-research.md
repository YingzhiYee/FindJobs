# GitHub skill research

初筛日期：2026-07-27。仓库内容、许可证和活跃度需要在实际发布前重新核验；`config/skills.lock.yaml` 中没有 commit/hash 的项目禁止自动安装。

## 推荐作为参考或审查后接入

| 仓库 | 许可证 | 适合借鉴的部分 | 结论 |
| --- | --- | --- | --- |
| [Paramchoudhary/ResumeSkills](https://github.com/Paramchoudhary/ResumeSkills) | MIT | JD 分析、简历定制、求职信、表单问答、版本管理 | 无一可原样安装；已把安全方法改写进 bundled skills |
| [SankaiAI/ats-optimized-resume-agent-skill](https://github.com/SankaiAI/ats-optimized-resume-agent-skill) | MIT | 阶段闸门、JSON 校验、DOCX 渲染和回读 | DOCX renderer 源码通过合成数据 smoke test；依赖 wheel 未锁哈希，因此仍只作参考 |
| [QuentinMeow/jobs-finder-toolkit](https://github.com/QuentinMeow/jobs-finder-toolkit) | Apache-2.0 | 岗位 schema、来源追踪、简历版本和投递 tracker | 主要借鉴契约；不直接搬美国站点适配器 |
| [Miracle-Aligner/job-search-hq](https://github.com/Miracle-Aligner/job-search-hq) | MIT | 本地 JSON CRM、追加式状态历史、求职信流程 | 借鉴记录模型，适配 Codex |
| [OriginalDopey/job-search-agent-skills](https://github.com/OriginalDopey/job-search-agent-skills) | MIT | evidence-based fit、Apply/Stretch/Skip、简单 tracker | 借鉴评分说明和证据引用 |
| [couragec/LLMInternSkill](https://github.com/couragec/LLMInternSkill) | MIT | 中文场景的 truth boundary、evidence contract、材料审计 | 抽取安全规则，不整体复制实习场景流程 |
| [dhanushk-offl/resume-parser](https://github.com/dhanushk-offl/resume-parser) | MIT | 本地 PDF → 结构化候选人画像 | 86 个 raw-text 测试通过，但真实 PDF 失败后仍返回虚假 ATS 结果；只参考 schema |
| [bowenliang123/markdown-exporter](https://github.com/bowenliang123/markdown-exporter) | Apache-2.0 | Markdown 转 DOCX/PDF | 排除：可抓远程图片/读取本地文件、依赖过重且存在已知漏洞 |

## 只做架构参考

- [Sma1lboy/coforce-apply](https://github.com/Sma1lboy/coforce-apply)：状态机和 hostile HTML 测试很有价值，但存在危险权限、自动注册/邮箱验证码、确认状态校验和许可证来源问题，只能参考设计。
- [art2url/career-agent-skills](https://github.com/art2url/career-agent-skills)：能力覆盖广，但活跃度和测试证据不足。

## 排除

- [Jichengyuuuuu/resume-builder-skill](https://github.com/Jichengyuuuuu/resume-builder-skill)：仓库缺少可核验的 LICENSE。
- [eonghk/jobsparrow-ai-skill](https://github.com/eonghk/jobsparrow-ai-skill)：依赖付费外部服务并传输简历，且许可证文件不足。
- [surapuramakhil-org/Job_search_agent](https://github.com/surapuramakhil-org/Job_search_agent)：AGPL-3.0 且包含自动投递方向，不纳入公开 bundle。
- [Nebutra/MinerU-Skill](https://github.com/Nebutra/MinerU-Skill)：默认云端处理文档，首版不启用。
- [anthropics/skills](https://github.com/anthropics/skills)：相关文档 skill 不能复制进公开 bundle，只能参考接口设计。

## 首版组合

1. 自己维护 `find-my-dream-job` 编排 skill 和三个安全适配 skill。
2. Paramchoudhary/ResumeSkills 只作为有固定哈希的设计来源，不自动安装。
3. couragec/LLMInternSkill 只作为有固定哈希的事实边界参考，不自动安装。
4. Sankai renderer 仅在后续锁定依赖 wheel 后才可成为显式 opt-in；简历解析优先使用已信任的宿主文档能力。
5. 用 Quentin/Miracle/OriginalDopey 的 schema 和 tracker 思路实现本地记录。
6. 用 ego-browser 负责网站访问、并行 Space 和表单交互；不再引入另一个爬虫/提交 skill。

最终权限流固定为 `Discover → Draft → Fill → Submit`。Fill 前取得数据披露授权，Submit 前再把授权绑定到岗位、域名、答案哈希和附件哈希。
