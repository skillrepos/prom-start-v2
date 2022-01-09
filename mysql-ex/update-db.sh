
result=`kubectl get pods -n $1 | grep mysql | cut -d' ' -f1`
echo $result
kubectl -n $1 exec -it $result -- mysql -uroot -proot+1 -e 'CREATE USER "exporter" IDENTIFIED BY "admin"; GRANT PROCESS, REPLICATION CLIENT, REPLICATION SLAVE, SELECT ON *.* TO "exporter"; flush privileges;' 


