# Install Metal LB on Your Kubernetes Cluster

## Motivation

Without a load balancer implementation installed, any Kubernetes services of the  `LoadBalancer` type will remain in a pending state until one is configured. Since we disabled the default service load balancer offered by K3s during installation (`--disable 'servicelb'`), we'll install Metal LB to take its spot.

## Install Metal LB

1. Add and update the Helm repo, create the namespace, and install the Metal LB [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
    ```
    me@kubernetes-primary:~$ helm repo add metallb https://metallb.github.io/metallb
    me@kubernetes-primary:~$ helm repo update
    me@kubernetes-primary:~$ kubectl create namespace metallb
    me@kubernetes-primary:~$ helm -n metallb install metallb metallb/metallb
    ```
2. Apply [this Kubernetes manifest](./kubernetes-manifests/metallb.yaml) file, updating the IP address range as necessary (if you've followed this guide to a T, the IP address range won't need to be changed) and check to make sure its running
    ```
    me@kubernetes-primary:~$ kubectl apply -f guides/kubernetes-cluster/kubernetes-manifests/metallb.yaml
    me@kubernetes-primary:~$ kubectl get services --all-namespaces
    NAMESPACE       NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
    default         kubernetes                           ClusterIP      10.43.0.1      <none>        443/TCP                      7d12h
    kube-system     kube-dns                             ClusterIP      10.43.0.10     <none>        53/UDP,53/TCP,9153/TCP       7d12h
    kube-system     metrics-server                       ClusterIP      10.43.5.27     <none>        443/TCP                      7d12h
    metallb         metallb-webhook-service              ClusterIP      10.43.127.47   <none>        443/TCP                      7d5h
    me@kubernetes-primary:~$ kubectl get pods --all-namespaces
    NAMESPACE       NAME                                        READY   STATUS    RESTARTS       AGE
    kube-system     local-path-provisioner-84db5d44d9-nhpjx     1/1     Running   0              7d12h
    kube-system     coredns-6799fbcd5-t2jnt                     1/1     Running   0              7d12h
    kube-system     metrics-server-67c658944b-k7lxf             1/1     Running   0              7d12h
    metallb         metallb-controller-648b76f565-6plkg         1/1     Running   0              7d5h
    metallb         metallb-speaker-bxdmh                       4/4     Running   0              7d5h
    metallb         metallb-speaker-48dwz                       4/4     Running   0              7d5h
    metallb         metallb-speaker-sw4sf                       4/4     Running   0              7d5h
    metallb         metallb-speaker-4phzl                       4/4     Running   0              7d5h
    ```

## Next Step

- [Install the NGINX ingress controller](./ingress-nginx.md)
