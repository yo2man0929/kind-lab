# Create a namespace to run cert-manager in
kubectl create namespace cert-manager

# Disable resource validation on the cert-manager namespace
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Install the CustomResourceDefinitions and cert-manager itself
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml

