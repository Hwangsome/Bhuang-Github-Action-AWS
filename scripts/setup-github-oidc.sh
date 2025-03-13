#!/bin/bash

# 检查必要的参数
if [ -z "$1" ]; then
    echo "请提供 GitHub 仓库名称 (格式: owner/repo)"
    echo "使用方法: $0 owner/repo [aws-region]"
    exit 1
fi

# 设置变量
GITHUB_REPO=$1
AWS_REGION=${2:-"us-west-2"}  # 如果没有提供区域，默认使用 us-west-2
ROLE_NAME="github-actions-role"
PROVIDER_URL="token.actions.githubusercontent.com"

# 获取 AWS 账号 ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

echo "正在设置 GitHub Actions OIDC 集成..."
echo "GitHub 仓库: $GITHUB_REPO"
echo "AWS 区域: $AWS_REGION"
echo "AWS 账号 ID: $ACCOUNT_ID"

# 检查 OIDC provider 是否已存在
echo "检查 OIDC provider 是否存在..."
if ! aws iam list-open-id-connect-providers | grep -q "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${PROVIDER_URL}"; then
    echo "创建 OIDC provider..."
    aws iam create-open-id-connect-provider \
        --url "https://${PROVIDER_URL}" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1"
else
    echo "OIDC provider 已存在"
fi

# 创建信任策略文档
echo "创建信任策略文档..."
cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${PROVIDER_URL}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${PROVIDER_URL}:sub": "repo:${GITHUB_REPO}:*"
                }
            }
        }
    ]
}
EOF

# 检查角色是否已存在
if aws iam get-role --role-name "${ROLE_NAME}" 2>/dev/null; then
    echo "更新现有角色..."
    aws iam update-assume-role-policy \
        --role-name "${ROLE_NAME}" \
        --policy-document file://trust-policy.json
else
    echo "创建新角色..."
    aws iam create-role \
        --role-name "${ROLE_NAME}" \
        --assume-role-policy-document file://trust-policy.json
fi

# 附加管理员策略（注意：在生产环境中应该使用更严格的权限）
echo "附加 IAM 策略..."
aws iam attach-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"

# 获取角色 ARN
ROLE_ARN=$(aws iam get-role --role-name "${ROLE_NAME}" --query 'Role.Arn' --output text)

echo "设置完成！"
echo "============================================"
echo "角色 ARN: ${ROLE_ARN}"
echo "============================================"
echo "请将上述 Role ARN 添加到 GitHub 仓库的 Secrets 中，名称为 'AWS_ROLE_ARN'"
echo "同时添加 'AWS_REGION' secret，值为: ${AWS_REGION}"

# 清理临时文件
rm trust-policy.json

echo "完成！"
