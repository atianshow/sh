#!/bin/bash

# Function to check if a command is available
is_command_available() {
  command -v "$1" > /dev/null 2>&1
}

# Function to check if Docker is installed
is_docker_installed() {
  docker --version &> /dev/null
}

# Function to check if Docker Compose is installed
is_docker_compose_installed() {
  docker-compose --version &> /dev/null
}

# Function to check if Portainer is installed
is_portainer_installed() {
  docker ps -f name=portainer &> /dev/null
}

# Function to check if Nginx Proxy Manager is installed
is_nginx_proxy_manager_installed() {
  docker ps -f name=npm &> /dev/null
}

# Function to check if ServerStatus is installed
is_serverstatus_installed() {
  docker ps -f name=serverstatus &> /dev/null
}

# Function to install Docker
install_docker() {
  install_package docker.io
  sudo usermod -aG docker "$USER"
}

# Function to install Docker Compose
install_docker_compose() {
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

# Function to install Portainer
install_portainer() {
  docker volume create portainer_data
  docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
}

# Function to install Nginx Proxy Manager
install_nginx_proxy_manager() {
  docker volume create npm_data
  docker run -d -p 80:80 -p 443:443 -p 81:81 --name=npm --restart=always -v npm_data:/data -v ./letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest
}

# Function to install ServerStatus
install_serverstatus() {
  wget --no-check-certificate -qO ~/serverstatus-config.json https://raw.githubusercontent.com/cppla/ServerStatus/master/server/config.json && \
    mkdir ~/serverstatus-monthtraffic && \
    docker run -d --restart=always --name=serverstatus -v ~/serverstatus-config.json:/ServerStatus/server/config.json -v ~/serverstatus-monthtraffic:/usr/share/nginx/html/json -p 7777:80 -p 35601:35601 cppla/serverstatus:latest
}

# Function to display software installation status
display_software_status() {
  echo -e "\n软件安装状态:"
  echo -e "Docker: $(is_docker_installed && echo "\033[1;32m已安装\033[0m" || echo "\033[1;31m未安装\033[0m")"
  echo -e "Docker Compose: $(is_docker_compose_installed && echo "\033[1;32m已安装\033[0m" || echo "\033[1;31m未安装\033[0m")"
  echo -e "Portainer: $(is_portainer_installed && echo "\033[1;32m已安装\033[0m" || echo "\033[1;31m未安装\033[0m")"
  echo -e "Nginx Proxy Manager: $(is_nginx_proxy_manager_installed && echo "\033[1;32m已安装\033[0m" || echo "\033[1;31m未安装\033[0m")"
  echo -e "ServerStatus: $(is_serverstatus_installed && echo "\033[1;32m已安装\033[0m" || echo "\033[1;31m未安装\033[0m")"
}

# Function to choose and perform actions
choose_and_perform_action() {
  local actions=("安装 Docker" "安装 Docker Compose" "安装 Portainer" "安装 Nginx Proxy Manager" "安装 ServerStatus" "查看安装状态" "退出")

  while true; do
    echo -e "\033[1;36m请选择一个操作:\033[0m"
    for i in "${!actions[@]}"; do
      echo "${i}. ${actions[i]}"
    done

    read -rp "输入选项编号: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 0 && choice < ${#actions[@]})); then
      case "${actions[choice]}" in
        "安装 Docker")
          if is_docker_installed; then
            echo "Docker 已安装."
          else
            install_docker
            echo -e "\033[1;32mDocker 安装成功.\033[0m"
          fi
          ;;
        "安装 Docker Compose")
          if is_docker_compose_installed; then
            echo "Docker Compose 已安装."
          else
            install_docker_compose
            echo -e "\033[1;32mDocker Compose 安装成功.\033[0m"
          fi
          ;;
        "安装 Portainer")
          if is_portainer_installed; then
            echo "Portainer 已安装."
          else
            install_portainer
            echo -e "\033[1;32mPortainer 安装成功.\033[0m"
          fi
          ;;
        "安装 Nginx Proxy Manager")
          if is_nginx_proxy_manager_installed; then
            echo "Nginx Proxy Manager 已安装."
          else
            install_nginx_proxy_manager
            echo -e "\033[1;32mNginx Proxy Manager 安装成功.\033[0m"
          fi
          ;;
        "安装 ServerStatus")
          if is_serverstatus_installed; then
            echo "ServerStatus 已安装."
          else
            install_serverstatus
            echo -e "\033[1;32mServerStatus 安装成功.\033[0m"
          fi
          ;;
        "查看安装状态")
          display_software_status
          ;;
        "退出")
          echo -e "\033[1;36m退出...\033[0m"
          clear # Clear the terminal screen
          echo -e "\033[1;36m--------------------------------------------------\033[0m"
          echo -e "\033[1;36m|                                              |\033[0m"
          echo -e "\033[1;36m|           \033[1;32m壹哥传媒\033[1;36m                  |\033[0m"
          echo -e "\033[1;36m|                                              |\033[0m"
          echo -e "\033[1;36m|  如果您觉得这个脚本有用, 请考虑购买我一杯咖啡: V:Atian-show   |\033[0m"
          echo -e "\033[1;36m|                                              |\033[0m"
          echo -e "\033[1;36m--------------------------------------------------\033[0m"
          exit 0
          ;;
      esac
    else
      echo -e "\033[1;31m无效的选项, 请重新选择.\033[0m"
    fi
  done
}

# Main function
main() {
  # Update system
  echo -e "\033[1;36m更新系统...\033[0m"
  if is_command_available apt-get; then
    sudo apt-get update && sudo apt-get upgrade -y
  elif is_command_available yum; then
    sudo yum update -y
  elif is_command_available dnf; then
    sudo dnf update -y
  elif is_command_available zypper; then
    sudo zypper refresh && sudo zypper update -y
  else
    echo -e "\033[1;31m不支持的软件包管理器. 请手动更新系统.\033[0m"
    exit 1
  fi

  # Perform actions
  choose_and_perform_action
}

# Run the main function
main