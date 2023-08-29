#!/bin/bash

##helm repo add projectcalico https://projectcalico.docs.tigera.io/charts

##helm show values projectcalico/tigera-operator --version v3.24.0

##kubectl create namespace tigera-operator

##helm install calico projectcalico/tigera-operator --version v3.24.0 -f calico-values.yaml --namespace tigera-operator

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.0/manifests/tigera-operator.yaml

kubectl create -f custom-resources.yaml

##watch kubectl get pods -n calico-system
