#!/bin/bash

# 检查必要的命令是否存在
check_commands() {
    local commands=("aws" "jq")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "错误: 需要安装 $cmd"
            exit 1
        fi
    done
}

# 检查必要的环境变量
check_env_vars() {
    if [ -z "$GITHUB_REPOSITORY" ]; then
        echo "错误: 请设置 GITHUB_REPOSITORY 环境变量 (格式: owner/repo)"
        exit 1
    fi
}

# 创建 IAM OIDC Provider
create_oidc_provider() {
    local provider_exists
    provider_exists=$(aws iam list-open-id-connect-providers | jq -r '.OpenIDConnectProviderList[].Arn' | grep 'token.actions.githubusercontent.com' || true)
    
    if [ -z "$provider_exists" ]; then
        echo "创建 GitHub OIDC provider..."
        
        # 获取 GitHub OIDC 证书指纹
        THUMBPRINT=$(echo | openssl s_client -servername token.actions.githubusercontent.com -showcerts -connect token.actions.githubusercontent.com:443 2>/dev/null | openssl x509 -fingerprint -sha1 -noout | cut -d= -f2 | tr -d ':')
        
        aws iam create-open-id-connect-provider \
            --url https://token.actions.githubusercontent.com \
            --client-id-list sts.amazonaws.com \
            --thumbprint-list "$THUMBPRINT"
        
        echo "GitHub OIDC provider 已创建"
    else
        echo "GitHub OIDC provider 已存在"
    fi
}

# 创建 IAM 角色
create_iam_role() {
    local role_name="github-actions-oidc-role"
    local role_exists
    role_exists=$(aws iam get-role --role-name "$role_name" 2>/dev/null || echo "false")
    
    if [ "$role_exists" = "false" ]; then
        echo "创建 IAM 角色..."
        
        # 创建信任策略
        cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPOSITORY}:*"
                }
            }
        }
    ]
}
EOF
        
        # 创建角色
        aws iam create-role \
            --role-name "$role_name" \
            --assume-role-policy-document file://trust-policy.json
        
        # 附加必要的策略
        aws iam attach-role-policy \
            --role-name "$role_name" \
            --policy-arn "arn:aws:iam::aws:policy/PowerUserAccess"
        
        echo "IAM 角色已创建"
        rm trust-policy.json
    else
        echo "IAM 角色已存在"
    fi
    
    # 获取并输出角色 ARN
    ROLE_ARN=$(aws iam get-role --role-name "$role_name" --query Role.Arn --output text)
    echo "角色 ARN: $ROLE_ARN"
    echo
    echo "请在 GitHub 仓库设置中添加以下 secret:"
    echo "名称: AWS_ROLE_ARN"
    echo "值: $ROLE_ARN"
}

# 验证角色是否可用
verify_role() {
    local role_name="github-actions-oidc-role"
    echo "验证角色配置..."
    
    # 检查角色是否存在
    aws iam get-role --role-name "$role_name" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "错误: 角色不存在"
        return 1
    fi
    
    # 检查信任关系
    local trust_policy
    trust_policy=$(aws iam get-role --role-name "$role_name" --query Role.AssumeRolePolicyDocument --output text)
    if ! echo "$trust_policy" | grep -q "token.actions.githubusercontent.com"; then
        echo "错误: 角色缺少 GitHub OIDC 信任关系"
        return 1
    fi
    
    # 检查角色权限
    local attached_policies
    attached_policies=$(aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[].PolicyArn' --output text)
    if ! echo "$attached_policies" | grep -q "PowerUserAccess"; then
        echo "警告: 角色可能缺少必要的权限"
    fi
    
    echo "角色验证完成"
    echo "✅ 角色配置正确"
}

main() {
    echo "开始设置 GitHub Actions OIDC 角色..."
    check_commands
    check_env_vars
    create_oidc_provider
    create_iam_role
    verify_role
    echo "设置完成!"
}

main
