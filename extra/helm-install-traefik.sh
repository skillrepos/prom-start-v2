helm repo update
helm install traefik traefik/traefik -n traefik -f ~/prom-start/extra/traefik-values.yaml

