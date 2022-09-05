# Le reseau vu depuis les Pods

Déployer un Daemonset de debug
```shell
kubectl create daemonset debug --image=nicolaka/netshoot
```

Vérifier que les pods sont bien créés
```shell
kubectl get ds -o wide
```

Se connecter dans un pod (remplacer xxxx par une valeur correcte):
```shell
kubectl exec -it debug-xxxxx -- /bin/bash
```

Vérifier que le DNS fonctionne pour les noms de services
```shell
host hello-world.default.svc.cluster.local
```

Vérifier qu'on peut pinguer les autres pods (remlplacer xxxx par une valeur correcte):
```shell
ping hello-world-xxxxx
```

Nettoyer
```shell
kubectl delete svc hello-world
kubectl delete deployment hello-world
```
