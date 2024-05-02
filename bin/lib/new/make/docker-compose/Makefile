SHELL := bash
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(patsubst %/,%,$(dir $(mkfile_path)))
PATH := $(mkfile_dir)/bin:$(PATH)
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

vault_envs := $(shell vault_envs -n)

tag:
	@tag="Release_${app}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r envs.zip path/to/creds
unzip:
	@test -e envs.zip
	@unzip envs.zip


_compose:
	docker compose $(compose_opt) $(cmd) $(svc) $(opt) $(arg)
_compose_run-%:
	docker compose run --rm -it $(vault_envs) $(compose_opt) $(*) $(cmd) $(opt)
_compose_exec-%:
	docker compose exec -it $(vault_envs) $(compose_opt) $(*) $(cmd) $(opt)
_compose_exec_or_run-%:
	@if docker ps | grep -q $(app)-; then make _compose_exec-$(*); else make _compose_run-$(*); fi


build-images:
	@make _compose cmd=build
update-redocly:
	@make build-images opt="--no-cache redoc-watcher"
	@if docker ps | grep -q $(app)-redoc-watcher; then make down && make up; fi
build-images-force:
	@make build-images arg=--no-cache
build-all:
	@make -C ./client/front build


clean-docker:
	@clean_docker -e


up: upd logsf
upd:
	@make _compose cmd="up -d"
down: clean-docker
	@make _compose cmd=down
restart:
	@make _compose cmd=restart
logs:
	@make _compose cmd=logs
logsf:
	@make _compose cmd="logs -f"


console: console-app
console-app:
	@make _compose_exec-app cmd='bash --login'
console-client:
	@make _compose_exec-client cmd='bash --login'
console-redoc-watcher:
	@make _compose_exec-redoc-watcher cmd='sh'
console-codegen-openapi:
	@make _compose_exec-codegen-openapi cmd='bash'


codegen-openapi:
	@make _compose_run-codegen-openapi cmd='docker-entrypoint.sh generate -i /app/dist/swagger.yaml -g go -o /app/dist/codegen/openapi'
codegen-kiota:
	@make _compose_run-codegen-kiota cmd='generate --language go -n namespace-prefix'

open_browser:
	@make -C ./client/front open_browser
	@open "http://$(local_ip):8080" 2>/dev/null
	@open "http://$(local_ip):8081" 2>/dev/null
	@open "http://$(local_ip):8082" 2>/dev/null
