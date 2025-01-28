#!/usr/bin/env bash

export CLOUDFLARE_TUNNEL_TOKEN="" # if you want cloudflared on the control-plane node, set the tunnel token here (ZeroTrust > Networks > Tunnels)
export CLOUDFLARE_CERT_MANAGER_API_TOKEN="" # instructions are here if you plan to use the dns01 solver through CloudFlare: https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/
export K3S_TOKEN="" # any random string. if k3s is already installed, pull from /var/lib/rancher/k3s/server/node-token on the control-plane node
export DOMAIN="example.com" # your domain
export EMAIL_ADDRESS="email@email.com" # your email address for cert-manager
export CLUSTER_SUBNET="10.0.1.0/24"
export CLUSTER_DHCP_IP_POOL_RANGE="10.0.1.2-10.0.1.50"
export CLUSTER_DHCP_LEASE_LIFETIME="86400"
export CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS="10.0.1.1"
export CONTROL_PLANE_NODE_ETHERNET_STATIC_IP_ADDRESS_CIDR="/24"
export CONNECTED_NETWORK_GATEWAY_IP_ADDRESS="192.168.0.1"
export NETWORK_INTERFACE="wlan0"
export WORKER_NETWORK_INTERFACE="eth0"
export CONTROL_PLANE_NODE_HOME_NETWORK_STATIC_IP_ADDRESS="192.168.0.2/24"
export NFS_DRIVES="/nfs/default:rw /nfs/media:ro"
