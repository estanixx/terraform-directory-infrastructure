output "terraform_state_bucket" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.tf_state.bucket
}

output "terraform_lock_table" {
  description = "DynamoDB table name used for Terraform state locking."
  value       = aws_dynamodb_table.tf_lock.name
}

output "github_actions_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions via OIDC."
  value       = aws_iam_role.github_actions_terraform.arn
}

output "ssm_password_parameter_name" {
  description = "SSM parameter name expected by CI for the Simple AD password."
  value       = var.ssm_password_parameter_name
}
