#!/bin/bash

# ========================================
# Quartz 快速部署脚本（无交互）
# 适用于日常快速部署
# ========================================

set -e

# 配置
SERVER="root@outaink.com"
REMOTE_DIR="/var/www/outaink-quartz-dg"

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🚀 开始快速部署..."

# 1. 构建
echo "📦 构建网站..."
npx quartz build

# 2. 部署
echo "📤 同步文件到服务器..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude 'node_modules' \
    public/ $SERVER:$REMOTE_DIR/ > /dev/null 2>&1

# 3. 重载 Nginx
echo "🔄 重载 Nginx..."
ssh $SERVER "systemctl reload nginx" > /dev/null 2>&1

# 4. 验证
echo "✅ 验证部署..."
status=$(curl -s -o /dev/null -w "%{http_code}" http://outaink.com/)
if [ "$status" = "200" ]; then
    echo -e "${GREEN}✨ 部署成功！${NC}"
    echo "🌐 访问: http://outaink.com"
else
    echo -e "${RED}❌ 部署可能失败，HTTP状态码: $status${NC}"
fi