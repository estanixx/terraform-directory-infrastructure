# Non-sensitive values consumed by CI workflows.
# This file is committed because terraform.tfvars is ignored by .gitignore.

aws_region   = "us-east-1"
project_name = "tf-directory"
environment  = "dev"

azs                  = ["us-east-1a", "us-east-1b"]
vpc_cidr             = "10.50.0.0/16"
public_subnet_cidrs  = ["10.50.1.0/24", "10.50.2.0/24"]
private_subnet_cidrs = ["10.50.11.0/24", "10.50.12.0/24"]

simple_ad_name = "corp.example.com"
simple_ad_size = "Small"

sso_user_name        = "s3-reader"
sso_user_given_name  = "S3"
sso_user_family_name = "Reader"
sso_user_email       = "s3-reader@example.com"

permission_set_name             = "S3ReadOnlyAllBuckets"
permission_set_session_duration = "PT4H"
target_account_id               = "981743521277"

extra_tags = {
  Owner = "platform-team"
}
