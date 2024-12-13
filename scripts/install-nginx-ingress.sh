#!/bin/bash

echo "Install de nginx ingress de la marketplace DO sur :"

for c in $(doctl kubernetes clusters list --format ID | grep -v ID ); do
    if [[ "$c" != "Name" ]]; then
        echo "- $c"
	doctl kubernetes 1-click install $c --1-clicks nginx-ingress
    fi
done;
