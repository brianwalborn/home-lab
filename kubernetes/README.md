# Kubernetes

These are fast-track scripts and manifests designed to help get a Kubernetes cluster from zero to functional quickly.

- `00-variables.sh`: contains variables used in subsequent scripts

- `01-control-plane-setup.sh`: sets up the control plane node for the cluster from a fresh install of Ubuntu Server 24.10 or 24.04.1 (could work for other distros but I haven't tried)

- `02-worker-setup.sh`: sets up any worker nodes in the cluster from a fresh install of Ubuntu Server 24.10 or 24.04.1 (could work with other distros but I haven't tried)

- `argo-cd.sh`: deploys [Argo CD](https://github.com/argoproj/argo-cd) into the cluster (requires `cert-manager` to be deployed, plus a domain if you'd like it to be accessible publicly)

- `cert-manager.sh`: deploys [cert-manager](https://github.com/cert-manager/cert-manager) into the cluster (requires cloudflared to be deployed)

- `cloudflared.sh`: deploys cloudflared into the cluster (requires a [CloudFlare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/))

- `ingress-nginx.sh`: deploys the [ingress-nginx](https://github.com/kubernetes/ingress-nginx) Ingress controller into the cluster
