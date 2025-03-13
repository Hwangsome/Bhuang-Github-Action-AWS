# Terraform AWS GitHub Actions

这个项目使用 GitHub Actions 自动化 Terraform 部署 AWS 资源的过程。

## 前置条件

1. AWS 账号和适当的权限
2. GitHub 仓库
3. 配置 AWS IAM Role 用于 GitHub Actions OIDC 认证

## 设置说明

### 1. AWS IAM 配置

创建一个 IAM Role，并配置信任关系允许 GitHub Actions 使用 OIDC 进行身份验证：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
                }
            }
        }
    ]
}
```

### 2. GitHub Secrets 配置

在 GitHub 仓库中配置以下 secrets：

- `AWS_ROLE_ARN`: 设置为你创建的 IAM Role 的 ARN

### 3. Terraform 后端配置

1. 在 AWS 中创建一个 S3 bucket 用于存储 Terraform 状态
2. 更新 `main.tf` 中的后端配置，替换 bucket 名称和区域

### 4. 自定义配置

1. 根据需要修改 `main.tf` 中的资源配置
2. 在 `.github/workflows/terraform.yml` 中更新 AWS 区域配置

## 工作流程说明

- 推送到 `main` 分支或创建 Pull Request 时触发工作流
- 工作流会执行以下步骤：
  - 检查代码格式
  - 初始化 Terraform
  - 验证配置
  - 生成执行计划
  - 在 PR 中显示计划结果
  - 在合并到 main 分支后自动应用更改

## 安全注意事项

- 确保 IAM Role 权限符合最小权限原则
- 定期轮换密钥和证书
- 使用 OIDC 进行身份验证，避免存储长期凭证
- 在生产环境中启用 Terraform 工作区隔离

## 贡献指南

1. Fork 本仓库
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request
# Bhuang-Github-Action-AWS
