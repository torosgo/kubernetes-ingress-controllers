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

#// Deploy Nginx ingress for ratings app
kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-ingress-nginx.yaml

#// Get nginx ingress service public ip and browse
INGIP=$(kubectl get service nginx-ingress-ingress-nginx-controller --namespace ingress|grep LoadBalancer| awk '{print $4}')

curl -I "http://$INGIP"

#// Delete ingress to stop public access to ratings app
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-ingress-nginx.yaml

```