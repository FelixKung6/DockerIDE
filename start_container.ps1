# ============================
# Windows 容器启动脚本
# 作用：启动 dev-ide-ubuntu 容器并确保其持续运行
# ============================

# 设置颜色变量，用于终端输出高亮
$GREEN = "`e[0;32m"
$YELLOW = "`e[1;33m"
$RED = "`e[0;31m"
$NC = "`e[0m" # No Color

Write-Host "${YELLOW}🚀 开始启动开发环境容器...${NC}"

# 1. 检查 .env 文件是否存在
if (-not (Test-Path -Path ".env")) {
    Write-Host "${RED}❌ 错误：.env 文件不存在！${NC}"
    Write-Host "请确保 .env 文件与本脚本在同一目录下。"
    exit 1
}

# 2. 检查镜像是否存在
$IMAGE_NAME = "dev-ide-ubuntu"
if (-not (docker image inspect $IMAGE_NAME)) {
    Write-Host "${RED}❌ 错误：镜像 '$IMAGE_NAME' 不存在！${NC}"
    Write-Host "请先执行 docker build 或 docker compose build 来构建镜像。"
    exit 1
}

# 3. 启动容器
Write-Host "${GREEN}▶️  正在启动容器...${NC}"
docker compose up -d --remove-orphans

# 4. 检查容器状态
Write-Host "${GREEN}▶️  检查容器状态...${NC}"
Start-Sleep -Seconds 2 # 等待2秒让容器初始化

# 获取容器 ID
$CONTAINER_ID = (docker ps -q --filter "name=dev-ide-ubuntu")

if ([string]::IsNullOrEmpty($CONTAINER_ID)) {
    Write-Host "${RED}❌ 启动失败！容器启动后立即退出了。${NC}"
    Write-Host "原因可能包括："
    Write-Host "1. Dockerfile 中的 CMD/ENTRYPOINT 进程结束得太快。"
    Write-Host "2. .env 中的变量为空导致启动脚本报错。"
    Write-Host "3. 端口被占用。"
    Write-Host ""
    Write-Host "💡 建议排查："
    Write-Host "运行 'docker compose logs' 查看详细错误日志。"
    exit 1
} else {
    Write-Host "${GREEN}✅ 容器启动成功！容器ID: $CONTAINER_ID${NC}"
    Write-Host ""
    Write-Host "📋 常用命令速查："
    Write-Host "   查看日志:   docker compose logs"
    Write-Host "   进入容器:   docker compose exec dev-ide-ubuntu bash"
    Write-Host "   停止容器:   docker compose down"
}

Write-Host "${GREEN}🎉 启动流程结束。${NC}"
