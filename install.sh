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
  echo -e "\nSoftware installation status:"
  echo -e "Docker: $(is_docker_installed && echo "\033[1;32mInstalled\033[0m" || echo "\033[1;31mNot installed\033[0m")"
  echo -e "Docker Compose: $(is_docker_compose_installed && echo "\033[1;32mInstalled\033[0m" || echo "\033[1;31mNot installed\033[0m")"
  echo -e "Portainer: $(is_portainer_installed && echo "\033[1;32mInstalled\033[0m" || echo "\033[1;31mNot installed\033[0m")"
  echo -e "Nginx Proxy Manager: $(is_nginx_proxy_manager_installed && echo "\033[1;32mInstalled\033[0m" || echo "\033[1;31mNot installed\033[0m")"
  echo -e "ServerStatus: $(is_serverstatus_installed && echo "\033[1;32mInstalled\033[0m" || echo "\033[1;31mNot installed\033[0m")"
}

# Function to choose and perform actions
choose_and_perform_action() {
  local actions=("Install Docker" "Install Docker Compose" "Install Portainer" "Install Nginx Proxy Manager" "Install ServerStatus" "Check Installation Status" "Exit")

  while true; do
    echo -e "\033[1;36mPlease choose an action:\033[0m"
    for i in "${!actions[@]}"; do
      echo "${i}. ${actions[i]}"
    done

    read -rp "Enter the option number: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 0 && choice < ${#actions[@]})); then
      case "${actions[choice]}" in
        "Install Docker")
          if is_docker_installed; then
            echo "Docker is already installed."
          else
            install_docker
            echo -e "\033[1;32mDocker installed successfully.\033[0m"
          fi
          ;;
        "Install Docker Compose")
          if is_docker_compose_installed; then
            echo "Docker Compose is already installed."
          else
            install_docker_compose
            echo -e "\033[1;32mDocker Compose installed successfully.\033[0m"
          fi
          ;;
        "Install Portainer")
          if is_portainer_installed; then
            echo "Portainer is already installed."
          else
            install_portainer
            echo -e "\033[1;32mPortainer installed successfully.\033[0m"
          fi
          ;;
        "Install Nginx Proxy Manager")
          if is_nginx_proxy_manager_installed; then
            echo "Nginx Proxy Manager is already installed."
          else
            install_nginx_proxy_manager
            echo -e "\033[1;32mNginx Proxy Manager installed successfully.\033[0m"
          fi
          ;;
        "Install ServerStatus")
          if is_serverstatus_installed; then
            echo "ServerStatus is already installed."
          else
            install_serverstatus
            echo -e "\033[1;32mServerStatus installed successfully.\033[0m"
          fi
          ;;
        "Check Installation Status")
          display_software_status
          ;;
        "Exit")
          echo -e "\033[1;36mExiting...\033[0m"
          exit 0
          ;;
      esac
    else
      echo -e "\033[1;31mInvalid option, please choose again.\033[0m"
    fi
  done
}

# Main function
main() {
  # Update system
  echo -e "\033[1;36mUpdating system...\033[0m"
  if is_command_available apt-get; then
    sudo apt-get update && sudo apt-get upgrade -y
  elif is_command_available yum; then
    sudo yum update -y
  elif is_command_available dnf; then
    sudo dnf update -y
  elif is_command_available zypper; then
    sudo zypper refresh && sudo zypper update -y
  else
    echo -e "\033[1;31mUnsupported package manager. Please update your system manually.\033[0m"
    exit 1
  fi

  # Perform actions
  choose_and_perform_action
}

# Run the main function
main

# --------------------------------------------------
# |                                                |
# |          \033[1;36m壹哥传媒\033[0m                  |
# |                                                |
# |  If you find this script helpful, please consider |
# |          buying me a cup of coffee: 188151151  |
# |                                                |
# --------------------------------------------------