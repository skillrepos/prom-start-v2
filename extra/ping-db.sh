#!/bin/bash
result=`kubectl get pods -n $1 | grep mysql | cut -d' ' -f1`
echo $result
counter=$2
offset=$2
sleepval=$3
echo admin | kubectl -n $1 exec -it $result -- mysql_config_editor set --login-path=local --host=localhost --user=admin --password &> /dev/null
while [ $counter -gt 0 ]
do
   iteration=$(( $offset - $counter + 1 )) 
   echo Iteration $iteration

   kubectl -n $1 exec -it $result -- mysql -sN -uadmin -padmin -e 'SELECT * FROM agents ORDER BY RAND() LIMIT 1' registry 2> /dev/null 
   counter=$(( $counter - 1 ))
   echo Waiting $sleepval seconds
   sleep $sleepval
done
echo DONE: Completed $2 iterations.
