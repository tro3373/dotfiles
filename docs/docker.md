# CheatSheet

## index.docker.ioから指定したイメージを取り込む
```sh
docker pull REPOSITORY[:TAG]
```
## イメージ一覧を得る
```sh
docker images
```

## イメージからコンテナを起動する
```sh
docker run -i -t -d IMAGE /bin/bash
```

## イメージからコンテナを起動して、接続する。コンテナに名前をつける
```sh
docker run -i -t IMAGE /bin/bash
docker run -i -t --name NAME IMAGE /bin/bash
```

## ホストの/var/wwwを、コンテナ内の/var/htmlからアクセスできるように共有する
```sh
docker run -i -t -v /var/www:/var/html IMAGE /bin/bash
```

## ホスト8080番portへの通信をコンテナ80番portへ転送する
```sh
docker run -i -t -p 8080:80 IMAGE /bin/bash
```

## ゲストのPRIVATE_PORTに指定したPortがホストのどのPortにポートフォワードしてるかを調べる
```sh
docker port CONTAINER PRIVATE_PORT
```

## イメージからコンテナを作る
```sh
docker create IMAGE
docker create --name NAME IMAGE
```

## コンテナを起動する
```sh
docker start CONTAINER
```

## コンテナを停止する
```sh
docker stop CONTAINER
```

## コンテナを再起動する
```sh
docker restart CONTAINER
```

## コンテナを削除する
```sh
docker rm CONTAINER [CONTAINER...]
```

## コンテナをすべて削除する
```sh
docker rm $(docker ps -a -q)
```

## イメージを削除する
```sh
docker rmi IMAGE [IMAGE...]
```

## タグなしのイメージをすべて削除する
```sh
docker rmi $(docker images | grep '<none>' | awk '{print$3}')
```

## 起動しているコンテナに接続する
```sh
# exitするとコンテナが終了してしまう
# コンテナを終了せずに抜ける「Ctrl + p, Ctrl + q」
docker attach CONTAINER

# exitしてもコンテナは終了しない
docker exec -it CONTAINER /bin/bash
```

## リポジトリにタグを貼る（:TAGを省略すると、latestになる）
```sh
docker tag IMAGE REPOSITORY[:TAG]
```

## ./にあるDockerfileをビルドして、イメージを作成する
```sh
docker build  ./
docker build -t REPOSITORY[:TAG] ./
```

## ビルドを最初からやりなおす
```sh
docker build --no-cache .
```

## 起動中のコンテナ一覧を得る
```sh
docker ps
```

## 停止中のコンテナも含めすべての一覧を得る
```sh
docker ps -a
```

## コンテナのハッシュリストを得る
```sh
docker ps -a -q
```

## index.docker.ioからイメージを検索する
```sh
docker search TERM
```

## イメージをビルドした際のコマンドリストを得る。Dockerfileに記述したもののみ
```sh
docker history IMAGE
```

## イメージをファイル出力する
```sh
docker save IMAGE > filename.tar
```

## ファイルをイメージとして取り込む
```sh
docker load < filename.tar
```

## コンテナをファイル出力する
```sh
docker export CONTAINER > filename.tar
```

## コンテナからイメージを作成する
```sh
docker commit CONTAINER REPOSITORY[:TAG]
```

## URLを指定してイメージを取り込む
```sh
docker import url REPOSITORY[:TAG]
```

## ファイルからイメージを取り込む
```sh
cat filename.tar | docker import - REPOSITORY[:TAG]
```

## コンテナの標準出力を見る
```sh
docker logs CONTAINER
```

## コンテナ内のファイルをホストにコピーする
```sh
docker cp CONTAINER:filename ./
```

## イメージがコンテナ化されてから変更されたファイル差分を得る
```sh
docker diff CONTAINER
```

## URLのファイルをイメージ内のPATHに生成する
```sh
docker insert IMAGE URL PATH
```

## コンテナの実行中のプロセス一覧を見る
```sh
docker top CONTAINER
```

## dockerの現在インストールしているバージョンと最新のバージョンを得る
```sh
docker version
```

## コンテナ内のイベントを監視する（コンテナが作られた、起動した、停止したなど)
```sh
docker events
```

## コンテナの詳細な情報を得る。formatオプションで情報の絞り込みができる
```sh
docker inspect CONTAINER
docker inspect  --format="{{.NetworkSettings.IPAddress}}" CONTAINER
```

## コンテナ内でコマンドを実行する
```sh
docker exec CONTAINER コマンド
```

## コンテナ内でコマンドを対話式に実行する
```sh
docker exec -it CONTAINER コマンド
```

