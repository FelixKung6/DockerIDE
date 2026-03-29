#!/bin/bash
# ==============================================================================
# VNC 桌面启动配置文件
# ==============================================================================
# 用途：定义 VNC 会话启动时运行的程序

# 清理旧的会话锁
rm -rf /tmp/.X11-unix /tmp/.X*-lock

# 设置显示环境
export XKL_XMODMAP_DISABLE=1
export DISPLAY=:1
export DEBIAN_FRONTEND=noninteractive

# 设置桌面分辨率
xsetroot -solid "#3465a4"

# 启动 XFCE 桌面环境
exec startxfce4