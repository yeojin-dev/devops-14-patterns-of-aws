resource "aws_vpc" "event" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
}

resource "aws_subnet" "event_a" {
  cidr_block = "192.168.10.0/24"
  vpc_id = aws_vpc.event.id
  availability_zone = "ap-northeast-2a"
}

resource "aws_internet_gateway" "event" {
  vpc_id = aws_vpc.event.id
}

resource "aws_route_table" "event" {
  vpc_id = aws_vpc.event.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.event.id
  }
}

// 서브넷과 별도로 연결시킬 때는 aws_route_table_association 사용
resource "aws_main_route_table_association" "event" {
  route_table_id = aws_route_table.event.id
  vpc_id = aws_vpc.event.id
}
