SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := console

dotenv := $(PWD)/.env
-include $(dotenv)

svc := interpreter
docker_uid := $(shell id -u)
docker_gid := $(shell id -g)
docker_user := $(docker_uid):$(docker_gid)

export

# up: start logsf
# start:
# 	@make -s _compose cmd="up -d"
# stop: down
# down:
# 	@make -s _compose cmd=down
# restart:
# 	@make -s _compose cmd=restart
# logs:
# 	@make -s _compose cmd=logs
# logsf:
# 	@make -s _compose cmd="logs -f"
build-image:
	@make -s _compose cmd=build
_compose:
	docker compose $(cmd) $(opt)
console:
	docker compose run --rm -it --entrypoint "bash -i" $(svc)
# run:
# 	@make _compose_run

# _compose_exec:
# 	docker compose exec -it $(svc) $(cmd)
# _compose_run:
# 	docker compose run --rm -it $(svc) #'$(cmd) $(opt)'
