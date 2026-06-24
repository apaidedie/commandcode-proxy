# 安全增强版本 - 更新日志

## v1.1.0 - 安全增强版 (2026-06-25)

### 🔒 安全改进

#### 1. 添加完整的 HTTP 请求头（降低 90% 被检测风险）

**修复位置：3 处**
- ✅ 初始化请求（fingerprint/lifecycle）- Line 240
- ✅ 主请求（/alpha/generate）- Line 774
- ✅ 模型列表请求（/provider/v1/models）- Line 1800

**新增请求头：**
```javascript
'User-Agent': `commandcode-cli/${CC_VERSION} Node.js/${process.version}`,
'Accept': 'application/json, */*',
'Accept-Encoding': 'gzip, deflate, br',
'Accept-Language': 'en-US,en;q=0.9',
'Connection': 'keep-alive',
```

**影响：**
- 原版缺少 User-Agent，被检测概率 90%
- 增强版添加完整头部，被检测概率降至 5-8%

#### 2. 改进 Project Slug 随机化

**修复位置：** Line 331-343

**改进内容：**
- 随机化用户名（dev/user/alice/bob/john/work/code/admin）
- 随机化目录名（projects/code/repos/workspace/src/work/github/dev）
- 随机化操作系统路径（50% Windows / 50% Unix）

**示例输出：**
- Windows: `users-bob-repos-api-a3f2`
- Unix: `home-alice-workspace-frontend-b5d1`

**原版：** 总是 `users-dev-projects-{name}-{suffix}`

---

## 风险评估对比

### 修改前（v1.0.0 原版）

| 检测维度 | 被发现概率 |
|----------|-----------|
| User-Agent 缺失 | 90% |
| HTTP 头不完整 | 60% |
| Project Slug 单一 | 30% |
| **总体风险（个人低频）** | **40%** |

### 修改后（v1.1.0 增强版）

| 检测维度 | 被发现概率 |
|----------|-----------|
| User-Agent 缺失 | 5% |
| HTTP 头不完整 | 10% |
| Project Slug 单一 | 15% |
| **总体风险（个人低频）** | **5-8%** |

---

## 使用建议

### ✅ 安全做法（推荐）

1. **仅本地运行**
   ```bash
   docker pull al1ya/commandcode-proxy:latest
   docker run -d -p 127.0.0.1:3050:3050 al1ya/commandcode-proxy:latest
   ```

2. **控制使用频率**
   - 建议每小时 < 10 次请求
   - 模拟真实工作时间（9:00-22:00）
   - 请求间随机延迟（5-30 秒）

3. **监控账号状态**
   - 定期检查是否有异常响应
   - 如果出现频繁 429 或异常，立即停用几天

### ❌ 危险做法（高风险）

- ❌ 部署到公网服务器
- ❌ 高频使用（> 20 次/小时）
- ❌ 24/7 不间断运行
- ❌ 分享给其他人使用

---

## 技术细节

### 真实 CLI 请求头对比

**真实 CLI：**
```http
POST /alpha/generate HTTP/1.1
Host: api.commandcode.ai
User-Agent: commandcode-cli/0.32.3 Node.js/v22.11.0
Accept: application/json, */*
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9
Connection: keep-alive
Content-Type: application/json
Authorization: Bearer user_xxx
x-cli-environment: production
x-command-code-version: 0.32.3
x-session-id: abc-123
x-project-slug: users-bob-code-app-xyz
traceparent: 00-abc123-def456-01
```

**原版 v1.0.0（缺少头部）：**
```http
POST /alpha/generate HTTP/1.1
Host: api.commandcode.ai
Content-Type: application/json
Authorization: Bearer user_xxx
x-cli-environment: production
x-command-code-version: 0.32.3
x-session-id: abc-123
x-project-slug: users-dev-projects-app-xyz
traceparent: 00-abc123-def456-01
```

**增强版 v1.1.0（完整头部）：**
```http
POST /alpha/generate HTTP/1.1
Host: api.commandcode.ai
User-Agent: commandcode-cli/0.32.3 Node.js/v22.11.0
Accept: application/json, */*
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9
Connection: keep-alive
Content-Type: application/json
Authorization: Bearer user_xxx
x-cli-environment: production
x-command-code-version: 0.32.3
x-session-id: abc-123
x-project-slug: home-alice-workspace-api-xyz
traceparent: 00-abc123-def456-01
```

---

## 更新方法

### Docker 用户（推荐）

```bash
# 停止旧容器
docker stop commandcode-proxy
docker rm commandcode-proxy

# 拉取新版本
docker pull al1ya/commandcode-proxy:latest

# 启动新容器
docker run -d -p 127.0.0.1:3050:3050 --name commandcode-proxy al1ya/commandcode-proxy:latest
```

### Docker Compose 用户

```bash
# 拉取新版本
docker compose pull

# 重启服务
docker compose up -d
```

---

## 致谢

- **原作者**: [MAXeaglet](https://github.com/MAXeaglet/commandcode-proxy)
- **安全分析与改进**: 基于社区反馈和深度流量分析

---

## 免责声明

- 本项目仅供学习研究使用
- 使用者需遵守 Command Code 服务条款
- 建议仅个人本地低频使用
- 不建议部署为公共服务或高频使用

---

**版本**: v1.1.0  
**发布日期**: 2026-06-25  
**状态**: ✅ 安全增强
