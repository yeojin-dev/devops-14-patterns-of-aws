provider "aws" {
  profile = "terraform"
  region = "ap-northeast-2"
}

terraform {
  required_providers {
    aws = "=3.14.1"
  }
}

module "vpc" {
  source = "./vpc"
}

module "services" {
  source = "./services"

  vpc_id = module.vpc.vpc_id
  subnet_a_id = module.vpc.subnet_a_id
  subnet_b_id = module.vpc.subnet_b_id
}
