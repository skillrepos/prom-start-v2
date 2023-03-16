sudo minikube stop
sudo minikube delete
sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.28.0/minikube-linux-amd64 && sudo chmod +x minikube && sudo cp minikube /usr/local/bin/ && sudo rm minikube
sudo minikube start --vm-driver=none --kubernetes-version=1.23.1
sudo mv /home/diyuser3/.kube /home/diyuser3/.minikube $HOME
sudo chown -R $USER $HOME/.kube $HOME/.minikube
sudo chown -R $USER $HOME/.minikube; chmod -R u+wrx $HOME/.minikube
kubectl create ns monitoring
wget https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz
tar xvf helm-v3.9.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin
helm install prom-start2 prometheus-community/kube-prometheus-stack -n monitoring --set prometheus.service.nodePort=31000 --set prometheus.service.type=NodePort


