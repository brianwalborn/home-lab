#!/usr/bin/env bash

. ./00-variables.sh

MANIFEST="../manifests/cloudflared/cloudflared.yaml"

if [ -f $MANIFEST ]; then
    sed -i -e 's/{{TOKEN}}/'$CLOUDFLARE_TUNNEL_TOKEN'/g' $MANIFEST

    kubectl create namespace cloudflared
    kubectl -n cloudflared apply -f $MANIFEST
else
    echo "$MANIFEST not found. Make sure you're in the ./kubernetes/scripts directory."
fi
