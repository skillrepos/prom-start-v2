kubectl port-forward $(kubectl get pods --selector=app.kubernetes.io/name=prometheus-mysql-exporter -n monitoring --output=jsonpath="{.items..metadata.name}") -n monitoring 9104 &




