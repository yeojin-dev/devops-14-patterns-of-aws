resource "aws_launch_template" "enterprise" {
  name = "enterprise-web-app"
  instance_type = "t2.micro"
  image_id = data.aws_ami.enterprise_web_app.id
  vpc_security_group_ids = [aws_security_group.enterprise_instance.id]
}

// 이미 생성한 리소스는 data 키워드로 관리
data "aws_ami" "enterprise_web_app" {
  owners = ["self"]
  name_regex = "14-patterns-of-aws-02"
  most_recent = true
}

resource "aws_autoscaling_group" "enterprise" {
  max_size = 2
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = [var.subnet_a_id, var.subnet_b_id]
  target_group_arns = [aws_lb_target_group.enterprise.arn]
  launch_template {
    id = aws_launch_template.enterprise.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "enterprise_scale_up" {
    name = "agents-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.enterprise.name
}

resource "aws_autoscaling_policy" "enterprise_scale_down" {
    name = "agents-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.enterprise.name
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
    alarm_name = "mem-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 memory for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.enterprise_scale_up.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.enterprise.name
    }
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
    alarm_name = "mem-util-low-agents"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.enterprise_scale_down.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.enterprise.name
    }
}

resource "aws_lb" "enterprise" {
  name = "enterprise-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.enterprise_alb.id]
  subnets = [var.subnet_a_id, var.subnet_b_id]  // 2개 이상 필요
}

resource "aws_lb_listener" "enterprise" {
  load_balancer_arn = aws_lb.enterprise.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.enterprise.arn
  }
}

resource "aws_lb_target_group" "enterprise" {
  name = "enterprise-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "enterprise_alb" {
  name = "enterprise-alb-sg"
  description = "sg for enterprise alb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "enterprise_alb_ingress" {
  security_group_id = aws_security_group.enterprise_alb.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "enterprise_alb_egress" {
  security_group_id = aws_security_group.enterprise_alb.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_security_group" "enterprise_instance" {
  name = "enterprise-instance-sg"
  description = "sg for enterprise instance"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "enterprise_instance_ingress" {
  security_group_id = aws_security_group.enterprise_instance.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
  source_security_group_id = aws_security_group.enterprise_alb.id
  type = "ingress"
}

resource "aws_security_group_rule" "enterprise_instance_egress" {
  security_group_id = aws_security_group.enterprise_instance.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}
