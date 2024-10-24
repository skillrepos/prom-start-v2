#!/bin/bash

# Timeout in seconds (adjust as needed)
TIMEOUT=60

# Check if Docker is available
while ! docker info >/dev/null 2>&1; do
  if [ $TIMEOUT -le 0 ]; then
    echo "Timeout: Docker is not available."
    exit 1
  fi

  echo "Waiting for Docker..."
  sleep 1
  TIMEOUT=$((TIMEOUT - 1))
done

echo "Docker is available!"
echo ...Removing any old minikube instances
minikube delete
echo ...Starting minikube
minikube start
echo ...Creating namespace
kubectl create ns monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prom-start prometheus-community/prometheus -n monitoring
helm install grafana grafana/grafana -n monitoring
echo ...Waiting on resources to be ready
while [[ $(kubectl get pods prom-start-alertmanager-0 -n monitoring -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
kubectl -n monitoring wait --timeout 180s pod --all --for=condition=Ready
kubectl label pod/prom-start-alertmanager-0 app=prometheus -n monitoring
kubectl label pod/prom-start-alertmanager-0 component=alertmanager -n monitoring
echo ...Forwarding ports
nohup kubectl port-forward -n monitoring svc/prom-start-prometheus-server  35200:80 >&/dev/null &
nohup kubectl port-forward -n monitoring svc/prom-start-prometheus-node-exporter 35300:9100 >&/dev/null &
nohup kubectl port-forward -n monitoring svc/prom-start-alertmanager  35400:9093 >&/dev/null &
nohup kubectl port-forward -n monitoring svc/grafana 35500:80 >&/dev/null &

