module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.instance_name

  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  security_group_ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_ipv4   = local.my_ip
    }

    nginx = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  ami = data.aws_ami.ubuntu.id

  tags = {
    Name        = var.instance_name
    Terraform   = true
    Environment = "dev"
  }
}