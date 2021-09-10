output "vpc_eip" {
  value = "${aws_eip.eib.id}"
}

output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "subnets_tier1_id" {
    value = [for x in aws_subnet.subnets_tier1 : x.id]
}

output "subnets_tier2_id" {
    value = [for s in aws_subnet.subnets_tier2 : s.id]
}

output "subnets_tier3_id" {
    value = [for s in aws_subnet.subnets_tier3 : s.id]
}

output "tier1_rt_id" {
  value = "aws_route_table.public_rt.id"
}

output "tier2_rt_id" {
  value = "aws_route_table.private_rt.id"
}

output "tier3_rt_id" {
  value = "aws_route_table.private_rt.id"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}