#!/bin/bash

helm upgrade --install --namespace kube-system --repo https://helm.cilium.io cilium cilium --values values.yaml  --version 1.12.19

#kubectl rollout restart daemonset cilium -n kube-system

#cilium status --wait
