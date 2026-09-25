module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  tags = {
    cluster = "demo"
  }

  eks_managed_node_groups = {
    node_group = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.micro"]
      ami_type       = "AL2023_x86_64_STANDARD"

      vpc_security_group_ids = [
        aws_security_group.all_worker_mgmt.id
      ]
    }
  }
}