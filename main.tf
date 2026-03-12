terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(local.default_tags, local.environment_tags)
  }
}