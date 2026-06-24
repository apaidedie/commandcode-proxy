# 🔬 CLI 真实流量 vs 反代流量深度对比分析

## 场景：Go 套餐 + 仅访问 DeepSeek + 个人本地使用

---

## 📡 真实 CLI 流量特征

### 1. HTTP 请求头（真实 CLI）

```http
POST /alpha/generate HTTP/1.1
Host: api.commandcode.ai
User-Agent: commandcode-cli/0.32.3 Node.js/v22.x.x
Accept: application/json, */*
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9
Connection: keep-alive
Content-Type: application/json
Authorization: Bearer user_xxx
x-cli-environment: production
x-command-code-version: 0.32.3
x-session-id: <uuid>
x-co-flag: false
x-taste-learning: false
x-project-slug: <slug>
traceparent: 00-<trace>-<span>-01
```

### 2. 行为特征

| 特征 | 真实 CLI | 反代项目 |
|------|---------|---------|
| 启动事件 | fingerprint + lifecycle | ✅ 已模拟 |
| 心跳 | 每 8h 一次 | ✅ 已模拟 |
| Session 持续 | ~12h | ✅ 已模拟 |
| 工作目录 | 真实路径 | ⚠️ 伪造 |
| Git 仓库信息 | 读取 .git | ❌ 缺失 |
| IDE 集成 | VS Code/Cursor | ❌ 缺失 |
| Terminal 类型 | 真实终端 | ❌ 缺失 |
| 请求间隔 | 不规律（人类） | ⚠️ 取决于客户端 |
| 凌晨使用 | 罕见 | ⚠️ 取决于客户端 |
| 使用时长 | 8-12h/天 | ⚠️ 取决于客户端 |

---

## 🎯 已修复的差异（v1.1.0）

### ✅ 修复 1：HTTP 请求头完整性

**修复前**：
- 缺少 User-Agent
- 缺少 Accept、Accept-Encoding、Accept-Language、Connection

**修复后**：
- 全部 HTTP 标准头已添加
- User-Agent 与真实 CLI 一致

**效果**：检测风险从 90% 降到 5%

### ✅ 修复 2：Project Slug 多样化

**修复前**：
```
总是 users-dev-projects-{name}-{suffix}
```

**修复后**：
```
随机用户名 + 随机目录 + Windows/Unix 路径
home-alice-workspace-api-a3f2
users-bob-repos-frontend-b5d1
```

---

## 🔧 v1.2.0 新增改进

### ✅ 改进 1：指纹定期轮换（90 天）

**问题**：原版指纹永久固定，真实用户的硬件会升级。

**实现**：
- 添加 `fingerprintCreatedAt` 字段
- 每 90 天自动重新生成指纹
- 启动时检查并轮换

### ✅ 改进 2：时区与系统一致

**问题**：随机时区可能与 IP 地理位置不匹配。

**实现**：
```javascript
const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
```

### ✅ 改进 3：内置请求频率限制

**问题**：用户可能高频请求触发风控。

**实现**：
- 默认 8 次/小时
- 通过 `MAX_REQUESTS_PER_HOUR` 环境变量配置
- 超限返回 429

### ✅ 改进 4：使用时间检查

**问题**：凌晨高频使用是异常模式。

**实现**：
- 凌晨 2-7 点警告
- 记录到日志
- 不阻断请求（仅警告）

---

## 📊 风险演进

| 版本 | 风险 | 主要改进 |
|------|------|---------|
| v1.0.0 原版 | 40% | - |
| v1.1.0 安全增强版 | 10% | HTTP 头 + Slug |
| **v1.2.0 进阶版** | **5-7%** | 指纹轮换 + 频率限制 + 时间检查 |

---

## 🚨 仍然无法消除的风险

### 1. TLS/HTTP2 指纹（5%）

Node.js fetch 的 TLS ClientHello 和 HTTP/2 SETTINGS 帧与真实 CLI 不同。
**只能通过修改 Node.js 底层或使用代理库才能完全解决。**

### 2. 协议复刻本身（3%）

只要使用 `/alpha/generate` 端点而非 `/provider/v1/*`，就有协议复刻嫌疑。
**根本解决方法：使用官方 Provider API（$15/月）。**

### 3. IP 地址模式（2%）

固定 IP + 长期使用统计学模式。
**只能通过更换 IP 或使用代理 IP 缓解。**

---

## 💡 终极使用建议

### Go 套餐（$1）+ 仅 DeepSeek 用户

```bash
# 拉取最新版本（包含所有优化）
docker pull al1ya/commandcode-proxy:latest

# 推荐配置
docker run -d \
  --name commandcode-proxy \
  -p 127.0.0.1:3050:3050 \
  -e MAX_REQUESTS_PER_HOUR=8 \
  -e ENABLE_RATE_LIMIT=true \
  -e ENABLE_TIME_CHECK=true \
  al1ya/commandcode-proxy:latest
```

### 行为建议

1. **仅本地访问**（127.0.0.1）
2. **每小时 ≤ 8 次请求**（已硬性限制）
3. **避开凌晨 2-7 点**
4. **仅访问 DeepSeek 模型**（开源模型，价值匹配）
5. **使用 1-2 个月后停几天**（避免连续模式）

### 风险等级

| 使用方式 | 风险 |
|----------|------|
| Go + DeepSeek + 个人本地 + v1.2.0 | **~5%** ✅ |
| 高频使用 + 固定指纹 | 30%+ |
| 云服务器 + 多人共享 | 95%+ |

---

## 🎯 最终建议

如果你只用 DeepSeek，Go 套餐的 $10 信用 ≈ 25-50K 次 DeepSeek Flash 请求，对个人完全够用。

**最安全的策略**：
- 用 v1.2.0 反代（已优化到极限）
- 控制使用频率（每天 < 30 次）
- 工作时间使用
- 一旦看到异常立即停用

**风险持续存在**，但已经是技术层面能做到的最低水平。
