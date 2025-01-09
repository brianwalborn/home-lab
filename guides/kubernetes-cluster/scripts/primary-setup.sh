#!/usr/bin/env bash

# to use, on the target machine (only tested on Ubuntu Server 24.10):
# wget https://raw.githubusercontent.com/brianwalborn/home-lab/refs/heads/main/guides/kubernetes-cluster/scripts/primary-setup.sh
# sudo chmod +x primary-setup.sh
# edit script variables
# sudo ./primary-setup.sh

# # # variables
CLOUDFLARE_TOKEN="FILL TOKEN HERE"
CLUSTER_SUBNET_BASE="10.0.1"
CLUSTER_SUBNET="$CLUSTER_SUBNET_BASE.0/24"
NETWORK_POOL_RANGE="$CLUSTER_SUBNET_BASE.2-$CLUSTER_SUBNET_BASE.50"
PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS="$CLUSTER_SUBNET_BASE.1"
PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS_CIDR="/24"
DHCP_LEASE_LIFETIME="86400"
HOME_NETWORK_GATEWAY_IP_ADDRESS="192.168.0.1"
NETWORK_INTERFACE="wlan0"
PRIMARY_SERVER_HOME_NETWORK_STATIC_IP_ADDRESS="192.168.0.2/24"

# # # 01. update packages

sudo apt update -y
sleep 5
sudo apt upgrade -y

# # # 02. static ips and dhcp server

kea_file="/etc/kea/kea-dhcp4.conf"
netplan_file="/etc/netplan/80-static-ip.yaml"
kea_config='{
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": [ "eth0" ],
            "dhcp-socket-type": "raw"
        },
        "match-client-id": false,
        "valid-lifetime": '"$DHCP_LEASE_LIFETIME"',
        "max-valid-lifetime": '"$DHCP_LEASE_LIFETIME"',
        "subnet4": [{
            "pools": [ { "pool": "'"$NETWORK_POOL_RANGE"'" } ],
            "option-data": [{
                "name": "routers",
                "data": "'"$PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS"'"
            }],
            "subnet": "'"$PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS$PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS_CIDR"'",
            "id": 1
        }],
        "loggers": [{
            "name": "*",
            "severity": "DEBUG"
        }]
    }
}'
netplan_config="network:
    version: 2
    renderer: networkd
    wifis: # this should be 'ethernets' if using the eth0 interface
        $NETWORK_INTERFACE: # replace with your interface's id
            dhcp4: false # disables dynamic IP assignment on this interface
            addresses:
                - $PRIMARY_SERVER_HOME_NETWORK_STATIC_IP_ADDRESS # an IP address on your home network
            routes:
                - to: default
                  via: $HOME_NETWORK_GATEWAY_IP_ADDRESS # the IP address of your gateway/router
            nameservers: # use google's nameservers
                addresses:
                    - 8.8.8.8
                    - 8.8.4.4
    ethernets:
        eth0:
            dhcp4: false # disables dynamic IP assignment on this interface
            addresses:
                - $PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS$PRIMARY_SERVER_ETHERNET_STATIC_IP_ADDRESS_CIDR # a private IP address of your choice"

sudo touch $netplan_file
sudo chmod 600 $netplan_file
sudo echo "$netplan_config" > $netplan_file
sudo netplan generate
sudo netplan apply
sudo apt install kea-dhcp4-server -y
sudo mv $kea_file $kea_file.backup
sudo echo "$kea_config" > $kea_file
sudo systemctl restart kea-dhcp4-server

# # # 03. internet gateway

sudo sed -i 's/#\s*\(net.ipv4.ip_forward=1\)/\1/' /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -s $CLUSTER_SUBNET -o $NETWORK_INTERFACE -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt install iptables-persistent -y

# # # 04. cloudflare tunnel set up

sudo curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb &&
sudo dpkg -i cloudflared.deb &&
sudo cloudflared service install $CLOUDFLARE_TOKEN
echo "Follow these instructions to finish setting up tunneled SSH access: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/ssh-infrastructure-access"

# # # 05. k3s/helm set up

k3s_config="apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
shutdownGracePeriod: 30s
shutdownGracePeriodCriticalPods: 10s"
k3s_token=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32; echo)

sudo mkdir -p /etc/rancher/k3s/
sudo echo "$k3s_config" > /etc/rancher/k3s/kubelet.config
curl -sfL https://get.k3s.io | K3S_TOKEN="$k3s_token" sh -s - server --write-kubeconfig-mode '0644' --node-taint 'node-role.kubernetes.io/master=true:NoSchedule' --disable 'servicelb' --disable 'traefik' --disable 'local-path' --kube-controller-manager-arg 'bind-address=0.0.0.0' --kube-proxy-arg 'metrics-bind-address=0.0.0.0' --kube-scheduler-arg 'bind-address=0.0.0.0' --kubelet-arg 'config=/etc/rancher/k3s/kubelet.config' --kube-controller-manager-arg 'terminated-pod-gc-threshold=10'
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
sudo rm get_helm.sh
sudo mkdir $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/.

echo "Rebooting..."
sudo reboot