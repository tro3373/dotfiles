app := app
timestamp := $(shell date '+%Y%m%d.%H%M%S')
.DEFAULT_GOAL := up

tag:
	@tag="Release_${app}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."

_compose:
	@docker_user=$(docker_user) docker-compose $(cmd) $(arg)

build:
	@make -s _compose cmd=build

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

console:
	@docker exec -it $(app) /bin/bash --login
