#!/bin/bash

echo "--- Connexion des deux clusters via Cluster Mesh ---"
cilium clustermesh connect \
  --context kind-mesh1 \
  --destination-context kind-mesh2

echo "--- Vérification du statut Cluster Mesh sur mesh1 ---"
cilium clustermesh status --context kind-mesh1 --wait

echo "--- Vérification du statut Cluster Mesh sur mesh2 ---"
cilium clustermesh status --context kind-mesh2 --wait
