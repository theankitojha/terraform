resource "aws_ecs_cluster" "main" {
  name = "my-ecs-cluster${local.environment_suffix}"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole${local.environment_suffix}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

