##############################################################
# MODULE: IAM
# Creates IAM roles, policies, and instance profiles
# for common DevOps use cases (EC2, EKS, CI/CD).
##############################################################

# ── EC2 Instance Role ─────────────────────────────────────
resource "aws_iam_role" "ec2" {
  count = var.create_ec2_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  count      = var.create_ec2_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2[0].name
}

resource "aws_iam_role_policy_attachment" "ec2_ecr" {
  count      = var.create_ec2_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ec2[0].name
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.create_ec2_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ec2-profile"
  role  = aws_iam_role.ec2[0].name
  tags  = var.tags
}

# ── CI/CD Role (Jenkins / GitHub Actions) ────────────────
resource "aws_iam_role" "cicd" {
  count = var.create_cicd_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-cicd-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cicd_policy" {
  count = var.create_cicd_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-cicd-policy"
  role  = aws_iam_role.cicd[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Sid    = "EKSAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = "*"
      }
    ]
  })
}

output "ec2_role_arn"            { value = var.create_ec2_role ? aws_iam_role.ec2[0].arn : null }
output "ec2_instance_profile"    { value = var.create_ec2_role ? aws_iam_instance_profile.ec2[0].name : null }
output "cicd_role_arn"           { value = var.create_cicd_role ? aws_iam_role.cicd[0].arn : null }
