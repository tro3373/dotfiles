app := app
timestamp := $(shell date '+%Y%m%d.%H%M%S')
.DEFAULT_GOAL := up

tag:
	@tag="Release_${app}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."

_compose:
	@docker_user=$(docker_user) docker-compose $(CMD) $(ARG)

build:
	@make -s _compose CMD=build

up: start logsf
start:
	@make -s _compose CMD="up -d"
stop: down
down:
	@make -s _compose CMD=down
restart:
	@make -s _compose CMD=restart

logs:
	@make -s _compose CMD=logs
logsf:
	@make -s _compose CMD="logs -f"

console:
	@docker exec -it $(app) /bin/bash --login
