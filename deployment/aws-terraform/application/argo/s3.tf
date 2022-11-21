resource "aws_s3_bucket" "artifact_store" {
  bucket = "${var.artifact_bucket_prefix}-${local.cluster_name}-${var.aws_region}"

  tags = local.tags
}

resource "aws_s3_bucket_acl" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id
  acl    = "private"
}
