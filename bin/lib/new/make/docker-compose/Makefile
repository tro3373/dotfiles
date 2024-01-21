SHELL := bash
PATH := $(PWD)/bin:$(PATH)
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := up

dotenv := $(PWD)/.env
-include $(dotenv)

app := sample
stage := dev
timestamp := $(shell date '+%Y%m%d.%H%M%S')
local_ip := $(shell ipa 2>/dev/null || echo localhost)
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

_compose:
	docker compose $(cmd) $(opt)
_compose_run:
	docker compose run --rm -it $(compose_opt) $(svc) '$(cmd) $(opt)'
_compose_run-%:
	@make -s _compose_run svc=$(*)
_compose_exec:
	docker -s compose exec -it $(compose_opt) $(svc) $(cmd) $(opt)
_compose_exec-%:
	@make -s _compose_exec svc=$(*)

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

build-images:
	@make -s _compose cmd=build
build-all:
	@make -C ./client/front build

console: console-client
console-client:
	@make -s _compose_exec-client cmd='bash --login'

open_browser:
	make -C ./client/front open_browser
