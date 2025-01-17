#!/usr/bin/env bash

# steps
# this assumes that the control-plane node's ssh key is already in the worker node's authorized_keys file
# on the control-plane node of the cluster (only tested on Ubuntu Server 24.10 & 24.04.1):
# 1. (if not already) git clone https://github.com/brianwalborn/home-lab.git
# 2. cd home-lab/kubernetes/scripts
# 3. (if not already) fill in 00-variables.sh
# 4. cat 02-worker-setup.sh | ssh <WORKER_IP_ADDRESS> /bin/bash

. ./00-variables.sh

# # # 01. dns config (needed for URLs to resolve)

[[ "$WORKER_NETWORK_INTERFACE" == *"wlan"* ]] && interface_identifier="wifis" || interface_identifier="ethernets"
netplan_file="/etc/netplan/80-dns-servers.yaml"
netplan_config="network:
    version: 2
    renderer: networkd
    $interface_identifier:
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
sudo apt install nfs-common -y

# # # 03. k3s setup

k3s_config="apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
shutdownGracePeriod: 30s
shutdownGracePeriodCriticalPods: 10s"

sudo mkdir -p /etc/rancher/k3s/
echo "$k3s_config" | sudo tee /etc/rancher/k3s/kubelet.config
curl -sfL https://get.k3s.io | K3S_URL="https://$CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS:6443" K3S_TOKEN="$K3S_TOKEN" sh -s - --node-label 'node.kubernetes.io/role=worker' --kubelet-arg 'config=/etc/rancher/k3s/kubelet.config' --kube-proxy-arg 'metrics-bind-address=0.0.0.0'

echo "Rebooting..."
sudo reboot
