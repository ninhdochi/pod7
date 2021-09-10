variable "ami_id" {}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "subnet_id" {
  type = list
  default = []
}

variable "sg_name" {
  type = string
  default = "default"
}

variable "vpc_name" {
  type = string
  default = "default"
}

variable "vpc_id" {}

variable "auto_scaling_zones" {
  type = list
  default = []
}

variable "key" {
  type = string
  default = "key"
}