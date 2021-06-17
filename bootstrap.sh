#! /bin/bash
set -ex
if !(docker images nginx:dev)  ; then
    docker build .  -t nginx:dev
fi
# set up kind cluster
kind create cluster --wait 10m --config kind-ingress-config.yaml
kind load docker-image nginx:dev
# run app svc and deployment
kubectl create -f app-deployment.yaml
kubectl create -f app-service.yaml
# install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
# install monitoring
bash kube-prometheus-stack-values.yaml.sh > kube-prometheus-stack-values.yaml 
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f kube-prometheus-stack-values.yaml 
rm -rf kube-prometheus-stack-values.yaml &> /dev/null
# install cert-manager
bash -x install-cert-manager.sh
# install app-ingress
kubectl apply -f app-ingress.yaml -n default
