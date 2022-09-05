## Premier NP Ingress

Creez un Network Policy (NP) en ingress qui restreint l'accès à redis-leader uniquement depuis les redis-follower et les frontend

```yaml
## np-allow-redis-leader.yaml
```

Appliquer cette politique
```shell
kubectl apply -f np-allow-redis-leader.yaml
```

Vérifier qu'elle est bien appliquée
```shell
kubectl get netpol -A
```

```shell
kubectl describe netpol allow-redis-leader -n default
```

Vérifier que redis-leader n'est plus accessible depuis le debug pod
```shell
nc -p 6379 redis-leader
```

Vérifier que redis-leader est accessible depuis redis-slave
```shell
nc -p 6379 redis-leader
```

Cleanup : retirons la NP
```shell
kubectl delete -f np-allow-redis-leader.yaml
```