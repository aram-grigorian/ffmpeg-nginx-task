module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  # private_subnets = ["10.0.12.0/24", "10.0.22.0/24"] Not needed for this project

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name        = "ffmpeg-project-vpc"
    Terraform   = true
    Environment = "dev"
  }
}