#!/bin/bash

# ========================================
# 自动配置 Docker Hub Secrets 并触发构建
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
log_info "Docker Hub 自动配置脚本"
log_info "========================================="
echo ""

# Step 1: 添加 DOCKERHUB_USERNAME
log_info "Step 1: 添加 DOCKERHUB_USERNAME..."
echo ""
echo "al1ya" | gh secret set DOCKERHUB_USERNAME --repo apaidedie/commandcode-proxy
log_success "DOCKERHUB_USERNAME 已添加"
echo ""

# Step 2: 添加 DOCKERHUB_TOKEN
log_info "Step 2: 添加 DOCKERHUB_TOKEN..."
echo ""
log_warn "请输入你的 Docker Hub Access Token:"
echo ""
log_info "如果还没有 Token，请按以下步骤创建："
echo "  1. 访问 https://hub.docker.com/settings/security"
echo "  2. 点击 'New Access Token'"
echo "  3. Description: GitHub Actions - commandcode-proxy"
echo "  4. Permissions: Read, Write, Delete"
echo "  5. 复制生成的 Token"
echo ""
echo -n "请输入 Docker Hub Token: "
read -s DOCKERHUB_TOKEN
echo ""
echo ""

if [ -z "$DOCKERHUB_TOKEN" ]; then
    log_error "Token 不能为空"
    exit 1
fi

# 设置 Secret
echo "$DOCKERHUB_TOKEN" | gh secret set DOCKERHUB_TOKEN --repo apaidedie/commandcode-proxy
log_success "DOCKERHUB_TOKEN 已添加"
echo ""

# 验证 Secrets
log_info "Step 3: 验证 Secrets 配置..."
echo ""
gh secret list --repo apaidedie/commandcode-proxy
echo ""

# 触发构建
log_info "Step 4: 触发 GitHub Actions 构建..."
echo ""
gh workflow run docker-publish.yml --repo apaidedie/commandcode-proxy --ref main
log_success "构建已触发！"
echo ""

# 显示状态
log_info "查看构建状态:"
echo "  https://github.com/apaidedie/commandcode-proxy/actions"
echo ""

log_info "等待 5-10 分钟后，镜像将发布到:"
echo "  Docker Hub: docker pull al1ya/commandcode-proxy:latest"
echo "  GHCR: docker pull ghcr.io/apaidedie/commandcode-proxy:latest"
echo ""

log_success "========================================="
log_success "配置完成！"
log_success "========================================="
echo ""
