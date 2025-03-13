#!/bin/bash
# 此脚本为GitHub Actions OIDC角色添加iam:PassRole权限
# 允许GitHub Actions将EMR执行角色传递给EMR Serverless服务

# 设置变量
GITHUB_ACTIONS_ROLE_NAME="github-actions-oidc-role"
EMR_EXECUTION_ROLE_NAME="EMRServerlessExecutionRole"
POLICY_NAME="GitHubActionsPassRolePolicy"
POLICY_FILE="/tmp/github_actions_pass_role_policy.json"

# 确保必要的 AWS CLI 版本已安装
echo "检查 AWS CLI 是否已安装..."
if ! command -v aws &> /dev/null; then
    echo "错误: 未找到 AWS CLI。请安装 AWS CLI 并确保其在 PATH 中。"
    exit 1
fi

# 检查当前 AWS 身份
echo "检查当前 AWS 身份..."
AWS_IDENTITY=$(aws sts get-caller-identity)
if [ $? -ne 0 ]; then
    echo "错误: 无法获取 AWS 身份。请检查您的 AWS 凭证。"
    exit 1
fi

ACCOUNT_ID=$(echo $AWS_IDENTITY | jq -r '.Account')
echo "当前 AWS 账号 ID: $ACCOUNT_ID"

# 获取 EMR 执行角色的完整 ARN
EMR_ROLE_ARN=$(aws iam get-role --role-name $EMR_EXECUTION_ROLE_NAME --query "Role.Arn" --output text)

if [ -z "$EMR_ROLE_ARN" ]; then
    echo "错误: 无法获取 EMR 执行角色 ARN。请确保角色 $EMR_EXECUTION_ROLE_NAME 已创建。"
    echo "如果使用了不同的角色名称，请修改此脚本中的 EMR_EXECUTION_ROLE_NAME 变量。"
    exit 1
fi

echo "EMR 执行角色 ARN: $EMR_ROLE_ARN"

# 创建 PassRole 策略文档
echo "创建 PassRole 策略文档..."
cat > $POLICY_FILE << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "$EMR_ROLE_ARN",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "emr-serverless.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# 检查 GitHub Actions 角色是否存在
echo "检查 GitHub Actions 角色是否存在..."
ROLE_EXISTS=$(aws iam get-role --role-name $GITHUB_ACTIONS_ROLE_NAME 2>&1 || echo "NOT_FOUND")

if [[ "$ROLE_EXISTS" == *"NoSuchEntity"* || "$ROLE_EXISTS" == "NOT_FOUND" ]]; then
    echo "错误: GitHub Actions 角色 $GITHUB_ACTIONS_ROLE_NAME 不存在。"
    echo "请确保您的 GitHub Actions 工作流已经设置了正确的 OIDC 身份提供者和角色。"
    exit 1
fi

# 检查内联策略是否存在，如果存在则删除
echo "检查是否存在现有策略..."
EXISTING_POLICIES=$(aws iam list-role-policies --role-name $GITHUB_ACTIONS_ROLE_NAME)
if [[ "$EXISTING_POLICIES" == *"$POLICY_NAME"* ]]; then
    echo "删除现有内联策略 $POLICY_NAME..."
    aws iam delete-role-policy --role-name $GITHUB_ACTIONS_ROLE_NAME --policy-name $POLICY_NAME
fi

# 添加内联策略
echo "添加内联策略 $POLICY_NAME 到角色..."
aws iam put-role-policy --role-name $GITHUB_ACTIONS_ROLE_NAME --policy-name $POLICY_NAME --policy-document file://$POLICY_FILE

if [ $? -ne 0 ]; then
    echo "错误: 无法添加策略到角色。"
    exit 1
fi

echo "====================================================="
echo "成功为 GitHub Actions 角色添加了 PassRole 权限!"
echo "GitHub Actions 角色: $GITHUB_ACTIONS_ROLE_NAME"
echo "现在可以将 EMR 执行角色传递给 EMR Serverless 服务"
echo "====================================================="

# 清理临时文件
rm -f $POLICY_FILE

echo "完成。"
