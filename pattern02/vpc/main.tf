resource "aws_vpc" "enterprise" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
}

// Web app, S3 and RDS primary
resource "aws_subnet" "enterprise_a" {
  cidr_block = "192.168.1.0/24"
  vpc_id = aws_vpc.enterprise.id
  availability_zone = "ap-northeast-2a"
}

// RDS standby
resource "aws_subnet" "enterprise_b" {
  cidr_block = "192.168.2.0/24"
  vpc_id = aws_vpc.enterprise.id
  availability_zone = "ap-northeast-2b"
}

resource "aws_internet_gateway" "enterprise" {
  vpc_id = aws_vpc.enterprise.id
}

resource "aws_route_table" "enterprise" {
  vpc_id = aws_vpc.enterprise.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.enterprise.id
  }
}

resource "aws_main_route_table_association" "enterprise" {
  route_table_id = aws_route_table.enterprise.id
  vpc_id = aws_vpc.enterprise.id
}
