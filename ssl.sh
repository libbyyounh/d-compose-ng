#!/bin/bash
mkdir -p nginx/ssl

# 进入 nginx 目录
cd nginx

# 生成证书
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout ssl/nginx.key \
-out ssl/nginx.crt