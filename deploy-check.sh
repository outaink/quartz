#!/bin/bash

# ========================================
# Quartz 部署状态检查脚本
# 检查本地构建和远程部署状态
# ========================================

set -e

# 配置
SERVER="root@outaink.com"
REMOTE_DIR="/var/www/outaink-quartz-dg"

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Quartz 部署状态检查 ==="
echo ""

# 1. 检查本地构建
echo "🔍 检查本地构建状态..."
if [ ! -f "public/index.html" ]; then
    echo -e "${RED}❌ 缺少 index.html，请先运行: npx quartz build${NC}"
    exit 1
fi

# 统计本地文件
local_files=$(find public -type f | wc -l)
local_html=$(find public -name "*.html" | wc -l)
echo -e "${GREEN}✅ 本地构建正常：$local_files 个文件，$local_html 个 HTML 页面${NC}"

# 2. 检查关键文件
echo ""
echo "🔍 检查关键文件..."
test_files=(
    "public/index.html"
    "public/404.html"
)

all_exist=true
for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅${NC} $(basename "$file")"
    else
        echo -e "  ${RED}❌${NC} $(basename "$file") 不存在"
        all_exist=false
    fi
done

# 3. 检查服务器连接
echo ""
echo "🔍 检查服务器连接..."
if ssh -o ConnectTimeout=5 $SERVER "echo '连接成功'" &> /dev/null; then
    echo -e "${GREEN}✅ 服务器连接正常${NC}"

    # 检查远程目录
    if ssh $SERVER "[ -d $REMOTE_DIR ]"; then
        remote_files=$(ssh $SERVER "find $REMOTE_DIR -type f | wc -l")
        echo -e "${GREEN}✅ 远程目录存在：$remote_files 个文件${NC}"
    else
        echo -e "${RED}❌ 远程目录不存在：$REMOTE_DIR${NC}"
    fi

    # 检查 Nginx 状态
    if ssh $SERVER "systemctl is-active nginx" &> /dev/null; then
        echo -e "${GREEN}✅ Nginx 服务运行正常${NC}"
    else
        echo -e "${RED}❌ Nginx 服务未运行${NC}"
    fi

    # 检查 Nginx 配置
    if ssh $SERVER "nginx -t" &> /dev/null; then
        echo -e "${GREEN}✅ Nginx 配置有效${NC}"

        # 检查 try_files 配置
        if ssh $SERVER "grep -q 'try_files.*\.html' /etc/nginx/conf.d/default.conf"; then
            echo -e "${GREEN}✅ try_files 配置正确${NC}"
        else
            echo -e "${YELLOW}⚠️  try_files 配置可能需要更新${NC}"
        fi
    else
        echo -e "${RED}❌ Nginx 配置有误${NC}"
    fi

else
    echo -e "${RED}❌ 无法连接到服务器${NC}"
fi

# 4. 在线验证
echo ""
echo "🔍 验证在线状态..."
test_urls=(
    "http://outaink.com/"
    "http://outaink.com/Android-Notes/Activity"
    "http://outaink.com/CS-Notes/MIT-6.s081"
    "http://outaink.com/Android-Notes/Handler机制"
)

all_online=true
for url in "${test_urls[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$status" = "200" ]; then
        echo -e "  ${GREEN}✅${NC} $url [HTTP $status]"
    else
        echo -e "  ${RED}❌${NC} $url [HTTP $status]"
        all_online=false
    fi
done

# 5. 总结
echo ""
echo "=== 检查总结 ==="
if [ "$all_exist" = true ] && [ "$all_online" = true ]; then
    echo -e "${GREEN}🎉 所有检查通过！网站运行正常${NC}"
    echo ""
    echo "📋 部署命令："
    echo "   ./deploy.sh        # 完整部署（推荐）"
    echo "   ./quick-deploy.sh  # 快速部署"
    echo ""
    echo "🌐 网站地址: http://outaink.com"
else
    echo -e "${YELLOW}⚠️  发现问题，建议重新部署${NC}"
    echo ""
    echo "🔧 修复命令："
    echo "   npx quartz build   # 重新构建"
    echo "   ./deploy.sh        # 完整部署"
fi