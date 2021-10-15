### Create Nginx Ingress

```bash
#// Nginx Controller
kubectl create namespace ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
kubectl get services --namespace ingress -w

kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress-nginx.yaml

#// Get nginx ingress service public ip and open in browser http://<ingressip>
kubectl get service nginx-ingress-ingress-nginx-controller --namespace ingress|grep LoadBalancer| awk '{print $4}'

#// delete ingress to stop accepting requests to ratingsapp publicly
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-ingress-nginx.yaml

```