#!/bin/bash

# 脚本用途：启动certbot-docker-compose.yml中定义的Nginx代理服务

# 设置脚本执行目录为脚本所在目录
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dir"

# 定义Docker Compose文件路径
COMPOSE_FILE="cerbot-docker-compose.yml"

# 检查Docker是否可用
docker -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "错误：未找到Docker命令。请先安装Docker。"
    exit 1
fi

# 检查docker-compose是否可用
docker-compose -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "错误：未找到docker-compose命令。请先安装docker-compose。"
    exit 1
fi

# 检查compose文件是否存在
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "错误：找不到$COMPOSE_FILE文件。"
    exit 1
fi

# 检查并创建必要的目录
CERBOT_ETC_DIR="certbot/etc"
CERBOT_WWW_DIR="certbot/www"

if [ ! -d "$CERBOT_ETC_DIR" ]; then
    echo "创建证书存储目录: $CERBOT_ETC_DIR"
    mkdir -p "$CERBOT_ETC_DIR"
fi

if [ ! -d "$CERBOT_WWW_DIR" ]; then
    echo "创建验证文件目录: $CERBOT_WWW_DIR"
    mkdir -p "$CERBOT_WWW_DIR"
fi

# 检查并创建网络（如果需要）
docker network inspect app-network > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "警告：未找到app-network网络。根据compose文件配置，这应该是一个外部网络。"
    echo "请先创建网络：docker network create app-network"
    read -p "是否现在创建网络？(y/n) " create_network
    if [ "$create_network" = "y" ] || [ "$create_network" = "Y" ]; then
        docker network create app-network
        if [ $? -ne 0 ]; then
            echo "错误：创建网络失败。"
            exit 1
        fi
    fi
fi

# 启动服务
echo "正在启动certbot相关服务..."
docker-compose -f "$COMPOSE_FILE" up -d --force-recreate

# 检查启动结果
if [ $? -eq 0 ]; then
    echo "服务启动成功！"
    echo "使用以下命令查看服务状态：docker-compose -f $COMPOSE_FILE ps"
    echo "使用以下命令查看日志：docker-compose -f $COMPOSE_FILE logs -f"
else
    echo "错误：服务启动失败。"
    exit 1
fi

# 提示用户后续步骤
echo "\n注意："
echo "1. 服务启动后，您可能需要运行get-certbot.sh脚本来获取SSL证书"
echo "2. 请确保您已经在nginx/certbot.nginx.conf中正确配置了域名和代理设置"
echo "3. 证书获取后，可能需要重启Nginx容器使配置生效"