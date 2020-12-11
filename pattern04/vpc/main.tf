resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "${var.name}-${var.profile}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  count = var.subnet_number

  cidr_block = lookup(var.cidr_blocks, format("zone%d", count.index))
  availability_zone = lookup(var.zones, format("zone%d", count.index))
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-${count.index}-subnet"
  }
}
