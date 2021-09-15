#! /bin/bash
set -euo pipefail
[[ $(docker images nginx:dev | wc -l) -ge 2 ]] || docker build . -t nginx:dev

# set up kind cluster
kind create cluster --wait 10m --config kind-config/kind-ingress-config.yaml
kind load docker-image nginx:dev

# run app svc and deployment in kind
kubectl create -f app/app-deployment.yaml
kubectl create -f app/app-service.yaml

# install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# install monitoring using ensubst to render variables
bash kube-prometheus-stack-values.yaml.sh > kube-prometheus-stack-values.yaml 
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f kube-prometheus-stack-values.yaml 
rm -rf kube-prometheus-stack-values.yaml &> /dev/null

# install app-ingress
kubectl apply -f app/app-ingress.yaml -n default
kubectl apply -f app/ingress-nginx-deployment.yaml -n ingress-nginx
