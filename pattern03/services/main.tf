resource "aws_launch_template" "intra" {
  name = "intra-web-app"
  instance_type = "t2.micro"
  image_id = data.aws_ami.intra_web_app.id
  vpc_security_group_ids = [aws_security_group.intra_instance.id]
}

data "aws_ami" "intra_web_app" {
  owners = ["self"]
  name_regex = "14-patterns-of-aws-02"
  most_recent = true
}

resource "aws_autoscaling_group" "intra" {
  max_size = 2
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = [var.subnet_a_id, var.subnet_b_id]
  target_group_arns = [aws_lb_target_group.intra.arn]
  launch_template {
    id = aws_launch_template.intra.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "intra" {
  name = "intra-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "intra" {
  load_balancer_arn = aws_lb.intra.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.intra.arn
  }
}

resource "aws_lb" "intra" {
  name = "intra-alb"
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.intra_alb.id]
  subnets = [var.subnet_a_id, var.subnet_b_id]
}

resource "aws_security_group" "intra_alb" {
  name = "intra-alb-sg"
  description = "sg for intra alb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "intra_alb_ingress" {
  security_group_id = aws_security_group.intra_alb.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "intra_alb_egress" {
  security_group_id = aws_security_group.intra_alb.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_security_group" "intra_instance" {
  name = "intra-instance-sg"
  description = "sg for intra instance"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "intra_instance_ingress" {
  security_group_id = aws_security_group.intra_instance.id
  from_port = 80
  protocol = "tcp"
  to_port = 80
  source_security_group_id = aws_security_group.intra_instance.id
  type = "ingress"
}

resource "aws_security_group_rule" "intra_instance_egress" {
  security_group_id = aws_security_group.intra_instance.id
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_autoscaling_policy" "intra_scale_up" {
  autoscaling_group_name = aws_autoscaling_group.intra.name
  name = "agents-scale-up"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  scaling_adjustment = 1
}

resource "aws_autoscaling_policy" "intra_scale_down" {
  autoscaling_group_name = aws_autoscaling_group.intra.name
  name = "agents-scale-down"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  scaling_adjustment = -1
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name = "cpu-util-high-agents"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "80"
  alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
  alarm_actions = [aws_autoscaling_policy.intra_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.intra.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name = "cpu-util-low-agents"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "80"
  alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
  alarm_actions = [aws_autoscaling_policy.intra_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.intra.name
  }
}

resource "aws_autoscaling_schedule" "intra_night" {
  autoscaling_group_name = aws_autoscaling_group.intra.name
  scheduled_action_name = "intra-night"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  recurrence = "0 23 * * *"
}

resource "aws_autoscaling_schedule" "intra_day" {
  autoscaling_group_name = aws_autoscaling_group.intra.name
  scheduled_action_name = "intra-day"
  min_size = 1
  max_size = 2
  desired_capacity = 1
  recurrence = "0 9 * * *"
}
