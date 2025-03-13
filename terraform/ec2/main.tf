provider "aws" {
  region = var.region
}

# 获取默认 VPC
data "aws_vpc" "default" {
  default = true
}

# 获取默认子网
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 5.0"
#
#   name = "my-ec2-instance"
#
#   instance_type          = var.instance_type
#   ami                    = "ami-0735c191cf914754d"  # Amazon Linux 2 in us-west-2
#   monitoring             = true
#   vpc_security_group_ids = [aws_security_group.allow_ssh.id]
#   subnet_id              = element(data.aws_subnets.default.ids, 0)
#
#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }
#
# # 创建安全组
# resource "aws_security_group" "allow_ssh" {
#   name        = "allow_ssh"
#   description = "Allow SSH inbound traffic"
#   vpc_id      = data.aws_vpc.default.id
#
#   ingress {
#     description = "SSH from anywhere"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "allow_ssh"
#   }
# }
