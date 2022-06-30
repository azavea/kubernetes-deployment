# Public or private access in AWS
Created: 2022-06-30, 14:46

Amazon EKS can start up a cluster that is either publicly- or privately-accessible.  This refers to the K8S API endpoint.  The cluster nodes are usually launched inside private subnets; launching cluster nodes in a public subnet is possible, but inadvisable.

A public EKS API endpoint can be secured through the use of the [[aws-auth ConfigMap]], restricting access to only authorized users/roles/accounts.  This is what is meant in documentation about using role-based access control (RBAC) to control access.

Nodes/services in private subnets can be exposed to the wider internet through the use of load balancers, which can be created automatically by EKS when the [[#^service-type|service type]] is set appropriately.  It is also possible to use the [[AWS Load Balancer Controller]] to create internet-facing application load balancers for an ingress.

## Links/Tags/References
1. https://medium.com/devops-mojo/kubernetes-service-types-overview-introduction-to-k8s-service-types-what-are-types-of-kubernetes-services-ea6db72c3f8c ^service-type
2. #AWS