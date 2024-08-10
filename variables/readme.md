# Variables

Variables are typically used to share values accross resources. They are also quite useful to manage sensitive data. Here are the variables that we need to concern ourselves with:

- Input Variables
- Local Variables
- Output Variables

## Input Variables

These must be defined (NOT SET) within the `variables.tf` file. Then you should set the values of those variables in the `terraform.tfvars` file. Alternatively, you can set the values using `-var="variabel_name=value"` or `-var-file="path/to/different.tfvars"` options.

### variables.tf

```h
variable "instance_name" {
  description = "Name of the EC2 instance"
  type = string
}

variable "ami" {
  description = "Unique value of the amazon machine"
  type = string
  default = "ami-05e937fe6345a5c32"
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type = string
  default = "t2.micro"
}
```

### terraform.tfvars

```h
instance_name = "hello-world"
ami           = "ami-05e937fe6345a5c32"
instance_type = "t2.micro"
```

## Local Variables

These can be defined and set withing the `main.tf` files. They cannot be exported or used in other files. They also cannot be passed at runtime.

```h
# define
locals {
  extra-tag="extra-tag"
}

# access
local.extra-tag
```

## Output Variables

These can be exported and used elsewhere. Typically found at the end of the main.tf file and contain an object of the values you would want to export

```h
output "instance_ip_addr" {
  value = aws_instance.instance1.public_ip
}
```
