#!/bin/sh

if [ -z "$1" ]; then 
   echo "Syntax: $0 <numero de cluster>"
   exit -1
fi

if [ ! -f ~/.kube/config ]; then 
  wget https://kconfig.fra1.digitaloceanspaces.com/k8-do-grp${$1}.kubeconfig -O ~/.kube/config
fi

kubectl cluster-info
if [ $? -ne 0 ]; then 
  echo "mauvais kubeconfig!"
  exit -2;
fi

CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
GOOS=linux
GOARCH=amd64
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-${GOOS}-${GOARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-${GOOS}-${GOARCH}.tar.gz.sha256sum
sudo tar -C /usr/local/bin -xzvf cilium-${GOOS}-${GOARCH}.tar.gz
rm cilium-${GOOS}-${GOARCH}.tar.gz{,.sha256sum}

kubectl krew install cilium
kubectl krew index add kvaps https://github.com/kvaps/krew-index
kubectl krew install kvaps/node-shell
for i in $(kubectl get node -o json | jq -r '.items[].metadata.name'); do
	kubectl cilium exec $i cilium version
	kubectl cilium exec $i cilium status
done
kubectl krew install stern

cilium version
cilium status
