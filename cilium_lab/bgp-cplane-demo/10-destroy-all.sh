#!/bin/bash


containerlab destroy clusters -t topo.yaml 
for c in $(kind get clusters); do
	kind delete cluster --name $c
done
