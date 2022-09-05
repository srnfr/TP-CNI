## Egress Network Policy


Dans le NS blue, créer et appliquer une Egress NP qui empeche l'accès 23.23.23.23 en HTTP mais qui permette les autres flux.

Tester :
```shell
kubectl run -it --rm --restart=Never --image=nicolaka/netshoot --namespace=blue debug
# curl http://23.23.23.23
# curl http://1.1.1.1
```


## Cleanup : retirons la NP
