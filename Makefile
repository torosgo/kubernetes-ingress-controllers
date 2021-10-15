.DEFAULT_GOAL := help
KUBECTL := kubectl
APPS_DIR:="./apps"
INGRESS_DIR:="./ingress"
export BUILD_DIR := ./build

>:=\033[36m>>\033[0m
CCCOLOR:=\033[34m
LINKCOLOR:=\033[34;1m
SRCCOLOR:=\033[33m
BINCOLOR:=\033[37;1m
MAKECOLOR:=\033[32;1m
ENDCOLOR:=\033[0m
BLUE:=\033[36m

objectname:=Main Setup

ENV_FILE?=.env
ifneq ("$(wildcard $(ENV_FILE))","")
include $(ENV_FILE)
else
$(error Environment variable file $(ENV_FILE) is not available. Create the file and set values)
endif

.PHONY: help
help: ## This help
	@echo ""
	@echo "$(BINCOLOR)Usage:$(ENDCOLOR)"
	@echo "  make $(BLUE)<command>$(ENDCOLOR)"
	@echo ""
	@echo "$(BINCOLOR)Available Commands:$(ENDCOLOR)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
#	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
#	Thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@echo "  $(BLUE)path/to/folder/action:$(ENDCOLOR)         Runs cd path/to/folder && ./setup.sh action"
	@echo ""
	@echo "$(BINCOLOR)Example: Quick deployment$(ENDCOLOR)"
	@echo "  cp .env.example .env && edit .env"
	@echo "  make all"
	@echo ""
	@echo "$(BINCOLOR)Example: Step by step deployment$(ENDCOLOR)"
	@echo "  cp .env.example .env && edit .env"
	@echo "  make azure/landingzone/deploy"
	@echo "  make azure/aks/deploy"
	@echo "  make azure/acr/deploy"
	@echo "  make azure/appgw/deploy"
	@echo "  make apps/APP_NAME/deployns"
	@echo "  make ingress/INGRESS_NAME/deployctl"
	@echo "  make ingress/INGRESS_NAME/deployingress"
	@echo "  make apps/APP_NAME/deployapp"
	@echo ""
	@echo "  Browse $(LINKCOLOR)http://<ingress ip>$(ENDCOLOR)"
	@echo ""

# space := $(subst ,, )
_=$() $()
# Runs cd $path && ./setup action
# input: path/to/folder/action
define resetup
	action='$(lastword $(subst /, ,$@))' && \
	path='$(subst $(_),/,$(filter-out $(lastword $(subst /, ,$@)) ,$(subst /, ,$@)))' && \
	cd $$path && ./setup.sh $$action
endef

$(ENV_FILE):
	$(error Environment variable file $(ENV_FILE) is not available. Create the file and set values)

azure/%: $(ENV_FILE) ## path/to/folder/action
	@$(resetup)
apps/%: $(ENV_FILE) ## path/to/folder/action
	@$(resetup)
ingress/%: $(ENV_FILE) ## path/to/folder/action
	@$(resetup)

all: azure/landingzone/deploy azure/aks/deploy azure/acr/deploy azure/appgw/deploy apps/$(APP_NAME)/deployns ingress/$(INGRESS_NAME)/deployctl ingress/$(INGRESS_NAME)/deployingress apps/$(APP_NAME)/deployapp ## Deploy Landing Zone, AKS cluster, ACR, AppGW, Application, Ingress Controller
erase: azure/landingzone/erase ## Erase Resource Group and everything in it
