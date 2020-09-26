OS = $(strip $(shell uname -s))
ARCH = linux_amd64
ifeq ($(OS),Darwin)
	ARCH = darwin_amd64
endif

PLUGIN_DIR = ~/.terraform.d/plugins

ANSIBLE_PROVISIO_NAME = terraform-provisioner-ansible
ANSIBLE_PROVISIO_VERSION = v2.3.0
ANSIBLE_PROVISIO_ARCHIVE = $(ANSIBLE_PROVISIO_NAME)-$(subst _,-,$(ARCH))_$(ANSIBLE_PROVISIO_VERSION)
ANSIBLE_PROVISIO_URL = https://github.com/radekg/terraform-provisioner-ansible/releases/download/$(ANSIBLE_PROVISIO_VERSION)/$(ANSIBLE_PROVISIO_ARCHIVE)
ANSIBLE_PROVISIO_PATH = $(PLUGIN_DIR)/$(ARCH)/$(ANSIBLE_PROVISIO_NAME)_$(ANSIBLE_PROVISIO_VERSION)

all: requirements plugins init-terraform
	@echo "Success!"

plugins: install-ansible-provisioner

requirements:
	ansible-galaxy install --ignore-errors --force -r ansible/requirements.yml

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

cleanup:
	rm -r $(PLUGIN_DIR)/$(ARCHIVE)
