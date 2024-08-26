resource "aws_ecr_repository" "my_app" {
  name = "my-app-repo${local.environment_suffix}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "my-app-repo${local.environment_suffix}"
  }
}

