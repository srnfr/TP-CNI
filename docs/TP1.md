## Setup

* Installer kubectl

```shell
kubectl version --client
```

* Installer kubectx
* Installer le fichier kubeconfig

* Vérifier que l'accès fonctionne

```bash
kubectl get cluster-info
```

Vérifier que les Nodes sont biens vus :
```bash
kubectl get nodes -o wide
```

Notez 
* leurs IP publiques et privées
* la version du container runtime
* la version du lernel sous-jaçent

Installer  nsenter qui permet de se connecter dans les Nodes via un pod privilégié :
```bash
git clone https://github.com/alexei-led/nsenter.git
cd nsenter
./nsenter-node.sh <nom du node>
```
