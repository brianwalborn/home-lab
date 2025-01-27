# Install Ingress Nginx

## Motivation

During K3s installation, we disabled the default ingress controller (`--disable 'traefik'`) in favor of using the [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/) primarily due to its ubiquity. The ingress controller resource will deploy a `LoadBalancer` Kubernetes service that uses ports 80 and 443 and acts as the entrypoint to our cluster.

## Installing the Ingress Controller

1. Add and update the Helm repo, create the `ingress-nginx` namespace, and install the chart using this values file, updating the load balancer IP as necessary (if you've followed this guide to a T, the IP address won't need to be changed)
    ```
    me@kubernetes-primary:~$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    me@kubernetes-primary:~$ helm repo update
    me@kubernetes-primary:~$ kubectl create namespace ingress-nginx
    me@kubernetes-primary:~$ helm -n ingress-nginx install ingress-nginx ingress-nginx/ingress-nginx -f guides/kubernetes-cluster/helm-values/ingress-nginx.yaml
    ```
2. We should then be able to see the ingress controller `LoadBalancer` service running with the external IP we provided
    ```
    me@kubernetes-primary:~$ kubectl get services --all-namespaces
    NAMESPACE       NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
    default         kubernetes                           ClusterIP      10.43.0.1      <none>        443/TCP                      7d12h
    kube-system     kube-dns                             ClusterIP      10.43.0.10     <none>        53/UDP,53/TCP,9153/TCP       7d12h
    kube-system     metrics-server                       ClusterIP      10.43.5.27     <none>        443/TCP                      7d12h
    metallb         metallb-webhook-service              ClusterIP      10.43.127.47   <none>        443/TCP                      7d5h
    ingress-nginx   ingress-nginx-controller-admission   ClusterIP      10.43.249.51   <none>        443/TCP                      7d5h
    ingress-nginx   ingress-nginx-controller             LoadBalancer   10.43.144.53   10.4.4.10     80:31408/TCP,443:31249/TCP   7d5h
    ```
    To further verify, we can use `curl` to ensure the controller is listening
    ```
    me@kubernetes-primary:~$ curl 10.4.4.10
    <html>
    <head><title>404 Not Found</title></head>
    <body>
    <center><h1>404 Not Found</h1></center>
    <hr><center>nginx</center>
    </body>
    </html>
    ```
    A 404 tells us the controller is up and listening but there are no services up to forward requests to. This is OK at this point.
