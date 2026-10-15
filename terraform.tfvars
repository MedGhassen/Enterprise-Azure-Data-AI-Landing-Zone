# Default variable values (dev-like)
project_name    = "dataai"
environment     = "dev"
primary_region  = "westeurope"
cost_center     = "CC001"
owner_email     = "team@example.com"
resource_prefix = "dataai"
instance_suffix = "001"

enable_bastion = false
enable_purview = false

# Compliance policies (set to true to assign at management group)
enable_iso27001 = false
enable_nis2     = false
# nis2_initiative_id = ""  # set when using custom/partner NIS2 initiative

adf_repo_config = {
  type        = "GitHub"
  repo_url    = "https://github.com/org/repo"
  branch      = "main"
  root_folder = "/"
}
