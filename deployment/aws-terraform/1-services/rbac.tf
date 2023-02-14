resource "kubectl_manifest" "viewers_crb" {
  yaml_body = <<-YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewers
subjects:
- kind: Group
  name: viewer # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
YAML
}
