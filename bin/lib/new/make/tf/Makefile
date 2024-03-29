SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := plan

dotenv := $(PWD)/.env
-include $(dotenv)

app := sample
svc := tf
region := ap-northeast-1
stage := dev
profile_dev := t${app}
profile_prd := ${app}
tf_container := tf_aws
tf_version := 1.2.5
bucket_tfstate := ${app}-${stage}-tfstate
validate_cd := ([[ ! -e envs/${stage} ]] && echo 'No such stage:envs/${stage} exist.' && exit 1) || \
	cd envs/${stage} && \
	if [[ ${stage} == "prd" ]]; then export PROFILE=${profile_prd}; else export PROFILE=${profile_dev}; fi
# vault=export AWS_PROFILE="$${PROFILE}"; export AWS_DEFAULT_PROFILE="$${PROFILE}";
# vault := export GPG_TTY=$$(tty); aws-vault exec $${PROFILE} -n --
vault := export GPG_TTY=$$(tty); aws-vault exec $${PROFILE} --
timestamp := $(shell date '+%Y%m%d.%H%M%S')

export

tag:
	@tag="Release_${svc}_${timestamp}" && git tag "$$tag" && echo "==> $$tag tagged."
zip:
	@zip -r envs.zip envs/{dev,prd}/{.env,keys,terraform.tfvars}
unzip:
	@test -e envs.zip
	@unzip envs.zip


session:
	@make _sh cmd='-c "exit"'
check_aws:
	@make _aws cmd='s3 ls'
check_env:
	@make _sh cmd='-c "env"'
check: check_aws check_env
_aws:
	@make _vault_cmd entrypoint='--entrypoint aws'
_tf:
	@make _vault_cmd
_sh:
	@make _vault_cmd entrypoint='--entrypoint /bin/sh'
_vault_cmd:
	${validate_cd} \
 		&& docker run -it --rm \
			-v ${PWD}:/app \
			-w /app/envs/${stage} \
			--env-file <(${vault} env | grep ^AWS_) \
			${entrypoint} \
			${tf_container}:${tf_version} \
			${cmd}


init_tfstate_s3:
	@if make _aws cmd='s3 ls |grep ${bucket_tfstate}' &>/dev/null; then \
		echo '> Already bucket exist'; \
	else \
		echo '> No tf bucket exist. creating...'; \
		make _aws cmd='s3 mb s3://${bucket_tfstate} --region ${region}' && \
		make _aws cmd='s3api put-bucket-versioning --bucket "${bucket_tfstate}" --versioning-configuration "Status=Enabled"' && \
		echo '> Bucket created.'; \
	fi
fmt:
	@make _tf cmd=fmt
init: init_tfstate_s3
	@make _tf cmd=init
init_upgrade:
	@make _tf cmd='init -upgrade=true'
plan:
	@make _tf cmd=plan
apply:
	@make _tf cmd=apply
apply-refresh:
	@make _tf cmd='apply -refresh-only'
destroy:
	@make _tf cmd=destroy
refresh:
	@make _tf cmd=refresh
show:
	@make _tf cmd=show
list-state:
	@make _tf cmd='state list'
output:
	@make _tf cmd=output



asm_get_db_auth:
	make _asm_get SECRET_ID=${stage}-${app}-secret-db-auth
asm_put_db_auth:
	@${validate_cd} && \
		export h=$$(grep db_proxy .env |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		export d=$$(grep database_name terraform.tfvars |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		export u=$$(grep database_username terraform.tfvars |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		export p=$$(grep database_password terraform.tfvars |cut -d= -f2 |tr -d '"' |tr -d ' ') && \
		@make SECRET_ID=${stage}-${app}-secret-db-auth \
			SECRET_STRING='{\"host\":\"$$h\", \"database\":\"$$d\", \"username\":\"$$u\", \"password\":\"$$p\"}' \
			_asm_put
asm_remove_db_auth:
	make _asm_remove_force SECRET_ID=${stage}-${app}-secret-db-auth
_asm_get:
	@make _aws cmd='secretsmanager get-secret-value --secret-id ${SECRET_ID}'
_asm_put:
	@make _aws cmd='secretsmanager put-secret-value --secret-id ${SECRET_ID} --secret-string "${SECRET_STRING}"'
_asm_remove_force:
	@make _aws cmd='secretsmanager delete-secret --secret-id ${SECRET_ID} --force-delete-without-recovery'


bastion_status:
	@${validate_cd} && bash -c '. .env && ${vault} aws ec2 describe-instance-status --instance-ids $$ec2_id | jq ".InstanceStatuses[] | {InstanceId, InstanceState: .InstanceState.Name, SystemStatus: .SystemStatus.Status, InstanceStatus: .InstanceStatus.Status}"'
bastion_start:
	@${validate_cd} && bash -c '. ./.env && ${vault} aws ec2 start-instances --instance-ids $$ec2_id'
bastion_stop:
	@${validate_cd} && bash -c '. ./.env && ${vault} aws ec2 stop-instances --instance-ids $$ec2_id'
tunnel: session
	@${validate_cd} && bash -c '. ./.env && echo "==> Tunneling $$db_proxy via $$bastion..." && ssh -g -N -L 3306:$$db_proxy:3306 $$bastion'
