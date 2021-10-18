### Create AKS Cluster

```bash
#// Set environments variables for AKS and save some of them to .env file for reuse
REGION_NAME=westeurope; echo export REGION_NAME=$REGION_NAME>> .env
RESOURCE_GROUP=demok8singress; echo export RESOURCE_GROUP=$RESOURCE_GROUP>> .env
SUBNET_NAME=k8s-subnet
VNET_NAME=k8s-vnet; echo export VNET_NAME=$VNET_NAME>> .env
VNET_PREFIX=10.0.0.0/8
SNET_PREFIX=10.240.0.0/16
K8S_CLUSTER_NAME=demok8s-$RANDOM; echo export K8S_CLUSTER_NAME=$K8S_CLUSTER_NAME>> .env
NODE_CNT=1
NODE_MINCNT=1
NODE_MAXCNT=5
NODE_SIZE=Standard_DS2_v2
SVCCIDR=10.2.0.0/24
DNSIP=10.2.0.10
ACR_NAME=acr$RANDOM; echo export ACR_NAME=$ACR_NAME>> .env

az group create \
    --name $RESOURCE_GROUP \
    --location $REGION_NAME

# Create Vnet
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --location $REGION_NAME \
    --name $VNET_NAME \
    --address-prefixes $VNET_PREFIX \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix $SNET_PREFIX

SUBNET_ID=$(az network vnet subnet show \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME \
    --query id -o tsv)

VERSION=$(az aks get-versions \
    --location $REGION_NAME \
    --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' \
    --output tsv)

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
    --docker-bridge-address 172.17.0.1/16 \
    --generate-ssh-keys \
    --tags 'project=demo' \
    --network-policy calico \
    --no-wait 

az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $K8S_CLUSTER_NAME

kubectl get nodes
```

### Create ACR and associate with AKS

```bash

az acr create \
    --resource-group $RESOURCE_GROUP \
    --location $REGION_NAME \
    --name $ACR_NAME \
    --sku Standard

az aks update \
    --name $K8S_CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --attach-acr $ACR_NAME
```
