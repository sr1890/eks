provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

data "aws_availability_zones" "available" {
  
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
    "kubernetes.io/cluster/awesome" = "shared"
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "6.0.2"
  # insert the 4 required variables here
  cluster_name = "${local.cluster_name}"
  subnets = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  # worker nodes

    worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      
    }
  ]
}
