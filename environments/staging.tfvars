# Staging environment
project_name    = "dataai"
environment     = "staging"
primary_region  = "westeurope"
cost_center     = "CC002"
owner_email     = "dataai-staging@example.com"
resource_prefix = "dataai"
instance_suffix = "002"

enable_bastion = false
enable_purview = false

enable_iso27001 = false
enable_nis2     = false

adf_repo_config = {
  type        = "GitHub"
  repo_url    = "https://github.com/org/dataai-adf"
  branch      = "main"
  root_folder = "/"
}
