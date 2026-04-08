# Terraform: HA Network + Simple AD + IAM Identity Center S3 Access

This Terraform root module provisions in `us-east-1`:

- One VPC with two public subnets and two private subnets across two Availability Zones.
- One AWS Directory Service `SimpleAD` directory attached to the two private subnets.
- One IAM Identity Center user in the existing identity store.
- One custom permission set with S3 read-only permissions across all buckets.
- One account assignment to AWS account `981743521277`.

It now also includes:

- Remote state support using S3 + DynamoDB locking (`backend.tf` + backend config values).
- A bootstrap stack in `bootstrap/` to provision state backend resources and GitHub OIDC role.
- GitHub Actions workflows for:
   - `terraform plan` on pull requests.
   - Gated `terraform apply` on `main` using GitHub Environment approval.

## Prerequisites

- Terraform `>= 1.6.0`.
- AWS credentials in the management account (iamadmin context).
- IAM Identity Center already enabled in the management account.
- Permission to manage:
  - EC2 networking resources
  - Directory Service
  - IAM Identity Center (`ssoadmin`) and Identity Store

## Files

- `providers.tf`: Terraform and AWS provider constraints.
- `variables.tf`: Inputs with validation rules.
- `network.tf`: VPC, IGW, route tables, public/private subnets.
- `simple_ad.tf`: Simple AD plus client security group.
- `sso.tf`: Identity Center user, permission set, inline policy, assignment.
- `outputs.tf`: Key IDs and ARNs.
- `backend.tf`: Active S3 backend block (configured via `terraform init -backend-config=...`).
- `.github/workflows/terraform-plan-pr.yml`: PR plan workflow using AWS OIDC.
- `.github/workflows/terraform-apply-main.yml`: Main apply workflow with environment gate.
- `bootstrap/`: Separate Terraform stack for backend + OIDC role bootstrap.

## Zero-Trust CI/CD Setup

### 1) Bootstrap remote state + OIDC role

Use the `bootstrap/` stack first.

1. Copy variables:
   - `cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars`
2. Set values in `bootstrap/terraform.tfvars`:
   - `state_bucket_name` (must be globally unique)
   - `github_org`
   - `github_repo`
3. Apply bootstrap stack:
   - `cd bootstrap`
   - `terraform init`
   - `terraform apply`
4. Save outputs:
   - `github_actions_role_arn`
   - `terraform_state_bucket`
   - `terraform_lock_table`

### 2) Configure SSM SecureString for Simple AD password

Create the parameter once in AWS (example):

```bash
aws ssm put-parameter \
  --name "/platform/tf-directory/simple-ad-password" \
  --type "SecureString" \
  --value "REPLACE_WITH_STRONG_PASSWORD" \
  --overwrite
```

The root module reads this value through `var.simple_ad_password_ssm_parameter_name`.

### 3) Configure GitHub repository settings

Set repository-level **Secrets**:

- `AWS_ROLE_TO_ASSUME` = bootstrap output `github_actions_role_arn`
- `TF_STATE_BUCKET` = bootstrap output `terraform_state_bucket`
- `TF_LOCK_TABLE` = bootstrap output `terraform_lock_table`
- `SIMPLE_AD_PASSWORD_SSM_PARAMETER_NAME` = `/platform/tf-directory/simple-ad-password`

Do not configure static AWS access keys in GitHub secrets.

### 4) Protect apply with environment approval

Create GitHub Environment `production` and require reviewers. The apply workflow is bound to this environment.

## Backend Migration (local state -> remote state)

After bootstrap is applied, from this root:

```bash
terraform init \
  -migrate-state \
  -backend-config="bucket=<TF_STATE_BUCKET>" \
  -backend-config="key=05-tf-directory/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=<TF_LOCK_TABLE>" \
  -backend-config="encrypt=true"
```

Then verify backend and state access:

```bash
terraform state list
terraform plan
```

## Usage

1. Create your variable file from the example:
   - `cp terraform.tfvars.example terraform.tfvars`
2. Set `simple_ad_password_ssm_parameter_name` in `terraform.tfvars`.
3. (Optional for local testing only) set `simple_ad_password` directly.
3. Optionally configure remote state:
   - run `terraform init` with backend config arguments (see migration command above).
4. Run Terraform:
   - `terraform init`
   - `terraform fmt -recursive`
   - `terraform validate`
   - `terraform plan`
   - `terraform apply`

## CI/CD Workflows

- PRs to `main` run `.github/workflows/terraform-plan-pr.yml`.
- Pushes to `main` run `.github/workflows/terraform-apply-main.yml`.
- Both workflows authenticate to AWS via OIDC (`AssumeRoleWithWebIdentity`).
- Apply runs only after GitHub Environment `production` approval.
- CI plans use `ci.auto.tfvars` for non-sensitive inputs because `terraform.tfvars` is gitignored.
- The Simple AD password source is still injected in CI via `TF_VAR_simple_ad_password_ssm_parameter_name`.

## Availability Notes

Simple AD is deployed in two private subnets in separate AZs, giving regional multi-AZ availability. This is not cross-region disaster recovery. For DR, add a second-region directory strategy and replication/failover workflows.

## Verification

After apply:

1. Confirm two public and two private subnets exist in distinct AZs.
2. Confirm one Simple AD directory is attached to two private subnets.
3. Confirm one IAM Identity Center user exists.
4. Confirm one permission set exists with S3 read actions only.
5. Confirm one account assignment exists for `981743521277`.
6. Sign in through IAM Identity Center portal and validate S3 read-only behavior (list/get allowed, put/delete denied).

For pipeline verification:

1. Open a PR and confirm plan job succeeds with OIDC.
2. Merge to `main` and confirm apply waits for environment approval.
3. Approve deployment and confirm apply completes with remote state locking.
