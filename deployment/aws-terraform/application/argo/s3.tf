resource "aws_s3_bucket" "artifact_store" {
  bucket = var.artifact_bucket_name

  tags = local.tags
}

resource "aws_s3_bucket_acl" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id
  acl    = "private"
}
