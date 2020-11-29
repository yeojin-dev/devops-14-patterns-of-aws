resource "aws_vpc" "intra" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
}

resource "aws_subnet" "intra_a" {
  cidr_block = "192.168.1.0/24"
  vpc_id = aws_vpc.intra.id
  availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "intra_b" {
  cidr_block = "192.168.2.0/24"
  vpc_id = aws_vpc.intra.id
  availability_zone = "ap-northeast-2b"
}

resource "aws_internet_gateway" "intra" {
  vpc_id = aws_vpc.intra.id
}

resource "aws_route_table" "intra" {
  vpc_id = aws_vpc.intra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.intra.id
  }
}

resource "aws_main_route_table_association" "intra" {
  route_table_id = aws_route_table.intra.id
  vpc_id = aws_vpc.intra.id
}
