.DEFAULT_GOAL := help

.PHONY : deps clean conf-check certs install

PWD = $(shell pwd)

clean: ## Clean the environment to have a fresh start
	#-sudo rm

deps: ## Install all the needed deps to test & build it
	sudo apt update -q
	sudo apt install -y ldap-utils

conf-check: ## Make some tests to validate the actual config before proceed 
	# test the settings of the localhost
	scripts/test_localhost.sh
	# test the binddn user and search for the admin user
	scripts/test_bind_dn.sh
	# test a search on the admin user and warn about any misconfigured property
	scripts/test_mailadmin.sh

fix-vmail: ## Fix the warning by creating the vmail user as per the conf file
	scripts/vmail_create.sh

certs: ## Generate a self-signed certificate for the server SSL/TLS options
	scripts/gen_cert.sh

install: ## Install all the software from the repository
	scripts/install_mail.sh

install-purge: ## Uninstall postfix and dovecot already installed software (purge config also)
	scripts/install_purge.sh

provision: ## Provision the server, this will copy over the config files and set the vars
	scripts/provision.sh

all: deps conf-check certs install ## run all targets in the logic order
	echo "Done!"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
