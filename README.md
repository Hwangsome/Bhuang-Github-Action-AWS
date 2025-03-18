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

## GitHub 账号切换工具

项目包含一个 GitHub 账号切换脚本，帮助您在个人账号和工作账号之间轻松切换，实现代码提交身份的灵活管理。

### 功能特点

- 全局账号切换：一键切换 Git 用户名、邮箱和 SSH 密钥
- 仓库级别配置：为特定仓库单独设置不同的 GitHub 账号
- SSH 密钥管理：生成、配置和管理多个 SSH 密钥
- 配置记忆：自动保存您的配置，方便下次使用
- SSH 多账号支持：创建 SSH 配置以同时使用多个账号

### 使用方法

#### 初始设置

首先进行初始配置：

```bash
# 配置您的个人和工作账号信息
./scripts/github_account_switcher.sh configure
```

这将引导您输入：
- 个人 GitHub 账号用户名和邮箱
- 工作 GitHub 账号用户名和邮箱
- 各账号的 SSH 密钥路径

#### 生成 SSH 密钥

如果您还没有分别为个人和工作账号创建 SSH 密钥：

```bash
# 生成个人账号的 SSH 密钥
./scripts/github_account_switcher.sh gen-personal-key

# 生成工作账号的 SSH 密钥
./scripts/github_account_switcher.sh gen-work-key
```

生成后，将公钥添加到相应的 GitHub 账号中。

#### 创建 SSH 配置

要同时使用多个 GitHub 账号，需要设置 SSH 配置：

```bash
./scripts/github_account_switcher.sh create-ssh-config
```

这会创建/更新 `~/.ssh/config` 文件，允许您通过不同的主机别名访问 GitHub。

#### 切换账号

全局切换账号：

```bash
# 切换到个人账号
./scripts/github_account_switcher.sh personal

# 切换到工作账号
./scripts/github_account_switcher.sh work

# 查看当前状态
./scripts/github_account_switcher.sh status
```

#### 仓库级别配置

为特定仓库设置单独的 GitHub 账号：

```bash
# 进入仓库目录后，设置为个人账号
cd your-repo
./scripts/github_account_switcher.sh repo-personal

# 或设置为工作账号
./scripts/github_account_switcher.sh repo-work

# 查看当前仓库配置
./scripts/github_account_switcher.sh repo-info
```

#### 使用多账号克隆仓库

在设置 SSH 配置后，您可以这样克隆仓库：

```bash
# 使用个人账号克隆
git clone git@github.com-personal:username/repo.git

# 使用工作账号克隆
git clone git@github.com-work:username/repo.git
```

对于现有仓库，可以更新远程 URL：

```bash
# 更新为个人账号
git remote set-url origin git@github.com-personal:username/repo.git

# 更新为工作账号
git remote set-url origin git@github.com-work:username/repo.git
```

#### 帮助信息

随时查看帮助：

```bash
./scripts/github_account_switcher.sh help
```

# Bhuang-Github-Action-AWS
