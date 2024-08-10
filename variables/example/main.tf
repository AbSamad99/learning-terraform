terraform {
  backend "s3" {
    bucket         = "syed-tf-state"
    key            = "basics/web-app/terraform.tfstate"
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

resource "aws_instance" "instance1" {
  ami           = var.ami # passed during runtime or defined in terraform.tfvars
  instance_type = var.instance_type
  user_data     = <<-EOF
      #!/bin/bash
      echo "hello world 1" > index.html
      python3 -m http.server 8080 &
  EOF

  tags = {
    name     = var.instance_name
    ExtraTag = local.extra-tag # from locals object
  }
}

resource "aws_instance" "instance2" {
  ami           = var.ami # passed during runtime or defined in terraform.tfvars
  instance_type = var.instance_type
  user_data     = <<-EOF
      #!/bin/bash
      echo "hello world 1" > index.html
      python3 -m http.server 8080 &
  EOF

  tags = {
    name     = var.instance_name
    ExtraTag = local.extra-tag # from locals object
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "standard"
  engine              = "postgres"
  engine_version      = "12.5"
  instance_class      = "db.t2.micro"
  name                = "mydb"
  username            = var.db_user
  password            = var.db_password
  skip_final_snapshot = true
}

output "instance_ip_addr" {
  value = aws_instance.instance1.public_ip
}
