# http://qiita.com/takara@github/items/a0a295d265ab5ff43ddc
# http://qiita.com/takara@github/items/7beee975e6df7ce53755
all_container=`docker ps -a -q`
active_container=`docker ps -q`
images=`docker images | awk '/^<none>/ { print $$3 }'`

all:

build:
	docker build -t $(NAME):$(VERSION) .

restart: stop start

start:
	docker run -d \
		--name $(NAME) \
		-h $(NAME) \
		$(DOCKER_RUN_OPTIONS) $(NAME):$(VERSION)

stop:
	docker rm -f $(NAME)

logs:
	docker logs $(NAME)

attach:
	docker exec -it $(NAME) /bin/bash --login

tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest

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
