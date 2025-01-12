#!/usr/bin/env bash

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
echo "1. Follow instructions here (https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/) to create a CloudFlare API token for the cert-manager DNS solver"
echo "2. Fill the <TOKEN> in the ../manifests/cert-manager/cluster-issuers.yaml file"
read -n 1 -s -r -p "3. Press any key to continue..."
kubectl apply -f ../manifests/cert-manager/cluster-issuers.yaml 