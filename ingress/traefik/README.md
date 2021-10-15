### Setup Traefik Ingress

Using this Setup you can:
- Deploy ingress controller and ingress
- Get ingress controller and ingress status
- Delete ingress controller and ingress

**Requirements**
- Azure subscription
- Landing Zone
- AKS
- Kubectl
- Helm
- Environment Variables

```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
export APP_NAME=ratingsapp
export INGRESS_NAME=traefik

```

**Reference**
```bash

## Make setup.sh executable
chmod +x ./setup.sh

## To see available setup.sh options
./setup.sh help

## Deploy Ingress controller
./setup.sh deployctl

## To see traefik builtin dashboard, apply
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n traefik) 9000:9000 -n traefik
## open in browser http://127.0.0.1:9000/dashboard/
## or you can open dashboard to public using:
# kubectl apply -f traefik-dashboard-ingressroute.yaml -n traefik

## Deploy Ingress for app
./setup.sh deployingress

## Review ingress controller status
./setup.sh statusctl

## Review ingress status for app
./setup.sh statusingress

## Get nginx ingress service public ip and browse
INGIP=$(kubectl get service traefik --namespace traefik|grep LoadBalancer| awk '{print $4}')
curl -I "http://$INGIP"

## Delete Ingress controller
./setup erasectl

## Delete Ingress
./setup eraseingress

```

