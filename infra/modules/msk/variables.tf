variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy the MSK cluster in"
}

variable "subnet_cidr_blocks" {
  type = list(string)
  description = "A list of CIDR blocks for subnets to create"
}