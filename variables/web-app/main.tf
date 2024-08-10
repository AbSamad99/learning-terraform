# INITIALIZATION 

terraform {
  # the backed that we want to use, in our case s3 bucket + dynamodb
  backend "s3" {
    bucket         = "syed-tf-state"
    key            = "variables/web-app/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "tf-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

locals {
  extra-tag = "extra-tag" # local scope
}

# VPC AND SUBNETS

# data blocks reference existing resources in aws, we are using them to reference the default vpc as we do not want to setup a new one for this example
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

# INSTANCES

resource "aws_instance" "instance1" {
  ami           = var.ami           # unique Id of the VM image. Will be different for each region 
  instance_type = var.instance_type # type of the instance
  # assigning security group to ensure we have inbound traffic
  security_groups = [aws_security_group.instances.name]
  # simple instructions which setup a basic web server
  user_data = <<-EOF
      #!/bin/bash
      echo "hello world 1" > index.html
      python3 -m http.server 8080 &
  EOF

  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra-tag # from locals object
  }
}

resource "aws_instance" "instance2" {
  ami           = var.ami           # unique Id of the VM image. Will be different for each region 
  instance_type = var.instance_type # type of the instance
  # assigning security group to ensure we have inbound traffic
  security_groups = [aws_security_group.instances.name]
  # simple instructions which setup a basic web server
  user_data = <<-EOF
      #!/bin/bash
      echo "hello world 2" > index.html
      python3 -m http.server 8080 &
  EOF

  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra-tag # from locals object
  }
}

# INSTANCES SECURITY GROUP

# security group needed to allow inbound traffic to the instances
resource "aws_security_group" "instances" {
  name = "instance-security-group"
}

# security group rule which allows the traffic 
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress" # i.e inbound
  security_group_id = aws_security_group.instances.id

  # details of the connection, recall that http runs on top of tcp and 8080 is the port that we have for our server
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # allow traffic from all IPs
}

# BUCKET
resource "aws_s3_bucket" "web_app_bucket" {
  bucket        = "syed-web-app-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "web_app_bucket" {
  bucket = aws_s3_bucket.web_app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_app_bucket" {
  bucket = aws_s3_bucket.web_app_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# LOAD BALANCER

# load balancer target group which specifies where we want to send the traffic to. a target group contains the instances to which we want to forward traffic to
resource "aws_lb_target_group" "instances" {
  name     = "syed-target-group"
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

# attaching ec2 instances to the target group
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

# listener which listens for http request on port 80, forwards request to instances if match otherwise simply returns error page
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

# listener rule
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

# finally provisioning the load balancer itself and telling it what security group to use
resource "aws_lb" "load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application" # ideal for http and https
  subnets            = data.aws_subnet_ids.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
}

# LOAD BALANCER SECURITY GROUPS
resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

# essentially we are allowing inbound traffic on port 80 for the load balancer and then we are sending that traffic to port 8080 on the instances
resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# allows all outbound traffic from the load balancer to any IP address
resource "aws_security_group_rule" "allow_alb_http_outbound" {
  type              = "egress" # i.e outbound
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


# DATABASE - THERE IS SOME ISSUE WITH THIS

resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "standard"
  engine              = "postgres"
  engine_version      = "16"
  instance_class      = "db.t3.micro"
  name                = "mydb"
  username            = var.db_user
  password            = var.db_password
  skip_final_snapshot = true
}

# OUTPUT
output "instance1_ip_addr" {
  value = aws_instance.instance1.public_ip
}

output "instance2_ip_addr" {
  value = aws_instance.instance2.public_ip
}

output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}
