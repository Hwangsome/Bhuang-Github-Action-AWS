#!/bin/bash

echo "========== OIDC 配置验证脚本 =========="

# 设置区域
export AWS_DEFAULT_REGION=us-east-1
echo "使用区域: $AWS_DEFAULT_REGION"

# 获取账号信息
echo -e "\n1. 账号信息:"
aws sts get-caller-identity

# 检查 OIDC Provider
echo -e "\n2. OIDC Provider 配置:"
PROVIDER_ARN=$(aws iam list-open-id-connect-providers | jq -r '.OpenIDConnectProviderList[] | select(.Arn | contains("token.actions.githubusercontent.com")) | .Arn')
echo "Provider ARN: $PROVIDER_ARN"

if [ -n "$PROVIDER_ARN" ]; then
    echo -e "\nProvider 详细信息:"
    aws iam get-open-id-connect-provider --open-id-connect-provider-arn $PROVIDER_ARN
else
    echo "错误: 未找到 GitHub OIDC provider"
    exit 1
fi

# 检查角色配置
ROLE_NAME="github-actions-oidc-role"
echo -e "\n3. IAM 角色配置:"
echo "角色名称: $ROLE_NAME"

# 获取角色 ARN
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query Role.Arn --output text)
echo "角色 ARN: $ROLE_ARN"

# 显示信任关系
echo -e "\n4. 信任关系策略:"
aws iam get-role --role-name $ROLE_NAME --query Role.AssumeRolePolicyDocument --output json | jq '.'

# 显示附加的策略
echo -e "\n5. 附加的策略:"
aws iam list-attached-role-policies --role-name $ROLE_NAME

# 显示内联策略
echo -e "\n6. 内联策略:"
aws iam list-role-policies --role-name $ROLE_NAME

# 测试 AssumeRole
echo -e "\n7. 测试 AssumeRole 权限:"
aws sts get-caller-identity
echo "注意: 实际的 GitHub Actions 会使用 OIDC token 进行身份验证"

echo -e "\n========== 验证完成 ==========\n"

echo "建议操作:"
echo "1. 确保 GitHub 仓库中的 AWS_ROLE_ARN secret 值为: $ROLE_ARN"
echo "2. 确保在 GitHub Actions workflow 中使用正确的区域: us-east-1"
echo "3. 检查信任关系中的 repo 配置是否正确"
echo "4. 确保 OIDC Provider 配置正确"
