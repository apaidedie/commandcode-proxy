#!/bin/bash

# ========================================
# Docker Hub 配置检查脚本
# ========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo ""
log_info "========================================="
log_info "Docker Hub 配置检查"
log_info "========================================="
echo ""

# 检查 GitHub Secrets
log_info "检查 GitHub Secrets 配置..."
echo ""
log_info "请访问以下链接配置 Secrets："
echo "  https://github.com/apaidedie/commandcode-proxy/settings/secrets/actions"
echo ""

log_info "需要添加的 Secrets："
echo ""
echo "  1. DOCKERHUB_USERNAME"
echo "     值: al1ya"
echo ""
echo "  2. DOCKERHUB_TOKEN"
echo "     值: [从 Docker Hub 生成的 Access Token]"
echo ""

log_warn "如何获取 Docker Hub Token："
echo "  1. 登录 https://hub.docker.com/"
echo "  2. 点击右上角头像 → Account Settings"
echo "  3. 选择 Security → New Access Token"
echo "  4. 权限设置为: Read, Write, Delete"
echo "  5. 复制生成的 Token"
echo ""

# 检查当前 GitHub Actions 状态
log_info "检查 GitHub Actions 状态..."
if command -v gh &> /dev/null; then
    echo ""
    gh run list --repo apaidedie/commandcode-proxy --limit 3 2>&1 || log_warn "无法获取 Actions 状态"
else
    log_warn "gh CLI 未安装，无法自动检查"
    echo "  手动查看: https://github.com/apaidedie/commandcode-proxy/actions"
fi

echo ""
log_info "========================================="
log_info "手动触发构建"
log_info "========================================="
echo ""
log_info "配置完 Secrets 后，访问以下链接手动触发构建："
echo "  https://github.com/apaidedie/commandcode-proxy/actions/workflows/docker-publish.yml"
echo ""
log_info "点击 'Run workflow' → 选择 'main' 分支 → 'Run workflow'"
echo ""

echo ""
log_info "========================================="
log_info "镜像地址"
log_info "========================================="
echo ""
echo "构建完成后，可以使用以下命令拉取镜像："
echo ""
echo "  Docker Hub:"
echo "    docker pull al1ya/commandcode-proxy:latest"
echo ""
echo "  GitHub Container Registry:"
echo "    docker pull ghcr.io/apaidedie/commandcode-proxy:latest"
echo ""

log_success "配置指南已完成！"
echo ""
