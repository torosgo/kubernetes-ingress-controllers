#!/bin/bash
## Setup AKS cluster
## Set and save environments variables in env file.

main() {
    case "$1" in
        help) usage;;
        deploy) deploy;;
        status) status;;
        erase) erase;;
        erasectx) erasectx;;
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
    echo -e "  erasectx"
    echo
}

deploy() {
    check_vars K8S_CLUSTER_NAME RESOURCE_GROUP REGION_NAME NODE_CNT NODE_MINCNT NODE_MAXCNT NODE_SIZE SVCCIDR DNSIP ACR_NAME INGRESS_NAME
    whatifagic=""
    if [[ $INGRESS_NAME == "agic" ]]; then
        check_vars APPGW_NAME APPGW_SNET_PREFIX
        whatifagic=$(echo "-a ingress-appgw --appgw-name $APPGW_NAME --appgw-subnet-cidr $APPGW_SNET_PREFIX")
    fi
    az_login
    set -euxo pipefail

    SUBNET_ID=$(az network vnet subnet show \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $VNET_NAME \
        --name $SUBNET_NAME \
        --query id -o tsv  | tr -d '\r' | tr -d '$')

    VERSION=$(az aks get-versions \
        --location $REGION_NAME \
        --query 'values[?isDefault  == `true`].version' \
        --output tsv | tr -d '\r' | tr -d '$')

    # Create K8s Cluster

    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $K8S_CLUSTER_NAME \
        --vm-set-type VirtualMachineScaleSets \
        --enable-cluster-autoscaler \
        --min-count $NODE_MINCNT \
        --max-count $NODE_MAXCNT \
        --node-count $NODE_CNT \
        --node-vm-size $NODE_SIZE \
        --load-balancer-sku standard \
        --enable-addons monitoring \
        --location $REGION_NAME \
        --kubernetes-version $VERSION \
        --network-plugin azure \
        --vnet-subnet-id $SUBNET_ID \
        --service-cidr $SVCCIDR \
        --dns-service-ip $DNSIP \
        --generate-ssh-keys \
        --network-policy calico \
        --attach-acr $ACR_NAME \
        --yes $whatifagic

    az aks get-credentials \
        --resource-group $RESOURCE_GROUP \
        --name $K8S_CLUSTER_NAME \
        --overwrite-existing \
        -f ~/.kube/config.$K8S_CLUSTER_NAME
    KUBECONFIG=${KUBECONFIG:-~/.kube/config}::$HOME/.kube/config.$K8S_CLUSTER_NAME kubectl config view --merge --flatten > ~/.kube/merged_kubeconfig && mv ~/.kube/merged_kubeconfig ~/.kube/config 

}

status() {
    check_vars K8S_CLUSTER_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    az aks show -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP -o tsv
}

erase() {
    check_vars K8S_CLUSTER_NAME RESOURCE_GROUP
    az_login
    set -euxo pipefail
    az aks delete -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP
}

erasectx() {
    check_vars K8S_CLUSTER_NAME RESOURCE_GROUP
    set -euxo pipefail
    kubectl config delete-cluster $K8S_CLUSTER_NAME
    kubectl config delete-user clusterUser_${K8S_CLUSTER_NAME}_${RESOURCE_GROUP}
    kubectl config delete-context $K8S_CLUSTER_NAME
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