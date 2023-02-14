# # This key would be needed for cluster encryption
# # resource "aws_kms_key" "eks" {
# #   description             = "EKS Secret Encryption Key"
# #   deletion_window_in_days = 7
# #   enable_key_rotation     = true

# #   tags = local.tags
# # }

# resource "aws_kms_key" "ebs" {
#   description             = "Customer managed key to encrypt EKS managed node group volumes"
#   deletion_window_in_days = 7
#   policy                  = data.aws_iam_policy_document.ebs.json
# }
