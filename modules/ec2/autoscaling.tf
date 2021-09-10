resource "aws_launch_template" "template" {
  name_prefix   = "template"
  image_id      = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key}"
#  security_group_names = ["{var.sg_name}"]
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  depends_on = [aws_security_group.instance_sg]
}

resource "aws_autoscaling_group" "autoscaling" {
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier = var.auto_scaling_zones

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}
