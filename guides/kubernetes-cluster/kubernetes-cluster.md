# Set up a Kubernetes Cluster on Your Raspberry Pi Cluster

## Motivation

AWS and GCP's Kubernetes offerings do a great job at abstracting the difficult-to-manage parts of Kubernetes away from the user. That being said, I've had the urge to tinker with the parts of Kubernetes that managed offerings (EKS, GKE) generally handle.

## Prepare and Install K3s on the Control-Plane Node

When it comes to lightweight Kubernetes distributions, there are many to choose from (MiniKube, MicroK8s, and Kind -- among others). But K3s fits our use case due to its simplicity and ARM optimization for small machines like our Raspberry Pis.

1. Create the `k3s` directory and `kubelet.config` file
    ```
    me@kubernetes-primary:~$ sudo mkdir -p /etc/rancher/k3s/
    me@kubernetes-primary:~$ sudo vi /etc/rancher/k3s/kubelet.config
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    shutdownGracePeriod: 30s
    shutdownGracePeriodCriticalPods: 10s
    ```
2. Install K3s control plane on the control-plane node
    > For the `K3S_TOKEN` argument, I simply ran `uuid` to get a GUID, but it can be anything. Keep it handy, because we'll be using it to set up the worker nodes. If you forget it at any point, you can see it by running `sudo cat /var/lib/rancher/k3s/server/node-token`
    ```
    me@kubernetes-primary:~$ curl -sfL https://get.k3s.io | K3S_TOKEN='TOKEN' sh -s - server --write-kubeconfig-mode '0644' --node-taint 'node-role.kubernetes.io/master=true:NoSchedule' --disable 'servicelb' --disable 'traefik' --disable 'local-path' --kube-controller-manager-arg 'bind-address=0.0.0.0' --kube-proxy-arg 'metrics-bind-address=0.0.0.0' --kube-scheduler-arg 'bind-address=0.0.0.0' --kubelet-arg 'config=/etc/rancher/k3s/kubelet.config' --kube-controller-manager-arg 'terminated-pod-gc-threshold=10'
    ```
    The above command is installing K3s server with quite a few options that can be explored in detail [here](https://docs.k3s.io/cli/server). We're disabling `servicelb` (K3s default load balancer) and `traefik` (K3s default ingress) in favor of `metallb` and `nginx` respectively.
3. Install Helm
    ```
    me@kubernetes-primary:~$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    me@kubernetes-primary:~$ chmod 700 get_helm.sh
    me@kubernetes-primary:~$ ./get_helm.sh
    me@kubernetes-primary:~$ rm get_helm.sh
    ```
4. Create your `.kube` directory and copy the K3s config
    ```
    me@kubernetes-primary:~$ mkdir $HOME/.kube
    me@kubernetes-primary:~$ cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/.
    ```

## Prepare and Install K3s on the Worker Nodes

Now that our control-plane node is mostly set up, we need to set up each of our worker nodes.

1. As with the control-plane, create the `k3s` directory and `kubelet.config` file on the worker node
    ```
    me@one:~$ sudo mkdir -p /etc/rancher/k3s/
    me@one:~$ sudo vi /etc/rancher/k3s/kubelet.config
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    shutdownGracePeriod: 30s
    shutdownGracePeriodCriticalPods: 10s
    ```
2. Install K3s on the worker node, filling in the IP of your control-plane node and token created in the previous section
    ```
    me@one:~$ curl -sfL https://get.k3s.io | K3S_URL='https://<IP_OF_CONTROL_PLANE_NODE>:6443' K3S_TOKEN=<TOKEN> sh -s - --node-label 'node_type=worker' --kubelet-arg 'config=/etc/rancher/k3s/kubelet.config' --kube-proxy-arg 'metrics-bind-address=0.0.0.0'
    ```
3. Back on the control-plane node, give the worker node a label
    ```
    me@kubernetes-primary:~$ kubectl label nodes one kubernetes.io/role=worker
    ```
4. Follow these steps for each worker node

## Enable Remote Access

We've now got Kubernetes up and running on our control-plane and worker nodes! Now let's get our personal laptop set up to be able to connect and interact with our new cluster.

> You should have `kubectl` installed on your personal machine

1. From your control-plane node (it's helpful to do this in a separate terminal), run this command to get your cluster cert and key
    ```
    me@kubernetes-primary:~$ sudo cat .kube/k3s.yaml
    ...
    client-certificate-data: ***
    client-key-data: ***
    ```
    Now, on your personal laptop, put the base64-decoded value of `client-certificate-data` into `~/.kube/homelab.crt` and the base64-decoded value of `client-key-data` into `~/.kube/homelab.key`
    ```
    $ echo "VALUE_OF_CLIENT_CERTIFICATE_DATA" | base64 --decode
    $ echo "VALUE_OF_CLIENT_KEY_DATA" | base64 --decode
    $ vi ~/.kube/homelab.crt
    # value echoed above
    $ vi ~/.kube/homelab.key
    # value echoed above
    ```
2. Run the below commands to 1) create a local user that authenticates using the key and cert from our K3s cluster, 2) set the cluster server for the context to the home network-facing IP address of our control-plane node, 3) save the context, 4) use the context we just saved, and 5) rename the context to something meaningful.
    ```
   $ kubectl config set-credentials default --client-key=$HOME/.kube/homelab.key --client-certificate=$HOME/.kube/homelab.crt
   $ kubectl config set-cluster default --insecure-skip-tls-verify=true --server=https://192.168.0.2:6443
   $ kubectl config set-context default --user=default --namespace=default --cluster=default
   $ kubectl config use-context default
   $ kubectl config rename-context default homelab
    ```
3. Ensure we're all connected
    ```
    $ kubectl cluster-info
    Kubernetes control plane is running at https://192.168.0.2:6443
    CoreDNS is running at https://192.168.0.2:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    Metrics-server is running at https://192.168.0.2:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy
    ```

## Next Step

- [Install Metal LB](./metallb.md)
