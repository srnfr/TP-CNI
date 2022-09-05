## Deployer une première application


Cloner le guestbook PHP
```shell
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples
cd kubernetes-engine-samples/guestbook
```

L'architecture du guestbook est la suivante:
https://cloud.google.com/static/kubernetes-engine/images/guestbook_diagram.svg

Déployer redis-leader et son service :
```shell
kubectl apply -f redis-leader-deployment.yaml
kubectl apply -f redis-leader-service.yaml
```

Déployer redis-follower et son service :
```shell
kubectl apply -f redis-follower-deployment.yaml
kubectl apply -f redis-follower-service.yaml
```

Déployer le frontend :
```shell
kubectl apply -f frontend-deployment.yaml
```

Vérifier que les replicas sont bien déployés :
```shell
kubectl get pods -l app=guestbook -l tier=frontend
```

Exposer le service frontend :
```shell
kubectl apply -f frontend-service.yaml
```

Trouver l'IP de publication et vérifier avec votre navigateur que l'application fonctionne.