/*
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "my_vpc" {
  source               = "../modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "bastion"
  tenancy              = "default"
  subnets_cidr_public  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnets_cidr_private = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  #  azs                  = ["us-east-1a","us-east-1b","us-east-1c"]
  vpc_id  = module.my_vpc.vpc_id
  vpc_eip = "true"
}

resource "aws_lb" "bastion_nlb" {
  name               = "BastionNLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for a in module.my_vpc.subnet_public_id : a]

  enable_deletion_protection = true

  tags = {
    name = "bastion_nlb"
  }
}

module "my_ec2" {
  source             = "../modules/ec2"
  instance_type      = "t2.micro"
  ami_id             = "ami-0c2b8ca1dad447f8a"
  sg_name            = "bastion_sg"
  vpc_id             = module.my_vpc.vpc_id
  auto_scaling_zones = module.my_vpc.subnet_public_id

}
*/
