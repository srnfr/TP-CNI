# Setup initial

## Installer `kubectl`


```shell
kubectl version --client
```

## Installer `kubectx`

## Installer `cilium` cli
(Cilium sera pré-installé sur votre Cluster)

## Récupérer et installer le fichier kubeconfig
L'animateur vous fournit le lien de téléchargement
Enregistrez le dans votre répertoire home sous le nom `.kube/config`

## Vérifier que l'accès fonctionne

```bash
kubectl cluster-info
```

Pour rappel un cheat-sheet est disponible [ici](https://kubernetes.io/fr/docs/reference/kubectl/cheatsheet/)

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
Le code est disponile sous [https://github.com/stern/stern](https://github.com/stern/stern).
