# Setup Azure Container Registry

Using this Setup you can:
- Deploy ACR and associate with AKS
- Get ACR information
- Delete ACR

**Requirements**
- Azure subscription
- Landing Zone
- AKS
- Azure CLI - az
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
export K8S_CLUSTER_NAME=demok8s-ingress
export RESOURCE_GROUP=demok8singress
export REGION_NAME=westeurope
export ACR_NAME=acr123ZYX #
export RESOURCE_GROUP_ACR=${RESOURCE_GROUP}
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

## Deploy ACR
# Notice: Running deploy requires owner role for authentication identity which may require additional permissions for serviceprincipal azure login method. Try interactive login as a quick workaround with a owner user
./setup.sh deploy

## Review ACR info
./setup.sh status

## Delete ACR
./setup erase

```