terraform {
  # the backed that we want to use, in our case s3 bucket + dynamodb
  backend "s3" {
    bucket         = "syed-tf-state"
    key            = "modules/consul/terraform.tfstate"
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

# Modules are like classes, they abstract away the complexity of provisioning complex architecture. They can be easily shared with others.
# Reference: https://registry.terraform.io/modules/hashicorp/consul/aws/latest

# We define the module we want to use along with the source where we want to take it from
module "consul" {
  source  = "hashicorp/consul/aws"
  version = "0.7.4"
}

##############################################################################################
# NOTE: we cannot deply this as it uses too many resources (around 40+), but it serves as an 
# example of how easily we can use this module to provision a large system
############################################################################################## 

