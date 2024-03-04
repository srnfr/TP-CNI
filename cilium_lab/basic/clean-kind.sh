#!/bin/bash

for c in $(kind get clusters); do 
	##echo $c ; 
	kind delete cluster --name $c
done

./10-destroy-all.sh
