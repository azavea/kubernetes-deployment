# Karpenter
Created: 2022-06-30, 16:07

Karpenter orchestrates autoscaling of cluster nodes.  The strength of Karpenter over the [[Kubernetes autoscaler]] is that one does not need to configure a host of autoscaling groups as part of deploying the cluster—thereby eliminating the need to anticipate the demands of the workload that will run on the cluster.  Karpenter will examine the pod's needs, and with a knowledge of the menu of instance types will create nodes to fit the workload and place the pods on the set of managed nodes.  This process will respect the pod taints and affinities to make sure that the pod has the resources it requires.

In addition, Karpenter is more efficient about the allocation of resources than the Kubernetes autoscaler.  It will be smart about using existing resources and creating new nodes that meet the demands of the workload.

Karpenter is an open source project, but it's main disadvantage is that it is developed by Amazon, and currently only supports that provider.

## Links/Tags/References
1. https://karpenter.sh/
2. #AWS