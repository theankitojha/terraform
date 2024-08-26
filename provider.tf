provider "aws" {
  region = "us-west-2"
}

variable "environment" {
  description = "The environment to deploy (dev or prod)"
  type        = string
}

locals {
  environment_suffix = var.environment == "prod" ? "-prod" : "-dev"
}

