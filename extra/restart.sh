echo ...Starting minikube
minikube start
while [[ $(kubectl get pods prom-start-alertmanager-0 -n monitoring -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
kubectl -n monitoring wait --timeout 180s pod --all --for=condition=Ready
echo ...Forwarding ports
nohup kubectl port-forward -n monitoring svc/prom-start-prometheus-server  35200:80 >&/dev/null &
nohup kubectl port-forward -n monitoring svc/prom-start-prometheus-node-exporter 35300:9100 >&/dev/null &
nohup kubectl port-forward -n monitoring svc/prom-start-alertmanager  35400:9093 >&/dev/null &
nohup kubectl port-forward -n monitoring svc/grafana 35500:80 >&/dev/null &
