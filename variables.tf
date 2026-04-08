variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This stack currently supports us-east-1 only."
  }
}

variable "project_name" {
  description = "Project identifier used in naming and tags."
  type        = string
  default     = "tf-directory"

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Environment name for tags and naming."
  type        = string
  default     = "dev"

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must not be empty."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.50.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "azs" {
  description = "Two AZs used for subnet placement and regional HA."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.azs) == 2
    error_message = "Provide exactly two availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.50.1.0/24", "10.50.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2 && alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "public_subnet_cidrs must contain exactly two valid CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "Two private subnet CIDRs for Simple AD, one per AZ."
  type        = list(string)
  default     = ["10.50.11.0/24", "10.50.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "private_subnet_cidrs must contain exactly two valid CIDR blocks."
  }
}

variable "simple_ad_name" {
  description = "Simple AD DNS domain name (e.g., corp.example.com)."
  type        = string
  default     = "corp.example.com"

  validation {
    condition     = length(trimspace(var.simple_ad_name)) > 0
    error_message = "simple_ad_name must not be empty."
  }
}

variable "simple_ad_size" {
  description = "Directory size for Simple AD: Small or Large."
  type        = string
  default     = "Small"

  validation {
    condition     = contains(["Small", "Large"], var.simple_ad_size)
    error_message = "simple_ad_size must be either Small or Large."
  }
}

variable "simple_ad_password" {
  description = "Optional direct admin password for Simple AD. Prefer simple_ad_password_ssm_parameter_name in production."
  type        = string
  sensitive   = true
  default     = null
  nullable    = true

  validation {
    condition     = var.simple_ad_password == null || length(var.simple_ad_password) >= 8
    error_message = "If set, simple_ad_password must be at least 8 characters."
  }
}

variable "simple_ad_password_ssm_parameter_name" {
  description = "Optional SSM SecureString parameter name containing the Simple AD admin password."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.simple_ad_password_ssm_parameter_name == null || length(trimspace(var.simple_ad_password_ssm_parameter_name)) > 0
    error_message = "If set, simple_ad_password_ssm_parameter_name must not be empty."
  }
}

variable "sso_user_name" {
  description = "User name for IAM Identity Center user creation."
  type        = string
  default     = "s3-reader"

  validation {
    condition     = length(trimspace(var.sso_user_name)) > 0
    error_message = "sso_user_name must not be empty."
  }
}

variable "sso_user_given_name" {
  description = "Given name for IAM Identity Center user."
  type        = string
  default     = "S3"
}

variable "sso_user_family_name" {
  description = "Family name for IAM Identity Center user."
  type        = string
  default     = "Reader"
}

variable "sso_user_email" {
  description = "Email for IAM Identity Center user."
  type        = string
  default     = "s3-reader@example.com"

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.sso_user_email))
    error_message = "sso_user_email must be a valid email format."
  }
}

variable "permission_set_name" {
  description = "Name of the IAM Identity Center permission set."
  type        = string
  default     = "S3ReadOnlyAllBuckets"

  validation {
    condition     = length(trimspace(var.permission_set_name)) > 0
    error_message = "permission_set_name must not be empty."
  }
}

variable "permission_set_session_duration" {
  description = "Session duration for permission set in ISO-8601 format."
  type        = string
  default     = "PT4H"
}

variable "target_account_id" {
  description = "AWS account ID receiving the permission set assignment."
  type        = string
  default     = "981743521277"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.target_account_id))
    error_message = "target_account_id must be a 12-digit AWS account ID."
  }
}

variable "extra_tags" {
  description = "Additional tags merged with required base tags."
  type        = map(string)
  default     = {}
}
