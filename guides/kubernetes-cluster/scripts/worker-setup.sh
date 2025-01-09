#!/usr/bin/env bash

# steps
# this assumes that the primary node's ssh key is already in the worker node's authorized_keys file (via the RPi imager)
# on the primary node of the cluster (only tested on Ubuntu Server 24.10 & 24.04.1):
# 1. wget https://raw.githubusercontent.com/brianwalborn/home-lab/refs/heads/main/guides/kubernetes-cluster/scripts/worker-setup.sh
# 2. edit script variables
# 3. cat worker-setup.sh | ssh <WORKER_IP> /bin/bash

# # # variables

K3S_TOKEN="" # pull from /var/lib/rancher/k3s/server/node-token on the primary
PRIMARY_NODE_IP="10.0.1.1"
WORKER_NETWORK_INTERFACE="eth0"

# # # 01. dns config (needed for URLs to resolve)

netplan_file="/etc/netplan/80-dns-servers.yaml"
netplan_config="network:
    version: 2
    renderer: networkd
    ethernets:
        $WORKER_NETWORK_INTERFACE:
            nameservers:
                addresses:
                    - 8.8.8.8
                    - 8.8.4.4"

sudo touch $netplan_file
echo "$netplan_config" | sudo tee $netplan_file
sudo chmod 600 $netplan_file
sudo netplan generate
sudo netplan apply

# # # 02. update packages

sudo apt update -y
sleep 5
sudo apt upgrade -y
sudo apt install avahi-daemon -y

# # # 03. k3s setup

k3s_config="apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
shutdownGracePeriod: 30s
shutdownGracePeriodCriticalPods: 10s"

sudo mkdir -p /etc/rancher/k3s/
echo "$k3s_config" | sudo tee /etc/rancher/k3s/kubelet.config
curl -sfL https://get.k3s.io | K3S_URL="https://$PRIMARY_NODE_IP:6443" K3S_TOKEN="$K3S_TOKEN" sh -s - --node-label 'node.kubernetes.io/role=worker' --kubelet-arg 'config=/etc/rancher/k3s/kubelet.config' --kube-proxy-arg 'metrics-bind-address=0.0.0.0'

echo "Rebooting..."
sudo reboot