#!/bin/bash

set -x

for v in 207.154.240.227 159.89.8.64 159.89.24.108 134.209.250.14 159.89.8.180 159.89.16.66 134.209.250.24 134.122.68.99 ; do
	ssh root@${v} "sed -i 's/\/mnt\//\/home\//' /home/cilium_lab/basic/*.sh"
done;
