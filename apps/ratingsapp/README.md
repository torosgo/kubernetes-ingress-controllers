# Setup Ratings App

Using this Setup you can:
- Deploy App:
    - Downloads Ratings App repos
    - Builds and hosts the images in ACR
    - Deploys MongoDB to Kubernetes cluster
    - Deploys Ratings API and Web apps to Kubernetes cluster
- Delete App
- Get App deployment status
- Create port-forward proxy from your localhost to App

Ratings Api:  https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-api.git  
Ratings Web: https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-web.git  

**Requirements**
- Azure subscription
- Landing Zone
- AKS
- ACR
- Azure CLI - az
- Kubectl
- Helm
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
export ACR_NAME=acr123ZYX
export RESOURCE_GROUP_ACR=${RESOURCE_GROUP}
export APP_NAME=ratingsapp
export USR_NAME=demouser
export USR_PASSWD=Pa55w0rD
# 
# Set APP_DOWNLOADSRC=yes if you want to (re)download the source code
export APP_DOWNLOADSRC=yes
# Set APP_BUILDIMAGE=yes if you want to (re)build the image
export APP_BUILDIMAGE=yes
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

## Deploy App
./setup.sh deployns
./setup.sh deployapp

## Review app deployment status
./setup.sh status

## Browse the app at http://127.0.0.1:8087
./setup.sh proxy

## Delete App
./setup eraseapp
./setup erasens

```