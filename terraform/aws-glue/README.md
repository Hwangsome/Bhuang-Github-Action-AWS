# AWS Glue Terraform Module

这个目录包含了使用 [cloudposse/glue/aws](https://registry.terraform.io/modules/cloudposse/glue/aws/latest) 模块来创建和管理 AWS Glue 资源的 Terraform 配置。

## 功能

此配置允许您创建以下 AWS Glue 资源：

- Glue Catalog 数据库
- Glue 爬虫（可选）
- Glue 表（可选）

## 使用方法

1. 确保您已经安装了 Terraform（推荐 v0.13.0+）
2. 修改 `terraform.tfvars` 文件以满足您的需求
3. 运行 Terraform 命令初始化和应用配置

```bash
terraform init
terraform plan
terraform apply
```

## 参数配置

主要配置参数在 `terraform.tfvars` 文件中，您可以根据自己的需求进行修改：

- `namespace`, `stage`, `name` - 用于资源命名
- `database_name` - Glue 数据库名称
- `create_crawler` - 是否创建 Glue 爬虫（默认为 true）
- `crawler_s3_targets` - S3 存储桶爬虫目标

## 资源权限

请确保执行 Terraform 的 IAM 用户/角色具有创建和管理以下资源的权限：

- AWS Glue 数据库
- AWS Glue 爬虫
- AWS Glue 表
- IAM 角色和策略（爬虫需要）

## 使用 GitHub Actions

您可以通过仓库中的 Universal Terraform Workflow 来应用此配置：

1. 在 GitHub Actions 工作流中选择对应的分支
2. 选择 `terraform/aws-glue` 作为 Terraform 目录
3. 选择 Plan 或 Apply 操作

## 注意事项

- 默认配置创建一个 Glue 数据库和一个 S3 爬虫
- 爬虫默认每天午夜运行（可在 `terraform.tfvars` 中修改 `crawler_schedule`）
- 请确保在 `crawler_s3_targets` 中指定的 S3 存储桶路径存在并且具有正确的权限

## 相关资源

- [AWS Glue 文档](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html)
- [Terraform AWS Provider 文档](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database)
- [CloudPosse Glue 模块文档](https://registry.terraform.io/modules/cloudposse/glue/aws/latest)
