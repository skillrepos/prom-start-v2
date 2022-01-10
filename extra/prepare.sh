git stash
git pull
until [ -d /tmp/hostpath-provisioner/monitoring ]
do 
  sleep 5
done
echo "Directory found"
sudo chown -R 65534:65534 /tmp/hostpath-provisioner/monitoring
exit
