#!/bin/sh

###
cd /workspace/TP-CNI
git pull

###
if [ -z "$2" ]; then 
   echo "Syntax: $0 <numero de cluster> <entropy>"
   exit -1
fi

GRP=$1

ENTROPY=$2
URL="https://kconfig.fra1.digitaloceanspaces.com/k8-do-grp${GRP}-${ENTROPY}.kubeconfig.yaml"
echo "Downloading $URL ..."

wget -nv $URL -O ~/.kube/config
chmod o-r ~/.kube/config

kubectl cluster-info

if [ $? -ne 0 ]; then 
  echo "mauvais kubeconfig!"
  exit -2;
fi

## Install Cilium et autres
if [ -f /usr/local/bin/cilium ]; then
  echo "Cilium deja installé"
else
  export CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
  export GOOS=linux
  export GOARCH=amd64
  curl -s -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-${GOOS}-${GOARCH}.tar.gz{,.sha256sum}
  sha256sum --check cilium-${GOOS}-${GOARCH}.tar.gz.sha256sum
  sudo tar -C /usr/local/bin -xzvf cilium-${GOOS}-${GOARCH}.tar.gz
  rm -f cilium-*.tar.gz{,.sha256sum}

  kubectl krew install cilium
  kubectl krew index add kvaps https://github.com/kvaps/krew-index
  kubectl krew install kvaps/node-shell

  for i in $(kubectl get node -o json | jq -r '.items[].metadata.name'); do
	  kubectl cilium exec $i cilium version
	  kubectl cilium exec $i cilium status
  done
  kubectl krew install stern
fi

cilium version
cilium status

echo "#-----------------"
echo "Votre groupe : ${GRP}"
