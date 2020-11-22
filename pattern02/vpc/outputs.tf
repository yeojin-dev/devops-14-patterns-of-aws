output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.enterprise.id
}

output "subnet_a_id" {
  description = "Subnet A ID"
  value = aws_subnet.enterprise_a.id
}

output "subnet_b_id" {
  description = "Subnet B ID"
  value = aws_subnet.enterprise_b.id
}
