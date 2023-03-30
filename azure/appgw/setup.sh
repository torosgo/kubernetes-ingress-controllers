#!/bin/bash
## Setup Azure Application Gateway in the selected existing VNET.
## Set and save environments variables for AppGW in env file.

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
    check_vars APPGW_NAME RESOURCE_GROUP REGION_NAME VNET_NAME APPGW_SNET_PREFIX
    az_login
    set -euxo pipefail

    #// Create public ip,subnet amd AppGW: 
    az network public-ip create -n appgwPublicIp -g $RESOURCE_GROUP  --allocation-method Static --sku Standard
    az network vnet subnet create -n appgwSubnet -g $RESOURCE_GROUP --vnet-name $VNET_NAME --address-prefixes $APPGW_SNET_PREFIX 
    az network application-gateway create -n $APPGW_NAME -l $REGION_NAME -g $RESOURCE_GROUP --sku Standard_v2 --public-ip-address appgwPublicIp --vnet-name $VNET_NAME --subnet appgwSubnet --priority 1001
}

status() {
    check_vars APPGW_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    az network application-gateway show -g $RESOURCE_GROUP -n $APPGW_NAME 
    az network public-ip show -g $RESOURCE_GROUP -n appgwPublicIp --query "{fqdn: dnsSettings.fqdn,address: ipAddress}"
}

erase() {
    check_vars APPGW_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    az network application-gateway delete -g $RESOURCE_GROUP -n $APPGW_NAME
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

# Main
main "$@"; exit