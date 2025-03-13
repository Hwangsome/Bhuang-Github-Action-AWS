#!/bin/bash
# 创建 EMR Serverless 执行角色的脚本
# 此角色允许 EMR Serverless 访问 S3 存储桶、CloudWatch 日志等

# 设置变量
ROLE_NAME="EMRServerlessExecutionRole"
POLICY_NAME="EMRServerlessS3AndLogsPolicy"
TRUST_POLICY_FILE="/tmp/emr_serverless_trust_policy.json"
POLICY_FILE="/tmp/emr_serverless_policy.json"
S3_BUCKET_NAME="sprak-job" # 替换为您的 S3 存储桶名称

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

# 创建信任策略文档
echo "创建信任策略文档..."
cat > $TRUST_POLICY_FILE << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "emr-serverless.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# 创建权限策略文档
echo "创建权限策略文档..."
cat > $POLICY_FILE << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::$S3_BUCKET_NAME",
        "arn:aws:s3:::$S3_BUCKET_NAME/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:$ACCOUNT_ID:log-group:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:GetTable",
        "glue:GetTables",
        "glue:GetDatabase",
        "glue:GetDatabases",
        "glue:CreateTable",
        "glue:CreateDatabase"
      ],
      "Resource": [
        "arn:aws:glue:*:$ACCOUNT_ID:catalog",
        "arn:aws:glue:*:$ACCOUNT_ID:database/*",
        "arn:aws:glue:*:$ACCOUNT_ID:table/*/*"
      ]
    }
  ]
}
EOF

# 检查角色是否已存在
echo "检查角色是否已存在..."
ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME 2>&1 || echo "NOT_FOUND")

if [[ "$ROLE_EXISTS" == *"NoSuchEntity"* || "$ROLE_EXISTS" == "NOT_FOUND" ]]; then
    echo "创建新角色 $ROLE_NAME..."
    aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file://$TRUST_POLICY_FILE
    
    if [ $? -ne 0 ]; then
        echo "错误: 无法创建角色。"
        exit 1
    fi
else
    echo "角色 $ROLE_NAME 已存在，更新信任策略..."
    aws iam update-assume-role-policy --role-name $ROLE_NAME --policy-document file://$TRUST_POLICY_FILE
    
    if [ $? -ne 0 ]; then
        echo "错误: 无法更新角色的信任策略。"
        exit 1
    fi
fi

# 检查内联策略是否存在，如果存在则删除
echo "检查是否存在现有策略..."
EXISTING_POLICIES=$(aws iam list-role-policies --role-name $ROLE_NAME)
if [[ "$EXISTING_POLICIES" == *"$POLICY_NAME"* ]]; then
    echo "删除现有内联策略 $POLICY_NAME..."
    aws iam delete-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME
fi

# 添加内联策略
echo "添加内联策略 $POLICY_NAME 到角色..."
aws iam put-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME --policy-document file://$POLICY_FILE

if [ $? -ne 0 ]; then
    echo "错误: 无法添加策略到角色。"
    exit 1
fi

# 获取角色 ARN
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text)

if [ -z "$ROLE_ARN" ]; then
    echo "错误: 无法获取角色 ARN。"
    exit 1
fi

echo "====================================================="
echo "EMR Serverless 执行角色创建成功!"
echo "角色名称: $ROLE_NAME"
echo "角色 ARN: $ROLE_ARN"
echo "====================================================="
echo "您可以将此 ARN 用作 EMR_EXECUTION_ROLE_ARN 环境变量或 GitHub Secret"
echo "export EMR_EXECUTION_ROLE_ARN=$ROLE_ARN"

# 清理临时文件
rm -f $TRUST_POLICY_FILE $POLICY_FILE

echo "完成。"
