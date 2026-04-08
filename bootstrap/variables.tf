variable "aws_region" {
  description = "AWS region for bootstrap resources."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Global-unique S3 bucket name for Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  type        = string
  default     = "terraform-state-locks"
}

variable "github_org" {
  description = "GitHub organization or user that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "ci_role_name" {
  description = "IAM role name assumed by GitHub Actions via OIDC."
  type        = string
  default     = "github-actions-terraform"
}

variable "github_environment" {
  description = "Protected GitHub environment name used by apply job."
  type        = string
  default     = "production"
}

variable "ssm_password_parameter_name" {
  description = "SSM parameter name containing the Simple AD admin password."
  type        = string
  default     = "/platform/tf-directory/simple-ad-password"
}
