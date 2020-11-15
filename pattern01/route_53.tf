// 네임서버 목록: aws_route53_zone.main.name_servers
resource "aws_route53_zone" "main" {
  name = var.event_domain
}

// A -> ip
resource "aws_route53_record" "dev_ip" {
  zone_id = aws_route53_zone.main.zone_id
  name = "dev-ip.${var.event_domain}"
  type = "A"
  ttl = "30"
  records = [aws_eip.event.public_ip]
}

// CNAME -> dns
resource "aws_route53_record" "dev_domain" {
  zone_id = aws_route53_zone.main.zone_id
  name = "dev-domain"
  type = "CNAME"
  ttl = "30"
  records = [aws_instance.event.public_dns]
}
