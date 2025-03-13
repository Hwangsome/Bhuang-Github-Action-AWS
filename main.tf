terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 建议使用远程状态存储，例如 S3
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region = "us-west-2"  # 更改为你的目标区域
}

# 示例资源：创建一个 S3 存储桶
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-test-bucket-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
