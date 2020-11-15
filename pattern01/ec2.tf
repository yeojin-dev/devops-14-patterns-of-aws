// ssh-keygen -t rsa -b 4096 -C "<email>" -f "$HOME/.ssh/devops_14_patterns_of_aws" -N ""
resource "aws_key_pair" "event" {
  key_name = "terraform"
  public_key = file("~/.ssh/devops_14_patterns_of_aws.pub")
}

resource "aws_instance" "event" {
  ami = "ami-06f3207f56dc1ca18"
  instance_type = "t3.medium"
  key_name = aws_key_pair.event.key_name

  associate_public_ip_address = true
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination = false  // 책 내용대로라면 true 설정이 필요하지만 연습용이기 때문에 false 처리
  subnet_id = aws_subnet.event_a.id  // 서브넷 설정이 있으면 VPC 자동으로 찾는 듯
  vpc_security_group_ids = [
    aws_security_group.event.id
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2",
      "sudo yum install -y httpd mariadb-server",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start mariadb",
      "sudo systemctl enable mariadb",
    ]
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    password = ""
    private_key = file("~/.ssh/devops_14_patterns_of_aws")
    host = self.public_ip
  }
}

resource "aws_security_group" "event" {
  name = "sg_event"
  description = "sg for event instance"
  vpc_id = aws_vpc.event.id  // 설정이 없으면 기본 VPC
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]  // TODO: 접속 가능한 IP 변수로 입력
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  // 아웃바운드 설정도 반드시 해야만 함
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "event" {
  instance = aws_instance.event.id
  vpc = true
}
