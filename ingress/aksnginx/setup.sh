#!/bin/bash
## Deploy AKS Managed Nginx Ingress Controller
## Set and save environments variables for landing zone in env file

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
    check_vars K8S_CLUSTER_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    #// Nginx Controller
    az aks approuting enable -g $RESOURCE_GROUP -n $K8S_CLUSTER_NAME
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
    az aks approuting disable -g $RESOURCE_GROUP -n $K8S_CLUSTER_NAME
}

eraseingress() {
    check_vars INGRESS_NAME APP_NAME APP_NS
    set -euxo pipefail
    kubectl delete -n $APP_NS -f $BASEDIR/$APP_NAME-$INGRESS_NAME.yaml
}

statusctl() {
    set -euxo pipefail
    kubectl get po,deployment,svc,rs,secret -n app-routing-system
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