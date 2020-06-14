########
# bash #
########
ifneq ($(NO_BASH), true)
	SHELL := /bin/bash
endif

#######
# Env #
#######

include .env

#############
# Variables #
#############

# Bash
BASH_HISTORY=.bash-history
BASH_HISTORY_FILES=node terraform
BASH_HISTORY_PATHS=$(foreach FILE,$(BASH_HISTORY_FILES),$(BASH_HISTORY)/$(FILE))

# Docker Compose
DC=docker-compose
PULL=$(DC) pull
RUN_DEPS=false
RUN=$(DC) run --rm $(shell if [ "$(RUN_DEPS)" != "true" ]; then echo "--no-deps"; fi)

# Node
NODE_BUILD=build
NODE_RUN=$(shell if [ "$(NO_DOCKER)" != "true" ]; then echo "$(RUN) node"; fi)
NODE_NPM=$(NODE_RUN) npm
NODE_INSTALL=$(NODE_NPM) install
NODE_RUN_BUILD=$(NODE_NPM) run build

# Terraform
TERRAFORM=$(shell if [ "$(NO_DOCKER)" == "true" ]; then echo "cd ./terraform;"; fi) \
	$(RUN) \
	$(shell if [ "$(NO_DOCKER)" != "true" ]; then echo "terraform"; fi) \
	terraform

TERRAFORM_EXTRA_ARGS=$(shell if [ "$(TERRAFORM_AUTO_APPROVE)" == "true" ]; then echo "-auto-approve"; fi)

TERRAFORM_INIT=$(TERRAFORM) init \
	-reconfigure \

#############
# Assertion #
#############

.PHONY: assert-environment
assert-environment:
	@if [ "$(ENVIRONMENT)" == "" ]; then echo "Missing \"ENVIRONMENT\" parameter"; exit 1; fi

.PHONY: assert-lock
assert-lock:
	@if [ "$(LOCK)" == "" ]; then echo "Missing \"LOCK\" parameter"; exit 1; fi

.PHONY: assert-application
assert-application:
	@if [ "$(APPLICATION)" == "" ]; then echo "Missing \"APPLICATION\" parameter"; exit 1; fi

.PHONY: assert-service
assert-service:
	@if [ "$(SERVICE)" == "" ]; then echo "Missing \"SERVICE\" parameter"; exit 1; fi

.PHONY: assert-tags
assert-tags: assert-application assert-service

########
# Bash #
########

.PHONY: bash-init
bash-init:
	mkdir -p $(BASH_HISTORY)
	touch $(BASH_HISTORY_PATHS)

.PHONY: bash-reset
bash-reset: bash-init
	truncate --size=0 $(BASH_HISTORY_PATHS)

#############
# Terraform #
#############

.PHONY: terraform-deploy
terraform-deploy: node-build terraform-deploy-fast

.PHONY: terraform-deploy-fast
terraform-deploy-fast: assert-environment terraform-init
	$(TERRAFORM) apply $(TERRAFORM_EXTRA_ARGS) $(TERRAFORM_ARGS)

.PHONY: terraform-destroy
terraform-destroy: assert-environment terraform-init
	$(TERRAFORM) destroy $(TERRAFORM_EXTRA_ARGS) $(TERRAFORM_ARGS)

.PHONY: terraform-init
terraform-init: bash-init assert-tags
ifneq ($(NO_DOCKER), true)
	$(PULL) terraform
endif
	rm -rf terraform/.terraform/terraform.tfstate
	$(TERRAFORM_INIT)

.PHONY: terraform-test
terraform-test: node-build terraform-test-fast

.PHONY: terraform-test-fast
terraform-test-fast: assert-environment terraform-init
	$(TERRAFORM) plan $(TERRAFORM_ARGS)

.PHONY: terraform-unlock
terraform-unlock: assert-environment assert-lock terraform-init
	$(TERRAFORM) force-unlock -force $(LOCK)

########
# Node #
########

.PHONY: node-build
node-build: node-install node-build-fast

.PHONY: node-build-fast
node-build-fast:
	rm -rf $(NODE_BUILD)
	cp package.json $(NODE_BUILD)
	cp package-lock.json $(NODE_BUILD)
	$(NODE_INSTALL) --prefix $(NODE_BUILD) --production
	rm -rf $(NODE_BUILD)/etc $(NODE_BUILD)/package.json $(NODE_BUILD)/package-lock.json

.PHONY: node-init
node-init: bash-init
ifneq ($(NO_DOCKER), true)
	$(PULL) node
endif

.PHONY: node-install
node-install: node-init
	$(NODE_INSTALL)

.PHONY: node-test
node-test: node-install node-test-fast

.PHONY: node-test-fast
node-test-fast:
	$(NODE_NPM) test -- -R dot
