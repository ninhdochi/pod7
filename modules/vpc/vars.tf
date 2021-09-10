variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type = string
  default = "main"
}

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

variable "vpc_id" {}

variable "vpc_eip" {
  type = string
  default = true
}

variable "subnets_cidr_private" {
    type    = list(string)
    default = []
}

variable "subnets_cidr_private_tier3" {
    type    = list(string)
    default = []
}

variable "subnets_cidr_public" {
    type    = list(string)
    default = []
}

variable "azs" {
  type      = list(string)
  default   = []
}