#!/bin/bash
source ./.env

if ([ -z "${CTX_K8S}" ]); then
	echo "CTX_K8S  not set, using default"
	CTX_K8S="default"
fi

echo "Install de nginx ingress de la marketplace DO sur :"

for c in $(doctl kubernetes clusters list --format ID --context $CTX_K8S | grep -v ID ); do
    if [[ "$c" != "Name" ]]; then
        echo "- $c"
	doctl kubernetes 1-click install $c --1-clicks nginx-ingress --context $CTX_K8S
    fi
done;
