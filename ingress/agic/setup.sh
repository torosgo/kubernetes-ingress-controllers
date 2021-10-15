#!/bin/bash
## Deploy Application Gateway Ingress Controller (AGIC)

##  Note: If you didn't set AKS vnet name as environment variable you can get it as below
##  VNET_NAME=$(az network vnet list -g $RESOURCE_GROUP -o tsv --query "[0].name")


BASEDIR=$(dirname $0)

main() {
    check_vars APP_NAME
    export  APP_NS=$APP_NAME
    case "$1" in
        help) usage;;
        statusctl) statusctl;;
        statusingress) statusingress;;
        erasectl) erasectl;;
        eraseingress) eraseingress;;
        deployctl) deployctl;;
        deployingress) deployingress;;
        *) usage;;
    esac    
}

usage() {
    [[ -n "$*" ]] && echo -e "$*\n"
    echo -e ""
    echo -e "${WHITE}Usage: $(basename "$0") <command>${NOCOLOR}"
    echo -e "  help"
    echo -e "  deployctl"
    echo -e "  deployingress"
    echo -e "  statusctl"
    echo -e "  statusingress"
    echo -e "  erasectl"
    echo -e "  eraseingress"
    echo
}

deployctl() {
    check_vars APPGW_NAME RESOURCE_GROUP K8S_CLUSTER_NAME 
    az_login
    set -euxo pipefail

    appgwId=$(az network application-gateway show -n $APPGW_NAME -g $RESOURCE_GROUP -o tsv --query "id") 
    #// Enable ingress-appgw addon for AKS with AppGW id
    az aks enable-addons -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP -a ingress-appgw --appgw-id $appgwId
}

deployingress() {
    check_vars INGRESS_NAME APP_NAME APP_NS
    set -euxo pipefail
    #// Deploy ingress for the app
    kubectl apply -n $APP_NS -f $BASEDIR/$APP_NAME-$INGRESS_NAME.yaml
}

erasectl() {
    check_vars K8S_CLUSTER_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    az aks disable-addons -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP -a ingress-appgw
}

eraseingress() {
    check_vars INGRESS_NAME APP_NAME APP_NS
    set -euxo pipefail
    kubectl delete -n $APP_NS -f $BASEDIR/$APP_NAME-$INGRESS_NAME.yaml
}

statusctl() {
    # pod/ingress-appgw-deployment-***
    # deployment.apps/ingress-appgw-deployment
    # replicaset.apps/ingress-appgw-deployment-***
    # serviceaccounts/ingress-appgw-sa
    # configmaps/ingress-appgw-cm
    # secrets/ingress-appgw-sa-token-pqwgd
    # kubectl get deployment,po -l app=ingress-appgw -n kube-system
 
    check_vars RESOURCE_GROUP
    az_login   
    set -euxo pipefail
    az aks list -g $RESOURCE_GROUP -o json | jq -r '.[].addonProfiles.ingressApplicationGateway'
}

statusingress() {
    check_vars APP_NS
    set -euxo pipefail
    kubectl get ingress -n $APP_NS
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