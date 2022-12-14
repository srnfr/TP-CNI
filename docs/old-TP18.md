# Cilium avec et sans eBPF
Ce TP se déoule sur le Cluster KinD
//TO-DO

## kind

## Sommaire
  * [But du TP ](#but)
  * [Utiliser kind](#but)
  * [A. Création Cluster kind sans CNI](#but)
  * [Installation CNI cilium **sans** eBPF](#but)
  * [Vérification](#but)
  * [B. Création d'un nouveau Cluster kind sans CNI ni kube-proxy](#but)
  * [Installation CNI cilium **avec** eBPF](#but)
  * [Vérification](#but)

## But du TP

Constater le changement de comportement lors de l'accès à un NodePort suivant la configuration de Cilium
* no EBPF : perte de l'IP src
* EBPF : préservation de l'IP src
* EBPF + DSR

## Mise en place : utiliser KinD

## A.Création Cluster KinD sans CNI

Vérifier qu'aucun cluster kind ne tourne :

```bash
#kind get clusters
```

Si besoin effacer ceux qui seraient en cours :

```bash
# kind delete cluster --name <cluster-name>
```

Nous avons crée un miniscript pour faire ceci :
    
    ```bash
    ./clean-kind.sh
    ```


On utilise un config kind simple :
    
```yaml
## kind-config.yaml 
kind: Cluster
name: basic
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
#    listenAddress: 127.0.0.1
    protocol: TCP
  - containerPort: 443
    hostPort: 443
#    listenAddress: 127.0.0.1
    protocol: TCP
- role: worker
- role: worker
- role: worker
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443
  disableDefaultCNI: true
```

Lancer un cluster sans CNI :

```bash
# kind create cluster --config=kind-config.yaml
```

Au bout de quelques instants, le cluster répond, mais les Nodes ne sont pas Ready (normal, pas de CNI) :
    
```bash
# kubectl get nodes
NAME                  STATUS     ROLES           AGE     VERSION
basic-control-plane   NotReady   control-plane   9m32s   v1.24.0
basic-worker          NotReady   <none>          9m8s    v1.24.0
basic-worker2         NotReady   <none>          9m9s    v1.24.0
basic-worker3         NotReady   <none>          9m9s    v1.24.0
```

### Installation cilium sans EBPF 


```bash
# helm install  --namespace kube-system --repo https://helm.cilium.io cilium cilium --version 1.12.1 --values noebpf-values.yaml 
```
Au bout de quelques minutes, le cluster est Ready :

```bash
 kubectl get nodes -o wide
 ```
 ```
NAME                  STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION      CONTAINER-RUNTIME
basic-control-plane   Ready    control-plane   6m31s   v1.24.0   172.18.0.4    <none>        Ubuntu 21.10   5.15.0-46-generic   containerd://1.6.4
basic-worker          Ready    <none>          6m12s   v1.24.0   172.18.0.3    <none>        Ubuntu 21.10   5.15.0-46-generic   containerd://1.6.4
basic-worker2         Ready    <none>          6m11s   v1.24.0   172.18.0.2    <none>        Ubuntu 21.10   5.15.0-46-generic   containerd://1.6.4
basic-worker3         Ready    <none>          6m11s   v1.24.0   172.18.0.5    <none>        Ubuntu 21.10   5.15.0-46-generic   containerd://1.6.4
```

Et Cilium est OK :

```bash
# cilium status
    /¯¯\
 /¯¯\__/¯¯\    Cilium:         OK
 \__/¯¯\__/    Operator:       OK
 /¯¯\__/¯¯\    Hubble:         OK
 \__/¯¯\__/    ClusterMesh:    disabled
    \__/

```
Regardons la conf Cilium :
    
    ```bash
 cilium config view | egrep -i "(kube-proxy|tunnel|dsr|route|mode)"
auto-direct-node-routes                    true
bpf-lb-mode                                snat
identity-allocation-mode                   crd
**kube-proxy-replacement                     disabled**
tunnel                                     disabled
```

On constate également que Cilium et Kube-proxy sont présents :
   ```bash
# kubectl get ds -A
NAMESPACE     NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   cilium       4         4         4       4            4           kubernetes.io/os=linux   24m
kube-system   kube-proxy   4         4         4       4            4           kubernetes.io/os=linux   27m
   ```

Déployons un Pod unique et un svc NodePort

```bash
kubectl apply -f webdemo.yaml
```

L'image utilisée dans le déploiement est TODO, et permet de voir els détails de l'appelant

Notons quel est le NodePort du service (ici 32017)

```bash
kubectl get svc
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP          5m13s
svc-echoserver   NodePort    10.96.101.186   <none>        8080:32017/TCP   2m3s
```


Requetons ce svc et constatons que l'IP sec n'est pas préservée :

```bash
for i in {2..5}; do curl -s 172.18.0.$i:32017 | grep "Requesting" ; done

-> Requesting IP: 172.18.0.1:43594
-> Requesting IP: 172.18.0.3:57710
-> Requesting IP: 172.18.0.4:35104
-> Requesting IP: 172.18.0.5:54352
```

## B. Création d'un cluster sans kube-proxy

Cassons l'ancien cluster :
        
 ```bash
./clean-kind.sh
```

Créeon un nouveau cluster **sans** kube-proxy :
    

```bash
kind create cluster --config=kind-config-noproxy.yaml
```


### Installation cilium avec EBPF 

Installation ensuite cilium :

```bash
 helm install  --namespace kube-system --repo https://helm.cilium.io cilium cilium --version 1.12.1 --values ebpf-values.yaml 
```

Cilium est  OK :
        
```bash
# cilium status

    /¯¯\
 /¯¯\__/¯¯\    Cilium:         OK
 \__/¯¯\__/    Operator:       OK
 /¯¯\__/¯¯\    Hubble:         disabled
 \__/¯¯\__/    ClusterMesh:    disabled
    \__/

```

Vérifions la conf :
        
```bash
cilium config view | egrep -i "(kube-proxy|tunnel|dsr|route|mode)"
```

```
auto-direct-node-routes                        true
bpf-lb-mode                                    snat
identity-allocation-mode                       crd
**kube-proxy-replacement                         strict**

kube-proxy-replacement-healthz-bind-address    
tunnel                                         disabled
```

Redémarrons cilium :
```bash
kubectl rollout restart daemonset cilium -n kube-system
```

Nettoyons kube-proxy (daemonset et configmap):
```bash
kubectl -n kube-system delete ds kube-proxy
kubectl -n kube-system delete cm kube-proxy
```

Vérifions que les règles IPTables sont bien supprimées :
```bash
for node in worker worker2 worker3 control-plane; do docker exec basic-$node /usr/sbin/iptables-save | grep -c KUBE ; done
18
18
18
18
```

Vérifions la config étendue :
```bash
kubectl -n kube-system exec ds/cilium -- cilium status --verbose
```

## Création Cluster kind sans CNI

On efface le cluster précedent

```bash
kind delete cluster --name basic
```

On lance un nouveau cluster toujours sans CNI

```bash
kind create cluster --config=kind-config.yaml
```

Le cluster est accessible: 

```bash
kubectl cluster-info
```

```
Kubernetes control plane is running at https://0.0.0.0:6443
CoreDNS is running at https://0.0.0.0:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## Installation cilium avec EBPF

Cette fois-ci, on installe cilium avec eBPF

```bash
helm upgrade --install --namespace kube-system --repo https://helm.cilium.io cilium cilium --values ebpf-values.yaml
```

Au bout d'un moment, le cluster converge :
    
```bash
# cilium status
    /¯¯\
 /¯¯\__/¯¯\    Cilium:         OK
 \__/¯¯\__/    Operator:       OK
 /¯¯\__/¯¯\    Hubble:         OK
 \__/¯¯\__/    ClusterMesh:    disabled
    \__/

```
### Préservation de l'IP src lors de l'accès à un NodePort

Au niveau du svc, si on configure `externalTrafficPolicy: Local`, seul le Node portant des Pods répondra aux requêtes.

```bash
for i in {2..5}; do curl -s 172.18.0.$i:30107 | grep "Requesting" ; done
-> Requesting IP: 172.18.0.1:36974
```

Effectivement, si on fait
```bash
curl  172.18.0.2:30107
```
on obtient :
```
curl: (7) Failed to connect to 172.18.0.2 port 30107 after 0 ms: Connection refused 
```

Au niveau du svc, si on configure `externalTrafficPolicy: Cluster` , les Nodes vont envoyer le traffic vers le Node portant le Pod :

```bash
for i in {2..5}; do curl -s 172.18.0.$i:30107 | grep "Requesting" ; done
```
```
-> Requesting IP: 172.18.0.1:54762
-> Requesting IP: 172.18.0.1:49620
-> Requesting IP: 172.18.0.1:36964
-> Requesting IP: 172.18.0.1:53814
```
On constate que l'IP est préservée (c'est grace à eBPF, en mode IPtables, l'IP n'est pas préservée).

## Vérication de l'activation de eBPF

## Activation de DSR (Direct Server Return)

VXLAN doit être désactivé
https://docs.cilium.io/en/v1.9/gettingstarted/kubeproxy-free/

```bash
cilium config view | egrep -i "(proxy|ebpf|tunnel|dsr|route|node)"
```

```
bpf-lb-mode                                    dsr
enable-l7-proxy                                true
kube-proxy-replacement                         strict
kube-proxy-replacement-healthz-bind-address    
sidecar-istio-proxy-image                      cilium/istio_proxy
tofqdns-proxy-response-max-delay               100ms
tunnel                                         disabled
```

## Demonstration de DSR

Déployons un Pod unique et un svc NodePort

```bash
kubectl apply -f webdemo.yaml
```

Notons sur quel Node le POD est déployén (ici basic-worker)

```bash
# kubectl get pods -o wide
NAME                                 READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
deploy-echoserver-7ccc684445-msflx   1/1     Running   0          34s   10.244.1.199   basic-worker   <none>           <none>
```



Nous viserons donc un Node différent de celui où est déployé le POD, par exemple basic-worker2 (ici 172.18.0.2).

Notons quel est le NodePort du service (ici 31503)

```bash
kubectl get svc
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes       ClusterIP   10.96.0.1       <none>        443/TCP          5m13s
svc-echoserver   NodePort    10.96.101.186   <none>        8080:31503/TCP   2m3s
```


---

[Revenir au sommaire](../README.md) 