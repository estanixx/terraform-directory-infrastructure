resource "aws_security_group" "directory_clients" {
  name        = "${local.name_prefix}-directory-clients"
  description = "Attach to EC2 clients that need to talk to Simple AD in private subnets."
  vpc_id      = aws_vpc.main.id

  egress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Kerberos"
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "NTP"
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "RPC endpoint mapper"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "LDAP and SMB"
    from_port   = 389
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Kerberos change/set password"
    from_port   = 464
    to_port     = 464
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "LDAPS"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Global catalog"
    from_port   = 3268
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "AD dynamic RPC"
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-directory-clients-sg"
  }
}

data "aws_ssm_parameter" "simple_ad_password" {
  count           = var.simple_ad_password_ssm_parameter_name == null ? 0 : 1
  name            = var.simple_ad_password_ssm_parameter_name
  with_decryption = true
}

locals {
  simple_ad_password_from_ssm  = var.simple_ad_password_ssm_parameter_name == null ? null : data.aws_ssm_parameter.simple_ad_password[0].value
  simple_ad_password_effective = coalesce(var.simple_ad_password, local.simple_ad_password_from_ssm)
}

resource "aws_directory_service_directory" "simple_ad" {
  name     = var.simple_ad_name
  password = local.simple_ad_password_effective
  size     = var.simple_ad_size
  type     = "SimpleAD"

  vpc_settings {
    vpc_id     = aws_vpc.main.id
    subnet_ids = [for s in aws_subnet.private : s.id]
  }

  tags = {
    Name = "${local.name_prefix}-simple-ad"
  }

  lifecycle {
    precondition {
      condition     = local.simple_ad_password_effective != null && length(local.simple_ad_password_effective) >= 8
      error_message = "Set either simple_ad_password or simple_ad_password_ssm_parameter_name (with a decryptable SecureString value of at least 8 characters)."
    }
  }
}
