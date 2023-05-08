SERVICE := tf
APP := sample
REGION := ap-northeast-1
STAGE := dev
PROFILE_DEV := t${APP}
PROFILE_PRD := ${APP}
TF_CONTAINER := tf_aws
TF_VERSION := 1.2.5
BUCKET_TFSTATE := ${APP}-${STAGE}-tfstate
VALIDATE_CD := ([[ ! -e envs/${STAGE} ]] && echo 'No such stage:envs/${STAGE} exist.' && exit 1) || \
	cd envs/${STAGE} && \
	if [[ ${STAGE} == "prd" ]]; then export PROFILE=${PROFILE_PRD}; else export PROFILE=${PROFILE_DEV}; fi
# VAULT=export AWS_PROFILE="$${PROFILE}"; export AWS_DEFAULT_PROFILE="$${PROFILE}";
# VAULT := export GPG_TTY=$$(tty); aws-vault exec $${PROFILE} -n --
VAULT := export GPG_TTY=$$(tty); aws-vault exec $${PROFILE} --
TIMESTAMP := $(shell date '+%Y%m%d.%H%M%S')

.DEFAULT_GOAL := plan

tag:
	@tag="Release_${SERVICE}_${TIMESTAMP}" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r terraform.keys.zip envs/{dev,prd}/{.env,keys,terraform.tfvars}

_vault_cmd:
	${VALIDATE_CD} \
 		&& docker run -it --rm \
			-v ${PWD}:/app \
			-w /app/envs/${STAGE} \
			--env-file <(${VAULT} env | grep ^AWS_) \
			${ENTRYPOINT} \
			${TF_CONTAINER}:${TF_VERSION} \
			${CMD}

_aws:
	@make ENTRYPOINT='--entrypoint aws' _vault_cmd
_tf:
	@make _vault_cmd
_sh:
	@make ENTRYPOINT='--entrypoint /bin/sh' _vault_cmd

session:
	@make CMD='-c "exit"' _sh
check_aws:
	@make CMD='s3 ls' _aws
check_env:
	@make CMD='-c "env"' _sh
check: check_aws check_env

init_tfstate_s3:
	@if make CMD='s3 ls |grep ${BUCKET_TFSTATE}' _aws &>/dev/null; then \
		echo '> Already bucket exist'; \
	else \
		echo '> No tf bucket exist. creating...'; \
		make CMD='s3 mb s3://${BUCKET_TFSTATE} --region ${REGION}' _aws && \
		make CMD='s3api put-bucket-versioning --bucket "${BUCKET_TFSTATE}" --versioning-configuration "Status=Enabled"' _aws && \
		echo '> Bucket created.'; \
	fi

fmt:
	@make CMD=fmt _tf
init: init_tfstate_s3
	@make CMD=init _tf
init_upgrade:
	@make CMD='init -upgrade=true' _tf
plan:
	@make CMD=plan _tf
apply:
	@make CMD=apply _tf
apply-refresh:
	@make CMD='apply -refresh-only' _tf
destroy:
	@make CMD=destroy _tf
refresh:
	@make CMD=refresh _tf
show:
	@make CMD=show _tf
list-state:
	@make CMD='state list' _tf
output:
	@make CMD=output _tf


_asm_get:
	@make CMD='secretsmanager get-secret-value --secret-id ${SECRET_ID}' _aws
_asm_put:
	@make CMD='secretsmanager put-secret-value --secret-id ${SECRET_ID} --secret-string "${SECRET_STRING}"' _aws
_asm_remove_force:
	@make CMD='secretsmanager delete-secret --secret-id ${SECRET_ID} --force-delete-without-recovery' _aws

asm_get_db_auth:
	make SECRET_ID=${STAGE}-${APP}-secret-db-auth _asm_get
asm_put_db_auth:
	@${VALIDATE_CD} && \
		export h=$$(grep db_proxy .env |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		export d=$$(grep database_name terraform.tfvars |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		export u=$$(grep database_username terraform.tfvars |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		export p=$$(grep database_password terraform.tfvars |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		@make SECRET_ID=${STAGE}-${APP}-secret-db-auth \
			SECRET_STRING='{\"host\":\"$$h\", \"database\":\"$$d\", \"username\":\"$$u\", \"password\":\"$$p\"}' \
			_asm_put
asm_remove_db_auth:
	make SECRET_ID=${STAGE}-${APP}-secret-db-auth _asm_remove_force

bastion_status:
	@${VALIDATE_CD} && bash -c '. .env && ${VAULT} aws ec2 describe-instance-status --instance-ids $$ec2_id | jq ".InstanceStatuses[] | {InstanceId, InstanceState: .InstanceState.Name, SystemStatus: .SystemStatus.Status, InstanceStatus: .InstanceStatus.Status}"'
bastion_start:
	@${VALIDATE_CD} && bash -c '. ./.env && ${VAULT} aws ec2 start-instances --instance-ids $$ec2_id'
bastion_stop:
	@${VALIDATE_CD} && bash -c '. ./.env && ${VAULT} aws ec2 stop-instances --instance-ids $$ec2_id'
tunnel: session
	@${VALIDATE_CD} && bash -c '. ./.env && echo "==> Tunneling $$db_proxy via $$bastion..." && ssh -g -N -L 3306:$$db_proxy:3306 $$bastion'
