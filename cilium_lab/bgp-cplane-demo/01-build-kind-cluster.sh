#!/bin/bash

VERSION_K8S="1.30.4"
echo "---"
kind create cluster -v=2 --config=./kind-config.yaml --image kindest/node:v${VERSION_K8S}
echo -n "Kind running clusters :"
kind get clusters

echo "---"

kubectl cluster-info

echo "---"
kubectl get nodes
#./reconfigure-cilium.sh
#cilium status --wait
#./check-cilium
