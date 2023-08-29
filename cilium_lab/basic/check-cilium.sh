#!/bin/bash

kubectl -n kube-system exec ds/cilium -- cilium status --verbose
cilium status
