# Setup initial

## Installer kubectl


```shell
kubectl version --client
```

## Installer kubectx

## Installer cilium

## Installer le fichier kubeconfig

## Vérifier que l'accès fonctionne

```bash
kubectl get cluster-info
```

Vérifier que les Workers Nodes sont biens vus :
```bash
kubectl get nodes -o wide
```
Notez 
* leurs IP publiques et privées
* la version du container runtime
* la version du lernel sous-jaçent

## Accès aux Node
Installer  nsenter qui permet de se connecter dans les Nodes via un pod privilégié :
```bash
git clone https://github.com/alexei-led/nsenter.git
cd nsenter
./nsenter-node.sh <nom du node>
```

## Statut de Cilium
```shell
cilium status
```
