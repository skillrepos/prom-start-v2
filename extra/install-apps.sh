echo ...Starting minikube
minikube start
echo ...Creating namespace
kubectl create ns monitoring
echo ...Adding prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo ...Installing Prometheus and Grafana
helm install -n monitoring monitoring --version="38.0.3" prometheus-community/kube-prometheus-stack --set prometheusOperator.admissionWebhooks.failurePolicy=Ignore
echo ...Waiting on resources to be ready
kubectl -n monitoring wait pod --all --for=condition=Ready
echo ...Forwarding ports
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus  :9090 &
kubectl port-forward -n monitoring svc/monitoring-prometheus-node-exporter :9100 &
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager  :9093 &
kubectl port-forward -n monitorning svc/monitoring-grafana :80 &
