provider "aws" {
  region = "us-west-2"
}

module "my_bastion" {
  source               = "../modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "bastion"
  tenancy              = "default"
  subnets_cidr_public  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnets_cidr_private = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  vpc_id               = module.my_bastion.vpc_id
  vpc_eip              = "true"
}

resource "aws_lb" "bastion_nlb" {
  name               = "BastionNLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for a in module.my_bastion.subnet_public_id : a]

  #  enable_deletion_protection = true

  tags = {
    name = "bastion_nlb"
  }
}

module "my_ec2" {
  source             = "../modules/ec2"
  instance_type      = "t2.micro"
  key                = "ninh"
  ami_id             = "ami-083ac7c7ecf9bb9b0"
  sg_name            = "bastion_sg"
  vpc_id             = module.my_bastion.vpc_id
  auto_scaling_zones = module.my_bastion.subnet_public_id

}


module "non_prod" {
  source             = "../modules/eks"
  cluster_name       = "nnnn_non_prod"
  vpc_cidr           = "10.1.0.0/16"
  vpc_name           = "non_prod"
  tenancy            = "default"
  subnets_tier1_cidr = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  subnets_tier2_cidr = ["10.1.10.0/24", "10.1.11.0/24", "10.1.22.0/24"]
  subnets_tier3_cidr = ["10.1.100.0/24", "10.1.110.0/24", "10.1.220.0/24"]
  vpc_id             = module.non_prod.vpc_id
  vpc_eip            = true
  dns_support        = true
  dns_hostname       = true
  rds_name           = "non_prod_rds"
}

resource "aws_vpc_peering_connection" "bastion_to_Non_prod" {
  peer_vpc_id = module.non_prod.vpc_id
  vpc_id      = module.my_bastion.vpc_id
  auto_accept = true
}


module "prod" {
  source             = "../modules/eks"
  cluster_name       = "nnnn_prod"
  vpc_cidr           = "10.2.0.0/16"
  vpc_name           = "prod"
  tenancy            = "default"
  subnets_tier1_cidr = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  subnets_tier2_cidr = ["10.2.10.0/24", "10.2.11.0/24", "10.2.22.0/24"]
  subnets_tier3_cidr = ["10.2.100.0/24", "10.2.110.0/24", "10.2.220.0/24"]
  vpc_id             = module.prod.vpc_id
  vpc_eip            = true
  dns_support        = true
  dns_hostname       = true
  rds_name           = "prod_rds"
}

resource "aws_vpc_peering_connection" "bastion_to_prod" {
  peer_vpc_id = module.prod.vpc_id
  vpc_id      = module.my_bastion.vpc_id
  auto_accept = true
}