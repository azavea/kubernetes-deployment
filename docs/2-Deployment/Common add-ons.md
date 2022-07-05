# Common add-ons
Created: 2022-06-29, 17:53
#MOC

Add-ons provide fundamental system services to a Kubernetes cluster.  They appear to need to be added as part of the cluster initialization.  This is in contrast to microservices that can be added to the cluster at a later stage.

## Kubernetes system
These add-ons are available to any Kubernetes cluster, regardless of which cloud provider.

1. [[CoreDNS]]
2. [[kube-proxy]]
3. [[Kubernetes autoscaler]]

## AWS-specific
These add-ons apply only to clusters running on EKS.

1. [[VPC CNI]]
2. [[Karpenter]]
3. [[AWS Load Balancer Controller]]