#!/bin/bash

kubectl -n kube-system exec ds/cilium -- cilium bpf tunnel list
