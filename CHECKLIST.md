# ✅ 部署前检查清单

在部署 Command Code Proxy 之前，请确保完成以下检查：

---

## 📋 环境要求

### 必需软件

- [ ] **Docker** 已安装并运行
  ```bash
  docker --version
  docker info
  ```

- [ ] **Docker Compose** 已安装
  ```bash
  docker compose version
  ```

### 可选软件

- [ ] **Make** 已安装（用于 Makefile 命令）
  ```bash
  make --version
  ```

- [ ] **curl** 已安装（用于测试）
  ```bash
  curl --version
  ```

- [ ] **jq** 已安装（用于格式化 JSON 输出）
  ```bash
  jq --version
  ```

---

## 🔧 配置检查

### 1. 环境变量配置

- [ ] 复制 `.env.example` 到 `.env`
  ```bash
  cp .env.example .env
  ```

- [ ] 检查端口是否可用
  ```bash
  # Linux/Mac
  lsof -i :3050
  
  # Windows
  netstat -ano | findstr :3050
  ```

- [ ] 如需修改端口，编辑 `.env` 中的 `PROXY_PORT`

### 2. 脚本权限

- [ ] 给脚本添加执行权限
  ```bash
  chmod +x deploy.sh test.sh
  ```

---

## 🚀 部署步骤

### 选择部署方式

**方式 1：一键部署（推荐）**
```bash
./deploy.sh
```

**方式 2：Makefile**
```bash
make deploy
```

**方式 3：Docker Compose**
```bash
docker compose up -d
```

---

## ✅ 部署后验证

### 1. 服务状态检查

- [ ] 检查容器运行状态
  ```bash
  docker compose ps
  # 状态应为 "Up (healthy)"
  ```

- [ ] 查看容器日志
  ```bash
  docker compose logs commandcode-proxy
  # 应看到 "Server listening on http://0.0.0.0:3050"
  ```

### 2. 健康检查

- [ ] HTTP 健康检查
  ```bash
  curl http://localhost:3050/health
  # 应返回: OK
  ```

- [ ] 容器健康状态
  ```bash
  docker inspect --format='{{.State.Health.Status}}' commandcode-proxy
  # 应返回: healthy
  ```

### 3. API 功能测试

- [ ] 获取模型列表（需要有效的 API Key）
  ```bash
  curl http://localhost:3050/v1/models \
    -H "Authorization: Bearer user_YOUR_API_KEY"
  # 应返回模型列表 JSON
  ```

- [ ] 运行完整测试套件
  ```bash
  API_KEY=user_YOUR_API_KEY ./test.sh
  ```

---

## 🔑 API Key 配置

### API Key 格式要求

- [ ] API Key 必须以 `user_` 开头
- [ ] 示例：`user_abc123xyz789`
- [ ] ❌ 不支持：`sk-xxx`（OpenAI 格式）

### 获取 API Key

1. 访问 [Command Code 官网](https://www.commandcode.ai/)
2. 注册并登录
3. 在设置中获取 API Key

---

## 🔍 常见问题排查

### 问题 1：端口被占用

**症状：** `bind: address already in use`

**解决：**
```bash
# 修改 .env 文件
PROXY_PORT=8080

# 重启服务
docker compose down && docker compose up -d
```

### 问题 2：权限错误

**症状：** `Permission denied`

**解决：**
```bash
chmod +x deploy.sh test.sh
```

### 问题 3：Docker 未运行

**症状：** `Cannot connect to the Docker daemon`

**解决：**
- 启动 Docker Desktop
- 或运行 `sudo systemctl start docker`

### 问题 4：健康检查失败

**症状：** `unhealthy` 状态

**解决：**
```bash
# 等待 10-15 秒后重新检查
sleep 15
docker compose ps

# 查看详细日志
docker compose logs --tail=50 commandcode-proxy
```

---

## 📊 性能基准

### 预期资源使用

- **内存**：50-100MB
- **CPU**：0.1-0.5 核心（空闲时）
- **磁盘**：~100MB（镜像）

### 响应时间

- **健康检查**：< 50ms
- **模型列表**：< 200ms
- **聊天请求**：取决于上游 API

---

## 🎯 下一步行动

部署成功后：

- [ ] 集成到你的应用（Python/JS/cURL）
- [ ] 配置 Cursor/Continue/OpenCode
- [ ] 设置监控和日志
- [ ] 阅读完整文档 [README.md](README.md)

---

## 📞 获取帮助

- **文档**：[README.md](README.md) | [README_zh.md](README_zh.md)
- **快速指南**：[QUICKSTART.md](QUICKSTART.md)
- **构建总结**：[BUILD_SUMMARY.md](BUILD_SUMMARY.md)
- **原项目**：[github.com/MAXeaglet/commandcode-proxy](https://github.com/MAXeaglet/commandcode-proxy)

---

## ✨ 部署完成确认

当你完成所有检查项后：

- ✅ 环境就绪
- ✅ 配置正确
- ✅ 服务运行
- ✅ 健康检查通过
- ✅ API 功能正常

**🎉 恭喜！你已成功部署 Command Code Proxy！**

---

*最后更新：2026-06-25*
