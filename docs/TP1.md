# Setup initial

## Installer `kubectl`


```shell
kubectl version --client
```

## Installer `kubectx` cli

## Installer `cilium`

## Installer le fichier kubeconfig

## Vérifier que l'accès fonctionne

```bash
kubectl get cluster-info
```

Vérifier que les Workers Nodes sont biens vus :
```bash
kubectl get nodes -o wide
```
Notez :
* leurs IP publiques et privées
* la version du container runtime
* la version du kernel sous-jaçent

## Accès aux Node
Installer  `nsenter` qui permet de se connecter dans les Nodes via un pod privilégié :
```bash
git clone https://github.com/alexei-led/nsenter.git
cd nsenter
./nsenter-node.sh <nom du node>
```

## Statut de Cilium
Dans ce setup, Cilium est déjà installé comme CNI.

```shell
cilium version
```

```shell
cilium status
```
cilium status
```

## Installer `stern`

`Stern` permet de facilement consulter les logs de plusieurs pods en même temps.
