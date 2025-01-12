#!/usr/bin/env bash

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
kubectl -n metallb-system apply -f ../manifests/metallb/metallb.yaml
