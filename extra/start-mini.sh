sudo minikube stop
sudo minikube delete
sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.28.0/minikube-linux-amd64 && sudo chmod +x minikube && sudo cp minikube /usr/local/bin/ && sudo rm minikube
sudo minikube start --vm-driver=none --kubernetes-version=1.23.1
sudo mv /home/diyuser3/.kube /home/diyuser3/.minikube $HOME
sudo chown -R $USER $HOME/.kube $HOME/.minikube
sudo chown -R $USER $HOME/.minikube; chmod -R u+wrx $HOME/.minikube
./extra/install-apps.sh

