# Kubernetes Ingress Controllers


This project is designed to cover deployment of some selected ingress controllers and using them with some selected sample applications.

## Requirements
- A linux shell (bash, zsh, etc.)
- Git
- Azure CLI
- Kubectl
- Helm
- Azure subscription
- Istioctl

## Usage

**Quick deployment:**
1. [Clone this repository](#clone-this-repository)
2. [Edit configuration file](#edit-configuration-file)
3. Deploy Landing Zone, AKS cluster, ACR, AppGW, Application, Ingress Controller:
```bash
## Clone this repository
git clone https://github.com/torosgo/kubernetes-ingress-controllers

## Edit configuration file
cp .env.example .env
edit .env

## Deploy  Landing Zone, ACR, AKS cluster, AppGW, Application, Ingress Controller
make all

## Browse the app through public ip of ingress (http://INGRESSIP)
## You can get the ingress IP with the following:
kubectl get ingress --namespace ratingsapp| grep ratings-web-ingress-agic |awk '{print $4}'

## Delete Resource Group and everything in it if you want to remove the whole deployment
make erase
```
  

**Step by step deployment:**

1. [Clone this repository](#clone-this-repository)
2. [Edit configuration file](#edit-configuration-file)
3. [Deploy Landing Zone (Resource Group, VNET, SUBNET)](#deploy-landing-zone)
4. [Deploy ACR](#deploy-acr)
5. [Deploy AKS cluster](#deploy-aks-cluster)
6. [Deploy AppGW](#deploy-appgw)
7. [Deploy Application](#deploy-application)
8. [Deploy Ingress Controller](#deploy-ingress-controller)

Note: After deploying each component, it is recommended to wait for the components get deployed at the backgound and go to the next step after you make sure the current one is already deployed.
## Instructions
### Clone this Repository

```bash
git clone https://github.com/torosgo/kubernetes-ingress-controllers
```

### Edit configuration file

```bash
cp .env.example .env
edit .env
```

### Deploy Landing Zone

You can create a new Resource Group, VNET and SUBNET using the following 
```bash
## Deploy landing zone (Resourec Group, VNET, SUBNET)
make azure/landingzone/deploy

## Review landing zone info
make azure/landingzone/status
```
[README: Setup Landing Zone](azure/landingzone/README.md)

### Deploy ACR

You can create a new ACR using the following 
```bash
## Deploy ACR and attach to AKS
make azure/acr/deploy

## Review ACR info
make azure/acr/status
```
[README: Setup ACR](azure/acr/README.md)

### Deploy AKS Cluster

You can deploy a new AKS cluster and attach the ACR (and optionally AppGW) using the following 
```bash
## Deploy AKS cluster
make azure/aks/deploy

## You can answer "y" if you get a quesion like: "proceed to create cluster with system assigned identity? (y/N):"

## Review cluster info
make azure/aks/status

```
If you want a new AppGW to be deployed automatically while AKS deployment, you can do easily only by setting env ingress variables for AGIC in the env.example file:
```bash
export INGRESS_NAME=agic
export APPGW_NAME=demoingress-appgw
export APPGW_SNET_PREFIX=10.241.0.0/16
```

[README: Setup AKS Cluster Setup](azure/aks/README.md)

### Deploy AppGW

AppGW can be deployed within AKS cluster deployment but if you want to deploy a new AppGW separately, you can do using the following 
```bash
## Deploy AppGW
make azure/appgw/deploy

## Review AppGW info
make azure/appgw/status
```
[README: Setup Azure Application Gateway](azure/appgw/README.md)


### Deploy Application

```bash
## Deploy App namespace (e.g. ratingsapp)
make apps/ratingsapp/deployns

## Notice: If you will deploy a Service Mesh, do it at this step and and continue from here when that is done.

## Deploy App
make apps/ratingsapp/deployapp

## Check deployment status
make apps/ratingsapp/status

## Browse the App at http://127.0.0.1:8087
make apps/ratingsapp/proxy
```

[README: Setup Ratings App](apps/ratingsapp/README.md)

### Deploy Ingress Controller

You can install one of the following ingress controllers with following commands:
```bash
## Deploy selected Ingress Controller (e.g. nginx)
make ingress/nginx/deployctl

## Check deployment status
make ingress/nginx/statusctl

## Deploy selected Ingress for the App
make ingress/nginx/deployingress

## Check deployment status
make ingress/nginx/statusingress

## Browse the app through public ip of ingress (http://INGRESSIP)
## You can get the ingress IP with the following:
kubectl get ingress --namespace ratingsapp| grep ratings-web-ingress-agic |awk '{print $4}'

``` 

[README: Setup Nginx Ingress](ingress/nginx/README.md)  
[README: Setup Traefik Ingress](ingress/traefik/README.md)  
[README: Setup HAProxy Ingress](ingress/haproxy/README.md)  
[README: Setup Azure Application Gateway Ingress Controller (AGIC)](ingress/agic/README.md)  
[README: Setup Istio Service Mesh and Istio Gateway](ingress/istio/README.md)

### Delete Resources

```bash

## Delete the ingress
make ingress/nginx/eraseingress

## Delete the ingress controller
make ingress/nginx/erasectl

## Delete the app
make apps/ratingsapp/eraseapp
make apps/ratingsapp/erasens

## Delete AppGW
make azure/appgw/erase

## Delete AKS
make azure/aks/erase

## Delete ACR
make azure/acr/erase

## Delete Landing Zone
make azure/landingzone/erase

```

## References: 
[AKS Tutorial](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app)  
[Azure Kubernetes Service Workshop](https://docs.microsoft.com/en-us/learn/modules/aks-workshop/)  
[Nginx Ingress](https://kubernetes.github.io/ingress-nginx/)  
[Traefik Ingress](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)  
[HAProxy Ingress](https://haproxy-ingress.github.io/)    
[AGIC](https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing?toc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Faks%2Ftoc.json&bc=https%3A%2F%2Fdocs.microsoft.com%2Fen-us%2Fazure%2Fbread%2Ftoc.json)  
[Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/)    

## FAQ

- Q: Should I deploy everything in the repo to make it work?
A: You don't necessarily need to deploy all, but need most of the components. If you use the default .env settings, there is a requirement chain if you go from last component to the first. Ingress requires the App and Azure AppGW, App requires AKS and ACR, and they require an Azure landing zone.
- Q: Do I need AppGW if I use other ingress controllers, e.g. nginx?
A: You don't need AppGW if you are using a different ingress controller. However, it is a good practice to have it in front of other ingresses in order to use other AppGW features like WAF.
- Q: Can I deploy my own application with other components?
A: Yes you can. Make sure you update the config settings in .env file with respect to your own application.
- Q: How do I deploy my own application?
A: You can deploy either by creating a setup folder similar to demo app in the repo and write/modify your setup.sh file, or deploy manually. Make sure you update the config settings in .env file with respect to your own application, so that other component deployments (e.g. ingress) will be aware of the application settings and configure themselves properly during deployment.

## Support

No SLA. Continuous development. Use at your own risk. Please read License.

## Contribution

Contributions are welcome.


## Copyright

Copyright &copy; 2021.


## License

This document is open source software licensed under the [Apache License 2.0 license](https://opensource.org/licenses/Apache-2.0).
