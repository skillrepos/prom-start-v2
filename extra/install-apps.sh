echo ...Starting minikube
minikube start
echo ...Creating namespace
kubectl create ns monitoring
echo ...Adding prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo ...Installing Prometheus
helm install prom-start prometheus-community/prometheus -n monitoring --set server.service.nodePort=31000 --set server.service.type=NodePort
~/prom-start/extra/fixtmp2.sh
echo ...Installing Grafana
helm install grafana grafana/grafana -n monitoring --set service.type=NodePort --set service.nodePort=31750
echo ...Updating
kubectl -n monitoring patch svc prom-start-alertmanager --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31500}]'
while [[ $(kubectl get pods prom-start-alertmanager-0 -n monitoring -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
kubectl label pod/prom-start-alertmanager-0 app=prometheus -n monitoring
kubectl label pod/prom-start-alertmanager-0 component=alertmanager -n monitoring
echo ...Forwarding ports
kubectl port-forward -n monitoring svc/prom-start-prometheus-server :80 &
kubectl port-forward -n monitoring svc/prom-start-prometheus-node-exporter :9100 &
