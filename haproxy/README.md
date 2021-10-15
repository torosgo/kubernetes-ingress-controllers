
### Create HAProxy Ingress

```bash
#// HAProxy Ingress Controller

helm repo add haproxy-ingress https://haproxy-ingress.github.io/charts
helm install haproxy-ingress haproxy-ingress/haproxy-ingress\
  --create-namespace --namespace haproxy\
  --version 0.13.4\
  -f haproxy-ingress-values.yaml

kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress-haproxy.yaml

#// Get HAProxy ingress service public ip, and curl or open in browser http://<ingressip>
INGIP=$(kubectl get service haproxy-ingress --namespace haproxy|grep LoadBalancer| awk '{print $4}')

curl -I -H 'Host: ratings-haproxy.localhost' "http://$INGIP"

#// delete ingress to stop accepting requests to ratingsapp publicly
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-ingress-haproxy.yaml

```