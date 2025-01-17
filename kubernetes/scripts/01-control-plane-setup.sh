#!/usr/bin/env bash

# steps
# on the control-plane node (only tested on Ubuntu Server 24.10 & 24.04.1):
# 1. git clone https://github.com/brianwalborn/home-lab.git
# 2. cd home-lab/kubernetes/scripts
# 3. fill in 00-variables.sh
# 4. sudo ./00-control-plane-setup.sh

. ./00-variables.sh

# # # 01. update packages

sudo apt update -y
sleep 5
sudo apt upgrade -y
sudo apt install net-tools

# # # 02. static ips and dhcp server

[[ "$NETWORK_INTERFACE" == *"wlan"* ]] && interface_identifier="wifis" || interface_identifier="ethernets"
kea_file="/etc/kea/kea-dhcp4.conf"
netplan_file="/etc/netplan/80-static-ip.yaml"
kea_config='{
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": [ "eth0" ],
            "dhcp-socket-type": "raw"
        },
        "match-client-id": false,
        "valid-lifetime": '"$CLUSTER_DHCP_LEASE_LIFETIME"',
        "max-valid-lifetime": '"$CLUSTER_DHCP_LEASE_LIFETIME"',
        "subnet4": [{
            "pools": [ { "pool": "'"$CLUSTER_DHCP_IP_POOL_RANGE"'" } ],
            "option-data": [{
                "name": "routers",
                "data": "'"$CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS"'"
            }],
            "subnet": "'"$CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS$CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS_CIDR"'",
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
    $interface_identifier:
        $NETWORK_INTERFACE: # replace with your interface's id
            dhcp4: false # disables dynamic IP assignment on this interface
            addresses:
                - $CONTROL_PLANE_NODE_HOME_NETWORK_STATIC_IP_ADDRESS # an IP address on your home network
            routes:
                - to: default
                  via: $CONNECTED_NETWORK_GATEWAY_IP_ADDRESS # the IP address of your gateway/router
            nameservers: # use google's nameservers
                addresses:
                    - 8.8.8.8
                    - 8.8.4.4
    ethernets:
        eth0:
            dhcp4: false # disables dynamic IP assignment on this interface
            addresses:
                - $CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS$CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS_CIDR # a private IP address of your choice"

sudo touch $netplan_file
sudo chmod 600 $netplan_file
echo "$netplan_config" | sudo tee $netplan_file
sudo netplan generate
sudo netplan apply
sudo apt install kea-dhcp4-server -y
sudo mv $kea_file $kea_file.backup
echo "$kea_config" | sudo tee $kea_file
sudo systemctl restart kea-dhcp4-server

# # # 03. internet gateway

sudo sed -i 's/#\s*\(net.ipv4.ip_forward=1\)/\1/' /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -s $CLUSTER_SUBNET -o $NETWORK_INTERFACE -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt install iptables-persistent -y

# # # 04. k3s/helm set up

k3s_config="apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
shutdownGracePeriod: 30s
shutdownGracePeriodCriticalPods: 10s"

sudo mkdir -p /etc/rancher/k3s/
echo "$k3s_config" | sudo tee /etc/rancher/k3s/kubelet.config
curl -sfL https://get.k3s.io | K3S_TOKEN="$K3S_TOKEN" sh -s - server --write-kubeconfig-mode '0644' --node-taint 'node-role.kubernetes.io/master=true:NoSchedule' --disable 'servicelb' --disable 'traefik' --disable 'local-path' --kube-controller-manager-arg 'bind-address=0.0.0.0' --kube-proxy-arg 'metrics-bind-address=0.0.0.0' --kube-scheduler-arg 'bind-address=0.0.0.0' --kubelet-arg 'config=/etc/rancher/k3s/kubelet.config' --kube-controller-manager-arg 'terminated-pod-gc-threshold=10'
sudo mkdir $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/.
cat /etc/rancher/k3s/k3s.yaml | sudo tee $HOME/.kube/config

# # # 05. cloudflare tunnel set up

if [ "$CLOUDFLARE_TUNNEL_TOKEN" != "" ]; then
    sudo curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb &&
    sudo dpkg -i cloudflared.deb &&
    sudo cloudflared service install $CLOUDFLARE_TUNNEL_TOKEN
    echo "Follow these instructions to finish setting up tunneled SSH access: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/ssh-infrastructure-access"
fi

# # # 06. create ssh key

ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -q -N ""

# # # 07. nfs server

sudo apt install nfs-kernel-server -y

for drive in $NFS_DRIVES; do 
    IFS=: read -r name permission <<< "$drive"
    echo "$name *($permission,async,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
done

sudo exportfs -a

echo "Rebooting..."
sudo reboot
