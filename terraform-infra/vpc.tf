module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "video-frame-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name = "video-frame-vpc"
  }
}