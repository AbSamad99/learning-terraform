# Seperating the compute (instances) provisioning to a different file

locals {
  extra-tag = "extra-tag" # local scope
}

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
