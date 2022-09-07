## Premieres decouvertes

Effectuer un premier déploiement
```shell
kubetcl create deployment hello-world --image=stefanprodan/podinfo:4.0.3
```

Inspectez-le (retrouvez l'IP du Pod)
```shell
kubectl get pod -o wide
```

Changer le nombre de replicas 
```shell
kubectl scale deployment hello-world --replicas=5
```

Exposer le deploiement avec un Load Balancer
```shell
kubectl expose deployment hello-world --type=LoadBalancer --port=80
```

Determiner l'IP public du Load Balancer
```shell
kubectl get svc
```

Visiter le site web avec votre navigateur et verifier que le load balancer fonctionne

Constater les Endpoints attachés au svc :
```shell
kubectl describe svc/hello-world
```

Changer la version de l'image deployée
```shell
kubectl set image deployment/hello-world podinfo=stefanprodan/podinfo:3.1.0
```

Observer le déploiement des pods dans cette version :
```shell
kubectl rollout status deployment/hello-world
```

```shell
kubectl get pod -o wide
```

Vérifier que les Endpoints ont changé :
```shell
kubectl describe svc/hello-world
```
Changeons le type de déploiement pour passer de `LoadBalancer` à `Nodeport`
```bash
kubectl patch svc/hello-world -p '{"spec": {"type": "NodePort"}}'
kubect get svc
```

Notez la publication sur un port dynamique > 30.000
Naviguez sur ce port sur chacun des noeuds et constatez...