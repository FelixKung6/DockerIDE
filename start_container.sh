#!/bin/bash

# ============================
# 容器启动脚本
# 作用：启动 dev-ide-ubuntu 容器并确保其持续运行
# ============================

# 严格模式：遇到错误立即退出，未定义变量报错，管道命令任一失败即退出
set -euo pipefail

# 设置颜色变量，用于终端输出高亮
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 开始启动开发环境容器...${NC}"

# 1. 检查 .env 文件是否存在
if [ ! -f .env ]; then
    echo -e "${RED}❌ 错误：.env 文件不存在！${NC}"
    echo "请确保 .env 文件与本脚本在同一目录下。"
    exit 1
fi

# 2. 检查镜像是否存在
IMAGE_NAME="dev-ide-ubuntu"
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误：镜像 '$IMAGE_NAME' 不存在！${NC}"
    echo "请先执行 docker build 或 docker compose build 来构建镜像。"
    exit 1
fi

# 3. 启动容器
echo -e "${GREEN}▶️  正在启动容器...${NC}"
if ! docker compose up -d --remove-orphans; then
    echo -e "${RED}❌ 容器启动失败！${NC}"
    echo "请运行 'docker compose logs' 查看详细错误。"
    exit 1
fi

# 4. 检查容器状态
echo -e "${GREEN}▶️  检查容器状态...${NC}"
sleep 2 # 等待容器初始化

# 获取容器 ID（使用 docker compose 确保精确匹配）
CONTAINER_ID=$(docker compose ps -q dev-ide-ubuntu)

if [ -z "$CONTAINER_ID" ]; then
    echo -e "${RED}❌ 启动失败！容器启动后立即退出了。${NC}"
    echo "原因可能包括："
    echo "  1. Dockerfile 中的 CMD/ENTRYPOINT 进程结束得太快"
    echo "  2. .env 中的变量为空导致启动脚本报错"
    echo "  3. 端口被占用"
    echo ""
    echo "💡 建议排查："
    echo "  运行 'docker compose logs' 查看详细错误日志"
    exit 1
fi

# 检查容器是否真正在运行
CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_ID" 2>/dev/null || echo "unknown")
if [ "$CONTAINER_STATUS" != "running" ]; then
    echo -e "${RED}❌ 容器状态异常：$CONTAINER_STATUS${NC}"
    echo "请运行 'docker compose logs' 查看详细错误。"
    exit 1
fi

echo -e "${GREEN}✅ 容器启动成功！${NC}"
echo "   容器 ID: $CONTAINER_ID"
echo "   状态: $CONTAINER_STATUS"
echo ""
echo "📋 常用命令速查："
echo "   查看日志:   docker compose logs"
echo "   进入容器:   docker compose exec dev-ide-ubuntu bash"
echo "   停止容器:   docker compose down"

echo -e "${GREEN}🎉 启动流程结束。${NC}"
