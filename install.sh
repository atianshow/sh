#!/bin/bash

# 清除可能存在的 Windows 换行符
sed -i 's/\r$//' "$0"

# 下载安装脚本
download_script() {
    local script_url="https://raw.githubusercontent.com/atianshow/ygmaa/main/install.sh"
    echo "正在下载安装脚本..."
    if ! curl -sSfL -o install.sh "$script_url"; then
        echo "下载安装脚本失败，请检查网络连接或手动下载安装脚本。"
        exit 1
    fi
}

# 执行安装脚本
execute_script() {
    echo "正在执行安装脚本..."
    chmod +x install.sh
}

# 函数：更新系统 (改进错误处理)
update_system() {
    echo "正在更新系统..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update && sudo apt-get upgrade -y
    elif [ -x "$(command -v yum)" ]; then
        sudo yum update -y
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf update -y
    elif [ -x "$(command -v zypper)" ]; then
        sudo zypper refresh && sudo zypper update -y
    else
        echo "不支持的包管理器，请手动更新。"
        return 1 # 返回错误代码，而不是退出
    fi
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER

    # 显示已安装的容器名称
    echo "已安装的软件："
    docker ps --format "table {{.Names}}" | tail -n +2
}

# Function to query Docker running status
query_docker_status() {
    echo "查询 Docker 运行状态..."
    docker ps --format "table {{.Names}}\t{{.Status}}"
}

# Function to uninstall Docker
uninstall_docker() {
    echo "正在卸载 Docker..."
    sudo apt-get purge docker-ce docker-ce-cli containerd.io
    sudo rm -rf /var/lib/docker
    echo "Docker 已成功卸载。"
}

# Function to check Docker port usage
check_docker_port() {
    echo "检查 Docker 端口占用情况..."
    sudo netstat -tuln | grep docker
}

# Function to install Docker Compose
install_docker_compose() {
    echo "正在安装 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    if [ $? -eq 0 ]; then
        echo "Docker Compose 安装成功。"
        # 将 Docker Compose 命令添加到 PATH 中
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    else
        echo "Docker Compose 安装失败，请检查错误信息。"
        exit 1
    fi
}

# Function to query Docker Compose running status
query_docker_compose_status() {
    echo "查询 Docker Compose 运行状态..."
    docker-compose ps --format "table {{.Name}}\t{{.State}}"
}

# Function to uninstall Docker Compose
uninstall_docker_compose() {
    echo "正在卸载 Docker Compose..."
    sudo rm -f /usr/local/bin/docker-compose
    sudo rm -f /usr/bin/docker-compose
    echo "Docker Compose 已成功卸载。"
}

# Function to install Portainer
install_portainer() {
    echo "正在安装 Portainer..."
    docker volume create portainer_data
    docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
    if [ $? -eq 0 ]; then
        echo "Portainer 安装成功。访问 http://localhost:9000 进行配置。"
    else
        echo "Portainer 安装失败，请检查错误信息。"
        exit 1
    fi
}

# Function to query Portainer running status
query_portainer_status() {
    echo "查询 Portainer 运行状态..."
    docker ps -f "ancestor=portainer/portainer-ce" --format "table {{.Names}}\t{{.Status}}"
}

# Function to uninstall Portainer
uninstall_portainer() {
    echo "正在卸载 Portainer..."
    docker stop portainer
    docker rm portainer
    docker volume rm portainer_data
    echo "Portainer 已成功卸载。"
}

# Function to install Nginx Proxy Manager
install_nginx_proxy_manager() {
    echo "正在安装 Nginx Proxy Manager..."
    docker volume create npm_data
    docker run -d -p 80:80 -p 443:443 -p 81:81 --name=npm --restart=always -v npm_data:/data -v ~/letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest
    if [ $? -eq 0 ]; then
        echo "Nginx Proxy Manager 安装成功。访问 http://localhost:81 进行配置。"
    else
        echo "Nginx Proxy Manager 安装失败，请检查错误信息。"
        exit 1
    fi
}

# Function to query Nginx Proxy Manager running status
query_nginx_proxy_manager_status() {
    echo "查询 Nginx Proxy Manager 运行状态..."
    docker ps -f "ancestor=jc21/nginx-proxy-manager" --format "table {{.Names}}\t{{.Status}}"
}

# Function to uninstall Nginx Proxy Manager
uninstall_nginx_proxy_manager() {
    echo "正在卸载 Nginx Proxy Manager..."
    docker stop npm
    docker rm npm
    docker volume rm npm_data
    echo "Nginx Proxy Manager 已成功卸载。"
}

# Function to install ServerStatus
install_serverstatus() {
    echo "正在安装 ServerStatus..."
    wget --no-check-certificate -qO ~/serverstatus-config.json https://raw.githubusercontent.com/cppla/ServerStatus/master/server/config.json && \
    mkdir ~/serverstatus-monthtraffic && \
    docker run -d --restart=always --name=serverstatus -v ~/serverstatus-config.json:/ServerStatus/server/config.json -v ~/serverstatus-monthtraffic:/usr/share/nginx/html/json -p 7777:80 -p 35601:35601 cppla/serverstatus:latest
    if [ $? -eq 0 ]; then
        echo "ServerStatus 安装成功。访问 http://localhost:7777 查看状态。"
    else
        echo "ServerStatus 安装失败，请检查错误信息。"
        exit 1
    fi
}

# Function to query ServerStatus running status
query_serverstatus_status() {
    echo "查询 ServerStatus 运行状态..."
    docker ps -f "ancestor=cppla/serverstatus" --format "table {{.Names}}\t{{.Status}}"
}

# Function to uninstall ServerStatus
uninstall_serverstatus() {
    echo "正在卸载 ServerStatus..."
    docker stop serverstatus
    docker rm serverstatus
    echo "ServerStatus 已成功卸载。"
}

# Function to choose and perform actions
choose_and_perform_action() {
    while true; do
        echo "请选择要执行的操作："
        echo "1. Docker"
        echo "2. Docker Compose"
        echo "3. Portainer"
        echo "4. Nginx Proxy Manager"
        echo "5. ServerStatus"
        echo "6. 退出"

        read -p "请输入选项编号: " choice

        case "$choice" in
        1)
            echo "你选择了 Docker。"
            docker_actions
            ;;
        2)
            echo "你选择了 Docker Compose。"
            docker_compose_actions
            ;;
        3)
            echo "你选择了 Portainer。"
            portainer_actions
            ;;
        4)
            echo "你选择了 Nginx Proxy Manager。"
            nginx_proxy_manager_actions
            ;;
        5)
            echo "你选择了 ServerStatus。"
            serverstatus_actions
            ;;
        6)
            echo "退出安装。"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
        esac
    done
}

# Function to perform Docker actions
docker_actions() {
    while true; do
        echo "请选择 Docker 的操作："
        echo "1. 安装 Docker"
        echo "2. 查询 Docker 运行状态"
        echo "3. 卸载 Docker"
        echo "4. 检查 Docker 端口占用情况"
        echo "5. 返回上一级菜单"

        read -p "请输入选项编号: " choice

        case "$choice" in
        1)
            install_docker
            ;;
        2)
            query_docker_status
            ;;
        3)
            uninstall_docker
            ;;
        4)
            check_docker_port
            ;;
        5)
            return
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
        esac
    done
}

# Function to perform Docker Compose actions
docker_compose_actions() {
    while true; do
        echo "请选择 Docker Compose 的操作："
        echo "1. 安装 Docker Compose"
        echo "2. 查询 Docker Compose 运行状态"
        echo "3. 卸载 Docker Compose"
        echo "4. 返回上一级菜单"

        read -p "请输入选项编号: " choice

        case "$choice" in
        1)
            install_docker_compose
            ;;
        2)
            query_docker_compose_status
            ;;
        3)
            uninstall_docker_compose
            ;;
        4)
            return
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
        esac
    done
}

# Function to perform Portainer actions
portainer_actions() {
    while true; do
        echo "请选择 Portainer 的操作："
        echo "1. 安装 Portainer"
        echo "2. 查询 Portainer 运行状态"
        echo "3. 卸载 Portainer"
        echo "4. 返回上一级菜单"

        read -p "请输入选项编号: " choice

        case "$choice" in
        1)
            install_portainer
            ;;
        2)
            query_portainer_status
            ;;
        3)
            uninstall_portainer
            ;;
        4)
            return
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
        esac
    done
}

# Function to perform Nginx Proxy Manager actions
nginx_proxy_manager_actions() {
    while true; do
        echo "请选择 Nginx Proxy Manager 的操作："
        echo "1. 安装 Nginx Proxy Manager"
        echo "2. 查询 Nginx Proxy Manager 运行状态"
        echo "3. 卸载 Nginx Proxy Manager"
        echo "4. 返回上一级菜单"

        read -p "请输入选项编号: " choice

        case "$choice" in
        1)
            install_nginx_proxy_manager
            ;;
        2)
            query_nginx_proxy_manager_status
            ;;
        3)
            uninstall_nginx_proxy_manager
            ;;
        4)
            return
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
        esac
    done
}

# Function to perform ServerStatus actions
serverstatus_actions() {
    while true; do
        echo "请选择 ServerStatus 的操作："
        echo "1. 安装 ServerStatus"
        echo "2. 查询 ServerStatus 运行状态"
        echo "3. 卸载 ServerStatus"
        echo "4. 返回上一级菜单"

        read -p "请输入选项编号: " choice

        case "$choice" in
        1)
            install_serverstatus
            ;;
        2)
            query_serverstatus_status
            ;;
        3)
            uninstall_serverstatus
            ;;
        4)
            return
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
        esac
    done
}

# 主函数
main() {
    # 更新系统
    update_system

    # 下载安装脚本
    download_script

    # 执行安装脚本
    execute_script

    # 选择并执行操作
    choose_and_perform_action
}

# 执行主函数
main
