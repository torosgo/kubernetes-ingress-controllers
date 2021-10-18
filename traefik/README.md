
### Create Traefik Ingress

```bash
#// Traefik Controller
kubectl create namespace traefik
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik \
    --namespace traefik
kubectl get services --namespace traefik -w

#// To see traefik builtin dashboard, apply
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n traefik) 9000:9000 -n traefik

#// open in browser http://127.0.0.1:9000/dashboard/
#// or you can open dashboard to public using:
#// kubectl apply -f traefik-dashboard-ingressroute.yaml -n traefik

#// Deploy Traefik ingress for ratings app
kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress-traefik.yaml

#// Get Traefik ingress service public ip and browse
INGIP=$(kubectl get service traefik --namespace traefik|grep LoadBalancer| awk '{print $4}')

curl -I "http://$INGIP"

#// Delete ingress to stop public access to ratings app
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-ingress-traefik.yaml

```

