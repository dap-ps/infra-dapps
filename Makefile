#!/usr/bin/env bash

OS = $(strip $(shell uname -s))
ARCH = linux_amd64
ifeq ($(OS),Darwin)
	ARCH = darwin_amd64
endif

PLUGIN_DIR = ~/.terraform.d/plugins

PROVIDER_NAME = terraform-provider-ansible
PROVIDER_VERSION = v0.0.4
PROVIDER_ARCHIVE = $(PROVIDER_NAME)-$(ARCH).zip
PROVIDER_URL = https://github.com/nbering/terraform-provider-ansible/releases/download/$(PROVIDER_VERSION)/$(PROVIDER_ARCHIVE)

PROVISIONER_NAME = terraform-provisioner-ansible
PROVISIONER_VERSION = v2.0.0
PROVISIONER_ARCHIVE = $(PROVISIONER_NAME)-$(subst _,-,$(ARCH))_$(PROVISIONER_VERSION)
PROVISIONER_URL = https://github.com/radekg/terraform-provisioner-ansible/releases/download/$(PROVISIONER_VERSION)/$(PROVISIONER_ARCHIVE)

all: requirements install-provider install-provisioner secrets init-terraform
	@echo "Success!"

plugins: install-provider install-provisioner

requirements:
	ansible-galaxy install --ignore-errors --force -r ansible/requirements.yml

install-unzip:
	ifeq (, $(shell which unzip)) \
 		$(error "No unzip in PATH, consider doing apt install unzip") \
 	endif

install-provider: install-unzip
	if [ ! -e $(PLUGIN_DIR)/$(ARCH)/$(PROVIDER_NAME)_$(PROVIDER_VERSION) ]; then \
		mkdir -p $(PLUGIN_DIR); \
		wget $(PROVIDER_URL) -P $(PLUGIN_DIR); \
		unzip -o $(PLUGIN_DIR)/$(PROVIDER_ARCHIVE) -d $(PLUGIN_DIR); \
	fi

install-provisioner:
	if [ ! -e $(PLUGIN_DIR)/$(ARCH)/$(PROVISIONER_NAME)_$(PROVISIONER_VERSION) ]; then \
		mkdir -p $(PLUGIN_DIR); \
		wget $(PROVISIONER_URL) -O $(PLUGIN_DIR)/$(ARCH)/$(PROVISIONER_NAME)_$(PROVISIONER_VERSION); \
		chmod +x $(PLUGIN_DIR)/$(ARCH)/$(PROVISIONER_NAME)_$(PROVISIONER_VERSION); \
	fi

init-terraform:
	terraform init -upgrade=true

secrets:
	echo "Saving secrets to: terraform.tfvars"
	@echo "\
# secrets extracted from password-store\n\
aws_access_key  = \"$(shell pass cloud/AWS/access-key)\"\n\
aws_secret_key  = \"$(shell pass cloud/AWS/secret-key)\"\n\
" > terraform.tfvars

cleanup:
	rm -r $(PLUGIN_DIR)/$(ARCHIVE)
