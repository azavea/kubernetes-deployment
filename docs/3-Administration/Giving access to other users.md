# Giving access to other users
Created: 2022-07-08, 14:18

When creating an EKS cluster, not just any user has the capability to work with the cluster.  By default, the user that created the cluster has administrative privileges.  Any other user who wishes to interact directly with the cluster—as opposed to with the applications run by the cluster through, for instance, web endpoints—must be granted specific authorization.  This is provided, on AWS, via the `aws-auth` ConfigMap.

A [[#^configmap-docs|ConfigMap]] is a standard Kubernetes object used to configure applications.  In the case of EKS access, the `aws-auth` ConfigMap is the mechanism used to grant access to various accounts, roles, and/or users.  It is possible to tune this ConfigMap directly via `kubectl` or Lens, but persistent configuration changes should be made via more durable and discoverable pathways, such as Terraform, `eksctl`, or some other infrastructure management tool.  If using Terraform for deployment, one can pass a list of authorized users to the [[#^auth-users|aws_auth_users]] input to the EKS module (or to the `aws_auth_roles` or `aws_auth_accounts` inputs of same).

The parameters to `aws_auth_users` map users to groups, which are rule-based access control objects created on the cluster through the use of (Cluster)RoleBindings, which depend on (Cluster)Roles that describe permitted groups of actions.  There are some standard groups, but it is often best to create one's own (Cluster)RoleBindings from existing or custom (Cluster)Roles.

An example ClusterRoleBinding to grant a user fairly broad ability to view cluster resources with the ([[#^default-roles|system-provided]]) `view` ClusterRole:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewers
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: viewer
    namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
```

## Administrative roles
There exists a default group `system:masters` which essentially offers complete control over all cluster resources.  This may seem to be a simple answer for granting others access to a cluster, but it is bad to spread these permissions to many users.  Only those who are truly exerting administrative control over the cluster itself—not to be confused with broad latitude over, say, resources in a given namespace, which should be the preferred mechanism—should be assigned to the `system:masters` group.  This implies a greater need to manage roles, but will protect the cluster from accidental damage.

#question It should be possible to scope administrative privileges to a namespace.  We should figure out the specifics of this so that rights can be granted on a per-project basis.

## Links/Tags/References
1. https://kubernetes.io/docs/concepts/configuration/configmap/ ^configmap-docs
2. https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
3. https://github.com/terraform-aws-modules/terraform-aws-eks#input_aws_auth_users ^auth-users
4. https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings ^default-roles
5. [[Roles and RoleBindings]]
6. #AWS 