#!/bin/bash

if [ -f ./topo.yaml ]; then
	containerlab destroy clusters -t ./topo.yaml 
fi


for c in $(kind get clusters); do
	kind delete cluster --name $c
done
