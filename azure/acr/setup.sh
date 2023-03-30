#!/bin/bash
## Setup ACR
## Set and save environments variables in env file.

main() {
    case "$1" in
        help) usage;;
        deploy) deploy;;
        status) status;;
        erase) erase;;
        *) usage;;
    esac    
}

usage() {
    [[ -n "$*" ]] && echo -e "$*\n"
    echo -e ""
    echo -e "${WHITE}Usage: $(basename "$0") <command>${NOCOLOR}"
    echo -e "  help"
    echo -e "  deploy"
    echo -e "  status"
    echo -e "  erase"
    echo
}

deploy() {
    check_vars RESOURCE_GROUP_ACR REGION_NAME ACR_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    
    az acr create \
        --resource-group $RESOURCE_GROUP_ACR \
        --location $REGION_NAME \
        --name $ACR_NAME \
        --sku Standard

    # az aks update --name $K8S_CLUSTER_NAME --resource-group $RESOURCE_GROUP --attach-acr $ACR_NAME
}

status() {
    check_vars ACR_NAME RESOURCE_GROUP_ACR
    az_login
    set -euxo pipefail
    az acr show -n $ACR_NAME -g $RESOURCE_GROUP_ACR -o tsv
}

erase() {
    check_vars RESOURCE_GROUP ACR_NAME RESOURCE_GROUP_ACR
    az_login
    set -euxo pipefail
    # az aks update -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP --detach-acr $ACR_NAME
    az acr delete -n $ACR_NAME -g $RESOURCE_GROUP_ACR
}

# az login
# required vars: AZLOGINTYPE
# required vars if AZLOGINTYPE=serviceprincipal : SP_APPID SP_PASSWD AADTENANT
az_login() {
    azstatus=$(az account get-access-token -o none &> /dev/null)
    if [[ $? != 0 ]]; then
        case "$AZLOGINTYPE" in
            interactive) az login -o none;;
            device) az login -o none --use-device-code;;
            serviceprincipal) check_vars SP_APPID SP_PASSWD AADTENANT; az login -o none --service-principal -u $SP_APPID -p $SP_PASSWD --tenant $AADTENANT;;
            managedidentity) az login -o none --identity;;
            *) az login -o none;;
        esac
    fi
}

check_vars() {
    local missing=
    for i in $@;do
        local env_var=
        env_var=$(declare -p "$i")
        if ! [[  -v $i && $env_var =~ ^declare\ -x ]]; then
            missing+="$i "
        fi
    done
    if [[ -n $missing ]]; then 
        echo "Missing environment variable(s): $missing"
        exit
    fi
 }

# Colors
RED='\033[0;31m'
CYAN='\033[0;33m'
DBLUE='\033[34m'
BLUE='\033[34;1m'
LBLUE='\033[36m'
WHITE='\033[37;1m'
GREEN='\033[32;1m'
NOCOLOR='\033[0m'

main "$@"; exit