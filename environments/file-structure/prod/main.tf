# Here we make use of the terraform workspaces to deploy separate copies of our application
# To create a new workspace: terraform workspace new <workspace-name>

terraform {
  # the backed that we want to use, in our case s3 bucket + dynamodb
  backend "s3" {
    bucket         = "syed-tf-state"
    key            = "enviroment/file-structure/prod/terraform.tfstate"
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

variable "password" {
  type = string
}

# Here we are directly defining the environment and are not relying on the 'terrafrom.workspace' variable. Note that the code is the same as in dev, so this approach
# has a lot of repetition
locals {
  environment_name = "prod"
}

module "web-app-module" {
  source = "../../web-app-module"

  #   Input variables
  app_name         = "web-app"
  instance_name    = "Instance"
  ami              = "ami-05e937fe6345a5c32"
  instance_type    = "t2.micro"
  db_name          = "syedmydb${local.environment_name}"
  db_user          = "syeduser"
  db_password      = var.password
  bucket_prefix    = "syed-web-app-bucket-${local.environment_name}"
  environment_name = local.environment_name
}
