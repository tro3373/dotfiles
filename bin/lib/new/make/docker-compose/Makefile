app := app
timestamp := $(shell date '+%Y%m%d.%H%M%S')
.DEFAULT_GOAL := up

tag:
	@tag="Release_${app}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."

up: start logsf
start:
	@docker-compose up -d $(ARG)
stop: down
down:
	@docker-compose down $(ARG)
restart:
	@docker-compose restart $(ARG)

logs:
	@docker-compose logs $(ARG)
logsf:
	@docker-compose logs -f $(ARG)

console:
	@docker exec -it $(app) /bin/sh --login
