#!/bin/bash
# Kubernetes Testing Environment - Test Script
# This script sets up a Kind cluster and tests the basic functionality

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function for logging
log() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR] $1${NC}"
  exit 1
}

success() {
  echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Function to check tool availability
check_tool() {
  if ! command -v $1 &> /dev/null; then
    log "Installing $1..."
    case $1 in
      kind)
        curl -sL https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 -o /tmp/kind
        chmod 755 /tmp/kind
        sudo mv /tmp/kind /usr/local/bin/
        ;;
      kubectl)
        curl -sL https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/linux/amd64/kubectl -o /tmp/kubectl
        chmod 755 /tmp/kubectl
        sudo mv /tmp/kubectl /usr/local/bin/
        ;;
      helm)
        curl -fsSL https://get.helm.sh/helm-v3.11.0-linux-amd64.tar.gz -o /tmp/helm.tar.gz
        tar -xzf /tmp/helm.tar.gz -C /tmp
        sudo mv /tmp/linux-amd64/helm /usr/local/bin/
        rm -rf /tmp/helm.tar.gz /tmp/linux-amd64
        ;;
      *)
        error "Unknown tool: $1"
        ;;
    esac
  fi
}

# Check for required tools
log "Checking for required tools..."
check_tool kind
check_tool kubectl
check_tool helm

# Show versions
log "Tool versions:"
kind version
kubectl version --client=true
helm version

# Create Kind cluster
log "Creating Kind cluster..."
if ! kind create cluster --wait 10m --config kind-config/kind-config.yaml; then
  error "Failed to create Kind cluster"
fi

log "Cluster created successfully. Nodes:"
kubectl get nodes

# Build and load the Docker image
log "Building and loading Docker image..."
docker build -t nginx:dev .
kind load docker-image nginx:dev

# Deploy the application
log "Deploying application..."
kubectl apply -f app/app-deployment.yaml
kubectl apply -f app/app-service.yaml

# Wait for deployment to be ready
log "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/nginx-deployment

# Get the NodePort
NODE_PORT=$(kubectl get svc nginx-service -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')
log "Service NodePort: $NODE_PORT"

# Wait for pod to be ready
log "Waiting for service to be accessible..."
sleep 10

# Test the service
log "Testing the service..."
SUCCESS=$(curl -s 127.0.0.1:$NODE_PORT)
if [[ "${SUCCESS}" != "Hello World" ]]; then
  kind delete cluster
  error "Service test failed. Expected 'Hello World', got '${SUCCESS}'"
else
  success "Service test successful!"
fi

# Clean up
log "Cleaning up cluster..."
kind delete cluster

success "All tests completed successfully!" 