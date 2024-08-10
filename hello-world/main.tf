terraform {
  # specifies the providers which our terraform 
  required_providers {  
    aws = {
      source  = "hashicorp/aws" #
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1" # the region where you want to provision
}

resource "aws_instance" "example" {
  ami           = "ami-05e937fe6345a5c32" # unique Id of the VM image. Will be different for each region 
  instance_type = "t2.micro" 
}
