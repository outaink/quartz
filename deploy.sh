#!/bin/bash

# ========================================
# Quartz 博客自动部署脚本
# 服务器: outaink.com
# 目录: /var/www/outaink-quartz-dg
# ========================================

set -e  # 如果任何命令失败则退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
SERVER="root@outaink.com"
REMOTE_DIR="/var/www/outaink-quartz-dg"
NGINX_CONFIG="/etc/nginx/conf.d/default.conf"

# 函数：打印带颜色的消息
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${GREEN}[→]${NC} $1"
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装，请先安装"
        exit 1
    fi
}

# ========================================
# 主脚本开始
# ========================================

echo "╔═══════════════════════════════════════╗"
echo "║     Quartz 博客部署脚本 v2.0         ║"
echo "║     目标: outaink.com                ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# 1. 检查必要的工具
print_info "检查必要工具..."
check_command "node"
check_command "npm"
check_command "rsync"
check_command "ssh"
check_command "git"
print_status "所有必要工具已安装"

# 2. 检查 Git 状态
print_info "检查 Git 状态..."
if [[ $(git status --porcelain) ]]; then
    print_warning "有未提交的更改："
    git status --short
    echo ""
    read -p "是否继续部署？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "部署已取消"
        exit 1
    fi
fi

# 3. 拉取最新代码（可选）
read -p "是否拉取最新代码？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "拉取最新代码..."
    git pull origin v4
    print_status "代码已更新"
fi

# 4. 安装依赖（如果需要）
if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    print_info "安装/更新依赖..."
    npm install
    print_status "依赖安装完成"
fi

# 5. 构建网站
print_info "开始构建 Quartz 网站..."
npx quartz build

# 检查构建是否成功
if [ ! -f "public/index.html" ]; then
    print_error "构建失败：未找到 public/index.html"
    exit 1
fi

# 统计文件
FILE_COUNT=$(find public -type f | wc -l)
HTML_COUNT=$(find public -name "*.html" | wc -l)
print_status "构建成功：生成 $FILE_COUNT 个文件，其中 $HTML_COUNT 个 HTML 页面"

# 6. 测试重要文件是否存在
print_info "检查关键文件..."
test_files=(
    "public/index.html"
    "public/Android-Notes/Activity.html"
    "public/CS-Notes/MIT-6.s081.html"
    "public/404.html"
)

all_files_exist=true
for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $(basename $file)"
    else
        echo "  ✗ $(basename $file) 不存在"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = false ]; then
    print_error "某些关键文件缺失，请检查构建"
    exit 1
fi

# 7. 部署到服务器
print_info "开始部署到服务器 $SERVER..."
echo "目标目录: $REMOTE_DIR"

# 显示将要执行的 rsync 命令
echo "执行命令: rsync -avz --delete --progress public/ $SERVER:$REMOTE_DIR/"
read -p "确认开始部署？(y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "部署已取消"
    exit 1
fi

# 执行部署
rsync -avz --delete --progress \
    --exclude '.git' \
    --exclude '.gitignore' \
    --exclude 'node_modules' \
    public/ $SERVER:$REMOTE_DIR/

if [ $? -eq 0 ]; then
    print_status "文件同步成功"
else
    print_error "文件同步失败"
    exit 1
fi

# 8. 检查并修复服务器权限
print_info "检查服务器文件权限..."
ssh $SERVER "chown -R ubuntu:ubuntu $REMOTE_DIR && chmod -R 755 $REMOTE_DIR"
print_status "权限设置完成"

# 9. 检查 Nginx 配置
print_info "检查 Nginx 配置..."
ssh $SERVER "nginx -t" &> /dev/null
if [ $? -eq 0 ]; then
    print_status "Nginx 配置有效"

    # 检查关键配置
    if ssh $SERVER "grep -q 'try_files.*\.html' $NGINX_CONFIG"; then
        print_status "try_files 配置正确"
    else
        print_warning "try_files 配置可能需要更新"
        echo "建议添加: try_files \$uri \$uri/ \$uri.html =404;"
    fi

    # 重载 Nginx
    ssh $SERVER "systemctl reload nginx"
    print_status "Nginx 已重载"
else
    print_error "Nginx 配置有错误"
    ssh $SERVER "nginx -t"
fi

# 10. 验证部署
print_info "验证部署..."
echo ""

# 测试 URL 列表
test_urls=(
    "http://outaink.com/"
    "http://outaink.com/Android-Notes/Activity"
    "http://outaink.com/CS-Notes/MIT-6.s081"
)

all_success=true
for url in "${test_urls[@]}"; do
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$status_code" = "200" ]; then
        echo "  ✓ $url [HTTP $status_code]"
    else
        echo "  ✗ $url [HTTP $status_code]"
        all_success=false
    fi
done

echo ""
if [ "$all_success" = true ]; then
    print_status "所有页面验证通过！"
else
    print_warning "某些页面无法访问，请检查"
fi

# 11. 显示部署摘要
echo ""
echo "╔═══════════════════════════════════════╗"
echo "║         部署完成摘要                  ║"
echo "╚═══════════════════════════════════════╝"
echo ""
print_info "网站地址: http://outaink.com"
print_info "服务器目录: $REMOTE_DIR"
print_info "文件数量: $FILE_COUNT"
print_info "HTML 页面: $HTML_COUNT"
echo ""

# 12. Git 提交提示（可选）
read -p "是否提交更改到 Git？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "准备 Git 提交..."
    git add .
    read -p "请输入提交信息: " commit_message
    git commit -m "$commit_message

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    read -p "是否推送到远程仓库？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push origin v4
        print_status "已推送到远程仓库"
    fi
fi

echo ""
print_status "🎉 部署流程完成！"
echo "访问 http://outaink.com 查看你的博客"