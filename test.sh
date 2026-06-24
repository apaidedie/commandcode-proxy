#!/bin/bash

# ========================================
# Command Code Proxy - API 测试脚本
# ========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BASE_URL="${BASE_URL:-http://localhost:3050}"
API_KEY="${API_KEY:-user_test_key}"

# 日志函数
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

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."

    if ! command -v curl &> /dev/null; then
        log_error "curl 未安装"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        log_warn "jq 未安装，JSON 输出将不会格式化"
    fi

    log_success "依赖检查完成"
}

# 测试健康检查
test_health() {
    log_info "测试健康检查端点..."

    response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/health")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -eq 200 ]; then
        log_success "健康检查通过 (HTTP $http_code)"
        echo "  响应: $body"
    else
        log_error "健康检查失败 (HTTP $http_code)"
        exit 1
    fi
    echo ""
}

# 测试模型列表
test_models() {
    log_info "测试模型列表端点..."

    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer ${API_KEY}" \
        "${BASE_URL}/v1/models")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -eq 200 ]; then
        log_success "模型列表获取成功 (HTTP $http_code)"

        if command -v jq &> /dev/null; then
            model_count=$(echo "$body" | jq '.data | length')
            echo "  可用模型数量: $model_count"
            echo "  前 5 个模型:"
            echo "$body" | jq -r '.data[:5][] | "    - \(.id)"'
        else
            echo "$body" | head -n 10
        fi
    else
        log_error "模型列表获取失败 (HTTP $http_code)"
        echo "  响应: $body"
    fi
    echo ""
}

# 测试聊天完成（非流式）
test_chat_completion() {
    log_info "测试聊天完成端点（非流式）..."

    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{
            "model": "deepseek/deepseek-v4-flash",
            "messages": [{"role": "user", "content": "说一句话"}],
            "max_tokens": 50,
            "stream": false
        }' \
        "${BASE_URL}/v1/chat/completions")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -eq 200 ]; then
        log_success "聊天完成成功 (HTTP $http_code)"

        if command -v jq &> /dev/null; then
            content=$(echo "$body" | jq -r '.choices[0].message.content')
            tokens=$(echo "$body" | jq -r '.usage.total_tokens')
            echo "  响应内容: $content"
            echo "  Token 使用: $tokens"
        else
            echo "$body" | head -n 20
        fi
    else
        log_error "聊天完成失败 (HTTP $http_code)"
        echo "  响应: $body"
    fi
    echo ""
}

# 主函数
main() {
    echo ""
    log_info "========================================="
    log_info "Command Code Proxy - API 测试"
    log_info "========================================="
    echo ""
    log_info "配置:"
    echo "  Base URL: $BASE_URL"
    echo "  API Key:  ${API_KEY:0:15}..."
    echo ""

    check_dependencies
    echo ""

    test_health
    test_models

    if [ "$API_KEY" != "user_test_key" ]; then
        test_chat_completion
    else
        log_warn "使用测试 API Key，跳过实际 API 调用测试"
        log_warn "请设置环境变量 API_KEY 以运行完整测试"
        echo ""
        echo "示例: API_KEY=user_your_real_key ./test.sh"
    fi

    echo ""
    log_success "========================================="
    log_success "测试完成！"
    log_success "========================================="
    echo ""
}

# 运行
main
