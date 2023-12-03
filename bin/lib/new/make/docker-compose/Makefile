SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := up

dotenv := $(PWD)/.env
-include $(dotenv)

app := sample
svc_client := client
stage := dev
timestamp := $(shell date '+%Y%m%d.%H%M%S')
local_ip := $(shell (ip route 2>/dev/null |grep kernel |grep -v linkdown |grep -v 'br-' || echo localhost) |sed -e 's,.metric.*,,g' |awk 'END {print $$NF}')
docker_uid := $(shell id -u)
docker_gid := $(shell id -g)
docker_user := $(docker_uid):$(docker_gid)

export

tag:
	@tag="Release_${app}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r envs.zip path/to/creds
unzip:
	@test -e envs.zip
	@unzip envs.zip

up: start logsf
start:
	@make -s _compose cmd="up -d"
stop: down
down:
	@make -s _compose cmd=down
restart:
	@make -s _compose cmd=restart
logs:
	@make -s _compose cmd=logs
logsf:
	@make -s _compose cmd="logs -f"
build-image:
	@make -s _compose cmd=build
_compose:
	docker compose $(cmd) $(opt)
_compose_exec:
	docker compose exec -it $(svc) $(cmd) $(opt)
_compose_run:
	docker compose run --rm -it $(svc) '$(cmd) $(opt)'

build-all:
	@make -C ./client/front build

console: console-client
console-client:
	@make _client cmd='bash --login'
_client:
	@make _compose_exec svc=$(svc_client)

open_browser:
	make -C ./client/front open_browser
