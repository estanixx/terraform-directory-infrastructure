data "aws_ssoadmin_instances" "current" {}

locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]
}

resource "aws_identitystore_user" "s3_reader" {
  identity_store_id = local.identity_store_id
  user_name         = var.sso_user_name
  display_name      = "${var.sso_user_given_name} ${var.sso_user_family_name}"

  name {
    given_name  = var.sso_user_given_name
    family_name = var.sso_user_family_name
  }

  emails {
    value   = var.sso_user_email
    primary = true
    type    = "work"
  }
}

resource "aws_ssoadmin_permission_set" "s3_read_all" {
  instance_arn     = local.sso_instance_arn
  name             = var.permission_set_name
  description      = "Read-only access for S3 buckets and objects across the target account."
  session_duration = var.permission_set_session_duration
}

resource "aws_ssoadmin_permission_set_inline_policy" "s3_read_all" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.s3_read_all.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      },
      {
        Sid    = "ListAnyBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::*"
      },
      {
        Sid    = "ReadObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::*/*"
      }
    ]
  })
}

resource "aws_ssoadmin_account_assignment" "s3_reader_assignment" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.s3_read_all.arn

  principal_id   = aws_identitystore_user.s3_reader.user_id
  principal_type = "USER"

  target_id   = var.target_account_id
  target_type = "AWS_ACCOUNT"
}
