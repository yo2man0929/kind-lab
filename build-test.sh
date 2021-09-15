#! /bin/bash
set -xe
if !(which kind) ; then
    curl -sL https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64 -o /usr/local/bin/kind
    chmod 755 /usr/local/bin//kind
fi
if !(which kubectl) ; then
    curl -sL https://storage.googleapis.com/kubernetes-release/release/v1.17.4/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
    chmod 755 /usr/local/bin//kubectl
fi
if !(which helm) ; then
    curl -LO https://get.helm.sh/helm-v3.1.2-linux-amd64.tar.gz
    tar -xzf helm-v3.1.2-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/
    rm -rf helm-v3.1.2-linux-amd64.tar.gz
fi
kind version
kubectl version --client=true
helm version

kind create cluster --wait 10m --config kind-config/kind-config.yaml

kubectl get nodes

docker build -t nginx:dev .
kind load docker-image nginx:dev

kubectl apply -f app/app-deployment.yaml
kubectl apply -f app/app-service.yaml

NODE_PORT=$(kubectl get svc nginx-service -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')
sleep 60
SUCCESS=$(curl 127.0.0.1:$NODE_PORT)
if [[ "${SUCCESS}" != "Hello World" ]]; 
then
 kind -q delete cluster
 exit 1;
else
 kind -q delete cluster
 echo "Component test succesful"
fi
