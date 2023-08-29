#!/bin/bash

helm upgrade --install --namespace kube-system --repo https://helm.cilium.io cilium cilium --values values.yaml

#kubectl rollout restart daemonset cilium -n kube-system

#cilium status --wait
