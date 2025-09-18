#!/bin/bash

# ========================================
# Quartz 脚本助手
# 快速选择和执行部署相关脚本
# ========================================

echo "╔═══════════════════════════════════════╗"
echo "║       Quartz 部署脚本助手             ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "请选择要执行的操作："
echo ""
echo "1) 🔍 检查状态     (deploy-check.sh)"
echo "2) 🚀 完整部署     (deploy.sh)"
echo "3) ⚡ 快速部署     (quick-deploy.sh)"
echo "4) 📖 查看文档     (DEPLOYMENT.md)"
echo "5) ❌ 退出"
echo ""

read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo "🔍 开始状态检查..."
        ./deploy-check.sh
        ;;
    2)
        echo "🚀 开始完整部署..."
        ./deploy.sh
        ;;
    3)
        echo "⚡ 开始快速部署..."
        ./quick-deploy.sh
        ;;
    4)
        echo "📖 打开部署文档..."
        if command -v code &> /dev/null; then
            code DEPLOYMENT.md
        elif command -v vim &> /dev/null; then
            vim DEPLOYMENT.md
        else
            cat DEPLOYMENT.md | less
        fi
        ;;
    5)
        echo "👋 再见！"
        exit 0
        ;;
    *)
        echo "❌ 无效选项，请重新运行脚本"
        exit 1
        ;;
esac