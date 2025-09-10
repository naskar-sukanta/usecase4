# Configure the AWS Provider
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Specify the AWS region
provider "aws" {
  region = var.aws_region
}
