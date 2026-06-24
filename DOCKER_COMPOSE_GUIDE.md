# Docker Compose 配置说明

本项目提供两个 Docker Compose 配置文件，适用于不同场景。

---

## 📦 docker-compose.yml（精简版，推荐）

**适用场景**：快速启动、开发测试、简单部署

```yaml
services:
  commandcode-proxy:
    image: al1ya/commandcode-proxy:latest
    container_name: commandcode-proxy
    restart: unless-stopped
    ports:
      - '3050:3050'
    volumes:
      - ./logs:/app/logs
```

### 使用方法

```bash
docker compose up -d
```

### 特点

- ✅ 最简配置，一目了然
- ✅ 使用官方发布的镜像
- ✅ 自动重启
- ✅ 日志持久化到本地
- ✅ 无需 `.env` 文件

---

## 🔧 docker-compose.full.yml（完整版）

**适用场景**：生产环境、需要高级配置、资源管控

### 额外功能

- 🔧 环境变量配置（通过 `.env`）
- 🏥 健康检查机制
- 📊 资源限制（CPU/内存）
- 📝 日志轮转配置
- 🌐 独立网络
- 🏗️ 支持本地构建

### 使用方法

```bash
# 1. 复制环境变量模板
cp .env.example .env

# 2. 使用完整配置启动
docker compose -f docker-compose.full.yml up -d
```

---

## 📊 对比表

| 功能 | 精简版 | 完整版 |
|------|--------|--------|
| 镜像来源 | Docker Hub | Docker Hub / 本地构建 |
| 环境变量 | 默认值 | 可自定义 (.env) |
| 健康检查 | ❌ | ✅ |
| 资源限制 | ❌ | ✅ (CPU 1核/内存 512MB) |
| 日志轮转 | ❌ | ✅ (10MB×3) |
| 独立网络 | ❌ | ✅ |
| 配置复杂度 | ⭐ | ⭐⭐⭐⭐ |

---

## 🎯 推荐使用场景

### 使用精简版（docker-compose.yml）

- 快速测试项目
- 开发环境
- 个人使用
- 不需要资源限制
- 追求简洁

### 使用完整版（docker-compose.full.yml）

- 生产环境部署
- 需要精细控制资源
- 需要健康检查
- 需要自定义环境变量
- 团队协作

---

## 🔄 切换配置

### 从精简版切换到完整版

```bash
# 停止当前服务
docker compose down

# 启动完整版
cp .env.example .env
docker compose -f docker-compose.full.yml up -d
```

### 从完整版切换到精简版

```bash
# 停止当前服务
docker compose -f docker-compose.full.yml down

# 启动精简版
docker compose up -d
```

---

## 🛠️ 自定义配置

### 修改端口（精简版）

编辑 `docker-compose.yml`：

```yaml
ports:
  - '8080:3050'  # 宿主机端口:容器端口
```

### 修改端口（完整版）

编辑 `.env`：

```bash
PROXY_PORT=8080
```

### 添加环境变量（精简版）

```yaml
services:
  commandcode-proxy:
    image: al1ya/commandcode-proxy:latest
    container_name: commandcode-proxy
    restart: unless-stopped
    ports:
      - '3050:3050'
    volumes:
      - ./logs:/app/logs
    environment:
      LOG_LEVEL: debug
      CC_API_BASE: https://api.commandcode.ai
```

---

## 📝 常见问题

### Q: 为什么有两个配置文件？

A: 精简版适合快速启动，完整版提供生产级别的配置选项。大多数用户只需要精简版。

### Q: 我应该使用哪个？

A: 如果不确定，使用精简版（`docker-compose.yml`）。需要更多控制时再切换到完整版。

### Q: 精简版缺少健康检查会有问题吗？

A: 不会。健康检查主要用于生产环境的自动重启和监控。开发测试环境不需要。

### Q: 可以混合使用吗？

A: 可以。你可以复制完整版的部分配置到精简版中，根据需要定制。

---

## 🎉 快速开始

**新手推荐（最简单）：**

```bash
docker compose up -d
```

**进阶用户：**

```bash
cp .env.example .env
docker compose -f docker-compose.full.yml up -d
```

---

更多信息请参考：
- [README.md](README.md) - 完整文档
- [QUICKSTART.md](QUICKSTART.md) - 快速启动指南
