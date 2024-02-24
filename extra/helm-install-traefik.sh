helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik -n traefik -f /workspaces/prom-start-v2/extra/traefik-values.yaml

