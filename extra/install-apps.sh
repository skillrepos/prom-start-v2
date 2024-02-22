echo ...Removing any old minikube instances
minikube delete
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
kubectl -n monitoring wait --timeout 180s pod --all --for=condition=Ready
echo ...Forwarding ports
nohup kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus  35200:9090 &
nohup kubectl port-forward -n monitoring svc/monitoring-prometheus-node-exporter 35300:9100 &
nohup kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager  35400:9093 &
nohup kubectl port-forward -n monitoring svc/monitoring-grafana 35500:80 &

