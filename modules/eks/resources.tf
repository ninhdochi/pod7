resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.tenancy}"

# For EKS. Enable/disable DNS support in the VPC.
  enable_dns_support = "${var.dns_support}"

# For EKS. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = "${var.dns_hostname}"

  tags = {
     "Name" = "${var.cluster_name}_node",
     "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  }
}

resource "aws_subnet" "subnets_tier1" {
  for_each   = toset(var.subnets_tier1_cidr)
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${each.value}"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[index(var.subnets_tier1_cidr, each.key)]

  tags ={
    "Tier" = "Tier1"
  }
}

resource "aws_subnet" "subnets_tier2" {
  for_each   = toset(var.subnets_tier2_cidr)
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${each.value}"
  availability_zone = data.aws_availability_zones.available.names[index(var.subnets_tier2_cidr, each.key)]

  tags = {
     "Name" = "${var.cluster_name}_node",
     "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  }
/*
  tags ={
    "kubernetes.io/cluster/eks-cluster" = "shared"
    "Tier" = "Tier2"
  }
*/
}

resource "aws_subnet" "subnets_tier3" {
  for_each   = toset(var.subnets_tier3_cidr)
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${each.value}"
  availability_zone = data.aws_availability_zones.available.names[index(var.subnets_tier3_cidr, each.key)]

  tags ={
    "Tier" = "Tier3"
  }
}

resource "aws_eip" "eib" {
  vpc = "${var.vpc_eip}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "terraform-eks"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eib.id
  subnet_id     = element([for i in aws_subnet.subnets_tier1 : i.id],0)

  # maintaining proper order
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "subnet_tier1_rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "subnet_tier2_rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id 
  }
}

resource "aws_route_table" "subnet_tier3_rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id 
  }
}

resource "aws_route_table_association" "subnet_tier1_rta" {
  for_each       = toset(var.subnets_tier1_cidr)
  subnet_id      = aws_subnet.subnets_tier1[each.value].id
  route_table_id = aws_route_table.subnet_tier1_rt.id
}

resource "aws_route_table_association" "subnet_tier2_rta" {
  for_each       = toset(var.subnets_tier2_cidr)
  subnet_id      = aws_subnet.subnets_tier2[each.value].id
  route_table_id = aws_route_table.subnet_tier2_rt.id
}

resource "aws_route_table_association" "subnet_tier3_rta" {
  for_each       = toset(var.subnets_tier3_cidr)
  subnet_id      = aws_subnet.subnets_tier3[each.value].id
  route_table_id = aws_route_table.subnet_tier3_rt.id
}
