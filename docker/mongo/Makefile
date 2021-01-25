CONTAINERNAME_001=mongo001
CONTAINERNAME_002=mongo002
CONTAINERNAME_003=mongo003

all_container=$$(docker ps -a -q)
active_container=$$(docker ps -q)
images=$$(docker images | awk '/^<none>/ { print $$3 }')
local_ip=$$(ip route |awk 'END {print $$NF}')

#.PHONY: all test clean
.DEFAULT_GOAL := up

build:
	docker-compose build

up: start
start:
	docker-compose up -d && docker-compose logs -f
stop: down
down:
	docker-compose down
restart: stop start

logs:
	docker-compose logs
logsf:
	docker-compose logs -f

console: attach1
attach1:
	docker exec -it $(CONTAINERNAME_001) /bin/bash --login
console2: attach2
attach2:
	docker exec -it $(CONTAINERNAME_002) /bin/bash --login
console3: attach3
attach3:
	docker exec -it $(CONTAINERNAME_003) /bin/bash --login

rs:
	docker exec -it $(CONTAINERNAME_001) /setup_rs


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
