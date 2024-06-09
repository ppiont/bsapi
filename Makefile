SUBDIRECTORY=modules
TF_PARALLELISM?=10

pre_commit:
	@# Help: runs pre-commit hooks on the project
	pre-commit run --all-files

terraform_build:
	@# Help: packages modules into artifacts ready to be uploaded in a registry
	bash test/build_artifacts.sh "$(SUBDIRECTORY)"

terraform_validate:
	@# Help: ensures your Terraform code is valid.
	cd ./"$(SUBDIRECTORY)"/"$(dir_and_test_id)" \
	&& terraform init \
	&& terraform validate;

terraform_plan:
	@# Help: runs Terraform plan on the specified directory
	cd ./"$(SUBDIRECTORY)"/"$(dir_and_test_id)" \
	&& terraform init \
	&& terraform plan --out tfplan.binary \
	&& terraform show -json tfplan.binary | jq --ascii-output '.' > tfplan.json;

terraform_apply: terraform_plan
	@# Help: deploys the resources defined in the specified directory
	cd ./"$(SUBDIRECTORY)"/"$(dir_and_test_id)" \
	&& terraform apply -parallelism=$(TF_PARALLELISM) tfplan.binary \
	&& terraform show -json terraform.tfstate | jq --ascii-output '.' > tfstate.json;

terraform_immutability: terraform_apply
	@# Help: ensures that the infrastructure remains unchanged after the latest apply
	cd ./"$(SUBDIRECTORY)"/"$(dir_and_test_id)" \
	&& terraform plan --out tfplan.binary -detailed-exitcode \
	&& terraform show -json tfplan.binary | jq --ascii-output '.' > tfplan.json

terraform_destroy:
	@# Help: destroys the infrastructure defined in the specified directory
	cd ./"$(SUBDIRECTORY)"/"$(dir_and_test_id)" \
	&& terraform destroy -auto-approve -lock=false;

checkov: terraform_plan
	@# Help: scans infrastructure for security and compliance misconfigurations
	cd ./"$(SUBDIRECTORY)"/"$(dir_and_test_id)" \
	&& checkov -f tfplan.json \
		--config-file checkov.yaml \
		--download-external-modules true \
		--output cli \
		--output junitxml \
		--output-file-path console,checkov-junit.xml;

# help usage based on this comment: https://stackoverflow.com/a/65243296/3832956
help:
	@printf "%-20s %s\n" "Target" "Description"
	@printf "%-20s %s\n" "------" "-----------"
	@make -pqR : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$' \
		| xargs -I _ sh -c 'printf "%-20s " _; make _ -nB | (grep -i "^# Help:" || echo "") | tail -1 | sed "s/^# Help: //g"'
