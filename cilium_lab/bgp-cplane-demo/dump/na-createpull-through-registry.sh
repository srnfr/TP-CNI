#!/bin/bash
#cf https://maelvls.dev/docker-proxy-registry-kind/

docker run -d --name proxy --restart=always --net=kind \
  -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io registry:2
