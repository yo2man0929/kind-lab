export $(cat monitor.env | xargs) 
envsubst < kube-prometheus-stack-values.template 
