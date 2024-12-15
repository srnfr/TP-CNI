#!/bin/bash
source ./.env

if ([ -z "${CTX}" ] || [ -z "${CTX_K8S}" ] || [ -z "${INGRESS_DOMAIN}" ]); then
	die "CTX or/and INGRESS_DOMAIN not set"
	exit 0;
fi

echo "INGRESS_DOMAIN=$INGRESS_DOMAIN"
echo "CTX=$CTX"
echo "CTX_K8S=$CTX_K8S"

## DESTRUCTION

for n in $(doctl compute domain records list $INGRESS_DOMAIN --context $CTX | egrep "ing-[0-9]+" | cut -f1,2 -d' '); do
	echo "doctl compute domain records delete $INGRESS_DOMAIN ${n} --force --context $CTX";
	doctl compute domain records delete $INGRESS_DOMAIN ${n} --force --context $CTX;
done;

## CREATION

for c in $(doctl kubernetes clusters list --format Name --context $CTX_K8S | grep -v Name ); do
    if [[ "$c" != "Name" ]]; then
        echo "$c"
        doctl kubernetes cluster kubeconfig show $c --context $CTX_K8S > $c.kubeconfig.yaml
        PUBIP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' --kubeconfig=./$c.kubeconfig.yaml)
        echo "PUBIP of ingress $c = $PUBIP"
    fi
done;