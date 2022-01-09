
result=`kubectl get pods -n $1 | grep mysql | cut -d' ' -f1`
echo $result
kubectl -n $1 exec -it $result -- mysql -uadmin -padmin -e 'INSERT INTO agents VALUES ("6", "Woody Woodpecker","bird","1959-05-22","1979-04-15","Buzz Buzzard","menacing stare")' registry


