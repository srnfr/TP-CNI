## Namespace et libre circulation


Créer le namespace blue 
```shell
kubectl create ns blue
```

Déployer un pod dans le namespace blue
```shell
kubectl run -it --rm --restart=Never --image=nicolaka/netshoot --namespace=blue debug
```

Depuis ce pod, vérifier que vous avez accès au redis
```shell
nc -p 6379 redis-leader 
```

Verfier que vous pouvez sortir sur Internet sans restriction
```shell
curl https://perdus.com
curl http://23.23.23.23
curl https://myip.sreytan.workers.dev
```