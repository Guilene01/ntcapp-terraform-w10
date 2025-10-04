Terraform CI/CD Workflow

This repository contains a GitHub Actions CI/CD workflow for Terraform, designed to help teams manage infrastructure, security, and cost in a safe and automated way.

Workflow Features

Security Scans

TFLint: Lints Terraform code for best practices.

Checkov: Scans Terraform code for security and compliance issues.

Cost Analysis

Infracost: Generates accurate cost estimates from Terraform plans.

Automatically comments cost changes on pull requests.

Supports API key configuration via GitHub Secrets (INFRACOST_API_KEY).

Infrastructure Deployment

Terraform plan, validate, and apply (only on main branch).

Optional health check for deployed resources (like ALB).

Automatic destroy of resources after testing to prevent unnecessary cloud costs.

Optimizations

Caching Terraform providers for faster CI runs.

Caching Infracost CLI to avoid repeated installation.

Modular jobs for readability and maintainability.

How to Use

Set up GitHub Secrets

AWS_ROLE_ARN → IAM Role to assume for Terraform deployments.

INFRACOST_API_KEY → Infracost Cloud API key (optional for cost analysis).

Modify Terraform Code

Place your Terraform configuration in the ./terraform directory (or update TF_WORKING_DIR in the workflow).

Workflow Execution

On pull requests → Security scan + cost estimate.

On pushes to main → Full workflow including deploy, health check, and destroy.

Notes

The workflow is safe to share; it does not expose secrets.

Cost estimates are generated before deployment to help teams make informed decisions.

Only billable resources like EC2, ALB, and RDS will show costs.