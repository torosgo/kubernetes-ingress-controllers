#!/bin/bash
## Setup Landing Zone: Resource Group, VNET and SUBNET 
## Set and save environments variables for landing zone in env file

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
    check_vars RESOURCE_GROUP REGION_NAME VNET_NAME VNET_PREFIX SUBNET_NAME SNET_PREFIX
    az_login
    set -euxo pipefail

    az group create \
        --name $RESOURCE_GROUP \
        --location $REGION_NAME

    # Create Vnet
    az network vnet create \
        --resource-group $RESOURCE_GROUP \
        --location $REGION_NAME \
        --name $VNET_NAME \
        --address-prefixes $VNET_PREFIX \
        --subnet-name $SUBNET_NAME \
        --subnet-prefix $SNET_PREFIX
}

status() {
    check_vars RESOURCE_GROUP VNET_NAME SUBNET_NAME
    az_login
    set -euxo pipefail
    az group show -g $RESOURCE_GROUP -o tsv
    az network vnet show -g $RESOURCE_GROUP -n $VNET_NAME -o tsv
    az network vnet subnet show -g $RESOURCE_GROUP -n $SUBNET_NAME --vnet-name $VNET_NAME -o tsv
}

erase() {
    check_vars RESOURCE_GROUP
    az_login
    set -euxo pipefail
    az group delete -n $RESOURCE_GROUP
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