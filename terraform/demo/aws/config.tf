######################
# Provider
######################

provider "aws" {
  # profile = "development"
  region  = local.default_region
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
  default_region = local.config.default_region

  cloud9 = flatten([
    for cloud9 in local.config.cloud9 : [
      merge(cloud9, {
        region = local.default_region
      })
    ]
  ])
  vpc = flatten([
    for vpc in local.config.vpc : [
      merge(vpc, {
        region = local.default_region
      })
    ]
  ])
  lb = flatten([
    for lb in local.config.lb : [
      merge(lb, {
        region = local.default_region
      })
    ]
  ])
  eks = flatten([
    for eks in local.config.eks : [
      merge(eks, {
        region = local.default_region
      })
    ]
  ])
}

locals {
  private_subnets = [for k, v in local.azs : cidrsubnet(local.config.vpc.vpc_cidr, 3, k + 3)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.config.vpc.vpc_cidr, 3, k)]
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
}


output "name" {
  value = local.config
}