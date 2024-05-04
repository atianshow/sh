#!/bin/bash

# 提示用户
read -p "你确定要运行安装脚本吗？(Y/N): " choice

# 如果用户输入了Y，则运行install.sh脚本
if [[ "$choice" =~ ^[Yy]$ ]]; then
    # 下载并执行install.sh脚本
    curl -sS -O https://raw.githubusercontent.com/atianshow/sh/main/install.sh && chmod +x install.sh && ./install.sh
else
    echo "已取消运行安装脚本。"
fi
