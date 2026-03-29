# DockerIDE
这是一个dockerfile，用于构建基于Ubuntu系统的软件开发环境。
Dockerfile for software development IDE based on Ubuntu OS.


# 1. 构建镜像
cd F:\WorkStudio\MMT
docker-compose build

# 2. 启动容器
docker-compose up -d

# 3. 验证用户配置（确认不在 root 组）
docker exec dev-ide-ubuntu id FelixKung
# 预期：uid=1000(FelixKung) gid=1000(FelixKung) groups=1000(FelixKung),27(sudo),...
# ⚠️ 不应包含 ",0," (root 组 GID)

# 4. 验证 sudo 权限
docker exec dev-ide-ubuntu sudo whoami
# 预期：root

# 5. 验证默认用户不是 root
docker exec dev-ide-ubuntu whoami
# 预期：FelixKung

# 6. 验证服务状态
docker exec dev-ide-ubuntu supervisorctl status
# 预期：vnc、novnc、ssh 都应该是 RUNNING

# 7. 验证网络连接
docker exec dev-ide-ubuntu ping -c 4 www.baidu.com
