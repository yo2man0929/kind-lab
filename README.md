# kind-lab

## Prerequisite

#### Install helm, docker, kubectl, envsbst before running the bootstrap scripts!

```
brew install gettext kubernetes-helm

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

brew link --force gettext

```

## This repo is a playground for testing the function of k8s with helm chart  *_kube-prometheus-stack_*

1. Apply your own slack webhook token on https://my.slack.com/services/new/incoming-webhook/ ， kube-prometheus-stack would use it to send alerts 
2. Create a file named monitor.env
3. Put your slack in a format like below

   `SLACK_API_URL=https://hooks.slack.com/services/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oauuVi `

4. Run the script `bootstrap.sh`
5. Append the setting to your /etc/hosts
```
127.0.0.1 myservicea.foo.org
127.0.0.1 grafana.foo.org
127.0.0.1 alertmanager.foo.org
127.0.0.1 promethues.foo.org


```
6. Wait theose pods to init, connect to those endpoint by its hostname

grafna password admin/admin



## Operation commands

#### Sanitize the lab at once
`kind delete cluster`


#### self-test scirpt
bash build-test.sh

