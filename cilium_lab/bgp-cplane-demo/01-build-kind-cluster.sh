#!/bin/bash

echo "---"
kind create cluster -v=2 --config=./kind-config.yaml --image kindest/node:v1.24.17
echo -n "Kind running clusters :"
kind get clusters

echo "---"

kubectl cluster-info

echo "---"
kubectl get nodes
#./reconfigure-cilium.sh
#cilium status --wait
#./check-cilium
