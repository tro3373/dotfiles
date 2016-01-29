#!/bin/bash

execute=$1
dryrun="--dry-run"
if [[ "$execute" == "exec" ]]; then
    echo "Execute cleanup!"
    dryrun=""
fi

main() {
    # 削除可能 Data Volume のディレクトリ一覧
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /var/lib/docker:/var/lib/docker \
        martin/docker-cleanup-volumes $dryrun
}
main
