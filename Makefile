.PHONY: help build up down restart logs ps clean test health deploy

# 默认目标
.DEFAULT_GOAL := help

# 配置
COMPOSE := docker compose
PROJECT_NAME := commandcode-proxy

# 帮助信息
help: ## 显示帮助信息
	@echo "Command Code Proxy - Makefile 命令"
	@echo ""
	@echo "使用方法: make [命令]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# 部署相关
deploy: ## 一键部署（推荐）
	@chmod +x deploy.sh
	@./deploy.sh

build: ## 构建镜像
	@echo "构建 Docker 镜像..."
	@$(COMPOSE) build

up: ## 启动服务
	@echo "启动服务..."
	@$(COMPOSE) up -d
	@echo "等待服务就绪..."
	@sleep 3
	@$(MAKE) health

down: ## 停止服务
	@echo "停止服务..."
	@$(COMPOSE) down

restart: ## 重启服务
	@echo "重启服务..."
	@$(COMPOSE) restart

# 日志和状态
logs: ## 查看日志
	@$(COMPOSE) logs -f

ps: ## 查看服务状态
	@$(COMPOSE) ps

stats: ## 查看资源使用情况
	@docker stats $(PROJECT_NAME) --no-stream

# 测试和健康检查
health: ## 健康检查
	@echo "健康检查..."
	@curl -s http://localhost:3050/health && echo " ✓ 服务正常" || echo " ✗ 服务异常"

test: ## 测试 API
	@chmod +x test.sh
	@./test.sh

# 开发相关
dev: ## 本地开发模式
	@npm run dev

shell: ## 进入容器 Shell
	@$(COMPOSE) exec $(PROJECT_NAME) sh

# 清理
clean: ## 清理容器和镜像
	@echo "清理容器和镜像..."
	@$(COMPOSE) down -v --rmi local

clean-all: ## 完全清理（包括日志）
	@echo "完全清理..."
	@$(COMPOSE) down -v --rmi local
	@rm -rf logs/*
	@echo "清理完成"

# 更新
update: build restart ## 重新构建并重启

# 配置
config: ## 创建配置文件
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "已创建 .env 文件，请编辑配置"; \
	else \
		echo ".env 文件已存在"; \
	fi

# 信息
info: ## 显示服务信息
	@echo "服务信息:"
	@echo "  名称: $(PROJECT_NAME)"
	@echo "  地址: http://localhost:3050"
	@echo "  健康检查: http://localhost:3050/health"
	@echo "  模型列表: http://localhost:3050/v1/models"
	@echo ""
	@echo "容器状态:"
	@$(MAKE) ps
