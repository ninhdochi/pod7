#Master cluster IAM role
resource "aws_iam_role" "eks-cluster" {
  name = "${var.cluster_name}_master_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-cluster.name}"
}

#Master cluster security group
resource "aws_security_group" "eks-cluster" {
  name        = "${var.cluster_name}_master_sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "master-cluster-sg"
  }
}

/*
resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
#cidr_block for workstation
  cidr_blocks       = ["A.B.C.D/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
*/

#Master cluster
resource "aws_eks_cluster" "eks" {
  name            = "${var.cluster_name}"
  role_arn        = "${aws_iam_role.eks-cluster.arn}"

  vpc_config {
    endpoint_private_access   = true
    endpoint_public_access    = true
    security_group_ids        = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids                = [for i in aws_subnet.subnets_tier2 : i.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}