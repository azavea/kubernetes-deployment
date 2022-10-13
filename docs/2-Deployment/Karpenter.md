# Karpenter
Created: 2022-06-30, 16:07

Karpenter orchestrates autoscaling of cluster nodes.  The strength of Karpenter over the [[Kubernetes autoscaler]] is that one does not need to configure a host of autoscaling groups as part of deploying the cluster—thereby eliminating the need to anticipate the demands of the workload that will run on the cluster.  Karpenter will examine the pod's needs, and with a knowledge of the menu of instance types will create nodes to fit the workload and place the pods on the set of managed nodes.  This process will respect the pod taints and affinities to make sure that the pod has the resources it requires.

In addition, Karpenter is more efficient about the allocation of resources than the Kubernetes autoscaler.  It will be smart about using existing resources and creating new nodes that meet the demands of the workload.

Karpenter is an open source project, but it's main disadvantage is that it is developed by Amazon, and currently only supports that provider.

## Setting up the provisioner
Configuring Karpenter involves the creation of a manifest of `kind: Provisioner`.  Full documentation is [[#^provisioner-config|here]].  In practice, the provisioner configuration needs to be set so that new nodes are placed into the correct subnets and security groups.  Because base capacity needs to be provided (Karpenter, for instance, needs a place to run its pods), the security group for that base node group should be used or additional configuration will be needed to allow for communication with the default node group.

It may also be desirable to identify the nodes created by Karpenter, so that application pods can target them.  A useful way to approach this is through the use of node labels, which can interact with node affinities in pod specs.  Note that the [[#^k8s-labels|well-known labels]] are generally [[#^karpenter-label-restrictions|prohibited]] for use as labels.  For our purposes, we'll apply the `node-type` label with a value of `worker` for Karpenter-created nodes (`core` will be applied to nodes in the base node group).

A reference provisioner configuration:
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  labels:
    node-type: worker
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: [...]
  limits:
    resources:
      cpu: 1000
  provider:
    subnetSelector:
      kubernetes.io/cluster/<cluster-name>: '*'
    securityGroupSelector:
      "aws:eks:cluster-name": <cluster_name>
    instanceProfile:
      KarpenterNodeInstanceProfile-<cluster_name>
  ttlSecondsAfterEmpty: 30
```
Note that the `subnetSelector` and `securityGroupSelector` are targeting tags on the AWS resources.  EKS documentation can be consulted to see what tags will be assigned to various resources.

## Links/Tags/References
1. https://karpenter.sh/
2. https://karpenter.sh/v0.8.1/provisioner/ ^provisioner-config
3.  https://kubernetes.io/docs/reference/labels-annotations-taints/ ^k8s-labels
4. https://github.com/aws/karpenter/issues/1802 ^karpenter-label-restrictions
5. #AWS