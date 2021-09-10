resource "aws_db_subnet_group" "aws_rds" {
    name = "${var.cluster_name}_rds"
    subnet_ids = [for i in aws_subnet.subnets_tier3 : i.id]

    tags = {
        Name = "eks_DB"
    }
}