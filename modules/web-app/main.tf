terraform {
  # the backed that we want to use, in our case s3 bucket + dynamodb
  backend "s3" {
    bucket         = "syed-tf-state"
    key            = "modules/web-app/terraform.tfstate"
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

# New variable, which has to be passed during plan and apply. This will be passed to the module as seen below
variable "password-1" {
  type = string
}
variable "password-2" {
  type = string
}

# Importing and using our custom web-app module, notice that if we do not pass some variables, we get an error. We can make as many copies of the module as we want.

# Copy 1
module "web-app-module-1" {
  source = "../web-app-module"

  #   Input variables
  app_name      = "web-app-1"
  instance_name = "Instance"
  ami           = "ami-05e937fe6345a5c32"
  instance_type = "t2.micro"
  db_name       = "syedmydb1"
  db_user       = "syeduser-1"
  db_password   = var.password-1
  bucket_prefix = "syed-web-app-bucket-1"
}

# Copy 2
module "web-app-module-2" {
  source = "../web-app-module"

  #   Input variables
  app_name      = "web-app-2"
  instance_name = "Instance"
  ami           = "ami-05e937fe6345a5c32"
  instance_type = "t2.micro"
  db_name       = "syedmydb2"
  db_user       = "syeduser-2"
  db_password   = var.password-2
  bucket_prefix = "syed-web-app-bucket-2"
}
