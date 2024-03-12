### Setup AKS Managed NGINX ingress with the application routing add-on

Using this Setup you can:
- Deploy ingress controller and ingress
- Get ingress controller and ingress status
- Delete ingress controller and ingress

**Requirements**
- Azure subscription
- Landing Zone
- AKS
- Kubectl
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
export K8S_CLUSTER_NAME=demok8s-ingress
export RESOURCE_GROUP=demok8singress
export APP_NAME=ratingsapp
export INGRESS_NAME=aksnginx

```

**Reference**
```bash

## Make setup.sh executable
chmod +x ./setup.sh

## To see available setup.sh options
./setup.sh help

## Deploy Ingress controller
./setup.sh deployctl

## Deploy Ingress for app
./setup.sh deployingress

## Review ingress controller status
./setup.sh statusctl

## Review ingress status for app
./setup.sh statusingress

## Get nginx ingress service public ip and browse
INGIP=$(kubectl get service nginx -n app-routing-system|grep LoadBalancer| awk '{print $4}')
curl -I "http://$INGIP"

## Delete Ingress controller
./setup erasectl

## Delete Ingress
./setup eraseingress
```