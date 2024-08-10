terraform {
  # the backed that we want to use, in our case s3 bucket + dynamodb
  backend "s3" {
    bucket         = "syed-tf-state"
    key            = "testing/example/terraform.tfstate"
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
  region = "us-east-1"
}

module "web_app" {
  source = "../instance-module"
}

output "instance_ip_addr" {
  value = module.web_app.instance_ip_addr
}

output "url" {
  value = "http://${module.web_app.instance_ip_addr}:8080"
}
