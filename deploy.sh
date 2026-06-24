#!/bin/bash

# ========================================
# Command Code Proxy - 快速部署脚本
# ========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker
check_docker() {
    log_info "检查 Docker 环境..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker 未运行，请启动 Docker"
        exit 1
    fi

    log_success "Docker 环境正常"
}

# 检查 Docker Compose
check_docker_compose() {
    log_info "检查 Docker Compose..."
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi
    log_success "Docker Compose 已安装"
}

# 创建 .env 文件
create_env() {
    if [ ! -f .env ]; then
        log_info "创建 .env 配置文件..."
        cp .env.example .env
        log_success ".env 文件已创建，请根据需要修改配置"
    else
        log_info ".env 文件已存在，跳过创建"
    fi
}

# 创建日志目录
create_logs_dir() {
    log_info "创建日志目录..."
    mkdir -p logs
    log_success "日志目录已创建"
}

# 构建镜像
build_image() {
    log_info "构建 Docker 镜像..."
    docker compose build
    log_success "镜像构建完成"
}

# 启动服务
start_service() {
    log_info "启动服务..."
    docker compose up -d
    log_success "服务启动成功"
}

# 显示服务状态
show_status() {
    log_info "服务状态："
    docker compose ps

    echo ""
    log_info "健康检查："
    sleep 5
    if docker compose exec commandcode-proxy wget --spider --quiet http://127.0.0.1:3050/health 2>/dev/null; then
        log_success "服务健康检查通过"
    else
        log_warn "服务健康检查失败，请查看日志"
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    log_success "========================================="
    log_success "Command Code Proxy 部署完成！"
    log_success "========================================="
    echo ""
    log_info "服务地址: http://localhost:${PROXY_PORT:-3050}"
    echo ""
    log_info "常用命令："
    echo "  查看日志:    docker compose logs -f"
    echo "  停止服务:    docker compose down"
    echo "  重启服务:    docker compose restart"
    echo "  查看状态:    docker compose ps"
    echo ""
    log_info "API 测试："
    echo "  curl http://127.0.0.1:${PROXY_PORT:-3050}/health"
    echo "  curl http://127.0.0.1:${PROXY_PORT:-3050}/v1/models \\"
    echo "    -H 'Authorization: Bearer user_YOUR_API_KEY'"
    echo ""
    log_warn "请将 user_YOUR_API_KEY 替换为你的实际 API Key"
    echo ""
}

# 主函数
main() {
    echo ""
    log_info "========================================="
    log_info "Command Code Proxy - 快速部署"
    log_info "========================================="
    echo ""

    check_docker
    check_docker_compose
    create_env
    create_logs_dir
    build_image
    start_service
    show_status
    show_usage
}

# 运行
main
