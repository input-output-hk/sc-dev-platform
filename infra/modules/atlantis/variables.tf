# variables.tf

variable "name" {
  description = "Atlantis ECS Cluster Name"
  type        = string
}

variable "service_subnets" {
  description = "Atlantis ECS Service Subnets"
  type        = list(string)
}

variable "vpc_id" {
  description = "Atlantis VPC ID"
  type        = string
}

variable "alb_subnets" {
  description = "Atlantis ALB Subnets"
  type        = list(string)
}

variable "route53_zone_id" {
  description = "Atlantis Route53 Zone ID"
  type        = string
}

variable "task_exec_secret_arns" {
  description = "Atlantis Task Execution Secret ARNs"
  type        = list(string)
}

variable "domain_name" {
  description = "Atlantis Domain Name"
  type        = string
}
