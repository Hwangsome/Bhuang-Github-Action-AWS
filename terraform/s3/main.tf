provider "aws" {
  region = "us-west-2"  # 可以根据需要修改区域
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"  # 使用最新的稳定版本

  bucket = "my-s3-bucket-example-unique-name"  # 注意：S3 存储桶名称必须全局唯一
  
  # 基本设置
  acl    = "private"  # 访问控制列表，设为私有
  
  # 版本控制
  versioning = {
    enabled = true
  }
  
  # 服务器端加密设置
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  
  # 启用对象锁定
  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "COMPLIANCE"
        days = 30
      }
    }
  }
  
  # 标签
  tags = {
    Environment = "dev"
    Project     = "my-project"
    Owner       = "terraform"
  }
  
  # 控制公共访问设置
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 输出
output "s3_bucket_id" {
  description = "S3 存储桶的 ID"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "S3 存储桶的 ARN"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_bucket_domain_name" {
  description = "S3 存储桶的域名"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}
