# Command Code Proxy

> **Command Code API → OpenAI 兼容接口的反向代理**  
> 🚀 一键部署 | 🐳 Docker Compose | 📦 零外部依赖 | 🔄 完整的 OpenAI/Anthropic SDK 兼容

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-22-green.svg)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

基于官方 CLI v0.32.3 网络流量分析构建，完整复刻 Command Code API 协议。

[English](README.md) | [中文文档](README_zh.md)

---

## ✨ 特性

- 🚀 **零依赖单文件** - 纯 Node.js 实现，无需安装任何 npm 包
- 🔄 **双协议支持** - OpenAI Chat Completions + Anthropic Messages API
- 📡 **完整流式支持** - SSE 流式响应，实时输出
- 🛠️ **工具调用支持** - Function calling / Tool use
- 🖼️ **多模态输入** - 支持图像输入（Vision 模型）
- 🧠 **推理控制** - reasoning_effort 参数支持
- 📊 **动态模型列表** - 自动从 Provider API 获取最新模型
- 💾 **缓存命中统计** - 详细的 token 使用和缓存数据
- 🔒 **隐私保护** - 日志不记录 API Key 片段
- 🐳 **Docker 一键部署** - 完整的容器化方案
- 🏥 **健康检查** - 内置健康检查端点
- ⚡ **智能重试** - 零输出自动重试、连续超时处理

---

## 🚀 快速开始

### 方式 1：一键部署脚本（推荐）

```bash
# 1. 克隆或下载项目
git clone https://github.com/apaidedie/commandcode-proxy.git
cd commandcode-proxy

# 2. 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

部署脚本会自动：
- ✅ 检查 Docker 环境
- ✅ 创建配置文件
- ✅ 构建镜像
- ✅ 启动服务
- ✅ 健康检查
- ✅ 显示使用说明

### 方式 2：使用 Makefile

```bash
# 查看所有命令
make help

# 一键部署
make deploy

# 或者手动步骤
make config    # 创建配置文件
make build     # 构建镜像
make up        # 启动服务
make health    # 健康检查
make logs      # 查看日志
```

### 方式 3：Docker Compose

```bash
# 1. 创建配置文件
cp .env.example .env

# 2. 启动服务
docker compose up -d

# 3. 查看日志
docker compose logs -f

# 4. 健康检查
curl http://localhost:3050/health
```

### 方式 4：本地运行

```bash
# 无需 npm install，直接运行
npm start

# 或开发模式（自动重载）
npm run dev
```

---

## 📋 配置说明

### 环境变量配置

创建 `.env` 文件（或复制 `.env.example`）：

```bash
# 服务配置
PROXY_PORT=3050                               # 宿主机端口
PORT=3050                                     # 容器内端口
HOST=0.0.0.0                                  # 监听地址

# API 配置
CC_API_BASE=https://api.commandcode.ai        # CC API 地址
PROJECT_SLUG=cc-proxy                         # 项目标识

# 日志配置
LOG_FILE=                                     # 日志文件路径（空=控制台）
LOG_LEVEL=info                                # 日志级别

# 模型配置
CC_USE_PROVIDER_MODELS=true                   # 动态获取模型列表

# 其他
TZ=Asia/Shanghai                              # 时区
```

### config.json 配置

```json
{
  "port": 3050,
  "host": "0.0.0.0",
  "apiBase": "https://api.commandcode.ai",
  "projectSlug": "cc-proxy",
  "logFile": "",
  "logLevel": "info",
  "useProviderModels": true,
  "modelRefreshIntervalMs": 300000
}
```

---

## 🔧 API 使用示例

### 1. OpenAI Chat Completions

#### Python SDK

```python
from openai import OpenAI

client = OpenAI(
    api_key="user_xxxxxxxxx",  # 你的 Command Code API Key
    base_url="http://localhost:3050/v1",
)

# 非流式
response = client.chat.completions.create(
    model="deepseek/deepseek-v4-flash",
    messages=[{"role": "user", "content": "你好"}],
)
print(response.choices[0].message.content)

# 流式
stream = client.chat.completions.create(
    model="deepseek/deepseek-v4-flash",
    messages=[{"role": "user", "content": "你好"}],
    stream=True,
)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```

#### cURL

```bash
curl http://localhost:3050/v1/chat/completions \
  -H "Authorization: Bearer user_xxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek/deepseek-v4-flash",
    "messages": [{"role": "user", "content": "你好"}],
    "stream": true
  }'
```

### 2. Anthropic Messages API

```python
import anthropic

client = anthropic.Anthropic(
    api_key="user_xxxxxxxxx",
    base_url="http://localhost:3050",
)

message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1000,
    system="你是一个有帮助的助手。",
    messages=[{"role": "user", "content": "你好"}],
)
print(message.content[0].text)
```

### 3. 多模态图像输入

```python
# 需要使用支持 Vision 的模型
response = client.chat.completions.create(
    model="xiaomi/mimo-v2.5",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "描述这张图片"},
            {
                "type": "image_url",
                "image_url": {
                    "url": "data:image/jpeg;base64,/9j/4AAQ..."
                }
            }
        ]
    }]
)
```

### 4. 工具调用（Function Calling）

```python
tools = [{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "获取指定城市的天气",
        "parameters": {
            "type": "object",
            "properties": {
                "city": {"type": "string", "description": "城市名称"}
            },
            "required": ["city"]
        }
    }
}]

response = client.chat.completions.create(
    model="deepseek/deepseek-v4-flash",
    messages=[{"role": "user", "content": "北京天气怎么样？"}],
    tools=tools,
    tool_choice="auto"
)
```

---

## 📊 支持的模型

代理会动态获取最新模型列表，常见模型包括：

| 模型 ID | 描述 | 特性 |
|---------|------|------|
| `deepseek/deepseek-v4-flash` | DeepSeek V4 Flash | 快速、通用 |
| `deepseek/deepseek-v4-pro` | DeepSeek V4 Pro | 高精度推理 |
| `claude-sonnet-4-6` | Claude Sonnet 4.6 | 长上下文 |
| `claude-opus-4-8` | Claude Opus 4.8 | 最强推理 |
| `moonshotai/Kimi-K2.5` | Kimi K2.5 | 多模态/前端 |
| `xiaomi/mimo-v2.5` | MiMo V2.5 | 支持图像输入 |
| `Qwen/Qwen3.7-Max` | 通义千问 3.7 Max | 大参数 |
| `google/gemini-3.5-flash` | Gemini 3.5 Flash | 推理模型 |

### 获取完整模型列表

```bash
curl http://localhost:3050/v1/models \
  -H "Authorization: Bearer user_xxxxxxxxx"
```

---

## 🔗 第三方集成

### Cursor

在 Cursor 设置中添加自定义 Provider：

- **API Base URL**: `http://localhost:3050/v1`
- **API Key**: `user_xxxxxxxxx`
- **Model**: 从模型列表中选择

### OpenCode

```json
{
  "provider": "openai-compatible",
  "baseUrl": "http://localhost:3050/v1",
  "apiKey": "user_xxxxxxxxx"
}
```

### Continue

```json
{
  "models": [{
    "title": "DeepSeek V4 Flash",
    "provider": "openai",
    "model": "deepseek/deepseek-v4-flash",
    "apiKey": "user_xxxxxxxxx",
    "apiBase": "http://localhost:3050/v1"
  }]
}
```

---

## 🛠️ 常用命令

### Makefile 命令

```bash
make help       # 显示所有命令
make deploy     # 一键部署
make up         # 启动服务
make down       # 停止服务
make restart    # 重启服务
make logs       # 查看日志
make ps         # 查看状态
make health     # 健康检查
make test       # 运行测试
make clean      # 清理资源
```

### Docker Compose 命令

```bash
docker compose up -d              # 启动服务
docker compose down               # 停止服务
docker compose restart            # 重启服务
docker compose logs -f            # 查看日志
docker compose ps                 # 查看状态
docker compose exec commandcode-proxy sh  # 进入容器
docker compose build --no-cache   # 重新构建
```

### 测试命令

```bash
# 健康检查
curl http://localhost:3050/health

# 模型列表
curl http://localhost:3050/v1/models \
  -H "Authorization: Bearer user_xxxxxxxxx"

# 运行完整测试套件
chmod +x test.sh
API_KEY=user_xxxxxxxxx ./test.sh
```

---

## 📂 项目结构

```
commandcode-proxy/
├── proxy.mjs              # 代理核心（~1600 行，零依赖）
├── package.json           # npm 配置
├── config.json            # 服务配置
├── Dockerfile             # Docker 镜像构建
├── docker-compose.yml     # Compose 编排
├── .env.example           # 环境变量模板
├── .dockerignore          # Docker 忽略文件
├── .gitignore             # Git 忽略文件
├── deploy.sh              # 一键部署脚本
├── test.sh                # API 测试脚本
├── Makefile               # Make 命令
├── README.md              # 英文文档
├── README_zh.md           # 中文文档
├── LICENSE                # MIT 许可证
└── logs/                  # 日志目录（运行时创建）
```

---

## 🔒 安全特性

### API Key 验证
- ✅ 必须以 `user_` 开头
- ✅ 自动清理额外路径/前缀
- ✅ 拒绝 `sk-xxx` 格式（OpenAI 格式）
- ✅ 支持 Bearer token 格式

### 隐私保护
- ✅ 日志不记录 API Key 片段
- ✅ 日志不记录错误响应体
- ✅ 日志不记录堆栈跟踪
- ✅ 每个 API Key 独立会话

### 容器安全
- ✅ 非 root 用户运行（nodejs:1001）
- ✅ 资源限制（CPU/内存）
- ✅ 健康检查机制
- ✅ 日志轮转配置
- ✅ 最小化镜像体积（Alpine）

---

## 🚨 错误处理

| HTTP 状态码 | 说明 | 处理建议 |
|-------------|------|----------|
| `400` | 请求格式无效 | 检查请求体格式 |
| `401` | API Key 缺失/格式错误/被拒绝 | 确认 API Key 格式正确 |
| `429` | 流超时（30s 流式 / 90s 非流式） | SDK 会自动重试 |
| `502` | 零输出 token 或上游错误 | SDK 会自动重试 |
| `503` | 服务暂时不可用 | 稍后重试 |

---

## 🔍 监控与调试

### 健康检查

```bash
# 检查服务状态
curl http://localhost:3050/health

# 检查容器健康
docker inspect --format='{{.State.Health.Status}}' commandcode-proxy
```

### 日志查看

```bash
# 实时日志
docker compose logs -f

# 最近 100 行
docker compose logs --tail=100

# 导出日志
docker compose logs > proxy.log
```

### 性能监控

```bash
# 容器资源使用
docker stats commandcode-proxy

# 详细信息
docker inspect commandcode-proxy
```

---

## 📄 许可证

[MIT License](LICENSE)

---

## ⚠️ 免责声明

本项目仅供学习和研究使用。

- **非官方项目** - 本项目与 Command Code 官方无任何关联
- **个人使用** - 使用者承担所有责任，请遵守 Command Code 服务条款
- **API Key 安全** - 本项目不收集、上传或泄露你的 API Key
- **协议分析** - 基于本地 CLI 网络流量的被动观察，未进行任何服务器破解或篡改
- **账号风险** - 请保持使用频率与正常 CLI 使用一致，避免触发风控

---

## 🔗 相关链接

- [Command Code 官网](https://www.commandcode.ai/)
- [Command Code 价格](https://www.commandcode.ai/pricing)
- [OpenAI API 文档](https://platform.openai.com/docs/api-reference)
- [Anthropic API 文档](https://docs.anthropic.com/)
- [Linux.do 社区](https://linux.do/)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发流程

```bash
# 1. Fork 项目
# 2. 创建特性分支
git checkout -b feature/amazing-feature

# 3. 提交更改
git commit -m 'Add amazing feature'

# 4. 推送到分支
git push origin feature/amazing-feature

# 5. 创建 Pull Request
```

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/MAXeaglet">MAXeaglet</a>
</p>

<p align="center">
  <a href="#command-code-proxy">回到顶部 ⬆️</a>
</p>
