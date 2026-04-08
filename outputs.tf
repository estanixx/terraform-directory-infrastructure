output "vpc_id" {
  description = "ID of the VPC hosting the directory infrastructure."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs across two AZs."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by Simple AD."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "directory_id" {
  description = "Simple AD directory ID."
  value       = aws_directory_service_directory.simple_ad.id
}

output "directory_dns_ip_addresses" {
  description = "DNS server IP addresses for the Simple AD directory."
  value       = aws_directory_service_directory.simple_ad.dns_ip_addresses
}

output "directory_clients_security_group_id" {
  description = "Security group to attach to directory client instances."
  value       = aws_security_group.directory_clients.id
}

output "identity_store_user_id" {
  description = "ID of the IAM Identity Center user created by Terraform."
  value       = aws_identitystore_user.s3_reader.user_id
}

output "permission_set_arn" {
  description = "ARN of the S3 read-only permission set."
  value       = aws_ssoadmin_permission_set.s3_read_all.arn
}

output "account_assignment_target" {
  description = "AWS account ID where permission set assignment was created."
  value       = var.target_account_id
}
