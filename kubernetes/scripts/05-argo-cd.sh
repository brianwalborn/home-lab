#!/usr/bin/env bash

. ./00-variables.sh

MANIFEST_INGRESS="../manifests/argocd/ingress.yaml"
MANIFEST_ROOT_APP="../manifests/argocd/root-app.yaml"

if [[ -f $MANIFEST_INGRESS && -f $MANIFEST_ROOT_APP ]]; then
    sed -i -e 's/{{DOMAIN}}/'$DOMAIN'/g' $MANIFEST_INGRESS

    kubectl create namespace argocd

    kubectl -n argocd apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    kubectl -n argocd apply -f $MANIFEST_INGRESS
    kubectl -n argocd apply -f $MANIFEST_ROOT_APP
else
    echo "$MANIFEST_INGRESS or $MANIFEST_ROOT_APP not found. Make sure you're in the ./kubernetes/scripts directory."
fi
