### Create Application Gateway Ingress Controller (AGIC)

```bash
#// AGIC
#// Deploy Application Gateway in same Vnet as AKS. 
#// Note: If you prefer to deploy or have existing AppGW in another Vnet, then you will need network peering between AKS and AppGW Vnets. To read more go to https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing?toc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Faks%2Ftoc.json&bc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fbread%2Ftoc.json

#// Set and export AppGw spesific env variables. optionally recommended to save in .env file
APPGW_NAME=demoaksagw
APPGW_SNET_PREFIX=10.241.0.0/16

#// If you didn't set AKS vnet name as environment variable you can get it as below
#// VNET_NAME=$(az network vnet list -g $RESOURCE_GROUP -o tsv --query "[0].name")

#// Create public ip,subnet amd AppGW: 
az network public-ip create -n appgwPublicIp -g $RESOURCE_GROUP  --allocation-method Static --sku Standard
az network vnet subnet create -n appgwSubnet -g $RESOURCE_GROUP --vnet-name $VNET_NAME --address-prefixes $APPGW_SNET_PREFIX 
az network application-gateway create -n $APPGW_NAME -l $REGION_NAME -g $RESOURCE_GROUP --sku Standard_v2 --public-ip-address appgwPublicIp --vnet-name $VNET_NAME --subnet appgwSubnet
appgwId=$(az network application-gateway show -n $APPGW_NAME -g $RESOURCE_GROUP -o tsv --query "id") 

#// Enable ingress-appgw addon for AKS with AppGW id
az aks enable-addons -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP -a ingress-appgw --appgw-id $appgwId

#// To disable AGIC:
#// az aks disable-addons -n $K8S_CLUSTER_NAME -g $RESOURCE_GROUP -a ingress-appgw

#// Deploy AppGW ingress for ratings app
kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress-agic.yaml

#// Get AGIC  public ip and browse
INGIP=$(kubectl get ingress --namespace ratingsapp| grep ratings-web-ingress-agic |awk '{print $4}')

curl -I "http://$INGIP"

#// Delete ingress to stop public access to ratings app
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-ingress-agic.yaml

```