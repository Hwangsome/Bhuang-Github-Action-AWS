#!/bin/bash

# 创建新的信任策略
cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::058264261029:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": [
                "sts:AssumeRoleWithWebIdentity",
                "sts:TagSession"
            ],
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": [
                        "repo:Hwangsome/Bhuang-Github-Action-AWS:*",
                        "repo:Hwangsome/Bhuang-Github-Action-AWS:pull_request",
                        "repo:Hwangsome/Bhuang-Github-Action-AWS:ref:refs/heads/*"
                    ]
                }
            }
        }
    ]
}
EOF

# 更新角色的信任策略
aws iam update-assume-role-policy \
    --role-name github-actions-oidc-role \
    --policy-document file://trust-policy.json

# 清理
rm trust-policy.json

echo "信任策略已更新为新的仓库名称: Hwangsome/Bhuang-Github-Action-AWS"
