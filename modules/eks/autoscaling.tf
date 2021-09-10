/*
resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks_node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.micro"
  name_prefix                 = "${var.cluster_name}_node"
  security_groups             = ["${aws_security_group.eks_node.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

#autoscaling group that launch base on the configuration
resource "aws_autoscaling_group" "eks" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${var.cluster_name}_node"
  vpc_zone_identifier  = [for a in aws_subnet.subnets_tier2 : a.id]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
*/