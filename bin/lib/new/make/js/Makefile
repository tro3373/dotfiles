SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := up

DOTENV := $(PWD)/.env
-include $(DOTENV)

app := sample
svc_client := client
stage := dev
node_cache_d := $(PWD)/node_modules
timestamp := $(shell date '+%Y%m%d.%H%M%S')
local_ip := $(shell (ip route 2>/dev/null |grep kernel |grep -v linkdown |grep -v 'br-' || echo localhost) |sed -e 's,.metric.*,,g' |awk 'END {print $$NF}')
docker_uid := $(shell id -u)
docker_gid := $(shell id -g)
docker_user := "$(docker_uid):$(docker_gid)"

export

tag:
	@tag="Release_${app}_$$(date +%Y%m%d.%H%M%S)" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r envs.zip .env.development .env.production
unzip:
	@test -e envs.zip
	@unzip envs.zip

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
_compose:
	@docker-compose $(cmd) $(arg)

build-all: build-image build

npm-clean:
	@rm -rf $(node_cache_d)
npmi:
	@make _client cmd='npm i'
npmi-%:
	@make _client cmd='npm i $(*)'
npmi_if_needed:
	@if [[ ! -e $(node_cache_d) ]]; then \
		make npmi; \
	fi

_client:
	@make _exec svc=$(svc_client)
_exec:
	@echo "==> Executing $(cmd) in $(svc)..." && \
		make _compose cmd="exec -it $(svc) $(cmd)"

console:
	@make _client cmd='/bin/bash --login'

run: npmi_if_needed open_browser
	@make _client cmd='npm run dev'

local: npmi_if_needed open_browser
	@make cmd='npm run dev' _node

build: npmi_if_needed
	@make cmd='npm run build-$(stage)' _node

open_browser:
	@local_url="http://$(shell ipa 2>/dev/null || echo localhost):3000" && \
		open "$${local_url}" 2>/dev/null || echo "==> Open $${local_url} in your browser."
