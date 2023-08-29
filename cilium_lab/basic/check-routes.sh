#!/bin/bash

kubectl -n kube-system exec ds/cilium -- ip route list scope global
