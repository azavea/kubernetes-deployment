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
- Compute capacity will be supplied by two groups of nodes:
	1. Base capacity is provided either by a managed autoscaling group or via Fargate
		- These nodes will run system services
		- These nodes will be tagged as `node-type: core`
		- These nodes will be provisioned using low-cost instances that are not optimized for heavy computation
	2. Application pods will run on [[Karpenter]]-provisioned nodes
		- The instance types for these nodes will be determined based on pod affinities
		- These nodes will be tagged as `node-type: worker`; application pods should set their affinities to target these nodes
- The reason to separate node types has to do with pod and image life cycles
	- System services should be long-lived, stable deployments that change infrequently; applications can have rapid turnover during development, possibly requiring many changes to the underlying images, which can be cached on nodes; if the images become stale, it can be difficult to force the images to be re-pulled, leading to errors
	- Allows for cheaper spot instances for application loads, resilient on-demand instances for core services
- All nodes are in a private VPC, which requires a means of egress from those nodes to the open internet
	- For an internal IPv4 addressing scheme, we have to rely on a NAT gateway or other internet gateway.  This incurs an extra cost.
	- For an internal IPv6 addressing scheme, no additional infrastructure is required.
- All cluster resources—base nodes, worker nodes, and other AWS-managed resources, like RDS instances—share a common security group.  It's not clear if more differentiation is required.
- Access to AWS resources from running pods should be managed through [[IAM roles for service accounts (IRSA)]].

## Code organization
Typically, Terraform code that is intended to be reused by other projects is broken out into modules that can easily be included.  This approach works well for resources that need to be replicated across many different projects.  While we do provide some module code, our deployment is structured differently since we are attempting to deploy clusters infrequently, and so the module approach is not entirely applicable.

Instead, this repository presents a staged deployment by essentially collecting a number of related Terraform projects into a single repository that reuses some common script infrastructure.  There are three layers to the deployment:
1. The [hardware](https://github.com/azavea/kubernetes-deployment/tree/master/deployment/aws-terraform/0-hardware) stage provides the cluster and networking infrastructure.
2. The [services](https://github.com/azavea/kubernetes-deployment/tree/master/deployment/aws-terraform/1-services) stage installs vital [[Middleware|middleware]] onto the base cluster; this includes the autoscaler that makes sure that applications have the compute resources they need to run.  This stage also provides AWS resources that will be common to multiple applications.
3. The [application](https://github.com/azavea/kubernetes-deployment/tree/master/deployment/aws-terraform/application) stage is where the user-facing resources that will commonly be placed onto our deployed clusters will live.

> Note that the hardware and services stages are separated for practical reasons only; the services are deployed and managed using the `helm` and `kubernetes` providers, which depend on parameters set by the hardware module, and it's generally not advisable to have providers depend on the output of resources in the same Terraform module.

Apart from the hardware stage, all other deployment units essentially act as separate terraform projects.  These rely on a [data source](https://github.com/NASA-IMPACT/kubernetes-deployment/tree/master/modules/aws/cluster) that we provide to tap into an existing cluster by name.  This module uses the [[#^data-source|Hashicorp data source]] to expose some fields that are common to the Terraform [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest).

## Deploying a cluster
Deployment instructions are maintained in a separate [README](https://github.com/azavea/kubernetes-deployment/tree/master/deployment/aws-terraform/README.md).

## Links/Tags/References
1. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster ^data-source