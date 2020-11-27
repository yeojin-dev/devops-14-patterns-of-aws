resource "aws_db_instance" "enterprise" {
  allocated_storage = 20
  storage_type = "gp2"  // general purpose SSD
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "enterprise"  // 기본 데이터베이스 스키마
  identifier = "enterprise-db"

  // TODO: 변수 처리
  username = "foo"
  password = "foobarbaz"

  parameter_group_name = "default.mysql5.7"
  multi_az = true
  db_subnet_group_name = aws_db_subnet_group.enterprise.name
  vpc_security_group_ids = [aws_security_group.enterprise_rds.id]

  skip_final_snapshot = true  // 바로 destroy 가능하도록
}

resource "aws_db_subnet_group" "enterprise" {
  name = "enterprise-rds-subnet-group"
  subnet_ids = [var.subnet_a_id, var.subnet_b_id]
}

resource "aws_security_group" "enterprise_rds" {
  name = "enterprise-rds-sg"
  description = "sg for enterprise rds"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "enterprise_instance_ingress" {
  security_group_id = aws_security_group.enterprise_rds.id
  from_port = 3306
  protocol = "tcp"
  to_port = 3306
  cidr_blocks = ["192.168.0.0/16"]
  description = "VPC cidr"
  type = "ingress"
}

resource "aws_security_group_rule" "enterprise_instance_egress" {
  security_group_id = aws_security_group.enterprise_rds.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_s3_bucket" "enterprise" {
  bucket = "devops-14-patterns-of-aws-enterprise"
  acl = "private"  // CF 연결할 때 public acl 설정하지 않아도 됨

  // CF 통해서만 오브젝트 접근 가능
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccessIdentity",
      "Action": ["s3:GetObject"],
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_cloudfront_origin_access_identity.enterprise.iam_arn}"
      },
      "Resource": "arn:aws:s3:::devops-14-patterns-of-aws-enterprise/*"
    }
  ]
}
EOF

}

resource "aws_cloudfront_origin_access_identity" "enterprise" {
  comment = "enterprise"
}

resource "aws_cloudfront_distribution" "enterprise" {
  origin {
    domain_name = aws_s3_bucket.enterprise.bucket_regional_domain_name
    origin_id   = "enterprise-origin-id"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.enterprise.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "enterprise static resource"
  default_root_object = "index.html"

  //  logging_config {
  //    include_cookies = false
  //    bucket          = "mylogs.s3.amazonaws.com"
  //    prefix          = "myprefix"
  //  }
  //
  //  aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    target_origin_id = "enterprise-origin-id"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
