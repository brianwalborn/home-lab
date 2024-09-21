# Install Grafana

## Motivation

Among other things, [Grafana](https://grafana.com/) is a visualization tool that integrates with Prometheus to pull system metrics into a robust UI that extends the power of vanilla Prometheus.

## Installing Grafana

> Run these steps from a separate machine with a GUI (set up in the *Enable Remote Access* section of the [Kubernetes cluster setup](./06-kubernetes-cluster.md) guide) so we can access Grafana via a browser window

1. Add and update the Helm repo, create the `grafana` namespace, and install the chart
    ```
    $ helm repo add grafana https://grafana.github.io/helm-charts
    $ helm repo update
    $ kubectl create ns grafana
    $ helm -n grafana install grafana grafana/grafana
    ```
2. Next, we need to retrieve a) the password we'll be using to log into Grafana, and b) the cluster IP address of the Prometheus server (your IP addresses will be different)
    ```
    $ kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    PASSWORD_WILL_BE_HERE
    $ kubectl -n prometheus get service
    NAME                                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    prometheus-alertmanager-headless      ClusterIP   None            <none>        9093/TCP   2d1h
    prometheus-server                     ClusterIP   10.43.138.116   <none>        80/TCP     2d1h
    prometheus-alertmanager               ClusterIP   10.43.107.45    <none>        9093/TCP   2d1h
    prometheus-kube-state-metrics         ClusterIP   10.43.218.246   <none>        8080/TCP   2d1h
    prometheus-prometheus-node-exporter   ClusterIP   10.43.102.98    <none>        9100/TCP   2d1h
    prometheus-prometheus-pushgateway     ClusterIP   10.43.213.228   <none>        9091/TCP   2d1h
    ```
3. To access the Grafana UI, we can forward the service to a port on our local machine and access it through a browser
    ```
    $ kubectl -n grafana port-forward service/grafana 8080:80
    ```
    Now we can navigate to `http://localhost:8080` in a browser to see the Grafana UI and login with the username `admin` and password output in step 2
4. Once logged in, navigate to Connections > Data Sources > Add Data Source > Prometheus. In the *Prometheus server URL* text box, enter the Cluster IP of the `prometheus-server` service output in step 2, for example: `http://10.43.138.116`
  > Creating dashboards is out of the scope of this guide, but you can use [Grafana's dashboard site](https://grafana.com/grafana/dashboards/) to start playing with dashboards
