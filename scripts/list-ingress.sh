#!/bin/bash
source ./.env

if ([ -z "${CTX_K8S}" ]); then
	echo "CTX_K8S  not set, using default"
	CTX_K8S="default"
fi

for c in $(doctl kubernetes clusters list --format Name --context $CTX_K8S | grep -v Name ); do
    if [[ "$c" != "Name" ]]; then
        echo "$c"
        doctl kubernetes cluster kubeconfig show $c --context $CTX_K8S > $c.kubeconfig.yaml
        PUBIP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' --kubeconfig=./$c.kubeconfig.yaml)
        echo "PUBIP of ingress $c = $PUBIP"
    fi
done;