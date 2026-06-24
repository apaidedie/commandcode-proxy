# ========================================
# Command Code Proxy - 多阶段构建 Dockerfile
# ========================================

# ── 阶段 1: 基础镜像 ──
FROM node:22-alpine AS base

# 设置工作目录
WORKDIR /app

# 安装健康检查工具
RUN apk add --no-cache wget

# ── 阶段 2: 生产镜像 ──
FROM base AS production

# 复制依赖描述并安装
COPY package.json ./
RUN npm install --omit=dev --no-audit --no-fund && \
    npm cache clean --force

# 复制应用文件
COPY proxy.mjs ./
COPY config.json ./

# 创建日志目录
RUN mkdir -p /app/logs && \
    chmod 755 /app/logs

# 暴露端口
EXPOSE 3050

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider --quiet http://127.0.0.1:3050/health || exit 1

# 非 root 用户运行
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# 启动命令
CMD ["node", "proxy.mjs"]
