resource "aws_ecr_repository" "franklin_db_setup" {
  name                 = "franklin-db-setup"
  image_tag_mutability = "MUTABLE"
}

resource "docker_registry_image" "franklin_db_setup" {
  name = format(
    "%v:%v",
    aws_ecr_repository.franklin_db_setup.repository_url,
    var.pgstac_version
  )

  build {
    context = "docker/"
    dockerfile = "Dockerfile"
    build_args = {
      PGSTAC_VERSION : var.pgstac_version
    }
    auth_config {
      host_name  = aws_ecr_repository.franklin_db_setup.repository_url
      user_name = data.aws_ecr_authorization_token.token.user_name
      password = data.aws_ecr_authorization_token.token.password
    }
  }
}
