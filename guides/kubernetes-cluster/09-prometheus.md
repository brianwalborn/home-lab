# Install Prometheus

## Motivation

[Prometheus](https://prometheus.io/) is an open-source tool that aggregates metrics used to monitor and raise alerts for systems and services. Prometheus is pretty ubiquitous in the industry and is pretty powerful by itself, but you'll generally have it paired with a visualization tool such as [Grafana](https://grafana.com/) to get the most out of it. We'll be installing and configuring both Prometheus and Grafana in our Kubernetes cluster to provide us some observability.

## Installing Prometheus

> Run these steps from a separate machine with a GUI (set up in the *Enable Remote Access* section of the [Kubernetes cluster setup](./06-kubernetes-cluster.md) guide) so we can access the Prometheus dashboard via a browser window

1. Add and update the Helm repo, create the `prometheus` namespace, and install the chart. The `helm upgrade` command will install Prometheus as well as some dependent charts (alertmanager, kube-state-metrics, prometheus-node-exporter, and prometheus-pushgateway) that further extend the monitoring reach and functionality within the cluster
    ```
    $ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    $ helm repo update
    $ kubectl create ns prometheus
    $ helm -n prometheus upgrade -i prometheus prometheus-community/prometheus
    ```
2. To see everything that the chart installed, run `kubectl -n prometheus get all`:
    ```
    $ kubectl -n prometheus get all
    NAME                                                     READY   STATUS    RESTARTS      AGE
    pod/prometheus-prometheus-node-exporter-ncptm            1/1     Running   6 (15h ago)   2d1h
    pod/prometheus-kube-state-metrics-79c867c577-qw2f8       1/1     Running   6 (15h ago)   2d1h
    pod/prometheus-prometheus-node-exporter-vlhcx            1/1     Running   0             2d1h
    pod/prometheus-server-6459547474-b8sqc                   2/2     Running   0             2d1h
    pod/prometheus-prometheus-node-exporter-75vn8            1/1     Running   0             2d1h
    pod/prometheus-prometheus-node-exporter-6lfgb            1/1     Running   0             2d1h
    pod/prometheus-prometheus-pushgateway-57c548bd6f-r42dl   1/1     Running   0             2d1h
    pod/prometheus-alertmanager-0                            1/1     Running   0             2d1h

    NAME                                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/prometheus-alertmanager-headless      ClusterIP   None            <none>        9093/TCP   2d1h
    service/prometheus-server                     ClusterIP   10.43.138.116   <none>        80/TCP     2d1h
    service/prometheus-alertmanager               ClusterIP   10.43.107.45    <none>        9093/TCP   2d1h
    service/prometheus-kube-state-metrics         ClusterIP   10.43.218.246   <none>        8080/TCP   2d1h
    service/prometheus-prometheus-node-exporter   ClusterIP   10.43.102.98    <none>        9100/TCP   2d1h
    service/prometheus-prometheus-pushgateway     ClusterIP   10.43.213.228   <none>        9091/TCP   2d1h

    NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    daemonset.apps/prometheus-prometheus-node-exporter   4         4         4       4            4           kubernetes.io/os=linux   2d1h

    NAME                                                READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/prometheus-kube-state-metrics       1/1     1            1           2d1h
    deployment.apps/prometheus-server                   1/1     1            1           2d1h
    deployment.apps/prometheus-prometheus-pushgateway   1/1     1            1           2d1h

    NAME                                                           DESIRED   CURRENT   READY   AGE
    replicaset.apps/prometheus-kube-state-metrics-79c867c577       1         1         1       2d1h
    replicaset.apps/prometheus-server-6459547474                   1         1         1       2d1h
    replicaset.apps/prometheus-prometheus-pushgateway-57c548bd6f   1         1         1       2d1h

    NAME                                       READY   AGE
    statefulset.apps/prometheus-alertmanager   1/1     2d1h
    ```
3. To access the Prometheus dashboard, we can forward the service to a port on our local machine and access it through a brower:
    ```
    $ kubectl -n prometheus port-forward service/prometheus-server 8080:80
    ```
    Now we can navigate to `http://localhost:8080` in a browser to see the Prometheus dashboard
