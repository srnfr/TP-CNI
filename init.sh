#!/bin/sh

###
# Test GitPod or GitHub CodeSpaces
[ -d "/workspace/TP-CNI" ] && cd /workspace/TP-CNI
[ -d "/workspaces/TP-CNI" ] && cd /workspaces/TP-CNI

git pull

###
if [ -z "$2" ]; then 
   echo "Syntax Error: $0 <numero de cluster> <entropy>"
   exit 0
fi

GRP=$1

ENTROPY=$2
URL="https://kconfig.fra1.digitaloceanspaces.com/k8-do-grp${GRP}-${ENTROPY}.kubeconfig.yaml"
echo "Downloading $URL ..."

[ ! -d ~/.kube ] && mkdir ~/.kube
wget -nv $URL -O ~/.kube/config

echo "Securing access to kubeconfig"
chmod o-r ~/.kube/config
chmod g-r ~/.kube/config

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
fi

cilium version
cilium status

## Install Hubble 
if [ -f /usr/local/bin/hubble ]; then
  echo "Hubble deja installé"
else
  HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
  HUBBLE_ARCH=amd64
  if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
  curl -s -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
  sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
  sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
  rm -f hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
fi


## Install Krew
echo "--- Krew ---"
kubectl krew list
if [ $(kubectl krew list  | wc -l) -lt 4 ] ; then
  kubectl krew install cilium
  kubectl krew index add kvaps https://github.com/kvaps/krew-index
  kubectl krew install kvaps/node-shell
  kubectl krew install stern
fi

if ! k9s version ; then
	echo "Installation de k9s"
	curl -sS https://webinstall.dev/k9s | bash
	k9s version
else
	echo "k9s deja installe"
fi

for i in $(kubectl get node -o json | jq -r '.items[].metadata.name'); do
	  kubectl cilium exec $i cilium version
	  kubectl cilium exec $i cilium status
done


echo "----"
echo "Votre groupe : ${GRP}"
