provider "aws" {
  profile = "terraform"
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "backup"  // 추가 프로바이더에는 alias 필요함
  region = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = "=3.14.1"
  }
}

module "vpc_main" {
  source = "./vpc"

  name = "intra"
  profile = "dev"
}

module "vpc_backup" {
  providers = {
    aws  = aws.backup
  }
  source = "./vpc"

  name = "intra-backup"
  profile = "dev"
  subnet_number = 2
  zones = {
    zone0 = "ap-northeast-1c"
    zone1 = "ap-northeast-1d"
  }
}
