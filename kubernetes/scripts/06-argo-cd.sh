#!/usr/bin/env bash

kubectl create namespace argocd
kubectl -n argocd apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd apply -f ../manifests/argocd/ingress.yaml
kubectl -n argocd apply -f ../manifests/argocd/root-app.yaml