## Cloisonnement par NS

Pour plus de simplicité nous cloisonnons les NS entre eux


Créeons un NP de cloisonnement :
```yaml
## np-ns-isolation.yaml
```

Appliquons là au NS default
```shell
kubectl apply -f np-ns-isolation.yaml -n default
```

Vérifier que le NP est bien appliqué
```shell
kubectl get netpol -A
```

Vérifier que depuis le NS blue, on n'a plus accès à redis-leader
```shell
kubectl run -it --rm --restart=Never --image=nicolaka/netshoot --namespace=blue debug
# nc redis-leader.default.svc 6379
```
