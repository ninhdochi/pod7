resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.tenancy}"

# For EKS. Enable/disable DNS support in the VPC.
  enable_dns_support = "${var.dns_support}"

# For EKS. Enable/disable DNS hostnames in the VPC.
  enable_dns_hostnames = "${var.dns_hostname}"

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "main_private" {
  for_each   = toset(var.subnets_cidr_private)
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${each.value}"
  availability_zone = data.aws_availability_zones.available.names[index(var.subnets_cidr_private, each.key)]

  tags ={
    "kubernetes.io/cluster/eks" = "shared"
    "Tier" = "Tier2"
  }
}

resource "aws_subnet" "main_private_tier3" {
  for_each   = toset(var.subnets_cidr_private_tier3)
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${each.value}"
  availability_zone = data.aws_availability_zones.available.names[index(var.subnets_cidr_private_tier3, each.key)]

  tags ={
    "Tier" = "Tier3"
  }
}

resource "aws_subnet" "main_public" {
  for_each   = toset(var.subnets_cidr_public)
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${each.value}"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[index(var.subnets_cidr_public, each.key)]

  tags ={
#    "kubernetes.io/cluster/eks" = "shared"
    "Tier" = "Tier1"
  }
}

resource "aws_eip" "eib" {
  vpc = "${var.vpc_eip}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eib.id
  subnet_id     = element([for i in aws_subnet.main_public : i.id],0)

  # maintaining proper order
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id 
  }
}

resource "aws_route_table_association" "main_public_rta" {
  for_each       = toset(var.subnets_cidr_public)
  subnet_id      = aws_subnet.main_public[each.value].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "main_private_rta" {
  for_each       = toset(var.subnets_cidr_private)
  subnet_id      = aws_subnet.main_private[each.value].id
  route_table_id = aws_route_table.private_rt.id
}
