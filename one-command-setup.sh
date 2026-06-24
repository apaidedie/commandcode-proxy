#!/bin/bash
# 一键配置脚本 - 只需要你粘贴 Token

echo "========================================="
echo "Docker Hub 一键配置"
echo "========================================="
echo ""
echo "请从以下网址复制你的 Docker Hub Token:"
echo "https://hub.docker.com/settings/security"
echo ""
echo "如果还没有，请创建一个新 Token:"
echo "  - Description: GitHub Actions"
echo "  - Permissions: Read, Write, Delete"
echo ""
read -p "请粘贴你的 Docker Hub Token: " TOKEN
echo ""

if [ -z "$TOKEN" ]; then
    echo "错误: Token 不能为空"
    exit 1
fi

echo "正在配置 GitHub Secrets..."
echo "al1ya" | gh secret set DOCKERHUB_USERNAME --repo apaidedie/commandcode-proxy
echo "$TOKEN" | gh secret set DOCKERHUB_TOKEN --repo apaidedie/commandcode-proxy

echo ""
echo "✓ Secrets 配置完成！"
echo ""
echo "正在触发构建..."
gh workflow run docker-publish.yml --repo apaidedie/commandcode-proxy --ref main

echo ""
echo "✓ 构建已触发！"
echo ""
echo "查看进度: https://github.com/apaidedie/commandcode-proxy/actions"
echo ""
