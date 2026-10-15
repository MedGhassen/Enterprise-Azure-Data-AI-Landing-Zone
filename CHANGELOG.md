# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - first public release

### Added
- `platform/` stack for tenant-level governance (deploy once per tenant): management groups with
  deterministic IDs, subscription placement, allowed-locations and tag policies (require on
  resource groups, inherit on resources), ISO 27001 / NIS2 / custom initiatives, and default
  Data Engineer, Data Scientist and ML Engineer custom roles.
- Feature flags for every workload (`enable_firewall`, `enable_databricks`, `enable_synapse`,
  `enable_sql_database`, `enable_cosmos_db`, `enable_event_hubs`, `enable_foundry`,
  `enable_ai_search`, `enable_ml_workspace`, `enable_aks`, `enable_purview`, ...).
- Random `unique_suffix` for globally unique names, so default deployments do not collide.
- Azure Firewall policy with AKS egress rules and a UDR on the serving subnet; NAT Gateway for
  Databricks; VNet flow logs with Traffic Analytics.
- Microsoft Foundry (AI Services account, projects, model deployments) with a keyless AI Search
  connection; Databricks Access Connector for Unity Catalog; Synapse Private Link Hub.
- Private endpoints with `private_dns_zone_group` for every PaaS service, including Data Factory,
  Purview, ML storage and the Databricks browser-authentication endpoint.
- Diagnostic settings to Log Analytics for all services; Service Health alert.
- Resource locks (`enable_resource_locks`) and split resource groups (network, shared, data, ai,
  serving).
- Offline `terraform test` suites with mocked providers; TFLint, Trivy, terraform-docs and
  shellcheck in CI; Dependabot; pre-commit hooks.
- Deployment pipelines for GitHub Actions (reusable, sequential dev -> staging -> prod, applies
  the reviewed plan) and Azure DevOps (workload identity federation).
- draw.io architecture diagrams.
- `examples/minimal.tfvars` and `examples/full.tfvars`.

### Changed
- azurerm provider 3.x -> 4.x; Terraform >= 1.9. azuread, azapi and databricks providers removed.
- Entra-only authentication for Azure SQL, Synapse, Cosmos DB, Event Hubs, AI Search, Foundry and
  storage (shared keys disabled).
- AKS: user-assigned identities, Entra ID + Azure RBAC with local accounts disabled, CNI Overlay
  with Cilium, auto-upgrade channels, Azure Policy add-on, egress through the firewall.
- VPN Gateway defaults to the zone-redundant `VpnGw1AZ` SKU and the Microsoft-registered Azure VPN
  Client app ID.
- Data lake filesystems are created through the control plane, so plans keep working with
  public network access disabled.
- Bootstrap script works on macOS, enables state versioning/soft delete and resolves service
  principal object IDs correctly.

### Removed
- Hub-based AI Foundry (azapi), standalone Azure OpenAI and multi-service Cognitive Services
  accounts (replaced by the Foundry AI Services account).
- Manual private DNS A records, the unused `backend_*` variables and the root `terraform.tfvars`.

### Fixed
- Private DNS zones for Event Hubs (`privatelink.servicebus.windows.net`) and Cosmos DB
  (`privatelink.documents.azure.com`).
- AcrPull is granted to the kubelet identity (not the control-plane identity).
- The tag policy no longer requires the literal value `*`.
