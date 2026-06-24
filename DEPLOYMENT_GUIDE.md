# 🚀 GitHub 和 Docker Hub 部署指南

## ✅ 已完成的步骤

- ✅ GitHub 仓库已创建：https://github.com/apaidedie/commandcode-proxy
- ✅ 代码已推送到 GitHub（main 分支）
- ✅ GitHub Actions 工作流已配置（支持 GHCR 和 Docker Hub）

---

## 🔧 下一步：配置 Docker Hub 自动构建

### 1️⃣ 创建 Docker Hub Access Token

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → **Account Settings**
3. 选择 **Security** → **New Access Token**
4. 设置：
   - **Token Description**: `GitHub Actions - commandcode-proxy`
   - **Permissions**: `Read, Write, Delete`
5. 点击 **Generate**
6. **⚠️ 重要**：复制生成的 Token（只显示一次）

---

### 2️⃣ 在 GitHub 添加 Secrets

访问：https://github.com/apaidedie/commandcode-proxy/settings/secrets/actions

添加两个 Secrets：

#### Secret 1: `DOCKERHUB_USERNAME`
- **Name**: `DOCKERHUB_USERNAME`
- **Value**: `al1ya`

#### Secret 2: `DOCKERHUB_TOKEN`
- **Name**: `DOCKERHUB_TOKEN`
- **Value**: 刚才复制的 Docker Hub Token

---

### 3️⃣ 触发首次构建

配置完成后，有两种方式触发构建：

#### 方式 1：手动触发（推荐）

1. 访问：https://github.com/apaidedie/commandcode-proxy/actions
2. 选择 **Build and Publish Docker Images** 工作流
3. 点击 **Run workflow** → 选择 `main` 分支 → **Run workflow**

#### 方式 2：推送代码触发

```bash
cd /e/Vibe\ Coding/ClaudeCode/commandcode-proxy-rebuild

# 创建一个小更新
echo "" >> README.md
git add README.md
git commit -m "Trigger Docker build"
git push
```

---

## 📦 镜像地址

构建完成后，镜像将发布到：

### GitHub Container Registry (GHCR)
```bash
docker pull ghcr.io/apaidedie/commandcode-proxy:latest
```

### Docker Hub
```bash
docker pull al1ya/commandcode-proxy:latest
```

---

## 🔍 查看构建状态

- **GitHub Actions**: https://github.com/apaidedie/commandcode-proxy/actions
- **Docker Hub 仓库**: https://hub.docker.com/r/al1ya/commandcode-proxy

---

## 🎯 使用发布的镜像

### 方式 1：使用 Docker Hub 镜像

编辑 `docker-compose.yml`：

```yaml
services:
  commandcode-proxy:
    image: al1ya/commandcode-proxy:latest  # 使用 Docker Hub 镜像
    # build:  # 注释掉本地构建
    #   context: .
    #   dockerfile: Dockerfile
```

### 方式 2：使用 GHCR 镜像

```yaml
services:
  commandcode-proxy:
    image: ghcr.io/apaidedie/commandcode-proxy:latest  # 使用 GHCR 镜像
```

### 方式 3：直接 Docker Run

```bash
docker run -d \
  --name commandcode-proxy \
  -p 3050:3050 \
  -e PORT=3050 \
  -e CC_API_BASE=https://api.commandcode.ai \
  al1ya/commandcode-proxy:latest
```

---

## 🏷️ 多架构支持

构建的镜像支持以下架构：
- ✅ `linux/amd64` (x86_64)
- ✅ `linux/arm64` (Apple Silicon / ARM 服务器)

Docker 会自动拉取适合你系统的架构。

---

## 📊 构建徽章（可选）

添加到 README.md 顶部：

```markdown
[![Docker Hub](https://img.shields.io/docker/pulls/al1ya/commandcode-proxy.svg)](https://hub.docker.com/r/al1ya/commandcode-proxy)
[![GitHub Actions](https://github.com/apaidedie/commandcode-proxy/workflows/Build%20and%20Publish%20Docker%20Images/badge.svg)](https://github.com/apaidedie/commandcode-proxy/actions)
[![Docker Image Size](https://img.shields.io/docker/image-size/al1ya/commandcode-proxy/latest)](https://hub.docker.com/r/al1ya/commandcode-proxy)
```

---

## ⚙️ 自动构建触发条件

GitHub Actions 会在以下情况自动构建并推送镜像：

1. **推送到 main/master 分支** - 构建 `latest` 标签
2. **创建 Git Tag** (如 `v1.0.0`) - 构建版本标签
3. **手动触发** - 通过 Actions 页面的 "Run workflow"

---

## 🔒 安全说明

- ✅ `DOCKERHUB_TOKEN` 是加密存储的 GitHub Secret，不会泄露
- ✅ Token 可以随时在 Docker Hub 撤销
- ✅ GitHub Actions 日志不会显示 Secret 内容
- ✅ 建议每 6-12 个月轮换一次 Token

---

## 🐛 常见问题

### Q: 构建失败，提示 "unauthorized"
**A**: 检查 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN` Secrets 是否正确配置。

### Q: 镜像推送到 GHCR 成功，但 Docker Hub 失败
**A**: 确认 Docker Hub Token 有 `Read, Write, Delete` 权限。

### Q: 如何查看构建日志？
**A**: 访问 https://github.com/apaidedie/commandcode-proxy/actions，点击最新的工作流运行。

---

## 📞 下一步

1. ✅ 在 GitHub 添加 Docker Hub Secrets（见上方步骤 2）
2. ✅ 手动触发首次构建（见上方步骤 3）
3. ✅ 等待 5-10 分钟，镜像构建完成
4. ✅ 使用 `docker pull al1ya/commandcode-proxy:latest` 测试

---

**🎉 完成后，你的项目将同时发布到 GitHub Container Registry 和 Docker Hub！**

需要帮助？查看：
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Hub 文档](https://docs.docker.com/docker-hub/)
