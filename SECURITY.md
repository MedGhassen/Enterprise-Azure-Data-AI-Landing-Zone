# Security policy

## Reporting a vulnerability

Please **do not open a public issue** for security problems.

Report vulnerabilities privately through
[GitHub Security Advisories](https://github.com/MedGhassen/Enterprise-Azure-Data-AI-Landing-Zone/security/advisories/new).
Include:

- the affected module/file and version (tag or commit),
- a description of the issue and its impact,
- steps to reproduce (redact subscription IDs, tenant IDs and secrets).

You should receive an acknowledgement within 5 business days. Fixes are released as soon as
practical and credited in the changelog unless you prefer otherwise.

## Scope

In scope: insecure defaults or misconfigurations in this repository's Terraform, scripts and
pipeline templates (for example a resource unintentionally exposed to the internet, or
excessive permissions).

Out of scope: vulnerabilities in Azure services, Terraform or providers themselves; report
those to Microsoft (MSRC) or HashiCorp.

## Supported versions

Only the latest release receives security fixes.

## Handling secrets

This project never needs secrets in code. Do not commit subscription IDs, backend
configuration, state files or `.tfvars` containing private values. State is stored in Azure
Storage with Entra ID authentication; CI uses OIDC federation.
