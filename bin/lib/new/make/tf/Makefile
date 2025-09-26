tf_service := $(service)
tf_env := $(env)
tf_env_dir := terraform/envs/$(tf_env)

###############################################
# For GCP
###############################################
tf-check:
	@echo "==> Listing configs..."
	@gcloud config list
	@echo "==> Listing buckets..."
	@gsutil ls
tf_state_bucket := gs://tf-state-$(tf_service)
tf-state-bucket:
	@if gsutil ls $(tf_state_bucket) >&/dev/null; then \
		echo "==> $(tf_state_bucket) already exists."; \
	else \
		echo "==> Creating $(tf_state_bucket)... Press Enter to continue..(Cancel: Ctrl+C)"; \
		read -r _; \
		gcloud storage buckets create \
			$(tf_state_bucket) \
			--location=us \
			--default-storage-class=NEARLINE \
			--uniform-bucket-level-access \
			--public-access-prevention; \
	fi

# ###############################################
# # For AWS
# ###############################################
# tf_state_bucket := $(tf_env)-$(tf_service)-tfstate
# tf-state-bucket:
# 	@if aws s3 ls | grep "$(tf_state_bucket)" >&/dev/null; then \
# 		echo "==> $(tf_state_bucket) already exists."; \
# 	else \
# 		echo "==> Creating $(tf_state_bucket)... Press Enter to continue..(Cancel: Ctrl+C)"; \
# 		read -r _; \
# 		aws s3 mb "s3://$(tf_state_bucket)" --region "$(region)"
# 		aws s3api put-bucket-versioning --bucket "$(tf_state_bucket)" --versioning-configuration "Status=Enabled"
# 	fi


tf-init:
	@make _tf cmd=init
tf-init-upgrade:
	@make _tf cmd=init opt="-upgrade=true"
tf-init-migrate-state:
	@make _tf cmd=init opt="-migrate-state"

tf-plan:
	@make _tf cmd=plan
tf-plan-%:
	@make tf-plan opt="-target=$(*)"

tf-apply:
	@make _tf cmd=apply
tf-apply-%:
	@make tf-apply opt="-target=$(*)"
tf-apply-auto-approve:
	@make _tf cmd=apply opt=-auto-approve
tf-apply-refresh:
	@make _tf cmd=apply opt=-refresh-only

tf-refresh:
	@make _tf cmd=refresh
tf-show:
	@make _tf cmd=show
tf-output:
	@make _tf cmd=output
tf-console:
	@make _tf cmd=console
tf-validate:
	@make _tf cmd=validate
tf-state:
	@make _tf cmd=state opt=list

tf-destroy:
	@make _tf cmd=destroy
tf-rm:
	# @make _tf cmd=state opt="rm 'module.relational_database.google_firebase_data_connect_service.this'"
	@make _tf cmd=state opt="rm 'module.relational_database.google_sql_database.this'"
	@make _tf cmd=state opt="rm 'module.relational_database.google_sql_database_instance.this'"

_tf_check_env:
	@echo "==> Validating environment... env=$(tf_env)"
	@test -n $(tf_env) || (echo 'Error: env is not set.' && exit 1)
	@test -e $(tf_env_dir) || (echo 'No such env:$(tf_env_dir) exist.' && exit 1)

_tf: _tf_check_env
	@cd $(tf_env_dir) && \
		terraform $(tf_opt) $(cmd) $(opt)

tf-lint-init:
	@tflint --init
tf-lint: _tf_check_env
	@tflint --config $(PWD)/.tflint.hcl --recursive

tf-fmt:
	@make -s _tf cmd=fmt opt="-check -recursive"

tf_export_dir_name := terraform_exported
tf-bulk-export:
	@docker run --rm -it \
		-v ~/.config/gcloud:/root/.config/gcloud-ro:ro \
		-v $(PWD)/$(tf_export_dir_name):/$(tf_export_dir_name) \
		-e COMPONENTS='google-cloud-cli-config-connector' \
		gcr.io/google.com/cloudsdktool/google-cloud-cli:stable \
		bash -c "cp -rfvp /root/.config/gcloud-ro/* /root/.config/gcloud/ && gcloud beta resource-config bulk-export \
			--path=/$(tf_export_dir_name) \
			--project=$(project_id) \
			--resource-format=terraform"
