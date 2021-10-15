# Setup Azure Application Gateway

Using this Setup you can:
- Deploy AppGW
- Get AppGW inormation
- Delete AppGW

Note: Deploy Application Gateway in same Vnet as AKS. If you prefer to deploy or have existing AppGW in another Vnet, then you will need network peering between AKS and AppGW Vnets. To read more go to https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing

**Requirements**
- Azure subscription
- Landing Zone
- Azure CLI - az
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
#
# Use same resource group, region and vnet as AKS
export APPGW_NAME=demoaksagw
export RESOURCE_GROUP=demo-appgw-rg
export REGION_NAME=westeurope
export VNET_NAME=demo-appgw-vnet
export APPGW_SNET_PREFIX=10.0.10.0/26
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

# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.


# Make setup.sh executable
chmod +x ./setup.sh

# To see available setup.sh options
./setup.sh help

# Deploy AppGW
./setup.sh deploy

# Review AppGW status
./setup.sh status

# Delete AppGW
./setup erase
```