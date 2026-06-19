# PromLight-Reasonix Skill — TODO 总纲

> **目标**: 将 PromLight AI 状态灯完整适配到 DeepSeek-Reasonix 编码 Agent  
> **策略**: AGENT TEAMS 三波并行 — 4→4→3 代理并发执行  
> **驱动目录**: `F:\PromLight` (PromLight.exe + agent_hook.py + promlight_cli.py 已就绪)  
> **参考实现**: Gitee `zym1987/promlight-workbuddy-skill` (WorkBuddy 版本)  
> **当前日期**: 2026-06-20

---

## 🧬 AGENT TEAMS 并行策略

```
────────────────────────────────────────────────────────────────────────────
WAVE 0: 4 代理并行 (零依赖探索)          预计耗时: ~5min (最长链)
────────────────────────────────────────────────────────────────────────────
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  🟢 Agent-Alpha     │  │  🔵 Agent-Beta      │  │  🟡 Agent-Gamma     │  │  🟣 Agent-Delta     │
│  Reasonix 环境勘查  │  │  Hook 系统源码分析  │  │  PromLight 现场验证 │  │  WorkBuddy 参考分析 │
│                     │  │                     │  │                     │  │                     │
│  1.1→1.2→1.3        │  │  1.4→1.5            │  │  1.6 + 4.1          │  │  1.7→9.1            │
│  reasonix --version  │  │  hook.go 全事件     │  │  promlight test     │  │  Gitee 源码对比     │
│  config.toml 快照    │  │  事件映射对照表     │  │  events.json 审核   │  │  diff 文档          │
└────────┬────────────┘  └────────┬────────────┘  └────────┬────────────┘  └────────┬────────────┘
         │                        │                        │                        │
         │  产出: config快照      │  产出: 事件映射表      │  产出: 通信确认       │  产出: diff文档
         │                        │                        │                        │
         ▼                        ▼                        ▼                        ▼
────────────────────────────────────────────────────────────────────────────
WAVE 1: 4 代理并行 (依赖 Wave 0 产出)   预计耗时: ~10min (最长链)
────────────────────────────────────────────────────────────────────────────
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  🟢 Agent-Echo      │  │  🔵 Agent-Foxtrot   │  │  🟡 Agent-Golf      │  │  🟣 Agent-Hotel     │
│  agent_hook.py 全改 │  │  灯效定制           │  │  SKILL.md 全套      │  │  Hook 科普文档      │
│                     │  │                     │  │                     │  │                     │
│  2.1→2.2→2.3→2.4    │  │  4.2                │  │  6.1→6.2→6.3→6.4    │  │  9.2                 │
│  →2.5→2.6           │  │  Reasonix 专属宏    │  │  技能文档+工具绑定   │  │  Reasonix Hook 详解 │
│  +KNOWN_AGENTS      │  │  events.json diff   │  │  +always触发+usecase │  │                     │
│  +事件映射+字段+测试 │  │                     │  │                     │  │                     │
└────────┬────────────┘  └────────┬────────────┘  └────────┬────────────┘  └────────┬────────────┘
         │                        │                        │                        │
         │  产出: 改好的          │  产出: 灯效方案        │  产出: SKILL.md        │  产出: 科普文档
         │  agent_hook.py         │                        │                        │
         │                        │                        │                        │
         ▼                        ▼                        ▼                        ▼
────────────────────────────────────────────────────────────────────────────
WAVE 2: 3 代理并行 (依赖 Wave 1 产出)   预计耗时: ~10min (最长链)
────────────────────────────────────────────────────────────────────────────
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  🟢 Agent-India     │  │  🔵 Agent-Juliet    │  │  🟡 Agent-Kilo      │
│  Hook 配置 + 安装器 │  │  端到端测试         │  │  打包文档           │
│                     │  │                     │  │                     │
│  3.1→3.2→3.3→3.4    │  │  7.1→7.2→7.3→7.5    │  │  8.1→8.2→8.3        │
│  →5.1→5.2→5.3       │  │  Hook冒烟→真实会话  │  │  →9.3               │
│  →5.4→5.5           │  │  →容错→full mode    │  │  仓库结构+README     │
│  settings.json      │  │                     │  │  +CHANGELOG+排障     │
│  +安装器全套        │  │  7.4 并入此Agent    │  │                     │
│                     │  │  (CLI完整测试)      │  │                     │
└────────┬────────────┘  └────────┬────────────┘  └────────┬────────────┘
         │                        │                        │
         │  产出: settings.json   │  产出: 测试报告        │  产出: 完整仓库
         │  + install/uninstall   │                        │
         │                        │                        │
         ▼                        ▼                        ▼
────────────────────────────────────────────────────────────────────────────
WAVE 3: 串行收尾 (依赖 Wave 2 全部)
────────────────────────────────────────────────────────────────────────────
                              8.4→8.5  Gitee 创建仓库 + Push v1.0.0
                             10.1→10.2 CI 配置 (可选)
────────────────────────────────────────────────────────────────────────────
```

### 并行度总结

| Wave | 代理数 | 并行度 | 关键约束 |
|------|--------|--------|----------|
| Wave 0 | 4 | ════ 4路并行 | 零依赖，可同时启动 |
| Wave 1 | 4 | ════ 4路并行 | 各依赖 Wave 0 不同产出，无互相依赖 |
| Wave 2 | 3 | ═══ 3路并行 | India依赖Echo+Hotel; Juliet依赖India+Echo; Kilo依赖全部Wave1 |
| Wave 3 | 1 | ▸ 串行 | Gitee操作需Git，最后一步 |

**总预计耗时**: ~30min（vs 串行 ~120min），提速 **4x**

### 各 Agent 详细任务

---

## 🟢 Agent-Alpha: Reasonix 环境勘查

**依赖**: 无  
**合并理由**: 都是对 Reasonix 本地环境的只读探索，无需改动任何文件

### 1.1 [ ] 确认 Reasonix 安装状态
- **命令**: `reasonix --version`, `where reasonix`
- **产出**: 版本号 + 二进制路径

### 1.2 [ ] 读取 Reasonix 现有配置
- **文件**: `~/.reasonix/config.toml` 或 `./reasonix.toml`
- **产出**: default_model, providers, agent 配置段快照

### 1.3 [ ] 确认技能目录结构
- **路径**: `~/.reasonix/skills/`
- **产出**: 已安装技能清单 (cli-anything, caveman, rtk, promlight 等)

---

## 🔵 Agent-Beta: Hook 系统源码分析

**依赖**: 无  
**合并理由**: 纯 GitHub 源码阅读，输出事件映射表供所有后续 Agent 使用

### 1.4 [ ] 分析 Reasonix Hook 系统完整事件
- **源码**: `github.com/esengine/DeepSeek-Reasonix/blob/main-v2/internal/hook/hook.go`
- **产出**: 11 个事件清单 + Payload 字段 + gating 规则

### 1.5 [ ] 对比 Reasonix vs Claude Code Hook 事件
- **方法**: 事件名对比 + payload 字段映射
- **产出**: 事件映射对照表 (Reasonix→PromLight macro)

---

## 🟡 Agent-Gamma: PromLight 现场验证

**依赖**: 无  
**合并理由**: 都是对本地 F:\PromLight 的操作，硬件相关

### 1.6 [ ] 验证 PromLight 守护进程通信
- **命令**: `promlight test`, `promlight led all blink --count 2`
- **产出**: 守护进程在线确认 + 灯控测试结果

### 4.1 [ ] 审核现有 events.json 灯效配置
- **文件**: `F:\PromLight\events.json`
- **产出**: macros/events 完整性审核，记录所有可用宏

---

## 🟣 Agent-Delta: WorkBuddy 参考分析

**依赖**: 无  
**合并理由**: Gitee 源码分析 + 对比文档，一气呵成

### 1.7 [ ] 分析 WorkBuddy 版本参考实现
- **URL**: `https://gitee.com/zym1987/promlight-workbuddy-skill`
- **产出**: 目录结构 / SKILL.md / install 脚本 / hook 配置的参考结构

### 9.1 [ ] 编写与 WorkBuddy 版本的差异对照
- **内容**: 安装方式 / Hook系统 / 事件映射 / 灯效配置 的异同
- **产出**: comparison.md

---

## 🟢 Agent-Echo: agent_hook.py 全面适配 (核心改动)

**依赖**: Agent-Beta (1.4, 1.5)  
**合并理由**: 所有改动集中在同一文件 `F:\PromLight\agent_hook.py`，一人改避免冲突

### 2.1 [ ] 新增 `reasonix` 到已知 agent 列表
- **文件**: `agent_hook.py` 第 26 行 `_KNOWN_AGENTS`
- **改动**: 添加 `"reasonix"`

### 2.2 [ ] 添加 Reasonix 事件分类映射
- **文件**: `agent_hook.py` `_DEFAULT_EVENTS`
- **改动**: 添加 11 条 Reasonix 事件→macro 映射

### 2.3 [ ] 添加 Reasonix 事件展示字段
- **文件**: `agent_hook.py` `_DETAIL_FIELDS`
- **改动**: 添加 10 条 payload 字段提取（字段名用 camelCase，与 Reasonix Payload JSON tags 一致）

### 2.4 [ ] 确认 SessionEnd 释放逻辑
- **检查**: `_SESSION_END_EVENTS` 已含 `"SessionEnd"`，确认同名兼容
- **改动**: 无需修改或仅确认注释

### 2.5 [ ] 处理 payload 字段命名差异
- **检查**: `_norm_session` / `_summarize` 对 camelCase 的兼容性
- **改动**: 如 Reasonix payload 用 `toolName` 而非 `tool_name`，添加字段兼容

### 2.6 [ ] agent_hook.py 基础冒烟测试
- **命令**: 模拟 Reasonix payload stdin 调用 agent_hook.py
- **验证**: exit 0，灯响应正确

---

## 🔵 Agent-Foxtrot: Reasonix 专属灯效

**依赖**: Agent-Gamma (4.1)  
**合并理由**: 纯灯效配置，独立于代码逻辑

### 4.2 [ ] 创建 Reasonix 专属灯效方案
- **文件**: `F:\PromLight\events.json`
- **内容**: 可选微调，如 reasonix_start 蓝绿呼吸区别于 Claude Code 红黄绿
- **验证**: 灯效符合审美+功能需求

### 4.3 [ ] 多设备路由配置 (可选)
- **文件**: `F:\PromLight\devices.json`
- **内容**: 若有多台设备，配置 routes

---

## 🟡 Agent-Golf: SKILL.md 全套文档

**依赖**: Agent-Beta (1.5) + Agent-Gamma (1.6)  
**合并理由**: 技能文档的所有内容（正文+工具绑定+触发+场景），同源同构

### 6.1 [ ] 编写 SKILL.md 核心内容
- **产出**: 完整的 PromLight Reasonix 技能文档

### 6.2 [ ] 编写工具绑定段
- **内容**: bash 调用 promlight 命令、读取 events.json 等

### 6.3 [ ] 添加自动触发
- **frontmatter**: `always: true`

### 6.4 [ ] 编写 use-cases.md
- **产出**: references/use-cases.md

---

## 🟣 Agent-Hotel: Reasonix Hook 科普文档

**依赖**: Agent-Beta (1.4, 1.5)  
**合并理由**: 纯文档，无代码依赖

### 9.2 [ ] 编写 Reasonix Hook 系统科普
- **内容**: settings.json 格式 / 事件列表 / payload / blocking 规则 / 与 Claude Code 的异同
- **产出**: references/reasonix-events.md

---

## 🟢 Agent-India: Hook 配置 + 安装器全套

**依赖**: Agent-Echo (2.6) + Agent-Golf (6.1)  
**合并理由**: settings.json 和安装器脚本紧密耦合（安装器要生成 settings.json）

### 3.1 [ ] 创建全局 settings.json
- **文件**: `~/.reasonix/settings.json`
- **内容**: 10 个事件的 hook command

### 3.2 [ ] 优化 hook 命令路径
- **改动**: 绝对路径替换 `python`

### 3.3 [ ] 压测验证超时
- **验证**: 100 次连续 hook 调用 <5s

### 3.4 [ ] 创建项目级 settings.json 模板
- **产出**: templates/project-settings.json

### 5.1 [ ] 创建 install.ps1 (Windows)
- **功能**: 复制 agent_hook + 生成 settings.json + 安装 SKILL.md + 测试连接

### 5.2 [ ] 创建 install.sh (macOS/Linux)
- **功能**: 同上，Unix 路径

### 5.3 [ ] 创建 uninstall.ps1 / uninstall.sh
- **功能**: 移除 hook 配置 + 技能文件

### 5.4 [ ] 安装器 --dry-run 模式
### 5.5 [ ] 安装器幂等性保证

---

## 🔵 Agent-Juliet: 端到端测试

**依赖**: Agent-India (3.2) + Agent-Echo (2.6)  
**合并理由**: 所有测试集中执行，统一出测试报告

### 7.1 [ ] 测试 hooks 正确触发
- **方法**: 逐事件模拟，填测试矩阵 (11 个事件)

### 7.2 [ ] 测试 Reasonix 真实会话
- **方法**: 启动 Reasonix 真实对话，观察实体灯

### 7.3 [ ] 测试 hook 失败容错
- **方法**: 停掉守护进程，确认 Reasonix 不受影响

### 7.4 [ ] 测试 promlight_cli.py 完整功能
- **方法**: 8 个子命令逐一验证

### 7.5 [ ] 测试 rtk+caveman full mode 集成
- **方法**: 同一会话中验证 rtk 压缩 + caveman 风格 + PromLight 灯效

---

## 🟡 Agent-Kilo: 打包文档

**依赖**: Agent-Golf + Agent-Foxtrot + Agent-Hotel (Wave 1 全部)  
**合并理由**: 所有文档已就绪，集中组装仓库

### 8.1 [ ] 创建仓库目录结构
### 8.2 [ ] 编写 README.md (中英双语)
### 8.3 [ ] 编写 CHANGELOG.md
### 9.3 [ ] 编写故障排除指南 (references/troubleshooting.md)

---

## Wave 3: 最终发布 (串行)

### 8.4 [ ] 在 Gitee 创建仓库 `zym1987/promlight-reasonix-skill`
### 8.5 [ ] 推送 v1.0.0 并打 tag
### 10.1 [ ] CI 冒烟测试 (可选)
### 10.2 [ ] agent_hook.py 单元测试 (可选)

## 关键技术决策点

1. **agent_hook.py 是扩展还是新建？**  
   → 扩展：在现有 agent_hook.py 中添加 reasonix 支持，因为它已包含完整的事件映射、宏展开、payload 解析、守护进程通信逻辑。Claude Code 和 Reasonix 的 hook 协议几乎相同（JSON stdin → exit code）。

2. **Reasonix 的 hook 配置方式？**  
   → 通过 `settings.json` 的 `hooks` 段，每个事件配一条 shell command 调用 agent_hook.py。
   这与 Claude Code 的 hook 配置模式一致。

3. **promlight_cli.py 是否保留？**  
   → 保留，作为手动灯控工具。Agent 可通过 `bash` 工具直接调用。
   SKILL.md 中列出所有子命令。

4. **是否需要 MCP/Plugin 方式？**  
   → 不需要。Reasonix 的 hook 系统（stdin JSON → shell command）已经完美支持 agent_hook.py。
   不需要开发额外的 MCP server 或 plugin。

5. **灯效方案是什么？**  
   → 沿用 events.json 中已有的 kiri 系列多彩灯效。
   可根据需要微调 Reasonix 专属灯效颜色。

---

## 安装命令（设计稿）

```powershell
# 一键安装（Windows）
irm https://gitee.com/zym1987/promlight-reasonix-skill/raw/main/scripts/install.ps1 | iex

# 一键安装（macOS/Linux）
curl -fsSL https://gitee.com/zym1987/promlight-reasonix-skill/raw/main/scripts/install.sh | bash
```

安装后效果：
- `~/.reasonix/settings.json` 添加 PromLight hooks
- `~/.reasonix/skills/promlight/SKILL.md` 技能文档就位
- `promlight` CLI 在 PATH 中可用
- 新开 Reasonix 会话 → 灯自动同步状态

---

## 参考资源

| 资源 | URL |
|------|-----|
| Reasonix 仓库 | https://github.com/esengine/DeepSeek-Reasonix |
| Reasonix Hook 源码 | `internal/hook/hook.go` + `internal/hook/runner.go` |
| PromLight 文档 | https://light.buildfpga.com/light-v2/index.html |
| WorkBuddy 版本 | https://gitee.com/zym1987/promlight-workbuddy-skill |
| CLI-Anything reasonix-skill | `~/.reasonix/skills/cli-anything/` |
| rtk | https://github.com/rtk-ai/rtk |
| caveman | https://github.com/JuliusBrussee/caveman |
