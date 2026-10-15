variable "name_prefix" {
  description = "Prefix for resource names, e.g. `dataai-dev-weu`."
  type        = string
}

variable "name_suffix" {
  description = "Instance suffix for resource names, e.g. `001`."
  type        = string
}

variable "unique_suffix" {
  description = "Short random suffix used for globally unique names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for Data Factory."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Entra tenant ID (Azure DevOps Git integration)."
  type        = string
}

variable "storage_account_id" {
  description = "Data lake storage account ID (managed private endpoints + RBAC)."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the ADF private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name (from the networking module)."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics."
  type        = string
}

variable "git_repo_type" {
  description = "Git integration type: GitHub or AzureDevOpsGit."
  type        = string
  default     = "GitHub"
  validation {
    condition     = contains(["GitHub", "AzureDevOpsGit"], var.git_repo_type)
    error_message = "git_repo_type must be GitHub or AzureDevOpsGit."
  }
}

variable "git_repo_url" {
  description = "Git repository URL (https://github.com/<owner>/<repo> or https://dev.azure.com/<org>/<project>/_git/<repo>). null disables Git integration."
  type        = string
  default     = null
}

variable "git_branch" {
  description = "Collaboration branch."
  type        = string
  default     = "main"
}

variable "git_root_folder" {
  description = "Root folder in the repository."
  type        = string
  default     = "/"
}
