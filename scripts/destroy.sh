#!/bin/bash
##############################################################
# destroy.sh
# Safely destroy an environment with confirmation prompt.
# Usage: ./scripts/destroy.sh dev
##############################################################

set -e

ENV=${1:-dev}

echo "WARNING: You are about to DESTROY the '$ENV' environment!"
echo "This will delete: VPC, EKS cluster, EC2, S3 buckets, RDS, IAM roles."
echo ""
read -p "Type the environment name to confirm ($ENV): " CONFIRM

if [ "$CONFIRM" != "$ENV" ]; then
  echo "Confirmation failed. Aborting."
  exit 1
fi

cd "environments/$ENV"
terraform destroy -auto-approve
echo "Environment '$ENV' destroyed successfully."
