# Specify the AWS region.
variable "aws_region" {
  description = "The AWS region to create the resources in."
  type        = string
  default     = "us-east-1"
}

data "aws_caller_identity" "current" {} # Gets current AWS account ID

# The CIDR block for the custom VPC.
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# A list of CIDR blocks for the public subnets.
variable "public_subnet_cidr_blocks" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# The Availability Zones to use for the subnets.
variable "availability_zones" {
  description = "A list of Availability Zones to use for the subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# The EC2 instance type for the web servers.
variable "instance_type" {
  description = "The EC2 instance type for the web servers."
  type        = string
  default     = "t3.medium" # Minimum recommended for OpenProject
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "keysn"
}
