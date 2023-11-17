SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := up

DOTENV := $(PWD)/.env
-include $(DOTENV)

docker_user := "$(shell id -u):$(shell id -g)"
app := app
timestamp := $(shell date '+%Y%m%d.%H%M%S')

export

tag:
	@tag="Release_${app}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."

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
build-all: build-image
_compose:
	@docker_user=$(docker_user) docker-compose $(cmd) $(arg)

console:
	@docker exec -it $(app) /bin/bash --login
