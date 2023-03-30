# Setup Azure Kubernetes Service

Using this Setup you can:
- Deploy AKS cluster
- Deploy ACR and associate with AKS
- Get AKS cluster information
- Delete AKS

**Requirements**
- Azure subscription
- Landing Zone
- ACR
- Azure CLI - az
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
# AKS requirements Option 1: for existing cluster
export K8S_CLUSTER_NAME=demok8s-ingress
export RESOURCE_GROUP=demok8singress
export REGION_NAME=westeurope
# AKS requirements Option 2: for a new cluster
export K8S_CLUSTER_NAME=demok8s-ingress
export RESOURCE_GROUP=demok8singress
export REGION_NAME=westeurope
export SUBNET_NAME=k8s-subnet
export VNET_NAME=k8s-vnet;
export VNET_PREFIX=10.0.0.0/8
export SNET_PREFIX=10.240.0.0/16
export NODE_CNT=1
export NODE_MINCNT=1
export NODE_MAXCNT=5
export NODE_SIZE=Standard_DS2_v2
export SVCCIDR=10.2.0.0/24
export DNSIP=10.2.0.10
export ACR_NAME=acr123ZYX
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

## Deploy AKS cluster
## You can answer "y" if you get a quesion like: "proceed to create cluster with system assigned identity? (y/N):"
./setup.sh deploy

## Review cluster info in kubectl context
./setup.sh status

# Get AKS credentials
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $K8S_CLUSTER_NAME

## Delete Resource Group, AKS cluster and ACR
./setup erase

```