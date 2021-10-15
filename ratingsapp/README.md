## Deploy Ratings App


```bash

cd ratingsapp
kubectl create namespace ratingsapp

git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-api.git

cd mslearn-aks-workshop-ratings-api

az acr build \
    --resource-group $RESOURCE_GROUP \
    --registry $ACR_NAME \
    --image ratings-api:v1 .

cd ..

git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-web.git

cd mslearn-aks-workshop-ratings-web

az acr build \
    --resource-group $RESOURCE_GROUP \
    --registry $ACR_NAME \
    --image ratings-web:v1 .

az acr repository list \
    --name $ACR_NAME \
    --output table

cd ..

helm repo add bitnami https://charts.bitnami.com/bitnami

helm search repo bitnami

helm install ratings bitnami/mongodb \
    --namespace ratingsapp \
    --set auth.username=$USR_NAME,auth.password=$USR_PASSWD,auth.database=ratingsdb

```
 
OUTPUT similar like:
```bash
NAME: ratings
LAST DEPLOYED: Tue Oct 12 17:19:30 2021
NAMESPACE: ratingsapp
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **

MongoDB&reg; can be accessed on the following DNS name(s) and ports from within your cluster:

    ratings-mongodb.ratingsapp.svc.cluster.local

To get the root password run:

    export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace ratingsapp ratings-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)

To get the password for "demouser" run:

    export MONGODB_PASSWORD=$(kubectl get secret --namespace ratingsapp ratings-mongodb -o jsonpath="{.data.mongodb-password}" | base64 --decode)

To connect to your database, create a MongoDB&reg; client container:

    kubectl run --namespace ratingsapp ratings-mongodb-client --rm --tty -i --restart='Never' --env="MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD" --image docker.io/bitnami/mongodb:4.4.9-debian-10-r0 --command -- bash

Then, run the following command:
    mongo admin --host "ratings-mongodb" --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace ratingsapp svc/ratings-mongodb 27017:27017 &
    mongo --host 127.0.0.1 --authenticationDatabase admin -p $MONGODB_ROOT_PASSWORD

```


```bash

kubectl create secret generic mongosecret \
    --namespace ratingsapp \
    --from-literal=MONGOCONNECTION="mongodb://$USR_NAME:$USR_PASSWD@ratings-mongodb.ratingsapp:27017/ratingsdb"

kubectl get secret mongosecret -n ratingsapp -o json | jq '.data | map_values(@base64d)'

mkdir out
sed -e "s/<acrname>/$ACR_NAME/g" ratings-api-deployment.yaml > out/ratings-api-deployment.yaml

kubectl apply \
    --namespace ratingsapp \
    -f out/ratings-api-deployment.yaml

kubectl get pods \
    --namespace ratingsapp \
    -l app=ratings-api -w

kubectl get deployment ratings-api --namespace ratingsapp

kubectl apply \
    --namespace ratingsapp \
    -f out/ratings-api-service.yaml

kubectl get service ratings-api --namespace ratingsapp

kubectl get endpoints ratings-api --namespace ratingsapp

sed -e "s/<acrname>/$ACR_NAME/g" ratings-web-deployment.yaml > out/ratings-web-deployment.yaml

kubectl apply \
--namespace ratingsapp \
-f out/ratings-web-deployment.yaml

kubectl get pods --namespace ratingsapp -l app=ratings-web -w
kubectl get deployment ratings-web --namespace ratingsapp

kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-service.yaml

kubectl get service ratings-web --namespace ratingsapp -w

#// delete loadbalancer service to stop accepting requests to public endpoint
kubectl delete \
    --namespace ratingsapp \
    -f ratings-web-service.yaml

#// create private svc for ingress
kubectl apply \
    --namespace ratingsapp \
    -f ratings-web-service-pri.yaml

```