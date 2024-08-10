# Seperating the networking provisioning to a different file

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group" "instances" {
  name = "${var.app_name}-${var.environment_name}-instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress" # i.e inbound
  security_group_id = aws_security_group.instances.id

  # details of the connection, recall that http runs on top of tcp and 8080 is the port that we have for our server
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # allow traffic from all IPs
}

resource "aws_lb_target_group" "instances" {
  name     = "${var.app_name}-${var.environment_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  # health check performed to see if the instances are alive or not
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance1.id
  port             = 8080 # What port the load balancer will have to send the traffic
}
resource "aws_lb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance2.id
  port             = 8080 # What port the load balancer will have to send the traffic
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn

  port     = 80     # listen on port 80
  protocol = "HTTP" # listen for the protocol http

  # returning a fixed response if no match
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100 # lower number = higher priority

  condition {
    path_pattern {
      values = ["*"] # specifies that this rule should apply to every request
    }
  }

  action {
    type             = "forward"                         # forward the traffic to the target group
    target_group_arn = aws_lb_target_group.instances.arn # the target group where the traffic has to be forwarded
  }
}

resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-${var.environment_name}-web-app-lb"
  load_balancer_type = "application" # ideal for http and https
  subnets            = data.aws_subnet_ids.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_security_group" "alb" {
  name = "${var.app_name}-${var.environment_name}-alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_http_outbound" {
  type              = "egress" # i.e outbound
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
