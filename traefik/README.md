
### Create Traefik Ingress

```bash
#// Traefik Controller
kubectl create namespace traefik
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik \
    --namespace traefik
kubectl get services --namespace traefik -w

#// to see traefik builtin dashboard apply
kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n traefik) 9000:9000 -n traefik

#// open in browser http://127.0.0.1:9000/dashboard/
#// or you can open dashboard to public using:
#// kubectl apply -f traefik-dashboard-ingressroute.yaml -n traefik

kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress-traefik.yaml

#// Get traefik ingress service public ip and open in browser http://<ingressip>
kubectl get service traefik --namespace traefik|grep LoadBalancer| awk '{print $4}'

#// delete ingress to stop accepting requests to ratingsapp publicly
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-ingress-traefik.yaml

```

