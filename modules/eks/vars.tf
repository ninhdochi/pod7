variable "cluster_name" {
  default = "eks_cluster"
  type    = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type = string
  default = "main"
}

variable "vpc_id" {}

variable "dns_support" {
  type = bool
  default = false
}

variable "dns_hostname" {
  type = bool
  default = false
}

variable "tenancy" {
  type = string
  default = "dedicated"
}

variable "vpc_eip" {
  type = string
  default = true
}

variable "subnets_tier1_cidr" {
    type    = list(string)
    default = []
}

variable "subnets_tier2_cidr" {
    type    = list(string)
    default = []
}

variable "subnets_tier3_cidr" {
    type    = list(string)
    default = []
}

variable "endpoint_private_access" {
    type    = bool
    default = false
}

variable "rds_name" {
    type    = string
    default = "rds"
}