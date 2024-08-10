# General 

variable "region" {
  description = "Region where the resources will be provisioned"
  type        = string
  default     = "ca-central-1"
}

variable "environment_name" {
  description = "Deployment enviroment (dev/staging/production)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Name of the web application"
  type        = string
}

# Instance

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ami" {
  description = "Unique value of the amazon machine"
  type        = string
  default     = "ami-05e937fe6345a5c32"
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# Database

variable "db_name" {
  description = "DB name"
  type        = string
}

variable "db_user" {
  description = "DB username"
  type        = string
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true # ensures that it is not printed 
}

# S3 buckets

variable "bucket_prefix" {
  description = "prefix of s3 bucket for app data"
  type        = string
}
