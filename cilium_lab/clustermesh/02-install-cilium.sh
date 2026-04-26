#!/bin/bash

C_VERSION="1.19.3"

echo "--- Installation de Cilium sur mesh1 ---"
cilium install \
  --context kind-mesh1 \
  --version ${C_VERSION} \
  --values values-cluster1.yaml

echo "--- Attente de Cilium sur mesh1 ---"
cilium status --context kind-mesh1 --wait

echo "--- Partage du CA de mesh1 vers mesh2 ---"
# Les deux clusters doivent partager le meme CA Cilium pour que
# les certificats ClusterMesh soient generes dans la meme chaine de confiance.
kubectl get secret cilium-ca -n kube-system \
  --context kind-mesh1 -o yaml \
  | grep -v '^\s*\(creationTimestamp\|resourceVersion\|uid\|selfLink\|generation\):' \
  | kubectl apply --context kind-mesh2 -f -

echo "--- Installation de Cilium sur mesh2 (avec CA partagé) ---"
cilium install \
  --context kind-mesh2 \
  --version ${C_VERSION} \
  --values values-cluster2.yaml

echo "--- Attente de Cilium sur mesh2 ---"
cilium status --context kind-mesh2 --wait

echo "--- Activation de Cluster Mesh sur mesh1 ---"
cilium clustermesh enable --context kind-mesh1 --service-type NodePort

echo "--- Activation de Cluster Mesh sur mesh2 ---"
cilium clustermesh enable --context kind-mesh2 --service-type NodePort

echo "--- Attente readiness clustermesh sur mesh1 ---"
cilium clustermesh status --context kind-mesh1 --wait

echo "--- Attente readiness clustermesh sur mesh2 ---"
cilium clustermesh status --context kind-mesh2 --wait
