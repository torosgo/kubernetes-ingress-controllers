#!/bin/bash
## Deploy Istio and Istio Gateway
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
    check_vars INGRESS_NAME
    set -euxo pipefail
    #// Istio with Istio Gateway
    istioctl install --set profile=demo -y
}

deployingress() {
    check_vars INGRESS_NAME APP_NAME APP_NS
    set -euxo pipefail
    # Label app namespace for  Istio sidecar injection
    kubectl label ns $APP_NS istio-injection=enabled
    # Deploy ingress for the app
    kubectl apply -n $APP_NS -f $BASEDIR/$APP_NAME-$INGRESS_NAME.yaml
}

erasectl() {
    check_vars INGRESS_NAME
    set -euxo pipefail
    istioctl x uninstall --purge
}

eraseingress() {
    check_vars INGRESS_NAME APP_NAME APP_NS
    set -euxo pipefail
    kubectl delete -n $APP_NS -f $BASEDIR/$APP_NAME-$INGRESS_NAME.yaml
}

statusctl() {
    check_vars INGRESS_NAME
    set -euxo pipefail
    istioctl verify-install
    kubectl -n istio-system get deploy
    kubectl get svc istio-ingressgateway -n istio-system
}

statusingress() {
    check_vars APP_NS
    set -euxo pipefail
    istioctl analyze -n $APP_NS
    kubectl get svc istio-ingressgateway -n istio-system
    kubectl get virtualservice -n $APP_NS
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