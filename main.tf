provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

data "aws_availability_zones" "available" {
  
}

terraform {
  backend "s3" {
    bucket         = "terraform-eks-state-sr"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"
  name = "vpc-${local.cluster_name}"
  cidr = "${local.vpc_cidr}" # 192.168 , 172.16
  azs = data.aws_availability_zones.available.names
  public_subnets = "${local.vpc_subnets}"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "9.0.0"
  # insert the 4 required variables here
  cluster_name = "${local.cluster_name}"
  subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  map_users = var.map_users
  # worker nodes

    worker_groups_launch_template = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.large"
      asg_max_size = 5
      asg_min_size = 2
      asg_desired_capacity = 2
      autoscaling_enable = true
      public_ip = true
    }
  ]
}
