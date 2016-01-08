#!/bin/bash

# Install Docker
wget -qO- https://get.docker.com/ | sudo sh
# version を確認しておく。
docker --version
# ユーザーを docker グループに追加
sudo usermod -aG docker $USER


# Install Docker Machine
version="v0.5.5"
sudo bash -c "curl -L https://github.com/docker/machine/releases/download/$version/docker-machine_linux-amd64 >/usr/local/bin/docker-machine" && \
  sudo chmod +x /usr/local/bin/docker-machine
# version を確認しておく。
docker-machine --version

