#!/usr/bin/env bash

. ./00-variables.sh

MANIFEST_INGRESS="../manifests/argocd/ingress.yaml"

if [[ -f $MANIFEST_INGRESS ]]; then
    sed -i -e 's/{{DOMAIN}}/'$DOMAIN'/g' $MANIFEST_INGRESS

    kubectl create namespace argocd

    kubectl -n argocd apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl -n argocd apply -f $MANIFEST_INGRESS
else
    echo "$MANIFEST_INGRESS not found. Make sure you're in the ./kubernetes/scripts directory."
fi
