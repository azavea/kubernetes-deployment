# Azavea-standard Kubernetes architecture
Created: 2022-07-08, 13:31
#MOC 

> #WIP The contents of this note are still evolving.  Consider this a work in progress.

Using Kubernetes as the basis of an infrastructure within Azavea is an ongoing research effort.  As we better understand how to use this technology, we will be better able to roll out projects into these environments, and to perhaps one day offer it as a solution for client projects.

The basic principles undergirding a k8s deployment is fairly clear:
1. [[Single or multiple clusters|Sharing clusters]] to the greatest extent possible to amortize overhead costs.
2. Providing [[Middleware|core services]] that can be used by outward-facing applications.
	- Roughly equivalent to AWS services like SNS, SQS, Step Functions, etc.
3. Placing applications into [[Namespaces|namespaces]] to isolate resources and provide a means to [[Tracking resource usage|track utilization]] for billing purposes and to [[Giving access to other users|partition administrative roles]].

The specifics of how to manage a cluster of this description are less clear:
1. #question What cluster management tools are best?
2. #question How do we divide deployments into smaller pieces to avoid a massive IAC description that is impossible to maintain?

## Basic architecture
- We'll start by maintaining a single cluster.  Future efforts may be undertaken to expand to two or more clusters for staging and/or testing.
- Compute capacity will be supplied by two groups of nodes:
	1. Base capacity is provided either by a managed autoscaling group or via Fargate
		- These nodes will run system services
		- These nodes will be tagged as `node-type: core`
		- These nodes will be provisioned using low-cost instances that are not optimized for heavy computation
	2. Application pods will run on Karpenter-provisioned nodes
		- The instance types for these nodes will be determined based on pod affinities
		- These nodes will be tagged as `node-type: worker`; application pods should set their affinities to target these nodes
	- The reason to separate node types has to do with pod and image life cycles
		- System services should be long-lived, stable deployments that change infrequently; applications can have rapid turnover during development, possibly requiring many changes to the underlying images, which can be cached on nodes; if the images become stale, it can be difficult to force the images to be re-pulled, leading to errors
		- Allows for cheaper spot instances for application loads, resilient on-demand instances for core services

## Code organization
This repository will host a module to describe the infrastructure needed to set up a standard cluster.  That involves the creation of a VPC and EKS cluster, plus the installation of some basic add-ons, including [[Karpenter]] for autoscaling and the [[AWS Load Balancer Controller]] to allow applications to create application load balancer-mediated ingresses to cluster services.

This module can be called on by other projects, but it will serve another part of this repository that will eventually encapsulate the multiple cluster architecture (production/staging/etc.).  That part of the repository will house the necessary deployment scripts that setup backends to track state, and so forth.  This will be the portion of the repository that does the actual work of deploying and updating the cluster.

Applications will tap into these existing clusters by using the `aws_eks_cluster` [[#^data-source|data source]], which should provide information about the needed resources, including VPC and OIDC provider.  A prototype of this mechanism will need to be tested.

## Links/Tags/References
1. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster ^data-source