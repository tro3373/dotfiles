#!/bin/bash

old_install() {
    # Install Docker
    wget -qO- https://get.docker.com/ | sudo sh
    # version を確認しておく。
    docker --version
}

old_uninstall() {
    sudo apt-get remove docker docker-engine
}

install_via_curl() {
    url="$1"
    command_name="$2"
    echo "===> Installing... $command_name"
    sudo bash -c "curl -L $url >/usr/local/bin/$command_name"
    sudo chmod +x /usr/local/bin/$command_name
    $command_name --version
}

install_compose() {
    # Install Docker Compose
    compose_version="1.11.2"
    install_via_curl "https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m`" docker-compose
}

install_machine() {
    # Install Docker Machine
    machine_version="v0.10.0"
    install_via_curl "curl -L https://github.com/docker/machine/releases/download/$machine_version/docker-machine-`uname -s`-`uname -m`" docker-machine
}

uninstall() {
    sudo apt-get purge docker-ce
}

install_docker() {
    # @see https://docs.docker.com/engine/installation/linux/ubuntu/#install-docker
    # Install packages to allow apt to use a repository over HTTPS:
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    # Add Docker’s official GPG key:
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce
    sudo docker run hello-world
}

mod_user() {
    # ユーザーを docker グループに追加
    sudo usermod -aG docker $USER
}

main() {
    install_docker
    install_machine
    install_compose
    mod_user
}
main
