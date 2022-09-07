#!/bin/bash

ID=0

if [ $# -gt 0 ]; then
    ID=$ARG1
fi
echo "Recup k8-do-grp$ID"
doctl kubernetes cluster kubeconfig save k8-do-grp$ID 

echo "Current context :"
kubectx -c
