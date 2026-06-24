# Command Code Proxy - 中文文档

> **Command Code API → OpenAI 兼容接口的反向代理**  
> 🚀 一键部署 | 🐳 Docker Compose | 📦 零外部依赖 | 🔄 OpenAI/Anthropic SDK 兼容

[English](README.md) | **中文文档**

---

## 🚀 快速开始

### 一键部署（推荐）

```bash
# 克隆项目
git clone https://github.com/apaidedie/commandcode-proxy.git
cd commandcode-proxy

# 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

### 使用 Makefile

```bash
make help      # 查看所有命令
make deploy    # 一键部署
make logs      # 查看日志
make test      # 运行测试
```

### Docker Compose

```bash
cp .env.example .env
docker compose up -d
docker compose logs -f
```

---

## 📋 配置

编辑 `.env` 文件：

```bash
PROXY_PORT=3050                          # 端口
CC_API_BASE=https://api.commandcode.ai   # API 地址
LOG_LEVEL=info                           # 日志级别
```

---

## 🔧 使用示例

### Python + OpenAI SDK

```python
from openai import OpenAI

client = OpenAI(
    api_key="user_xxxxxxxxx",
    base_url="http://localhost:3050/v1",
)

response = client.chat.completions.create(
    model="deepseek/deepseek-v4-flash",
    messages=[{"role": "user", "content": "你好"}],
    stream=True,
)

for chunk in response:
    print(chunk.choices[0].delta.content or "", end="")
```

### cURL

```bash
curl http://localhost:3050/v1/chat/completions \
  -H "Authorization: Bearer user_xxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek/deepseek-v4-flash",
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

---

## 📊 支持的模型

| 模型 | 描述 |
|------|------|
| `deepseek/deepseek-v4-flash` | 快速通用 |
| `deepseek/deepseek-v4-pro` | 高精度推理 |
| `claude-sonnet-4-6` | 长上下文 |
| `claude-opus-4-8` | 最强推理 |
| `xiaomi/mimo-v2.5` | 支持图像 |

获取完整列表：

```bash
curl http://localhost:3050/v1/models \
  -H "Authorization: Bearer user_xxxxxxxxx"
```

---

## 🔗 第三方集成

### Cursor

- **API Base URL**: `http://localhost:3050/v1`
- **API Key**: `user_xxxxxxxxx`

### OpenCode / Continue

```json
{
  "provider": "openai-compatible",
  "baseUrl": "http://localhost:3050/v1",
  "apiKey": "user_xxxxxxxxx"
}
```

---

## 🛠️ 常用命令

```bash
# Makefile
make deploy     # 一键部署
make up         # 启动
make down       # 停止
make restart    # 重启
make logs       # 日志
make health     # 健康检查
make test       # 测试

# Docker Compose
docker compose up -d
docker compose down
docker compose logs -f
docker compose ps

# 测试
curl http://localhost:3050/health
API_KEY=user_xxx ./test.sh
```

---

## 📂 项目结构

```
commandcode-proxy/
├── proxy.mjs              # 核心代码（零依赖）
├── Dockerfile             # 镜像构建
├── docker-compose.yml     # 容器编排
├── deploy.sh              # 部署脚本
├── test.sh                # 测试脚本
├── Makefile               # Make 命令
└── README_zh.md           # 中文文档
```

---

## 🔒 安全特性

- ✅ API Key 必须以 `user_` 开头
- ✅ 日志不记录敏感信息
- ✅ 非 root 用户运行
- ✅ 资源限制和健康检查

---

## ⚠️ 免责声明

- **非官方项目** - 与 Command Code 官方无关
- **个人使用** - 遵守服务条款
- **隐私保护** - 不收集或泄露 API Key
- **使用建议** - 保持正常使用频率

---

## 📄 许可证

[MIT License](LICENSE)

---

## 🔗 相关链接

- [Command Code 官网](https://www.commandcode.ai/)
- [OpenAI API 文档](https://platform.openai.com/docs/api-reference)
- [Anthropic API 文档](https://docs.anthropic.com/)
- [原项目地址](https://github.com/MAXeaglet/commandcode-proxy)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/MAXeaglet">MAXeaglet</a>
</p>
