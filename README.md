# TP-CNI

## Sommaire
1. [Setup Initial](/docs/TP01.md)
2. [Deployer et inspecter un svc ClusterIP puis LoadBalancer et NodePort](/docs/TP02.md)
3. [Le réseau vu depuis les Pods](/docs/TP03.md)
4. [Deployer et débugger une premiere application](/docs/TP04.md)
5. [NameSpace et libre circulation](/docs/TP05.md)
6. [Première Ingress Network Policy](/docs/TP06.md)
7. [Cloisonnement par NameSpace](/docs/TP07.md)
8. [Egress Nework Policy](/docs/TP08.md)
9. [Monitoring & Métriques réseau *](/docs/TP09.md)
10. [Filtrage de flux L7](/docs/TP10.md)
11. [Preservation de l'IP source avec `externalTrafficPolicy`](/docs/TP11.md)
12. [eBPF et DSR *](/docs/TP12.md)
13. [Routage et annonces BGP *](/docs/TP13.md)
14. [Hubble *](/docs/TP14.md)
15. [Ingress Controller en HTTP et HTTPS](/docs/TP15.md) 
16. [eBPF Network Deep Dive](/docs/TP16.md)
17. [Securisation grandeur nature : Hipster Shop](/docs/TP17.md)
18. [Audit Mode](/docs/TP18.md)
19. [Filtrage L7 en autonomie](/docs/TP19.md)

Les TPs dont les noms finissent en (*) se déroulent sur une VM avec un cluster [KinD](https://kind.sigs.k8s.io/).  
Les autres se déroulent sur l'opérateur de Cloud Public DigitalOcean ([lien sponsorisé : 200€ sur 60j](https://m.do.co/c/ffe6205525bf)).

Ces TPs ont été conçus et écrits par [@srnfr](https://github.com/srnfr/) dans le cadre de la formation "Cilium pour les équipes réseaux"

Leur usage est possible dans le cadre de la [Licence GPL2.0](./LICENSE.md).

Vous pouvez utiliser cet [aide-memoire des commandes kubernetes](/docs/scaleway-kubernetes-cheatsheet.pdf).
