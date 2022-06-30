# CoreDNS
Created: 2022-06-30, 16:01

In order to have named services internal to the cluster, the CoreDNS add-on must be installed.  This will run at least two replicas of the `coredns` pod in the `kube-system` namespace.  This has some implications for the smallest size instance that can run your minimal cluster, as it will eat into your pod budget.

CoreDNS is #question not required?, but it more configurable than the basic [[#^kube-dns|kube-dns]].

## Links/Tags/References
1. https://coredns.io/
2. https://kubernetes.io/docs/tasks/administer-cluster/coredns/
3. https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/ ^kube-dns