#!/bin/bash

kubectl apply -f cilium-bgp-advertisement.yaml
kubectl apply -f cilium-bgp-peer-config.yaml
kubectl apply -f cilium-bgp-cluster-config-rack0.yaml
kubectl apply -f cilium-bgp-cluster-config-rack1.yaml
