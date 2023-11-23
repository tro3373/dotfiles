SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := tunnel

dotenv := $(PWD)/.env
-include $(dotenv)

app := sample
service := api
stage := dev
profile_dev := t${app}
profile_prd := ${app}
sls_container := sls_aws
sls_version := 16-3.21.0

test_api_prefix_dev := https://example.com/dev/api/v1
test_api_prefix_prd := https://example.com/prd/api/v1
test_api_prefix := ${test_api_prefix_dev}
prev_commands := ([[ ! -e node_modules ]] && npm i || :) && \
	if [[ ${stage} == "prd" ]]; then export PROFILE=${profile_prd}; else export PROFILE=${profile_dev}; fi && \
	export SLS_DEBUG=*
prev_commands_curltest := if [[ ${stage} == "prd" ]]; then export test_api_prefix=${test_api_prefix_prd}; else export test_api_prefix=${test_api_prefix_dev}; fi
vault := export GPG_TTY=$$(tty); aws-vault exec $${PROFILE} --
timestamp := $(shell date '+%Y%m%d.%H%M%S')
get_ngrok_url := curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'

export

tag:
	@tag="Release_${service}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r envs.zip envs/*.yml
unzip:
	@test -e envs.zip
	@unzip envs.zip


npmi-%:
	npm i -g ${*}
.PHONY: setup
setup: npmi-serverless npmi-eslint npmi-prettier npmi-eslint-config-prettier


check_aws:
	@make _aws cmd='s3 ls'
check_env:
	@make _sh cmd='-c "env"'
session:
	@make _sh cmd='-c "exit"'
check: check_aws check_env
_aws:
	@make _vault_cmd ENTRYPOINT='--entrypoint aws'
_sh:
	@make _vault_cmd ENTRYPOINT='--entrypoint /bin/sh'
_sls:
	@make _vault_cmd ENTRYPOINT='--entrypoint sls' cmd='${cmd} --stage ${stage} --verbose'
_vault_cmd:
	${prev_commands} \
 		&& docker run -it --rm \
			-v ${PWD}:/app \
			-w /app \
			--env-file <(${vault} env | grep ^AWS_) \
			${ENTRYPOINT} \
			${sls_container}:${sls_version} \
			${cmd} \
		&& echo "Done!"



deploy:
	@make _sls cmd=deploy
remove:
	@make _sls cmd=remove
sls_list_functions:
	@make _sls cmd='deploy list functions'
sls_list:
	@make _sls cmd='deploy list'
sls_info:
	@make _sls cmd=info


tests:
	@make _test cmd=tests
test:
	@make _test cmd=test
test-%:
	@make _test cmd=test-${*}
testt-%:
	@make _test cmd="testt -- ${*}"
test_util: test-util
delete_user:
	@make _test cmd="testt -- backend\ deleteUser"
front_user:
	@make _lib_cmd cmd=cognito_create_user
front_token:
	@make _lib_cmd cmd=cognito_auth_token
_lib_cmd:
	@${prev_commands} && ${vault} ./src/__tests__/lib/${cmd}
# MEMO:
#	FORCE_COLOR=true: For jest output color force with pipe tee log setting
# FOR ESMODULE
# && export NODE_OPTIONS=--experimental-vm-modules
_test:
	@${prev_commands} \
		&& export stage=${stage} \
		&& export FORCE_COLOR=true \
		&& export LOCAL_TEST=1 \
		&& export DEBUG_LAMBDA=true \
		&& export DEBUG_SES=true \
		&& export DEBUG_API_CLIENT=1 \
		&& export AWS_SDK_LOAD_CONFIG=true \
		&& eval "$$(grep -E '(^SM_|^LAMBDA_REGION|^COGNITO_|^MODE_API_|TZ)' ./envs/dev.yml | \
		sed -e 's,: ,=,g' \
			-e 's,LAMBDA_REGION,REGION,g' \
			-e 's,^,export ,g' | \
		tr '\n' ';')" \
		&& ${vault} npm run ${cmd} |& tee test.log




ngrok-url:
	@$(get_ngrok_url)
ngrok: init
	@((pgrep ngrok >& /dev/null) || (echo ">> Starting ngrok.." && (ngrok http 3000 >& /dev/null &) && (sleep 2))) && $(get_ngrok_url)
init:
	@if ! command -v ngrok >&/dev/null; then \
		echo "======================================= "; \
		echo "==> No ngrok command exits."; \
		echo "======================================= "; \
		exit 1; \
	fi;

tunnel:
	@cd $(PWD)/../terraform && make tunnel
pub:
	@cd $(PWD)/swagger && make pub

