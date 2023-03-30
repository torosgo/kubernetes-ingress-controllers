### Setup Application Gateway Ingress Controller (AGIC)
Using this Setup you can:
- Deploy Application Gateway, AGIC and ingress
- Get ingress controller and ingress status
- Delete ingress controller and ingress

Deploy Application Gateway in same Vnet as AKS. 

Note: If you prefer to deploy or have existing AppGW in another Vnet, then you will need network peering between AKS and AppGW Vnets. To read more go to https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing

**Requirements**
- Azure subscription
- Landing Zone
- AKS
- AppGW
- Azure CLI - az
- Kubectl
- Helm
- Environment Variables

```bash
## Required Environment Variables
## Define if not defined or override the values of required environments variables.
## You can write them in a file and run "source ${filename}" for reuse. Example
export APPGW_NAME=demoaksappgw
export APPGW_SNET_PREFIX=10.241.0.0/16
export RESOURCE_GROUP=demok8singress
export K8S_CLUSTER_NAME=demok8s-ingress
export INGRESS_NAME=agic
export APP_NAME=ratingsapp
# 
# Set Azure login method
# Options: interactive, device, serviceprincipal, managedidentity
export AZLOGINTYPE=interactive
# If serviceprincipal is selected, then first create a service principal with proper role and set SP_APPID SP_PASSWD AADTENANT variables
# Reference: https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli
# export AZLOGINTYPE=serviceprincipal
# export SP_APPID=******
# export SP_PASSWD=******
# export AADTENANT=******

```

**Reference**
```bash

## Make setup.sh executable
chmod +x ./setup.sh

## To see available setup.sh options
./setup.sh help

## Deploy Ingress controller
# deployctl is deprecated because agic addon is enabled during AKS installation
./setup.sh deployctl

## Deploy Ingress for app
./setup.sh deployingress

## Review ingress controller status
./setup.sh statusctl

## Review ingress status for app
./setup.sh statusingress

#// Get AGIC  public ip by yourself and browse
INGIP=$(kubectl get ingress --namespace ratingsapp| grep ratings-web-ingress-agic |awk '{print $4}')
# or
# INGIP=$(az network public-ip show -g $RESOURCE_GROUP -n appgwPublicIp -o tsv --query "ipAddress")
curl -I "http://$INGIP"

## Delete Ingress controller
./setup erasectl

## Delete Ingress
./setup eraseingress
```