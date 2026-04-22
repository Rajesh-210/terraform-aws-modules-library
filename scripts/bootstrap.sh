#!/bin/bash
##############################################################
# bootstrap.sh
# Run this ONCE before terraform init to create:
#   - S3 buckets for remote state (dev, staging, prod)
#   - DynamoDB table for state locking
##############################################################

set -e

AWS_REGION="ap-south-1"
PROJECT="rajesh-devops"

echo "==> Creating S3 state buckets..."

for ENV in dev staging prod; do
  BUCKET="${PROJECT}-terraform-state-${ENV}"
  if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
    echo "    Bucket $BUCKET already exists, skipping."
  else
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"

    aws s3api put-bucket-versioning \
      --bucket "$BUCKET" \
      --versioning-configuration Status=Enabled

    aws s3api put-bucket-encryption \
      --bucket "$BUCKET" \
      --server-side-encryption-configuration \
      '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

    aws s3api put-public-access-block \
      --bucket "$BUCKET" \
      --public-access-block-configuration \
      "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    echo "    Created: $BUCKET"
  fi
done

echo ""
echo "==> Creating DynamoDB state lock table..."

if aws dynamodb describe-table --table-name terraform-state-lock --region "$AWS_REGION" 2>/dev/null; then
  echo "    DynamoDB table already exists, skipping."
else
  aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION"
  echo "    Created: terraform-state-lock"
fi

echo ""
echo "Bootstrap complete! You can now run:"
echo "  cd environments/dev && terraform init && terraform plan"
