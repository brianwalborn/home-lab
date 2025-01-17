#!/usr/bin/env bash

. ./00-variables.sh

MANIFEST="../manifests/cert-manager/cluster-issuers.yaml"

if [ -f $MANIFEST ]; then
    sed -i -e 's/{{EMAIL_ADDRESS}}/'$EMAIL_ADDRESS'/g' $MANIFEST
    sed -i -e 's/{{CLOUDFLARE_CERT_MANAGER_API_TOKEN}}/'$CLOUDFLARE_CERT_MANAGER_API_TOKEN'/g' $MANIFEST

    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
    kubectl apply -f $MANIFEST
else
    echo "$MANIFEST not found. Make sure you're in the ./kubernetes/scripts directory."
fi
