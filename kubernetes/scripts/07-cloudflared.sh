#!/usr/bin/env bash

kubectl create namespace cloudflared
kubectl -n cloudflared apply -f ../manifests/cloudflared/cloudflared.yaml