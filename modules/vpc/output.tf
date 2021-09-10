output "vpc_eip" {
  value = "${aws_eip.eib.id}"
}

output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "subnet_private_id" {
    value = [for x in aws_subnet.main_private : x.id]
}

output "subnet_public_id" {
    value = [for s in aws_subnet.main_public : s.id]
}

output "public_rt_id" {
  value = "aws_route_table.public_rt.id"
}

output "private_rt_id" {
  value = "aws_route_table.private_rt.id"
}