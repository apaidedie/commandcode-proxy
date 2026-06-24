# Command Code Proxy - 项目构建总结

## 📦 项目概述

这是一个基于 [MAXeaglet/commandcode-proxy](https://github.com/MAXeaglet/commandcode-proxy) 原项目重新构建的**生产就绪的 Docker Compose 部署方案**。

### 核心功能

- 将 Command Code API 转换为 OpenAI/Anthropic 兼容接口
- 支持流式/非流式响应
- 支持工具调用（Function Calling）
- 支持多模态图像输入
- 动态模型列表
- 零外部依赖，单文件实现

---

## 🎯 改进点

相比原项目，本构建版本增加了：

### 1. 完整的容器化方案

- ✅ 优化的多阶段 Dockerfile
- ✅ 非 root 用户运行
- ✅ 健康检查机制
- ✅ 资源限制配置
- ✅ 日志轮转

### 2. 自动化部署

- ✅ 一键部署脚本 (`deploy.sh`)
- ✅ Makefile 快捷命令
- ✅ 环境变量配置模板
- ✅ API 测试脚本 (`test.sh`)

### 3. CI/CD 集成

- ✅ GitHub Actions 工作流
- ✅ 多架构镜像构建（amd64/arm64）
- ✅ 自动发布到 GitHub Container Registry

### 4. 完善的文档

- ✅ 详细的中英文 README
- ✅ 快速启动指南
- ✅ API 使用示例
- ✅ 故障排查指南

---

## 📁 项目结构

```
commandcode-proxy-rebuild/
├── .github/
│   └── workflows/
│       └── docker-publish.yml    # GitHub Actions CI/CD
├── logs/
│   └── .gitkeep                  # 日志目录占位
├── proxy.mjs                     # 核心代理代码（原项目）
├── package.json                  # npm 配置
├── config.json                   # 服务配置
├── Dockerfile                    # 优化的镜像构建
├── docker-compose.yml            # 完整的 Compose 配置
├── .env.example                  # 环境变量模板
├── .dockerignore                 # Docker 构建排除
├── .gitignore                    # Git 忽略文件
├── deploy.sh                     # 一键部署脚本
├── test.sh                       # API 测试脚本
├── Makefile                      # Make 命令集
├── LICENSE                       # MIT 许可证
├── README.md                     # 英文文档
├── README_zh.md                  # 中文文档
├── QUICKSTART.md                 # 快速启动指南
└── BUILD_SUMMARY.md              # 本文件
```

---

## 🚀 部署方式

### 方式 1：一键部署（推荐新手）

```bash
chmod +x deploy.sh
./deploy.sh
```

**优点：**
- 自动检查环境
- 自动创建配置
- 自动构建和启动
- 显示详细状态

### 方式 2：Makefile（推荐开发者）

```bash
make deploy    # 一键部署
make logs      # 查看日志
make health    # 健康检查
make test      # 运行测试
```

**优点：**
- 命令简洁
- 易于记忆
- 快速操作

### 方式 3：Docker Compose（推荐运维）

```bash
cp .env.example .env
docker compose up -d
docker compose logs -f
```

**优点：**
- 标准化流程
- 灵活配置
- 生产环境适用

---

## 🔧 配置说明

### 环境变量（.env）

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `PROXY_PORT` | `3050` | 宿主机端口 |
| `PORT` | `3050` | 容器内端口 |
| `HOST` | `0.0.0.0` | 监听地址 |
| `CC_API_BASE` | `https://api.commandcode.ai` | API 地址 |
| `PROJECT_SLUG` | `cc-proxy` | 项目标识 |
| `LOG_FILE` | `""` | 日志文件路径 |
| `LOG_LEVEL` | `info` | 日志级别 |
| `CC_USE_PROVIDER_MODELS` | `true` | 动态模型列表 |
| `TZ` | `Asia/Shanghai` | 时区 |

### Docker Compose 配置

- **资源限制**：CPU 1 核，内存 512MB
- **健康检查**：30 秒间隔，5 秒超时
- **日志轮转**：单文件 10MB，保留 3 个文件
- **重启策略**：`unless-stopped`

---

## 🧪 测试验证

### 1. 健康检查

```bash
curl http://localhost:3050/health
# 应返回: OK
```

### 2. 模型列表

```bash
curl http://localhost:3050/v1/models \
  -H "Authorization: Bearer user_YOUR_API_KEY"
```

### 3. 聊天完成

```bash
curl http://localhost:3050/v1/chat/completions \
  -H "Authorization: Bearer user_YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek/deepseek-v4-flash",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### 4. 自动化测试

```bash
chmod +x test.sh
API_KEY=user_YOUR_API_KEY ./test.sh
```

---

## 🔒 安全特性

### API Key 验证

- 必须以 `user_` 开头
- 自动清理额外前缀
- 拒绝 OpenAI 格式（`sk-xxx`）

### 容器安全

- 非 root 用户运行（`nodejs:1001`）
- 最小权限原则
- Alpine 基础镜像（最小化攻击面）

### 隐私保护

- 日志不记录 API Key
- 日志不记录响应内容
- 独立会话管理

---

## 📊 性能优化

### Docker 镜像

- 多阶段构建
- Alpine Linux 基础镜像
- 镜像大小：~100MB

### 运行时

- 零外部依赖
- 单进程架构
- 内存占用：~50-100MB

### 网络

- Keep-Alive 连接复用
- 流式传输优化
- 智能重试机制

---

## 🐛 故障排查

### 端口冲突

```bash
# 修改 .env
PROXY_PORT=8080

# 重启服务
docker compose restart
```

### 健康检查失败

```bash
# 查看日志
docker compose logs commandcode-proxy

# 进入容器调试
docker compose exec commandcode-proxy sh
```

### API Key 错误

确保格式正确：
- ✅ `user_abc123xyz`
- ❌ `sk-abc123xyz`
- ❌ `abc123xyz`

---

## 📈 未来改进

- [ ] 支持多个上游 API 负载均衡
- [ ] 添加 Prometheus 监控指标
- [ ] 添加请求限流功能
- [ ] 添加缓存层
- [ ] 支持 WebSocket 协议
- [ ] 添加 Grafana 监控面板

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发流程

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing`)
5. 创建 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证。

原项目：[MAXeaglet/commandcode-proxy](https://github.com/MAXeaglet/commandcode-proxy)

---

## 🙏 致谢

- **MAXeaglet** - 原项目作者
- **Command Code** - 提供 API 服务
- 所有贡献者和使用者

---

## 📞 支持

- GitHub Issues: [提交问题](https://github.com/apaidedie/commandcode-proxy/issues)
- 原项目: [MAXeaglet/commandcode-proxy](https://github.com/MAXeaglet/commandcode-proxy)
- Command Code: [官网](https://www.commandcode.ai/)

---

**构建时间：** 2026-06-25  
**版本：** 1.0.0  
**状态：** ✅ 生产就绪

---

<p align="center">
  <strong>🎉 祝你使用愉快！</strong>
</p>
