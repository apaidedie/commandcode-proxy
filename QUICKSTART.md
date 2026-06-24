# 🚀 快速启动指南

## 📦 项目已准备就绪！

本项目是 **Command Code Proxy** 的完整可部署版本，包含：

- ✅ Docker 镜像构建配置
- ✅ Docker Compose 一键部署
- ✅ 完整的环境变量配置
- ✅ 自动化部署脚本
- ✅ API 测试脚本
- ✅ Makefile 快捷命令
- ✅ GitHub Actions CI/CD
- ✅ 完整的中英文文档

---

## 🎯 三种部署方式

### 方式 1：一键部署（最简单）

```bash
chmod +x deploy.sh
./deploy.sh
```

### 方式 2：Makefile（推荐）

```bash
make deploy
```

### 方式 3：Docker Compose

```bash
cp .env.example .env
docker compose up -d
```

---

## ✅ 部署成功标志

当你看到以下输出时，说明部署成功：

```
[SUCCESS] Command Code Proxy 部署完成！
服务地址: http://localhost:3050
```

---

## 🧪 测试服务

### 健康检查

```bash
curl http://localhost:3050/health
# 应该返回: OK
```

### 获取模型列表

```bash
curl http://localhost:3050/v1/models \
  -H "Authorization: Bearer user_YOUR_API_KEY"
```

### 运行完整测试

```bash
chmod +x test.sh
API_KEY=user_YOUR_API_KEY ./test.sh
```

---

## 📝 配置 API Key

编辑 `.env` 文件或直接在请求中使用：

```bash
# 方式 1：环境变量
export API_KEY=user_xxxxxxxxx

# 方式 2：请求头
Authorization: Bearer user_xxxxxxxxx
```

**注意：** API Key 必须以 `user_` 开头！

---

## 🔧 常用命令

```bash
# 查看日志
docker compose logs -f

# 重启服务
docker compose restart

# 停止服务
docker compose down

# 查看状态
docker compose ps

# 进入容器
docker compose exec commandcode-proxy sh
```

---

## 📊 集成到你的项目

### Python

```python
from openai import OpenAI

client = OpenAI(
    api_key="user_xxxxxxxxx",
    base_url="http://localhost:3050/v1",
)

response = client.chat.completions.create(
    model="deepseek/deepseek-v4-flash",
    messages=[{"role": "user", "content": "Hello"}],
)
```

### JavaScript / TypeScript

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: 'user_xxxxxxxxx',
  baseURL: 'http://localhost:3050/v1',
});

const response = await client.chat.completions.create({
  model: 'deepseek/deepseek-v4-flash',
  messages: [{ role: 'user', content: 'Hello' }],
});
```

### Cursor / Continue / OpenCode

配置自定义 Provider：
- Base URL: `http://localhost:3050/v1`
- API Key: `user_xxxxxxxxx`

---

## 🐛 常见问题

### 1. 端口被占用

编辑 `.env` 文件，修改 `PROXY_PORT`：

```bash
PROXY_PORT=8080
```

### 2. 权限错误

```bash
chmod +x deploy.sh test.sh
```

### 3. 健康检查失败

等待几秒后重试，或查看日志：

```bash
docker compose logs commandcode-proxy
```

### 4. API Key 格式错误

确保 API Key 以 `user_` 开头，例如：
- ✅ `user_abc123xyz`
- ✅ `user_xxxxxxxxxxxxx`
- ❌ `sk-abc123xyz`（OpenAI 格式）
- ❌ `abc123xyz`（缺少前缀）

---

## 📚 更多信息

- [完整文档](README.md)
- [中文文档](README_zh.md)
- [原项目地址](https://github.com/MAXeaglet/commandcode-proxy)
- [Command Code 官网](https://www.commandcode.ai/)

---

## 🎉 下一步

1. ✅ 部署服务
2. ✅ 测试健康检查
3. ✅ 配置 API Key
4. ✅ 集成到你的项目
5. ✅ 开始使用！

---

**祝你使用愉快！** 🚀

如有问题，请查看日志或提交 Issue。
