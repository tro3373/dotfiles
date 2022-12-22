SERVICE := api
APP := sample
STAGE := dev
PROFILE_DEV := t${APP}
PROFILE_PRD := ${APP}
SLS_CONTAINER := sls_aws
SLS_VERSION := 16-3.21.0
TEST_API_PREFIX_DEV := https://example.com/dev/api/v1
TEST_API_PREFIX_PRD := https://example.com/prd/api/v1
TEST_API_PREFIX := ${TEST_API_PREFIX_DEV}
PREV_COMMANDS=([[ ! -e node_modules ]] && npm i || :) && \
	if [[ ${STAGE} == "prd" ]]; then export PROFILE=${PROFILE_PRD}; else export PROFILE=${PROFILE_DEV}; fi && \
	export SLS_DEBUG=*
PREV_COMMANDS_CURLTEST=if [[ ${STAGE} == "prd" ]]; then export TEST_API_PREFIX=${TEST_API_PREFIX_PRD}; else export TEST_API_PREFIX=${TEST_API_PREFIX_DEV}; fi
VAULT=export GPG_TTY=$$(tty); aws-vault exec $${PROFILE} --
TIMESTAMP := $(shell date '+%Y%m%d.%H%M%S')
GET_NGROK_URL := curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'

.DEFAULT_GOAL := tunnel

tag:
	@tag="Release_${SERVICE}_${TIMESTAMP}" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r sls.${SERVICE}.keys.zip envs/*.yml

npmi-%:
	npm i -g ${*}
.PHONY: setup
setup: npmi-serverless npmi-eslint npmi-prettier npmi-eslint-config-prettier

_vault_cmd:
	${PREV_COMMANDS} \
 		&& docker run -it --rm \
			-v ${PWD}:/app \
			-w /app \
			--env-file <(${VAULT} env | grep ^AWS_) \
			${ENTRYPOINT} \
			${SLS_CONTAINER}:${SLS_VERSION} \
			${CMD} \
		&& echo "Done!"

_aws:
	@make ENTRYPOINT='--entrypoint aws' _vault_cmd
_sh:
	@make ENTRYPOINT='--entrypoint /bin/sh' _vault_cmd
_sls:
	@make ENTRYPOINT='--entrypoint sls' CMD='${CMD} --stage ${STAGE} --verbose' _vault_cmd

check_aws:
	@make CMD='s3 ls' _aws
check_env:
	@make CMD='-c "env"' _sh
session:
	@make CMD='-c "exit"' _sh
check: check_aws check_env

sls_list_functions:
	@make CMD='deploy list functions' _sls
sls_list:
	@make CMD='deploy list' _sls
sls_info:
	@make CMD=info _sls

deploy:
	@make CMD=deploy _sls
remove:
	@make CMD=remove _sls

tunnel:
	@cd $(PWD)/../terraform && make tunnel
pub:
	@cd $(PWD)/swagger && make pub

# MEMO:
#	FORCE_COLOR=true: For jest output color force with pipe tee log setting
# FOR ESMODULE
# && export NODE_OPTIONS=--experimental-vm-modules
_test:
	@${PREV_COMMANDS} \
		&& export STAGE=${STAGE} \
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
		&& ${VAULT} npm run ${CMD} |& tee test.log

tests:
	@make CMD=tests _test
test:
	@make CMD=test _test
test-%:
	@make CMD=test-${*} _test
testt-%:
	@make CMD="testt -- ${*}" _test
test_util: test-util
delete_user:
	@make CMD="testt -- backend\ deleteUser" _test

init:
	@if ! command -v ngrok >&/dev/null; then \
		echo "======================================= "; \
		echo "==> No ngrok command exits."; \
		echo "======================================= "; \
		exit 1; \
	fi;

_lib_cmd:
	@${PREV_COMMANDS} && ${VAULT} ./src/__tests__/lib/${CMD}
front_user:
	@make _lib_cmd CMD=cognito_create_user
front_token:
	@make _lib_cmd CMD=cognito_auth_token
