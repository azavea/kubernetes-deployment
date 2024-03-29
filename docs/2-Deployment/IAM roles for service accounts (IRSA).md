# IAM roles for service accounts (IRSA)
Created: 2022-06-30, 14:52

Pods in a Kubernetes cluster may want to have access to AWS services.  Instead of constructing a capacious IAM role and applying it to every node in the cluster (and therefore to all pods running on those nodes), it may be desirable to define a set of [[#^service-accounts|service accounts]], each with narrower IAM permissions, tailored to the tasks that pods in a service account will need to do.  This is the the function of IRSA.

> **Note:** IRSA is an AWS-specific service.

IRSA requires an OpenID connect (OIDC) provider to authenticate the pod?/node?/service account? #question in order to grant access to the AWS services.  This OIDC provider will need to be provisioned at the time of cluster creation.

## Annotating service accounts
A service account to which the IAM role will be associated needs to be provided.  This may require creating one (see, for instance, this [[#^terraform-service-account|Terraform resource]]).  This service account must have an annotation added to its metadata giving the ARN of the IAM role that defines the permissions for the service account:
```yaml
metadata:
  ...
  annotations:
    eks.amazonaws.com/role-arn: <ARN>
```

For better or worse, the Terraform IRSA module does not make it possible to automatically tag a service account with this annotation.  We need to use an additional resource to make the connection:
```terraform
resource "kubernetes_annotations" "annotation_name" {
  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    name = "service-account-name"
    namespace = "namespace"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": aws_iam_role.target.arn
  }
}
```

See the [[#^aws-docs|AWS docs]] for more details.

## Links/Tags/References
1. [Amazon documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) ^aws-docs
2. https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ ^service-accounts
3. https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account ^terraform-service-account
4. https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v5.5.2/modules/iam-role-for-service-accounts-eks ^
5. #AWS