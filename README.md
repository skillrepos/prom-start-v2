# Getting Started with Prometheus - lab setup

These instructions will guide you through configuring a GitHub Codespaces environment that you can use to run the course labs.

These steps **must** be completed prior to starting the actual labs.

## Create your own repository for these labs

- Ensure that you have created a repository by forking the [skillrepos/prom-start-v2](https://github.com/skillrepos/prom-start-v2) project as a template into your own GitHub area.
- You do this by clicking the `Fork` button in the upper right portion of the main project page and following the steps to create a copy in **your-github-userid/prom-start-v2** .

![Forking repository](./images/promstart1.png?raw=true "Forking the repository")

![Forking repository](./images/promstart2.png?raw=true "Forking the repository")

## Configure your codespace

1. In your forked repository, start a new codespace.

    - Click the `Code` button on your repository's landing page.
    - Click the `Codespaces` tab.
    - Click `Create codespaces on main` to create the codespace.
    - After the codespace has initialized there will be a terminal present.

![Starting codespace](./images/promstart3.png?raw=true "Starting your codespace")


## Start the Kubernetes cluster and install the apps needed
2. There is a script file in [**extra/install-apps.sh**](./roar-k8s/install-apps.sh) :

    - Run the following commands in the codespace's terminal (**This will take quite a while to run...**):

      ```
      ./extra/install-apps.sh
      ```

    - The output should look similar to the following.

```console
...Removing any old minikube instances
🙄  "minikube" profile does not exist, trying anyways.
❌  Failed to stop ssh-agent process: failed loading config: cluster "minikube" does not exist
💀  Removed all traces of the "minikube" cluster.
...Starting minikube
😄  minikube v1.32.0 on Ubuntu 20.04 (docker/amd64)
✨  Automatically selected the docker driver. Other choices: none, ssh
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.28.3 preload ...
    > preloaded-images-k8s-v18-v1...:  403.35 MiB / 403.35 MiB  100.00% 148.60 
🔥  Creating docker container (CPUs=2, Memory=3900MB) ...
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
...Creating namespace
namespace/monitoring created
...Adding prometheus-community repo
"prometheus-community" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
...Installing Prometheus and Grafana
NAME: monitoring
LAST DEPLOYED: Fri Feb 23 12:10:40 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=monitoring"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
...Waiting on resources to be ready
pod/monitoring-grafana-788d74bfff-ttvj2 condition met
pod/monitoring-kube-prometheus-operator-7f588fd477-p92vn condition met
pod/monitoring-kube-state-metrics-987cdb7b6-4xdnv condition met
pod/monitoring-prometheus-node-exporter-77kns condition met
...Forwarding ports
nohup: nohup: appending output to 'nohup.out'
appending output to 'nohup.out'
nohup: appending output to 'nohup.out'
nohup: appending output to 'nohup.out'
```

## Labs

After the codespace has started, open the labs document by going to the file tree on the left, find the file named **labs.md**, right-click on it, and open it with the **Preview** option.)

![Labs doc preview in codespace](./images/promstart4.png?raw=true "Labs doc preview in codespace")

This will open it up in a tab above your terminal. Then you can follow along with the steps in the labs. 
Any command in the gray boxes is either code intended to be run in the console or code to be updated in a file.

Labs doc: [Kubernetes for Developers Deep Dive Labs](labs.md)
