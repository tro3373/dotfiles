#!/bin/bash

install_via_curl() {
    url="$1"
    command_name="$2"
    echo "===> Installing... $command_name"
    sudo bash -c "curl -L $url >/usr/local/bin/$command_name"
    sudo chmod +x /usr/local/bin/$command_name
    $command_name --version
}

# Install Docker
wget -qO- https://get.docker.com/ | sudo sh
# version を確認しておく。
docker --version
# ユーザーを docker グループに追加
sudo usermod -aG docker $USER

# Install Docker Machine
machine_version="v0.8.0"
install_via_curl "https://github.com/docker/machine/releases/download/$machine_version/docker-machine_linux-amd64" docker-machine

# Install Docker Compose
compose_version="1.8.0"
install_via_curl "https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m`" docker-compose

