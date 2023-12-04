FTP_CONTAINERNAME=ftpd
SFTP_CONTAINERNAME=sftpd
VERSION=1.0.0

all_container=`docker ps -a -q`
active_container=`docker ps -q`
images=`docker images | awk '/^<none>/ { print $$3 }'`

default: up
start: up
up: init_dirs
	docker compose up -d && docker compose logs

init_dirs:
	@if [ ! -e ./volume_ftp ] ; then \
		mkdir ./volume_ftp; \
		chmod 777 ./volume_ftp; \
	fi; \
	if [ ! -e ./volume_sftp ] ; then \
		mkdir ./volume_sftp; \
		chmod 777 ./volume_sftp; \
	fi;

stop: down
down:
	docker compose down -v

restart: stop start

logs:
	docker compose logs
logsf:
	docker compose logs -f

console_ftp: attach_ftp
attach_ftp:
	docker exec -it $(FTP_CONTAINERNAME) /bin/bash --login

console_sftp: attach_sftp
attach_sftp:
	docker exec -it $(SFTP_CONTAINERNAME) /bin/bash --login

prune:
	docker volume prune

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
