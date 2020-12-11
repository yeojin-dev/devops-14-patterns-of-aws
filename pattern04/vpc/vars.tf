variable "name" {
  description = "기본 접두어"
  type = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type = string
  default = "192.168.0.0/16"
}

variable "profile" {
  description = "개발 환경(dev, prd)"
  type = string
}

variable "subnet_number" {
  description = "사용할 서브넷 개수"
  type = number
  default = 2
}

variable "zones" {
  description = "VPC 내 사용할 AZ"
  type = map(string)
  default = {
    zone0 = "ap-northeast-2a"
    zone1 = "ap-northeast-2b"
  }
}

variable "cidr_blocks" {
  description = "VPC 내 사용할 CIDR"
  type = map(string)
  default = {
    zone0 = "192.168.1.0/24"
    zone1 = "192.168.2.0/24"
  }
}
