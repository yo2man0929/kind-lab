#!/bin/bash
# Kind Lab - Kubernetes Test Environment Bootstrap Script
# This script sets up a complete Kind cluster with monitoring and ingress capabilities

set -euo pipefail

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function for logging
log() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

section() {
  echo -e "\n${YELLOW}=== $1 ===${NC}"
}

success() {
  echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Check if required tools are installed
for tool in docker kind kubectl helm envsubst; do
  if ! command -v $tool &> /dev/null; then
    echo "Error: $tool is required but not installed. Please install it first."
    exit 1
  fi
done

section "Building Container Image"
log "Building NGINX container image..."
docker build . -t nginx:dev

section "Creating Kind Cluster"
log "Setting up Kind cluster with ingress configuration..."
kind create cluster --wait 10m --config kind-config/kind-ingress-config.yaml
log "Loading NGINX image into Kind cluster..."
kind load docker-image nginx:dev

section "Deploying Application"
log "Creating application deployment and service..."
kubectl create -f app/app-deployment.yaml
kubectl create -f app/app-service.yaml

section "Setting Up Ingress Controller"
log "Installing NGINX ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
log "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

section "Installing Monitoring Stack"
log "Setting up kube-prometheus-stack with Slack alerting..."
# Use environment variables from monitor.env
if [ ! -f monitor.env ]; then
  echo "Warning: monitor.env file not found. Slack alerts won't be configured correctly."
  echo "Please create monitor.env with SLACK_API_URL=https://hooks.slack.com/services/YOUR_TOKEN"
  touch monitor.env
fi

log "Generating values file from template..."
bash kube-prometheus-stack-values.yaml.sh > kube-prometheus-stack-values.yaml 

log "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

log "Installing kube-prometheus-stack..."
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f kube-prometheus-stack-values.yaml 
rm -rf kube-prometheus-stack-values.yaml &> /dev/null

section "Setting Up Application Ingress"
log "Creating application ingress resources..."
kubectl apply -f app/app-ingress.yaml -n default
kubectl apply -f app/ingress-nginx-deployment.yaml -n ingress-nginx

section "Setup Complete"
success "Kind Lab is now set up!"
echo
echo "Add these entries to your /etc/hosts file:"
echo "127.0.0.1 myservicea.foo.org"
echo "127.0.0.1 grafana.foo.org"
echo "127.0.0.1 alertmanager.foo.org"
echo "127.0.0.1 prometheus.foo.org"
echo
echo "Access the services at:"
echo "- Application: http://myservicea.foo.org"
echo "- Grafana: http://grafana.foo.org (admin/admin)"
echo "- Alertmanager: http://alertmanager.foo.org"
echo "- Prometheus: http://prometheus.foo.org"
echo
echo "To clean up the environment: kind delete cluster"
