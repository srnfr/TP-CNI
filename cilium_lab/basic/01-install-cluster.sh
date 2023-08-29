#!/bin/bash

echo "---"
kind delete cluster --name basic && kind create cluster --config=kind-config.yaml

exit

echo "---"
./reconfigure-cilium.sh
cilium status --wait
./check-cilium.sh

echo "---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "---"
kubectl apply -f ./ingress-test.yaml 

sleep 3;
curl localhost/foo
curl localhost/bar
