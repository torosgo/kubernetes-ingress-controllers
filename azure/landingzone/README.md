# Setup Landing Zone

Using this Setup you can:
- Deploy Resource Group, Vnet and Subnet
- Get Resource Group, Vnet and Subnet information
- Delete Resource Group including all services in it

**Requirements**
- Azure Subscription
- Azure CLI - az
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
export RESOURCE_GROUP=demok8singress
export REGION_NAME=westeurope
export VNET_NAME=k8s-vnet
export VNET_PREFIX=10.0.0.0/8
export SUBNET_NAME=k8s-subnet
export SNET_PREFIX=10.240.0.0/16
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

## Deploy Resource Group, VNET and SUBNET
./setup.sh deploy

## Review cluster info in kubectl context
./setup.sh status

## Delete Resource Group, AKS cluster and ACR
./setup erase

```