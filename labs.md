# Getting Started with Prometheus
## Monitoring Kubernetes Infrastructure and Applications for Reliability
## Session labs 
## Revision 2.4 - 10/24/24

**Startup IF NOT ALREADY DONE! (This will take several minutes to run and there will be some error/warning messages along the way.)**
```
extra/install-apps.sh
```
**Accessing running apps***

As part of the startup process, the various apps we'll be using (Prometheus, Grafana, etc.) have been started and setup for you.
You can see them listed in the **PORTS** tab (accessible in the same row of the Codespace as **TERMINAL**). 

To open one of those applications in a separate browser tab for use in the class, click on the *globe* icon in the column under **Forwarded Address**. (See screenshot)
For all but Grafana, you can also open them in a smaller *preview* window in the Codespace by clicking on the *split square* icon to the right of the *globe* one.

![Accessing apps through PORTS tab](./images/promstart5.png?raw=true "Accessing apps through PORTS tab")

**NOTE: If you need to restart your codespace, run the *extra/restart.sh* script to get things running again.**

**NOTE: To copy and paste in the codespace using the mouse, you will need to hold down the 'Shift' key while you click 'Copy' or 'Paste'. Alternatively, you can use the keyboard commands - CTRL+C and CTRL+V.**

**Lab 1 - Monitoring with Prometheus**

**Purpose: In this lab, we’ll run an instance of the node exporter and use Prometheus to surface basic data and metrics.**

1.	For this lab, we have already setup an instance of the Prometheus Community edition main server running in a namespace in our cluster named *monitoring*.  Take a quick look at the different pieces that we have running there since we installed the prometheus-community/prometheus helm chart. Run the command below in the terminal. (We have an alias "k" for the Kubernetes command line tool "kubectl".)

```
k get all -n monitoring
```		

2.	 Notice that we have both Prometheus itself and the node exporter piece running there (among others).  Let's take a look at the Prometheus dashboard in the web browser.  Click on the PORTS tab, and find the row labeled **Prometheus**. Then hover over the **Forwarded Address** section, and click on the *globe* icon to open the application in a browser tab. 

![Opening Prometheus](./images/promstart7.png?raw=true "Opening Prometheus")

![Prometheus](./images/promstart8.png?raw=true "Prometheus")

3.	Now, lets open up the node exporter's metrics page and look at the different information on it.  (Note that we only have one node on this cluster.) To open that page, go back to the codespace and follow the same process as for the Prometheus app for the Node Exporter link (**PORTS-> Node Exporter -> Open in Browser**). Then click on the **Metrics** link on the browser screen that comes up. Once on that page, scan through some of the metrics that are exposed by this exporter.  Then see if you can find the "total number of network bytes received" on device "lo". (Hint: look for this metric **node_network_receive_bytes_total{device="lo"}**).

![Opening Node Exporter](./images/promstart9.png?raw=true "Opening Node Exporter")

![Node Exporter](./images/promstart10.png?raw=true "Node Exporter")


<br>
4.	Now, let's see which targets Prometheus is automatically scraping from the cluster.  Switch back to the Prometheus application's tab in your browser.  Back in the top menu (dark bar) on the main Prometheus page tab, select Status and then Targets. Search for **cadvisor** or scroll through the screen to find cadvisor.  Then see if you can find how long ago the last scraping happened, and how long it took for the **kubernetes-nodes-cadvisor** target. 

![Targets](./images/promstart15.png?raw=true "Targets")
 
5.	Let's setup an application in our cluster that has a built-in Prometheus metrics exporter - *traefik* - an ingress. Switch back to the codespace. The Helm chart is already loaded for you. So, we just need to create a namespace for it and run a script to deploy it.  In the terminal, run the commands below. After a few moments, you should be able to see things running in the *traefik* namespace. (You will see some *waiting* messages - this is ok.)

```
k create ns traefik
extra/helm-install-traefik.sh 
k get all -n traefik
```

6.	After a minute or two, you should now be able to see the metrics area that Traefik exposes for Prometheus as a pod endpoint.  In the tab where Prometheus is loaded, take a look in the **Status -> Targets** area of Prometheus and see if you can find it. You can enter "traefik" in the search box or use Ctrl-F/CMD-F to try to find the text **traefik**.  Note that this is the pod endpoint and not a standalone target.  (If you don't find it, see if the **kubernetes-pods (1/1 up)** has a *show more* button next to it. If so, click on that to expand the list.) If you don't see this, wait a bit, then refresh the browser and try again. 

![traefik in targets](./images/promstart61.png?raw=true "traefik in targets") 
![traefik in targets](./images/promstart16.png?raw=true "targets")
 

7.	While we can find it as a pod endpoint, we don't yet have the traefik metrics established as a standalone "job" being monitored in Prometheus. You can see this because there is no section specifically for "traefik (1/1 up)" in the Targets page.  Also, Traefik is not listed if you check the Prometheus service-discovery page under **Status->Service Discovery**.
 

8.	So we need to tell Prometheus about traefik as a job.  There are two ways.  One way is just to apply two annotations to the service for the target application. However, this will not work with more advanced versions of Prometheus. So, we'll do this instead by updating a configmap that the Prometheus server uses to get job information out of. Back in the codespace, let's take a look at what has to be changed to add this job.  We have a "before" and "after" version in the extra directory. We'll use the built-in code diff tool to see the differences. Run the following in the terminal.

```
cd extra  
code -d ps-cm-with-traefik.yaml ps-cm-start.yaml
``` 

![Traefik change compare](./images/promstart12.png?raw=true "Traefik change compare")
 
9.	This will bring up a visual side-by-side diff for the file. It's easy to see the difference here.  When you're done viewing, just go ahead and click on the X to the right of the name to close the diff. Now we'll apply the new configmap definition with our additional job. (Ignore the warning.)

```
k apply -n monitoring -f ps-cm-with-traefik.yaml 
```
      
10.	 Now, after a few minutes, if you go back to the Prometheus session and refresh and look at the **Status->Targets** page in Prometheus and the **Service Discovery** page and filter via "traefik" in the search bar or do a Ctrl-F/CMD+F to search for **traefik**, you should find that the new item shows up as a standalone item on both pages. (It will take some time for the traefik target to reach (1/1 up) in the targets page, so you may have to wait, refresh and repeat until it shows up.)

![Traefik in targets](./images/promstart18.png?raw=true "Traefik in targets")
![Traefik in service discovery](./images/promstart17.png?raw=true "Traefik in service discovery")

11. (Optional) If you want to see the metrics generated by traefik, you can open up the app from the PORTS page (**Traefik metrics row**) and add **/metrics** at the end of the URL once the page has opened.  (There will be a 404 there until you add the **/metrics** part.)

![Traefik metrics](./images/promstart19.png?raw=true "Traefik metrics")
 
<p align="center">
**[END OF LAB]**
</p>

**Lab 2 - Deploying a separate exporter for an application**

**Purpose:  In this lab, we’ll see how to deploy a separate exporter for a mysql application running in our cluster.**

1.	We have a simple webapp application with a mysql backend that we're going to run in our cluster.  The application is named "roar" and we have a manifest with everything we need to deploy it into our cluster.  Go ahead and deploy it now.

```
cd /workspaces/prom-start-v2/roar-k8s
k create ns roar
k apply -f roar-complete.yaml
nohup kubectl port-forward -n roar svc/roar-web 31790:8089 >&/dev/null &
```

2.	After a few moments, you can go to the **PORTS** tab, find the row for **ROAR Sample App (31790)** and click on the globe icon to open in the browser tab **or** click on the two-column icon to view the running application in a preview tab .  You will need to add **/roar** onto the end of the URL to see the actual app. (**NOTE: If you can't get to the app, wait a few moments and then run the last line from step 1 "nohup kubectl port-forward..."  again.**)

![Preview roar application](./images/promstart13.png?raw=true "Preview roar application")

3.	Since we are using mysql on the backend, we'd like to be able to get metrics on that.  Let's see if there's already a mysql exporter available. The best place to look if you're using the Prometheus community edition is in the helm charts area of that. Open a browser tab to https://github.com/prometheus-community/helm-charts/tree/main/charts.  Notice that there's a prometheus-mysql-exporter chart.  You can click on that and look at the README.md for it.
 
 ![mysql exporter](./images/promstart14.png?raw=true "mysql exporter")

4.	As part of the configuration for this, we need to setup a new user with certain privileges in the database that's running for our backend. For simplicity, I've provided a simple script that you can run for this.  You can take a look at the script to see what it does and then run it to add the user and privileges. (Note that it requires the namespace as an argument to be passed to it.) This script and other files are in a different directory under prom-start-v2 named **mysql-ex**. For the last command, we are supplying as an argument the namespace where the database is running.

```
cd /workspaces/prom-start-v2/mysql-ex
cat update-db.sh
./update-db.sh roar  
```
<br>
5.	Now we are ready to deploy the mysql helm chart to get our mysql exporter up and running.  To do this we need to supply a values.yaml file that defines the image we want to use, a set of metrics "collectors" and the pod to use (via labels).  We also have a data file for a secret that is required with information on the service, user, password, and port that we want to access.  Take a look at those files.

```
cat values.yaml
cat secret.yaml
```
<br>
6.	Now we can go ahead and deploy the helm chart for the exporter with our custom values.  For convenience, there is a script that runs the helm install.  After a few moments you should be able to see things spinning up in the monitoring namespace.

```
./helm-install-mysql-ex.sh
k get all -n monitoring | grep mysql
```
<br>

7.	Finally, to connect up the pieces, we need to define a job for Prometheus. We can do this the same way we did for Traefik in Lab 1. To see the changes, you can look at a diff between the configmap definition we used for Traefik and one we already have setup with the definition for the mysql exporter. You can click the **X** to the right of the name when done.

```
code -d ps-cm-with-mysql.yaml ../extra/ps-cm-with-traefik.yaml
```
 ![mysql diffs](./images/promstart64.png?raw=true "mysql diffs")
<br> 

8.	Now you can apply the updated configmap definition.

```
k apply -n monitoring -f ps-cm-with-mysql.yaml
```
<br>

9.	Switching back to the application, you should now be able to see the mysql item in the **Prometheus Targets** page and also in the **Service Discovery** page. (Again, it may take a few minutes for the mysql target to appear and reach (1/1 up).)

 ![mysql exporter in targets](./images/promstart21.png?raw=true "mysql exporter in targets")
 ![mysql exporter in service discovery](./images/promstart20.png?raw=true "mysql exporter in service discovery")
<br> 

10.	 (Optional) If you want to see the metrics that are exposed by this job, there is a small script named pf.sh (in mysql-ex) that you can run to setup port-forwarding for the mysql-exporter.  Then you can look in the browser via the location from the PORTS tab.

$ ./pf.sh

![mysql exporter metrics](./images/promstart22.png?raw=true "mysql exporter metrics")

<p align="center">
**[END OF LAB]**
</p>

**Lab 3 -  Writing queries with PromQL**

**Purpose:  In this lab, we’ll see how to construct queries with the PromQL language.**

**NOTE: If you encounter a situation where you are not getting the metrics from mysql showing up in Prometheus but they were before, try re-running step 4 from the previous lab (with update-db.sh) to make sure the admin setup is still in place.**

1.	We're now going to turn our attention to creating queries in the Prometheus interface using Prometheus' built-in query language, PromQL.  First, to get ready for this, in the browser that is running the Prometheus interface, switch back to the main Prometheus window by clicking on "Prometheus" in the dark line at the top.  Once there, click to enable the five checkboxes under the main menu.

![selecting options](./images/promstart23.png?raw=true "selecting options")

2.	There are a couple of different ways to find available metrics to choose from in Prometheus. One way is to click on the query explorer icon next to the blue **Execute** button on the far right. Click on that and you can scroll through the list that pops up.  You don't need to pick any right now and you can close it (via the **X** in the upper right) when done.
 
![metrics explorer](./images/promstart24.png?raw=true "metrics explorer")

3.	Another way to narrow in quickly on a metric you're interested in is to start typing in the **Expression** area and pick from the list that pops-up based on what you've typed. Try typing in the names of some of the applications that we are monitoring and see the metrics available.  For example, you can type in **con** to see the ones for containers, **mysql** to see the ones for mysql, and so on. You don't need to select any right now, so once you are done, you can clear out the Expression box.
 
![mysql metrics](./images/promstart25.png?raw=true "mysql metrics")

4.	Now, let's actually enter a metric and execute it and see what we get.  Let's try a simple *time series* one.  In the Expression box, type in *node_cpu_seconds_total*. As the name may suggest to you, this is a metric provided by the node exporter and tracks the total cpu seconds for the node. In our case, we only have one node.  After you type this in, click on the blue **Execute** button at the far right to see the results.  

```
node_cpu_seconds_total
```

![node_cpu_seconds_total metric](./images/promstart26.png?raw=true "node_cpu_seconds_total metric")


5.	Notice that we have a lot of rows of output from this single query.  If you look closely, you can see that each row is different in some aspect, such as the cpu number or the mode. Rows of data like this are not that easy to digest. Instead, it is easier to visualize with a graph. So, click on the **Graph** link above the rows of data to see a visual representation.  You can then move your cursor around and get details on any particular point on the graph.  Notice that there is a color-coded key below the graph as well.

 ![metrics graph](./images/promstart27.png?raw=true "metrics graph")

6.	What if we want to see only one particular set of data?  If you look closely at the lines below the graph, you'll see that each is qualified/filtered by a set of *labels* within { and }.  We can use the same syntax in the Expression box with any labels we choose to pick which items we see.  Change your query to the one below and then click on Execute again to see a filtered graph. (Notice that Prometheus will offer pop-up lists to help you fill in the syntax if you want to use them.) After you click Execute, you will see a single data series that increases over time.

```
node_cpu_seconds_total{cpu="0",mode="user"}  
```
![individual metric](./images/promstart28.png?raw=true "individual metric")

7.	So far we have used counters in our queries - a value that increases (or can be reset to 0) as indicated by the *total* in the name.  However, there are other kinds of time series such as *gauges* where values can go up or down.  Let's see an example of one of those. Change your query to the expression below and then click the blue Execute button again.

```
node_memory_Active_bytes
```

![gauge metric](./images/promstart29.png?raw=true "gauge metric")

8.	Let's look at queries for another application. Suppose we want to monitor how much applications are referencing our database and doing "select" queries. We could use a mysql query to see the increase over time.  Enter the query below in the query area and then click on Execute. A screenshot below shows what this should look like.

```
mysql_global_status_commands_total{command=~"(select)"}
```
 
 ![mysql select metric 1](./images/promstart30.png?raw=true "mysql select metric 1")


9.	Now let's simulate some query traffic to the database.  I have a simple shell script that randomly queries the database in our application x times while waiting a certain interval between queries. It's called ping-db.sh.  Run this in a terminal for 30 times with an interval of 1 second per the command below. Then go back and refresh the graph again by clicking on the blue Execute button. (Note that you may need to wait a bit and refresh again to see the spike.)

```
../extra/ping-db.sh roar 30 1
```

![select spike](./images/promstart31.png?raw=true "select spike")

10.	After clicking on the Execute button to refresh, you should see a small spike on the graph from our monitoring. (It may take a minute for the monitoring to catch up.) This is something we could key off of to know there was a load, but it will always just be an increasing value. Let's focus in on a smaller timeframe so we can see the changes easier.  In the upper left of the Prometheus Graph tab, change the interval selector down to 10m. (Note that you can type in this field too.)
 
![decrease timeframe](./images/promstart33.png?raw=true "decrease timeframe") 

11.	What we really need here is a way to detect any significant increase over a point in time regardless of the previous value.  We can use the rate function we saw before for this. Change the query in Prometheus to be one that shows us the rate of change over the last 5 minutes and click on the Execute button again.

```
rate(mysql_global_status_commands_total{command=~"(select)"}[5m])
```

12.	After clicking on the Execute button to refresh, you should see a different representation of the data. After you refresh, you'll be able to see that we no longer just see an increasing value, we can see where the highs and lows are.  
 
![rate over 5](./images/promstart34.png?raw=true "rate over 5") 

<p align="center">
**[END OF LAB]**
</p>


**Lab 4 -  Alerts and AlertManager**

**Purpose:  In this lab, we'll see how to construct some simple alerts for Prometheus based on queries and conditions, and use AlertManager to see them.**

1.	Let's  suppose that we want to get alerted when the *select* traffic spikes to high levels. We have a working *rate* query for our mysql instance which gives us that information from the last lab. Take another look at that one to refresh your memory.  Now let's change it to only show when our rate is above .35.  And let's also change it to use a scale of 0 to 100.  We do this by multiplying the result by 100.   Change the query to add the multiplier and **> 30** at the end and click on the blue **Execute** button. The query to use is shown below.

```
rate(mysql_global_status_commands_total{command=~"(select)"}[5m]) * 100 > 30
```

2.	After clicking on the Execute button to refresh, you will probably see an empty query result on the page.  This is because we are targeting a certain threshold of data and that threshold hasn't been hit in the time range of the query (5 minutes).  To have some data to look at, let's run our program to simulate the load again with the rate query in effect. Back in the codespace's terminal, execute the same script we used before with 30 iterations and a 2 second wait in-between. 

```
../extra/ping-db.sh roar 30 2
```

3.	After a couple of minutes and a couple of refreshes, you'll be able to see that we no longer just see an increasing value, we can see where the highs and lows are.  

![rate + multiplier](./images/promstart35.png?raw=true "rate + multiplier") 
 
4.	While we can monitor by refreshing the graph and looking at it, it would work better to have an alert setup for this.  Let's see what alerts we have currently.  Switch to the alerts tab of Prometheus by clicking on "Alerts" in the dark bar at the top. Currently, you wil not see any configured.

![no alerts](./images/promstart36.png?raw=true "no alerts") 
 
5.	Now let's configure some alert rules.  We already have a configmap with some basic rules in it. Back in the terminal, "cat" the file extra/ps-cm-with-rules.yaml with the grep command and look at the "alerting-rules.yml" definition under "data:". 

```
cd /workspaces/prom-start-v2/extra 
cat ps-cm-with-rules.yaml | grep -A20 alerting_rules.yml:
```

6.	Now, go ahead and apply that configmap definition. Then refresh your view of the Alerts and you should see a set of alerts that have been defined. 

```
k apply -n monitoring -f ps-cm-with-rules.yaml
``` 

7.   This will take a few minutes to be picked up. You can then go back to the **Alerts** screen, **refresh it** and expand those to see the alert definitions. Notice that each alert uses a PromQL query like we might enter in the main Prometheus query area.

![alert rules](./images/promstart37.png?raw=true "alert rules") 
 

8.	Let's add some custom alert rules for a group for mysql. These will follow a similar format as the other rules but using mysql PromQL queries, names, etc. There is already a file with them added - ps-cm-with-rules2.yaml. You can do a diff on that and our previous version of the cm data to see the new rules. (This is in the *extra* directory.)

```
code -d ps-cm-with-rules2.yaml ps-cm-with-rules.yaml
```

![alert rules diff](./images/promstart38.png?raw=true "alert rules diff") 
 
9.	When you're done, just close the diff tab. Now, let's apply the updated configmap manifest and add the new mysql alerts. Then refresh the Alerts view (and after a period of time) you should see the new mysql rules.

```
k apply -n monitoring -f ps-cm-with-rules2.yaml
``` 

![new alert rules](./images/promstart39.png?raw=true "new alert rules") 

10.	Let's see if we can get our alert to fire now. Run our loading program to simulate the load again with the rate query in effect. Execute the same script we used before again with 60 iterations and a 0.5 second wait in-between. 

```
/workspaces/prom-start-v2/extra/ping-db.sh roar 60 0.5
```

11.	After this runs, refresh Prometheus in the browser. Then, on the Alerts tab, you should be able to see that the alert was fired. You can expand it to see details.
   
![alert firing](./images/promstart40.png?raw=true "alert firing")

12. Now, that our alert has fired, we should be able to see it in the Alert Manager application.  On this machine, it is exposed at node port 35500.  Open up that location up via the row in the PORTS tab and take a look.
 
![alert manager](./images/promstart41.png?raw=true "alert manager")
 
<p align="center">
**[END OF LAB]**
</p>

**Lab 5 - Grafana**

**Purpose:  In this lab, we'll see how to use Grafana to display custom graphs and dashboards for Prometheus data.**

1.	For this lab, we need to get the default password that was created when Grafana was installed. Run the command "get-gf-pass.sh" to retrieve it and then copy the password that is displayed.

```
/workspaces/prom-start-v2/extra/get-gf-pass.sh
```

2.	We already have an instance of Grafana running on this system at port 35500. Open up a browser to that page via the row in the PORTS tab.  The default admin userid is *admin*.   The password will be the one that was echoed to your screen from step 1.  Just enter/paste the output from that step into the password field.

![grafana login](./images/promstart43.png?raw=true "grafana login")
 

3.	Let's  first add our Prometheus instance as a Data Source.  Click on the *3 bar* menu at the top left and then select **Connections** and then **Data Sources** from the left menu.  Then click on the blue button for **Add data source**.  
 
![add data source](./images/promstart59.png?raw=true "add data source")
 

4. Select **Prometheus** and then for the HTTP URL field, enter
```   
http://prom-start-prometheus-server.monitoring.svc.cluster.local
```
Then scroll to the bottom of the page and click on **Save and Test**.  After a moment, you should get a response that indicates the data source is working.
 
![enter source](./images/promstart46.png?raw=true "enter source")
![test source](./images/promstart47.png?raw=true "test source")

5. Now, let's create a simple dashboard for one of our mysql metrics.  Click on the *three bars* menu on the left and select *Dashboards*.  Then on the Dashboards pane, select **+ Create Dashboard** from the menu.  
 
![new dashboard](./images/promstart60.png?raw=true "new dashboard") 

6.  Click on **Add visualization**. 

![add viz](./images/promstart49.png?raw=true "add viz")  

7.  Select the **Prometheus** data source on the next screen.

 ![select source](./images/promstart50.png?raw=true "select source")  


8. Then click on the **Select metric** section (lower left) and pick a metric to show.  For example, you could type in **node_disk_io_time_seconds_total**.

 ![select metric](./images/promstart62.png?raw=true "select metric")  
 

9.  When done, click on the **Run queries** button and you should see a new graph being shown.

![run queries](./images/promstart63.png?raw=true "run queries")  

10.  While we can create individual dashboards with Grafana, that can take a lot of time and effort.  The community has already created a number of dashboards that we can just import and use.  So let's grab one for mysql.  Back on the main page, click on the *three bars* icon on the left side, then select **Dashboards** then click on **+ Create Dashboard** to get to the **+Add visualization** page.  Do not click on the button to add a visualization. Instead click on the **Import dashboard** button below and to the right.   

 ![import option](./images/promstart51.png?raw=true "import option")
 
11.  In the field that says **Grafana.com dashboard URL or ID**, enter the location below and click the blue **Load** button.
```
https://grafana.com/grafana/dashboards/7362
```
 ![enter location](./images/promstart52.png?raw=true "enter location")
 
12. On the next page, you can leave everything as-is, except at the bottom for the Prometheus source, click in that box and select our default Prometheus data source that we setup. Then click the blue **Import** button at the bottom.
 
 ![data source](./images/promstart53.png?raw=true "data source")

13. At this point, you should see a populated dashboard with a number of panels looking at the mysql exporter data from our system through Prometheus.  You can scroll around and explore.
 
 ![new dashboard](./images/promstart55.png?raw=true "new dashboard")

14.  Another cool one to import (via the same process) is the **Node Exporter Full** one.  It's available from the link below. A screenshot is also included.  (Here again, you'll need to select the Prometheus data source as we did before.)
```
https://grafana.com/grafana/dashboards/1860
``` 
 ![new dashboard](./images/promstart56.png?raw=true "new dashboard") 

<p align="center">
**[END OF LAB]**
</p>

<p align="center">
(c) 2024 Brent Laster and Tech Skills Transformations
</p>

