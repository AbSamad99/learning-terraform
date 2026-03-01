# Terraform

A repo containing all the logic written as part of my effort to learn Terraform — HashiCorp's Infrastructure as Code tool for provisioning and managing AWS resources.

## Structure

### [hello-world/](hello-world/)
The simplest possible Terraform configuration. Provisions a single EC2 instance on AWS. Starting point for understanding the three core blocks: `terraform {}`, `provider {}`, and `resource {}`.

### [basics/](basics/)
Foundational patterns split into two examples:
- **aws-backend/** — Sets up remote state storage using an S3 bucket (with versioning + encryption) and a DynamoDB table for state locking. Demonstrates the bootstrapping pattern required before any team collaboration.
- **web-app/** — A realistic web app stack: 2x EC2 instances behind an Application Load Balancer, with security groups and an S3 bucket. Uses the remote backend from aws-backend.

### [language-features/](language-features/)
Reference notes on HCL syntax: template strings, operators, ternary conditionals, built-in functions (numeric, string, collection), and meta-arguments (`depends_on`, `count`, `for_each`, `lifecycle`).

### [variables/](variables/)
Covers the three variable types: input variables (`variables.tf` + `terraform.tfvars`), local variables (`locals {}`), and output variables. Includes notes on sensitive variable handling.

### [modules/](modules/)
Reusable infrastructure components. The `web-app-module` splits a full web app across separate files by concern — `compute.tf`, `networking.tf`, `database.tf`, `storage.tf`, `variables.tf`, `outputs.tf`. Callers pass in variables and receive outputs; internals are encapsulated.

### [environments/](environments/)
Two strategies for managing dev/staging/prod:
- **file-structure/** — Separate directory per environment, each with its own state file. More explicit and isolated.
- **workspaces/** — Single configuration using `terraform.workspace` to derive the environment name. Less duplication but requires discipline to avoid cross-environment mistakes.

### [testing/](testing/)
Infrastructure testing with [Terratest](https://terratest.gruntwork.io/) (Go). Tests actually run `terraform apply` against real AWS infrastructure, hit the live endpoint, assert HTTP 200, then destroy everything. Integrated into the GitHub Actions CI pipeline on pull requests.

## CI/CD

GitHub Actions workflow (`.github/workflows/terraform.yml`) automates the full lifecycle:

| Trigger | Action |
|---|---|
| Pull request | Format check, `terraform plan` posted as PR comment, Terratest suite |
| Push to `main` | Auto-deploy to **staging** |
| Tagged release (`v*.*.*`) | Auto-deploy to **production** |
