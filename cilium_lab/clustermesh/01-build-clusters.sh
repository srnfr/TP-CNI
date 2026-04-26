#!/bin/bash

VERSION_K8S="1.35.0"

echo "--- Suppression des anciens clusters si existants ---"
kind delete cluster --name mesh1 2>/dev/null
kind delete cluster --name mesh2 2>/dev/null

echo "--- Création du cluster mesh1 ---"
kind create cluster -v=2 --config=kind-config-cluster1.yaml --image kindest/node:v${VERSION_K8S}

echo "--- Création du cluster mesh2 ---"
kind create cluster -v=2 --config=kind-config-cluster2.yaml --image kindest/node:v${VERSION_K8S}

echo "--- Clusters KinD actifs ---"
kind get clusters

echo "--- Noeuds mesh1 ---"
kubectl get nodes --context kind-mesh1

echo "--- Noeuds mesh2 ---"
kubectl get nodes --context kind-mesh2
