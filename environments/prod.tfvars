# Production environment
project_name    = "dataai"
environment     = "prod"
primary_region  = "westeurope"
cost_center     = "CC003"
owner_email     = "dataai-prod@example.com"
resource_prefix = "dataai"
instance_suffix = "001"

enable_bastion = true
enable_purview = true

enable_iso27001 = true
enable_nis2     = false # set to true and set nis2_initiative_id when using NIS2 initiative

adf_repo_config = {
  type        = "GitHub"
  repo_url    = "https://github.com/org/dataai-adf"
  branch      = "main"
  root_folder = "/"
}
