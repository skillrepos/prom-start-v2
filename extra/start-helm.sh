helm upgrade prometheus-stack prometheus-community/kube-prometheus-stack --set prometheus.service.nodePort=30500 --set prometheus.service.type=NodePort --set grafana.service.nodePort=30600 --set grafana.service.type=NodePort

