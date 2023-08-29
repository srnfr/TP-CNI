#!/bin/bash

for c in $(kind get clusters); do 
	##echo $c ; 
	kind delete cluster --name $c
done

/mnt/cilium_lab/bgp-cplane-demo/10-destroy-all.sh
