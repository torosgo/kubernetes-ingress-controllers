#!/bin/bash
## Setup Ratings App
## Set and save required environments variables in env file

BASEDIR=$(dirname $0)

main() {
    check_vars APP_NAME
    export APP_NS=$APP_NAME
    case "$1" in
        help) usage;;
        status) status;;
        eraseapp) eraseapp;;
        erasens) erasens;;
        deployapp) deployapp;;
        deployns) deployns;;
        proxy) proxy;;
        *) usage;;
    esac    
}

usage() {
    [[ -n "$*" ]] && echo -e "$*\n"
    echo -e ""
    echo -e "${WHITE}Usage: $(basename "$0") <command>${NOCOLOR}"
    echo -e "  help"
    echo -e "  deployapp"
    echo -e "  deployns"
    echo -e "  status"
    echo -e "  eraseapp"
    echo -e "  erasens"
    echo -e "  proxy"
    echo
}

deployapp() {
    check_vars USR_NAME USR_PASSWD BUILD_DIR ACR_NAME RESOURCE_GROUP_ACR 
    az_login
    set -euxo pipefail

    ## Download source code and build ratings-api image
    download_src
    build_acr_image

#   deploy mongodb and app
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm upgrade --install ratings bitnami/mongodb -n $APP_NS --set auth.username=$USR_NAME,auth.password=$USR_PASSWD,auth.database=ratingsdb
#   kubectl create secret generic mongosecret -n $APP_NS --from-literal=MONGOCONNECTION="mongodb://$USR_NAME:$USR_PASSWD@ratings-mongodb.ratingsapp:27017/ratingsdb"
    MONGOCONNECTION=$(echo -ne "mongodb://$USR_NAME:$USR_PASSWD@ratings-mongodb.ratingsapp:27017/ratingsdb" |base64 -w 0)
    sed -e "s/<mongoconnection>/$MONGOCONNECTION/g" $BASEDIR/ratings-secret.yaml | kubectl apply -n $APP_NS -f -
    sed -e "s/<acrname>/$ACR_NAME/g" $BASEDIR/ratings-api-deployment.yaml | kubectl apply -n $APP_NS -f -
    kubectl apply -n $APP_NS -f $BASEDIR/ratings-api-service.yaml
    sed -e "s/<acrname>/$ACR_NAME/g" $BASEDIR/ratings-web-deployment.yaml | kubectl apply -n $APP_NS -f -
    kubectl apply -n $APP_NS -f $BASEDIR/ratings-web-service.yaml
}

deployns() {
    set -euxo pipefail
#   kubectl create namespace $APP_NS
    sed -e "s/<nsname>/$APP_NS/g" $BASEDIR/ratings-namespace.yaml | kubectl apply -f -
}

download_src(){
    if [[ "$APP_DOWNLOADSRC" == "yes" ]]; then
        check_vars BUILD_DIR
        echo "Downloading source" 
        delete_temp_git_dirs
        git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-api.git ${BUILD_DIR}/ratingsapi/
        git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-web.git ${BUILD_DIR}/ratingsweb/
    fi
}

build_acr_image(){
    if [[ "$APP_BUILDIMAGE" == "yes" ]]; then
        check_vars BUILD_DIR RESOURCE_GROUP_ACR ACR_NAME
        echo "Building container image at ACR" 
        az acr build \
            --resource-group $RESOURCE_GROUP_ACR \
            --registry $ACR_NAME \
            --image ratings-api:v1.0.1 ${BUILD_DIR}/ratingsapi/
        az acr build \
            --resource-group $RESOURCE_GROUP_ACR \
            --registry $ACR_NAME \
            --image ratings-web:v1.0.1 ${BUILD_DIR}/ratingsweb/
    fi
}

## function: delete cloned git repos
delete_temp_git_dirs() {
    check_vars BUILD_DIR
    if [ -d "${BUILD_DIR}/ratingsweb/" ]; then
        rm -rf "${BUILD_DIR}/ratingsweb/"
    fi
    if [ -d "${BUILD_DIR}/ratingsapi/" ]; then
        rm -rf "${BUILD_DIR}/ratingsapi/"
    fi
}

eraseapp() {
    check_vars USR_NAME USR_PASSWD ACR_NAME 
    delete_temp_git_dirs
    helm uninstall ratings -n $APP_NS
    MONGOCONNECTION=$(echo -ne "mongodb://$USR_NAME:$USR_PASSWD@ratings-mongodb.ratingsapp:27017/ratingsdb" |base64 -w 0)
    sed -e "s/<mongoconnection>/$MONGOCONNECTION/g" $BASEDIR/ratings-secret.yaml | kubectl delete -n $APP_NS -f -
    sed -e "s/<acrname>/$ACR_NAME/g" $BASEDIR/ratings-api-deployment.yaml | kubectl delete -n $APP_NS -f -
    kubectl delete -n $APP_NS -f $BASEDIR/ratings-api-service.yaml
    sed -e "s/<acrname>/$ACR_NAME/g" $BASEDIR/ratings-web-deployment.yaml | kubectl delete -n $APP_NS -f -
    kubectl delete -n $APP_NS -f $BASEDIR/ratings-web-service.yaml
}

erasens() {
    kubectl delete ns $APP_NS
}

status() {
    kubectl get po,deployment,svc,rs,secret -n $APP_NS
}

proxy() {
    echo "Browse app at http://127.0.0.1:8087"
    kubectl port-forward service/ratings-web 8087:80 -n $APP_NS
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

