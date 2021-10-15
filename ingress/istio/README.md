### Setup Istio Service Mesh and Istio Gateway

Using this Setup you can:
- Deploy service mesh, ingress controller and ingress
- Get ingress controller and ingress status
- Delete ingress controller and ingress

**Requirements**
- Azure subscription
- Landing Zone
- AKS
- Kubectl
- Helm
- Istioctl
- Environment Variables
- An app namespace to be created


```bash
# Required Environment Variables
# Define if not defined or override the values of required environments variables.
# You can write them in a file and run "source ${filename}" for reuse.
export APP_NAME=ratingsapp
export INGRESS_NAME=istio

```

```bash
# Install Istioctl at client side (requirement)

curl -sL https://istio.io/downloadIstioctl | sh -


# Add the istioctl to your path with either:
  export PATH=$PATH:$HOME/.istioctl/bin
# And/Or add the following to .bashrc (or .zshrc etc.):
# if [ -d "$HOME/.istioctl/bin" ] ; then
#     PATH="$PATH:$HOME/.istioctl/bin"
# fi
# if [ -f "$HOME/completion/_istioctl" ] ; then
#     PATH="$PATH:$HOME/completion/_istioctl"
# fi
# source .bashrc

# Begin the Istio pre-installation check by running:
istioctl x precheck

```

```bash
# Install Istio and Istio Gateway

## Make setup.sh executable
chmod +x ./setup.sh

## To see available setup.sh options
./setup.sh help

## Deploy Ingress controller
./setup.sh deployctl

## Deploy Ingress for app. Make sure an app namespace exists in advance
./setup.sh deployingress

## Deploy the app in the app namespace. Istio sidecars will be automatically injected.

## Review ingress controller status
./setup.sh statusctl

## Review ingress status for app
./setup.sh statusingress

## Get Istio Gateway service public ip and browse
INGIP=$(kubectl get svc istio-ingressgateway -n istio-system|grep LoadBalancer| awk '{print $4}')
curl -I -HHost:ratingsapp.local  "http://$INGIP"

## Delete Ingress controller
./setup erasectl

## Delete Ingress
./setup eraseingress

```