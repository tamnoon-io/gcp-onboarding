# Tamnoon GCP onboarding module

This module creates:

- A service account named `tamnoon-<service_account_suffix>`
- A workload identity pool with display name `TamnoonWorkloadIdentityPool`
- An AWS workload identity provider for a single trusted AWS account
- A workload identity binding that trusts a normalized AWS role through `attribute.aws_role`
- The requested IAM roles on either projects/folders or a single organization

The module is designed to stay compatible with Google Cloud Infrastructure Manager by using only standard Terraform and `hashicorp/google` resources.


## Usage
This repo should only be used while following GCP onboarding instructions in the Tamnoon platform
