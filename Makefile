.DEFAULT_GOAL := help

.PHONY : deps clean check-configs

PWD = $(shell pwd)

deps: ## Install all the needed deps to test & build it
	sudo apt update -q
	sudo apt install -y ldap-utils

clean: ## Clean the environment to have a fresh start
	#-sudo rm 

check-configs: ## Make some tests to validate the actual config before proceed 
	# test the binddn user and search for the admin user
	scripts/test_bind_dn.sh
	# test a search on the admin user and warn about any misconfigured property
	scripts/test_mailadmin.sh
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
