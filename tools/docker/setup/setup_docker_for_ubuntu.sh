#!/bin/bash

repository_installable_max_version=16.10
old_install() {
    # Install Docker
    wget -qO- https://get.docker.com/ | sudo sh
    # version を確認しておく。
    docker --version
}

old_uninstall() {
    sudo apt-get remove docker docker-engine
}

is_supported_os() {
    local version=$(get_dist_version)
    local res=$(echo "$version > $repository_installable_max_version" | bc)
    if [[ $res -eq 1 ]]; then
        # using distribution is higher than repository_installable_max_version.
        # should use package.
        return 1
    else
        # you can install docker from repository.
        return 0
    fi
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
    compose_version="1.13.0"
    install_via_curl "https://github.com/docker/compose/releases/download/$compose_version/docker-compose-`uname -s`-`uname -m`" docker-compose
}

install_machine() {
    # Install Docker Machine
    machine_version="v0.11.0"
    install_via_curl "curl -L https://github.com/docker/machine/releases/download/$machine_version/docker-machine-`uname -s`-`uname -m`" docker-machine
}

uninstall() {
    sudo apt-get purge docker-ce
}

install_docker_via_repository() {
    local use_version_name=$(lsb_release -cs)
    if ! is_supported_os; then
        use_version_name=zesty
    fi
    # @see https://docs.docker.com/engine/installation/linux/ubuntu/#install-docker
    # Install packages to allow apt to use a repository over HTTPS:
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    # Add Docker’s official GPG key:
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # verify
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       ${use_version_name} \
       stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce
    sudo docker run hello-world
}

install_docker_via_package() {
    local vname="$(lsb_release -cs)"
    # local url="https://download.docker.com/linux/ubuntu/dists/$vname/stable/Contents-amd64.gz"
    local url="https://download.docker.com/linux/ubuntu/dists/$vname/pool/test/amd64/docker-ce_17.05.0~ce~rc3-0~ubuntu-zesty_amd64.deb"
    local url="https://download.docker.com/linux/ubuntu/dists/yakkety/pool/stable/amd64/docker-ce_17.03.1~ce-0~ubuntu-yakkety_amd64.deb"
    if [[ ! -e ./tmp ]]; then
        mkdir -p ./tmp
    fi
    cd ./tmp
    curl -fsSLO $url
    sudo dpkg -i ./*.deb
}

mod_user() {
    # ユーザーを docker グループに追加
    sudo usermod -aG docker $USER
}

get_dist_version() {
    local version="$(cat /etc/lsb-release |grep RELEASE)"
    version=${version##*=}
    echo $version
}

main() {
    # if is_supported_os; then
    #     install_docker_via_package
    # else
    #     install_docker_via_repository
    # fi
    install_docker_via_repository
    install_machine
    install_compose
    # mod_user
}
main
