#!/bin/bash

echo "开始 OIDC 调试..."

# 获取当前 AWS 账号 ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $AWS_ACCOUNT_ID"

# 检查 OIDC Provider
echo -e "\n检查 OIDC Provider..."
aws iam list-open-id-connect-providers

# 创建更新后的信任策略
cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": [
                "sts:AssumeRoleWithWebIdentity",
                "sts:TagSession"
            ],
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": [
                        "repo:bhuang/Bhuang-Github-Action:*",
                        "repo:bhuang/Bhuang-Github-Action:pull_request",
                        "repo:bhuang/Bhuang-Github-Action:ref:refs/heads/*"
                    ]
                },
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF

echo -e "\n更新角色信任策略..."
aws iam update-assume-role-policy \
    --role-name github-actions-oidc-role \
    --policy-document file://trust-policy.json

echo -e "\n当前角色信任策略："
aws iam get-role --role-name github-actions-oidc-role --query Role.AssumeRolePolicyDocument --output json

# 检查角色权限
echo -e "\n检查角色权限..."
aws iam list-attached-role-policies --role-name github-actions-oidc-role

# 添加额外的权限策略
echo -e "\n添加必要的 STS 权限..."
cat > sts-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRoleWithWebIdentity",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/github-actions-oidc-role"
        }
    ]
}
EOF

aws iam put-role-policy \
    --role-name github-actions-oidc-role \
    --policy-name sts-permissions \
    --policy-document file://sts-policy.json

echo -e "\n清理临时文件..."
rm trust-policy.json sts-policy.json

echo -e "\n调试完成！"
echo "请重新运行 GitHub Action 进行测试"
