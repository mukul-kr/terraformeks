provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", "myapp-eks-cluster"]
    command     = "aws"
  }
}

# data "aws_eks_cluster" "default" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "default" {
#   name = module.eks.cluster_id
# }

# data "aws_availability_zones" "available" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"


  cluster_name    = "myapp-eks-cluster"
  cluster_version = "1.24"
  # azs = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_endpoint_public_access = true

  subnet_ids = module.myapp_vpc.private_subnets
  vpc_id  = module.myapp_vpc.vpc_id

  tags = {
    "environment" = "dev"
    "application" = "myapp"
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
