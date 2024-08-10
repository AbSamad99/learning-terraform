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

variable "db_user" {
  description = "DB username"
  type        = string
  default     = "foo"
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true # ensures that it is not printed 
}
