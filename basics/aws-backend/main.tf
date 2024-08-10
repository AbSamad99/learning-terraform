terraform {
  ################################################################################################################################################################
  # You should uncomment the code below once you have intially provisioned the bucket and dynamodb. You have to then run init again to push the file to the bucket
  ################################################################################################################################################################

  # the backed that we want to use, in our case s3 bucket + dynamodb
  #   backend "s3" {
  #     bucket         = "syed-tf-state"
  #     key            = "basics/aws-backed/terraform.tfstate"
  #     region         = "ca-central-1"
  #     dynamodb_table = "tf-state-locking"
  #     encrypt        = true
  #   }

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

# s3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "syed-tf-state" # name of the bucket which will be created in aws, has to be unique
  force_destroy = true
}

# NOTE: We have to specify the versioning and the server side encryption as separate resources and not directly part of the main aws_s3_bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id # getting the name of the bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# dynamodb table
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tf-state-locking" # name of the table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # VERY IMPORTANT, HAS TO BE AS IS FOR SOME REASON
  attribute {
    name = "LockID" # has to match the value of hash_key
    type = "S"
  }
}
