CONTAINERNAME=mysql
# VERSION=1.0.0
# DOCKER_RUN_OPTIONS=

all_container=$$(docker ps -a -q)
active_container=$$(docker ps -q)
images=$$(docker images | awk '/^<none>/ { print $$3 }')
local_ip=$$(ip route |awk 'END {print $$NF}')

#.PHONY: all test clean
#default: build
.DEFAULT_GOAL := up

restart: stop start
start: up
up:
	EXTERNAL_IP=$(local_ip) docker compose up -d && docker compose logs -f
stop: down
down:
	EXTERNAL_IP=$(local_ip) docker compose down

logs:
	docker compose logs
logsf:
	docker compose logs -f

console: attach
attach:
	docker exec -it $(CONTAINERNAME) /bin/bash --login
attachdb:
	docker exec -it $(CONTAINERNAME) mysql -u root -p
init:
	cat <setup | docker exec -i $(CONTAINERNAME) bash -

clean: clean_container clean_images
clean_images:
	@if [ "$(images)" != "" ] ; then \
		docker rmi $(images); \
	fi
clean_container:
	@for a in $(all_container) ; do \
		for b in $(active_container) ; do \
			if [ "$${a}" = "$${b}" ] ; then \
				continue 2; \
			fi; \
		done; \
		docker rm $${a}; \
	done
