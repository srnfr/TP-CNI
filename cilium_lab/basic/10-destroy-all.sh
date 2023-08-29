#!/bin/bash


containerlab destroy clusters -t /mnt/cilium_lab/bgp-cplane-demo/topo.yaml 
for c in $(kind get clusters); do
	kind delete cluster --name $c
done
