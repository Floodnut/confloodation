######################
# Provider
######################

provider "aws" {
  # profile = "development"
  region  = "ap-southeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
  }

  required_version = ">= 1.4.0"
}

######################
# Locals
######################

locals {
  config = yamldecode(file("./config.yaml"))
  cloud9 = flatten([
    for cloud9 in local.config.cloud9 : [
      merge(cloud9, {
        region = "ap-southeast-1"
      })
    ]
  ])
}

output "name" {
  value = local.config
}