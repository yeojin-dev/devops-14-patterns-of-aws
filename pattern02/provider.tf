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
