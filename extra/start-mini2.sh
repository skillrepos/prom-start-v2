sudo minikube stop
sudo minikube start --vm-driver=none --addons=dashboard --kubernetes-version=v1.21.1
until [ -d /tmp/hostpath-provisioner/monitoring ]
do 
  sleep 5
done
echo "Directory found"
sudo chown -R 65534:65534 /tmp/hostpath-provisioner/monitoring
exit 

