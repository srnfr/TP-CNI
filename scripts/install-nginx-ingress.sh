#!/bin/bash
source ./.env

if ([ -z "${CTX_K8S}" ]); then
	echo "CTX_K8S  not set, using default"
	CTX_K8S="default"
fi

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update ingress-nginx

echo "Install de nginx ingress via Helm sur :"

for c in $(doctl kubernetes clusters list --format Name --context $CTX_K8S | grep -v Name ); do
    if [[ "$c" != "Name" ]]; then
        echo "- $c"
	doctl kubernetes cluster kubeconfig show $c --context $CTX_K8S > $c.kubeconfig.yaml
	helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --kubeconfig $c.kubeconfig.yaml
    fi
done;