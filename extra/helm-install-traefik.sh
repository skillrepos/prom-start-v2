helm repo update
helm install traefik traefik/traefik -n traefik -f /workspaces/prom-start-v2/extra/traefik-values.yaml
while [[ $(kubectl get pods -n traefik -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
nohup kubectl port-forward -n traefik svc/traefik 35600:9100 >&/dev/null &

