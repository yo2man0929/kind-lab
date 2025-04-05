# Kind Lab - Kubernetes Testing Environment

A lightweight Kubernetes development environment using Kind (Kubernetes in Docker) with built-in monitoring stack and ingress capabilities.

## Overview

This repository provides a playground for testing Kubernetes functions with the following components:

- Kind cluster configuration
- NGINX ingress controller
- Prometheus monitoring stack (kube-prometheus-stack)
- Slack alerting integration
- Sample application deployment

## Prerequisites

Before running the bootstrap scripts, ensure you have the following tools installed:

### For macOS:

```bash
# Install Helm and gettext
brew install gettext kubernetes-helm

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Ensure gettext is linked
brew link --force gettext

# Install Kind
brew install kind
```

### For Linux:

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
```

## Setup Instructions

1. **Configure Slack Webhook for Alerts**

   - Create a webhook at: https://my.slack.com/services/new/incoming-webhook/
   - Create a file named `monitor.env` with your webhook URL:
     ```
     SLACK_API_URL=https://hooks.slack.com/services/YOUR_WEBHOOK_PATH
     ```

2. **Run the bootstrap script**

   ```bash
   bash bootstrap.sh
   ```

3. **Configure Local Hostnames**
   Add the following entries to your `/etc/hosts` file:

   ```
   127.0.0.1 myservicea.foo.org
   127.0.0.1 grafana.foo.org
   127.0.0.1 alertmanager.foo.org
   127.0.0.1 prometheus.foo.org
   ```

4. **Wait for Pod Initialization**
   Run this command to check pod status:

   ```bash
   kubectl get pods --all-namespaces
   ```

5. **Access the Services**
   - Sample application: http://myservicea.foo.org
   - Grafana: http://grafana.foo.org (Username: admin, Password: admin)
   - Alertmanager: http://alertmanager.foo.org
   - Prometheus: http://prometheus.foo.org

## Operational Commands

### Run Self-test Script

```bash
bash build-test.sh
```

### Clean Up the Environment

```bash
kind delete cluster
```

## Project Structure

```
.
├── app/                          # Application definitions
│   ├── app-deployment.yaml       # Sample app deployment
│   ├── app-ingress.yaml          # Ingress configuration
│   ├── app-service.yaml          # Service definition
│   └── ingress-nginx-deployment.yaml # NGINX ingress controller config
├── kind-config/                  # Kind cluster configuration
│   ├── kind-config.yaml          # Basic cluster config
│   └── kind-ingress-config.yaml  # Ingress-enabled config
├── bootstrap.sh                  # Main setup script
├── build-test.sh                 # Testing script
├── Dockerfile                    # Sample app container definition
├── kube-prometheus-stack-values.template # Monitoring stack template
└── README.md                     # This documentation
```

## Troubleshooting

- If services are not accessible, check ingress status:

  ```bash
  kubectl get ingress --all-namespaces
  ```

- If monitoring alerts aren't working, verify the Slack webhook:
  ```bash
  kubectl get secret -n default
  ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
