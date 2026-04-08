# ==============================================================================
# Ubuntu 24.04 LTS 软件开发环境 Dockerfile
# ==============================================================================
# 版本：1.0.0
# 基础镜像：ubuntu:24.04
# 用途：Windows Docker Desktop 上的 Linux 开发环境
# 安全级别：普通用户运行 + sudo 提权（不加入 root 组）
# ==============================================================================

# ==============================================================================
# 第一阶段：基础镜像
# ==============================================================================
FROM ubuntu:24.04

# 构建参数（必须有，否则 $USER_NAME 等在构建阶段为空）
ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG USER_GROUPS
ARG USER_PASSWORD
ARG VNC_PASSWORD
ARG WEB_PASSWORD
ARG TZ

# ==============================================================================
# 环境变量设置
# ==============================================================================
# 避免 apt 安装过程中的交互式提示
ENV DEBIAN_FRONTEND=noninteractive
# 设置时区
ENV TZ=${TZ}
# 设置语言环境（英文，避免乱码）
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# 设置用户信息
ENV USER=${USER_NAME}
ENV HOME=/home/${USER_NAME}
# 设置显示环境
ENV DISPLAY=:1
ENV RESOLUTION=1920x1200

# ==============================================================================
# 步骤 1：配置中国大陆软件源（加速下载）
# ==============================================================================
# 使用阿里云镜像源替换官方源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/cn.archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    # 更新软件包列表
    apt-get update

# ==============================================================================
# 步骤 2：安装系统基础工具
# ==============================================================================
RUN apt-get install -y \
    # 系统管理工具
    sudo vim wget curl git net-tools dnsutils \
    # 网络工具
    iputils-ping telnet sshpass \
    # 文件工具
    unzip zip tar gzip \
    # 系统监控
    htop procps \
    # 其他工具
    ca-certificates gnupg lsb-release software-properties-common \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 步骤 3：安装图形界面组件（XFCE - 轻量级）
# ==============================================================================
RUN apt-get update && apt-get install -y \
    # X11 基础
    dbus-x11 x11-apps x11-xserver-utils x11-common \
    # XFCE 桌面环境（轻量、稳定）
    xfce4 xfce4-goodies \
    # 终端模拟器
    xfce4-terminal \
    # 文件管理器
    thunar thunar-volman \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 步骤 4：安装 VNC 服务（TigerVNC - 高性能）
# ==============================================================================
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-xorg-extension \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 步骤 5：安装 Web VNC（noVNC - 浏览器访问）
# ==============================================================================
RUN apt-get update && apt-get install -y \
    novnc \
    websockify \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 步骤 6：安装 SSH 服务
# ==============================================================================
RUN apt-get update && apt-get install -y \
    openssh-server \
    # 创建 SSH 运行目录
    && mkdir -p /var/run/sshd \
    # 配置 SSH 允许密码登录
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin prohibit-root/PermitRootLogin no/g' /etc/ssh/sshd_config \
    && sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 步骤 7：安装中文字体支持
# ==============================================================================
RUN apt-get update && apt-get install -y \
    # 文泉驿字体（开源中文字体）
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    # 字体配置
    fontconfig \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # 刷新字体缓存
    && fc-cache -fv

# ==============================================================================
# 步骤 8：安装进程管理器（Supervisor）
# ==============================================================================
RUN apt-get update && apt-get install -y \
    supervisor \
    netcat-openbsd \
    # 创建日志目录
    && mkdir -p /var/log/supervisor \
    && mkdir -p /var/run/supervisor \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 步骤 9：创建用户和用户组（安全配置）
# ==============================================================================
# ⚠️ 重要：用户加入 sudo 组，不加入 root 组
RUN groupadd -f -g ${USER_GID} ${USER_NAME} 2>/dev/null || true && \
    # 创建用户并添加到附加组
    useradd -m -s /bin/bash \
    -u ${USER_UID} \
    -g ${USER_GID} \
    -G ${USER_GROUPS} \
    ${USER_NAME} && \
    # 设置用户密码
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && \
    # 配置 sudo 免密码（开发环境）
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # 验证用户配置
    id ${USER_NAME}

# ==============================================================================
# 步骤 10：配置 VNC 密码和启动脚本
# ==============================================================================
USER ${USER_NAME}
WORKDIR ${HOME}

# 创建 VNC 配置目录
RUN mkdir -p ${HOME}/.vnc

# 设置 VNC 密码（使用 vncpasswd -f 从 stdin 读取）
RUN echo "${VNC_PASSWORD}" | vncpasswd -f > ${HOME}/.vnc/passwd && \
    chmod 600 ${HOME}/.vnc/passwd

# 创建 VNC xstartup 启动脚本
COPY --chown=${USER_NAME}:${USER_NAME} xstartup.sh ${HOME}/.vnc/xstartup.sh
RUN chmod +x ${HOME}/.vnc/xstartup.sh

# ==============================================================================
# 步骤 11：创建必要目录
# ==============================================================================
RUN mkdir -p ${HOME}/workspace \
    ${HOME}/backups \
    ${HOME}/.config \
    ${HOME}/.ssh \
    /var/log/supervisor \
    /var/run/supervisor && \
    # 设置目录权限
    chown -R ${USER_NAME}:${USER_NAME} ${HOME} && \
    chmod 755 ${HOME}/workspace && \
    chmod 700 ${HOME}/.ssh

# ==============================================================================
# 步骤 12：配置 Supervisor 进程管理
# ==============================================================================
# 切换回 root 用户以复制系统配置文件
USER root

# 复制 Supervisor 配置文件
COPY supervisord.conf /etc/supervisor/supervisord.conf

# 配置文件的变量替换，敏感数据不直接写在Dockerfile中，而是通过环境变量传递，构建时替换
RUN sed -i "s/__USER_NAME__/${USER_NAME}/g" /etc/supervisor/supervisord.conf

# ==============================================================================
# 步骤 13：暴露端口
# ==============================================================================
# VNC 客户端访问端口
EXPOSE 5901
# Web VNC 浏览器访问端口
EXPOSE 6080
# SSH 远程连接端口
EXPOSE 22

# ==============================================================================
# 步骤 14：健康检查
# ==============================================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD nc -z localhost 5901 || exit 1

# ==============================================================================
# 步骤 15：设置工作目录和启动命令
# ==============================================================================
# 切换回普通用户运行（安全最佳实践）
USER root
WORKDIR ${HOME}/workspace

# 使用 Supervisor 管理所有服务
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
