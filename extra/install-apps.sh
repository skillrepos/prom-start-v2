kubectl create ns monitoring
wget https://get.helm.sh/helm-v3.9.2-linux-amd64.tar.gz
tar xvf helm-v3.9.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prom-start prometheus-community/prometheus -n monitoring --set server.service.nodePort=31000 --set server.service.type=NodePort
~/prom-start/extra/fixtmp2.sh
helm install grafana grafana/grafana -n monitoring --set service.type=NodePort --set service.nodePort=31750
kubectl -n monitoring patch svc prom-start-alertmanager --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":31500}]'
while [[ $(kubectl get pods prom-start-alertmanager-0 -n monitoring -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
kubectl label pod/prom-start-alertmanager-0 app=prometheus -n monitoring
kubectl label pod/prom-start-alertmanager-0 component=alertmanager -n monitoring
