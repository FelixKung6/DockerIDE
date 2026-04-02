# DockerIDE

基于 Ubuntu 的软件开发环境 Docker 镜像。

## 功能特性

- **Ubuntu 22.04 LTS** - 稳定可靠的 Linux 发行版
- **XFCE 桌面** - 轻量级图形界面
- **VNC / noVNC** - 远程桌面访问
- **OpenSSH** - SSH 远程登录
- **非 root 用户** - 更安全的运行方式

## 快速开始

### 前置要求

- Docker Engine 20.10+
- Docker Compose 2.0+
- 至少 4GB 可用内存

### 构建镜像

```bash
# Windows / Linux / macOS
docker compose build
```

### Windows

```powershell
# 进入项目目录
cd F:\WorkStudio\MMT

# 启动容器（推荐）
.\start_container.ps1

# 或使用 Docker Compose
docker compose up -d
```

### Linux / macOS

```bash
# 进入项目目录
cd /path/to/MMT

# 启动容器（推荐）
./start_container.sh

# 或使用 Docker Compose
docker compose up -d
```

### 访问方式

| 服务 | 地址 |
|------|------|
| VNC 客户端 | `localhost:5901` |
| Web 浏览器 | `http://localhost:6080` |
| SSH | `localhost:2222` |

> 默认密码配置在 `.env` 文件中

## 配置说明

复制 `.env.example` 为 `.env` 并修改以下关键配置：

```bash
# 用户配置
USER_NAME=FelixKung
USER_UID=1000
USER_GID=1000
USER_PASSWORD=your_password

# 端口配置
VNC_PORT_HOST=5901
WEB_PORT_HOST=6080
SSH_PORT_HOST=2222
```

## 验证部署

```bash
# 1. 确认用户身份（非 root）
docker exec dev-ide-ubuntu whoami
# 预期输出: FelixKung

# 2. 确认 sudo 权限
docker exec dev-ide-ubuntu sudo whoami
# 预期输出: root

# 3. 确认用户组（不在 root 组）
docker exec dev-ide-ubuntu id FelixKung
# 预期: uid=1000(FelixKung) gid=1000(FelixKung) groups=1000(FelixKung),27(sudo)
# ⚠️ 不应包含 ",0," (root 组 GID)

# 4. 确认服务运行状态
docker exec dev-ide-ubuntu supervisorctl status
# 预期: vnc、novnc、ssh 都是 RUNNING

# 5. 测试网络连接
docker exec dev-ide-ubuntu ping -c 4 www.baidu.com
```

## 常用命令

```bash
# 查看日志
docker compose logs

# 进入容器
docker compose exec dev-ide-ubuntu bash

# 停止容器
docker compose down

# 重启容器
docker compose restart

# 重新构建镜像
docker compose build --no-cache
```

## 目录结构

```
MMT/
├── .env              # 环境变量配置
├── docker-compose.yml
├── Dockerfile
├── start_container.ps1   # Windows 启动脚本
├── start_container.sh    # Linux 启动脚本
├── xstartup.sh           # VNC 启动配置
├── supervisord.conf      # 服务管理配置
└── data/
    ├── backups/          # 备份目录
    └── config/           # 配置目录
```

## 故障排查

### 容器启动后立即退出

```bash
# 查看详细日志
docker compose logs

# 检查端口占用
netstat -ano | findstr "5901"
```

### VNC 连接无响应

```bash
# 检查 VNC 服务状态
docker exec dev-ide-ubuntu supervisorctl status vnc

# 重启 VNC 服务
docker exec dev-ide-ubuntu supervisorctl restart vnc
```

### 无法连接 SSH

```bash
# 检查 SSH 服务状态
docker exec dev-ide-ubuntu supervisorctl status ssh

# 查看 SSH 日志
docker compose logs | grep -i ssh
```

## 技术栈

- Ubuntu 22.04 LTS
- XFCE4 Desktop
- TigerVNC + noVNC
- OpenSSH Server
- Supervisor
- Docker + Docker Compose