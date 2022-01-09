helm repo update
helm install mysql-exporter prometheus-community/prometheus-mysql-exporter --namespace monitoring  -f values.yaml -f secret.yaml

