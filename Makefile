#!/usr/bin/env bash

OS = $(strip $(shell uname -s))
ARCH = linux_amd64
ifeq ($(OS),Darwin)
	ARCH = darwin_amd64
endif

PLUGIN_DIR = ~/.terraform.d/plugins

ANSIBLE_PROVIDER_NAME = terraform-provider-ansible
ANSIBLE_PROVIDER_VERSION = v1.0.3
ANSIBLE_PROVIDER_ARCHIVE = $(ANSIBLE_PROVIDER_NAME)-$(ARCH).zip
ANSIBLE_PROVIDER_URL = https://github.com/nbering/terraform-provider-ansible/releases/download/$(ANSIBLE_PROVIDER_VERSION)/$(ANSIBLE_PROVIDER_ARCHIVE)
ANSIBLE_PROVIDER_PATH = $(PLUGIN_DIR)/$(ARCH)/$(ANSIBLE_PROVIDER_NAME)_$(ANSIBLE_PROVIDER_VERSION)

ANSIBLE_PROVISIO_NAME = terraform-provisioner-ansible
ANSIBLE_PROVISIO_VERSION = v2.3.0
ANSIBLE_PROVISIO_ARCHIVE = $(ANSIBLE_PROVISIO_NAME)-$(subst _,-,$(ARCH))_$(ANSIBLE_PROVISIO_VERSION)
ANSIBLE_PROVISIO_URL = https://github.com/radekg/terraform-provisioner-ansible/releases/download/$(ANSIBLE_PROVISIO_VERSION)/$(ANSIBLE_PROVISIO_ARCHIVE)
ANSIBLE_PROVISIO_PATH = $(PLUGIN_DIR)/$(ARCH)/$(ANSIBLE_PROVISIO_NAME)_$(ANSIBLE_PROVISIO_VERSION)

all: requirements plugins secrets init-terraform
	@echo "Success!"

plugins: install-ansible-provider install-ansible-provisioner

requirements:
	ansible-galaxy install --ignore-errors --force -r ansible/requirements.yml

check-unzip:
ifeq (, $(shell which unzip))
	$(error "No unzip in PATH, consider doing apt install unzip")
endif

install-ansible-provider: check-unzip
	@if [ ! -e $(ANSIBLE_PROVIDER_PATH) ]; then \
		mkdir -p $(PLUGIN_DIR); \
		wget $(ANSIBLE_PROVIDER_URL) -P $(PLUGIN_DIR); \
		unzip -o $(PLUGIN_DIR)/$(ANSIBLE_PROVIDER_ARCHIVE) -d $(PLUGIN_DIR); \
	else \
		echo "Already installed: $(ANSIBLE_PROVIDER_PATH)"; \
	fi

install-ansible-provisioner:
	@if [ ! -e $(ANSIBLE_PROVISIO_PATH) ]; then \
		mkdir -p $(PLUGIN_DIR); \
		wget $(ANSIBLE_PROVISIO_URL) -O $(PLUGIN_DIR)/$(ARCH)/$(ANSIBLE_PROVISIO_NAME)_$(ANSIBLE_PROVISIO_VERSION); \
		chmod +x $(PLUGIN_DIR)/$(ARCH)/$(ANSIBLE_PROVISIO_NAME)_$(ANSIBLE_PROVISIO_VERSION); \
	else \
		echo "Already installed: $(ANSIBLE_PROVISIO_PATH)"; \
	fi

init-terraform:
	terraform init -upgrade=true

secrets:
	echo "Saving secrets to: terraform.tfvars"
	@echo -e "\
# secrets extracted from password-store\n\
aws_access_key     = \"$(shell pass cloud/AWS/access-key)\"\n\
aws_secret_key     = \"$(shell pass cloud/AWS/secret-key)\"\n\
dap_ps_smtp_user   = \"$(shell pass cloud/AWS/ses/smtp-access-key)\"\n\
dap_ps_smtp_pass   = \"$(shell pass cloud/AWS/ses/smtp-password)\"\n\
dap_ps_admin_user  = \"$(shell pass service/dev/app/admin-user)\"\n\
dap_ps_admin_pass  = \"$(shell pass service/dev/app/admin-pass)\"\n\
dap_ps_dev_db_uri  = \"$(shell pass service/dev/mongodb/uri)\"\n\
dap_ps_prod_db_uri = \"$(shell pass service/prod/mongodb/uri)\"\n\
" > terraform.tfvars

cleanup:
	rm -r $(PLUGIN_DIR)/$(ARCHIVE)
