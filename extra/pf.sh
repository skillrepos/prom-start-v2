kubectl port-forward $(kubectl get pods --selector=app.kubernetes.io/name=grafana -n monitor --output=jsonpath="{.items..metadata.name}") -n monitor 3000 &
echo grafana port forward pid=$!
kubectl port-forward $(kubectl get pods --selector=app.kubernetes.io/name=kube-state-metrics -n monitor --output=jsonpath="{.items..metadata.name}") -n monitor 3100 &
echo kube state metrics pid=$!
kubectl port-forward -n monitor prometheus-prometheus-operator-prometheus-0 9090 &
echo prometheus operator pid=$!



