# 🚀 Quartz 博客部署指南

本文档介绍如何部署 outaink 的 Quartz 博客到 outaink.com 服务器。

## 📁 部署脚本说明

### 1. `deploy.sh` - 完整部署脚本 （推荐）
**适用场景**：首次部署、重大更新、需要详细检查时

**功能特性**：
- ✅ 全面的环境检查（Node.js、npm、git 等）
- ✅ Git 状态检查和代码同步
- ✅ 自动构建和文件验证
- ✅ 服务器配置检查和修复
- ✅ 在线状态验证
- ✅ 交互式确认步骤
- ✅ 详细的部署摘要

**使用方法**：
```bash
./deploy.sh
```

### 2. `quick-deploy.sh` - 快速部署脚本
**适用场景**：日常内容更新、快速部署

**功能特性**：
- ⚡ 无交互，快速执行
- ⚡ 自动构建、同步、验证
- ⚡ 适合频繁的内容更新

**使用方法**：
```bash
./quick-deploy.sh
```

### 3. `deploy-check.sh` - 状态检查脚本
**适用场景**：故障排查、部署前检查

**功能特性**：
- 🔍 本地构建状态检查
- 🔍 服务器连接和配置检查
- 🔍 在线状态验证
- 🔍 详细的问题诊断

**使用方法**：
```bash
./deploy-check.sh
```

## 🛠 服务器配置

### 目录结构
```
/var/www/outaink-quartz-dg/  # 网站根目录
├── index.html               # 首页
├── Android-Notes/           # Android 笔记
├── CS-Notes/               # 计算机科学笔记
├── static/                 # 静态资源
└── ...
```

### Nginx 配置 (`/etc/nginx/conf.d/default.conf`)
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name outaink.com www.outaink.com;

    root /var/www/outaink-quartz-dg;
    index index.html;
    charset utf-8;

    location / {
        # 关键配置：支持无扩展名访问
        try_files $uri $uri/ $uri.html =404;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 错误页面
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
```

## 🔧 故障排除

### 常见问题

#### 1. 页面返回 404
**症状**：访问文章页面时返回 404 错误

**原因**：Nginx 配置缺少 `try_files` 指令

**解决方案**：
```bash
# 检查 Nginx 配置
ssh root@outaink.com "grep -q 'try_files.*\.html' /etc/nginx/conf.d/default.conf"

# 如果没有配置，使用 deploy.sh 重新部署
./deploy.sh
```

#### 2. 中文文件名无法访问
**症状**：包含中文的页面无法访问

**原因**：服务器编码设置问题

**解决方案**：
```bash
# 检查 Nginx 是否支持 UTF-8
ssh root@outaink.com "grep charset /etc/nginx/conf.d/default.conf"

# 应该看到：charset utf-8;
```

#### 3. 构建失败
**症状**：`npx quartz build` 失败

**解决方案**：
```bash
# 清理和重新安装依赖
rm -rf node_modules package-lock.json
npm install

# 重新构建
npx quartz build
```

#### 4. 服务器连接失败
**症状**：无法通过 SSH 连接服务器

**解决方案**：
```bash
# 测试连接
ssh -o ConnectTimeout=5 root@outaink.com "echo '连接测试'"

# 检查 SSH 密钥配置
ssh-add -l
```

### 检查命令

#### 本地检查
```bash
# 检查构建状态
./deploy-check.sh

# 手动检查关键文件
ls -la public/index.html
ls -la public/Android-Notes/Activity.html
ls -la public/CS-Notes/MIT-6.s081.html
```

#### 服务器检查
```bash
# 检查文件权限
ssh root@outaink.com "ls -la /var/www/outaink-quartz-dg/"

# 检查 Nginx 状态
ssh root@outaink.com "systemctl status nginx"

# 检查 Nginx 配置
ssh root@outaink.com "nginx -t"

# 查看 Nginx 错误日志
ssh root@outaink.com "tail -f /var/log/nginx/error.log"
```

#### 在线检查
```bash
# 测试主要页面
curl -I http://outaink.com/
curl -I http://outaink.com/Android-Notes/Activity
curl -I http://outaink.com/CS-Notes/MIT-6.s081

# 测试中文页面
curl -I "http://outaink.com/Android-Notes/Handler机制"
```

## 📋 部署清单

### 部署前检查
- [ ] 本地代码已提交到 Git
- [ ] 依赖已安装 (`npm install`)
- [ ] 构建成功 (`npx quartz build`)
- [ ] 服务器连接正常

### 部署后验证
- [ ] 首页可以访问 (`http://outaink.com/`)
- [ ] 英文路径正常 (`/Android-Notes/Activity`)
- [ ] 中文路径正常 (`/Android-Notes/Handler机制`)
- [ ] 404 页面正常显示
- [ ] CSS 和 JS 资源正常加载

## 🔄 更新流程

### 日常内容更新
```bash
# 1. 编辑内容文件
vim content/Android-Notes/新文章.md

# 2. 快速部署
./quick-deploy.sh

# 3. 验证
curl -I http://outaink.com/Android-Notes/新文章
```

### 配置或重大更新
```bash
# 1. 完整部署
./deploy.sh

# 2. 全面检查
./deploy-check.sh
```

## 📞 技术支持

如果遇到问题，请按以下顺序排查：

1. **运行检查脚本**：`./deploy-check.sh`
2. **查看详细日志**：使用 `deploy.sh` 的详细输出
3. **检查服务器日志**：SSH 到服务器查看 Nginx 错误日志
4. **重新部署**：使用 `./deploy.sh` 完整重新部署

---

**最后更新**：2025年9月18日
**维护者**：outaink
**网站地址**：http://outaink.com