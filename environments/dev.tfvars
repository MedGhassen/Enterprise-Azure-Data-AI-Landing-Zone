# Dev environment
project_name    = "dataai"
environment     = "dev"
primary_region  = "westeurope"
cost_center     = "CC001"
owner_email     = "dataai-dev@example.com"
resource_prefix = "dataai"
instance_suffix = "001"

enable_bastion     = false
enable_vpn_gateway = true
enable_purview     = false

enable_iso27001 = false
enable_nis2     = false

adf_repo_config = {
  type        = "GitHub"
  repo_url    = "https://github.com/org/dataai-adf"
  branch      = "main"
  root_folder = "/"
}
